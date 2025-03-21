import os
import json
import boto3
from botocore.exceptions import ClientError
import pymysql


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
        # Ensure the payload is a dictionary.
        data = event if isinstance(event, dict) else json.loads(event)
        item_name = data.get("item_purchased", {}).get("item_name")
    except Exception as e:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid JSON payload", "exception": str(e)})
        }
    
    if not item_name:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing field item_purchased.item_name"})
        }
    
    # Connect to the RDS database using pymysql.
    try:
        conn = pymysql.connect(
            host=db_host,
            user=db_user,
            password=db_password,
            db=db_name,
            cursorclass=pymysql.cursors.DictCursor
        )
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Database connection failed", "exception": str(e)})
        }
    
    try:
        with conn.cursor() as cursor:
            # Query to check the stock of the specified item by its name.
            sql = "SELECT stock FROM items WHERE name = %s"
            cursor.execute(sql, (item_name,))
            result = cursor.fetchone()
            
            if result is None:
                return {
                    "statusCode": 404,
                    "body": json.dumps({"error": f"Item '{item_name}' not found"})
                }
            
            stock = result.get("stock", 0)
            stock_status = "In stock" if stock > 0 else "Out of stock"
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Query failed", "exception": str(e)})
        }
    finally:
        conn.close()
    
    return {
        "statusCode": 200,
        "body": json.dumps({
            "item": item_name,
            "stock": stock,
            "status": stock_status
        })
    }