import os
import json
import boto3
from botocore.exceptions import ClientError
import mysql.connector


def get_secret(secret_name, region_name):


    """Retrieve and return the secret as a dict from Secrets Manager."""
    client = boto3.client("secretsmanager", region_name=region_name)
    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print("The requested secret " + secret_name + " was not found")
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            print("The request was invalid due to:", e)
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            print("The request had invalid params:", e)
        elif e.response['Error']['Code'] == 'DecryptionFailure':
            print("The requested secret can't be decrypted using the provided KMS key:", e)
        elif e.response['Error']['Code'] == 'InternalServiceError':
            print("An error occurred on service side:", e)
        return {
            "statusCode": 500,
            "body": json.dumps({
                "error": "Failed to retrieve secret", 
                "exception": str(e)
            })
        }
    else:
        # Extract the secret; assume it's stored as a JSON string.
        if 'SecretString' in get_secret_value_response:
            secret_data = json.loads(get_secret_value_response['SecretString'])
        else:
            # If the secret is stored in binary format.
            secret_data = json.loads(get_secret_value_response['SecretBinary'])
        
        password = secret_data.get("password")
        return password
def lambda_handler(event, context):
    # Read configuration from environment variables.
    secret_name = os.environ.get("secret_name")      # Secrets Manager secret name or ARN.
    region_name = os.environ.get("region_name")        # e.g., "us-east-1"
    db_host   = os.environ.get("DB_HOST")              # RDS endpoint (host)
    db_user   = os.environ.get("DB_USER")              # RDS username
    db_name   = os.environ.get("DB_NAME")              # RDS database name

    db_password = get_secret(secret_name, region_name)

    try:
        connection = mysql.connector.connect(
            host=db_host,
            user=db_user,
            password=db_password,
            database=db_name
        )

        cursor = connection.cursor()

        #return db_host

        # Extract fields from the event JSON payload
        transaction_id = event.get('transactionId')
        user_id = event.get('user_id')
        game = event.get('game')
        item_purchased = event.get('item_purchased', {})
        payment_details = event.get('payment_details', {})
        event_timestamp = event.get('event_timestamp')
        server_region = event.get('server_region')
        client_ip = event.get('client_ip')

        # Extract nested fields from item_purchased and payment_details
        item_id = item_purchased.get('item_id')
        item_name = item_purchased.get('item_name')
        item_type = item_purchased.get('item_type')
        price_currency = item_purchased.get('price', {}).get('currency')
        price_amount = item_purchased.get('price', {}).get('amount')

        payment_method = payment_details.get('payment_method')
        card_last4 = payment_details.get('card_last4')
        transaction_status = payment_details.get('transaction_status')
        gateway = payment_details.get('gateway')

        # Prepare SQL query to insert the data into the RDS table
        query = """

INSERT INTO orders (transaction_id, user_id, game, item_id, item_name, item_type,
                                      price_currency, price_amount, payment_method, card_last4, 
                                      transaction_status, gateway, event_timestamp, server_region, client_ip)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)        """

        # Data to be inserted
        data = (
            transaction_id, user_id, game, item_id, item_name, item_type, 
            price_currency, price_amount, payment_method, card_last4, 
            transaction_status, gateway, event_timestamp, server_region, client_ip
        )

        # Execute the query
        cursor.execute(query, data)
        connection.commit()

        # Return success response
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Transaction inserted successfully',
                'transaction_id': transaction_id
            })
        }

    except mysql.connector.Error as err:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': f"Error: {err}"
            })
        }

    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
