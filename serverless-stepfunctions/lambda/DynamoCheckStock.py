import os
import json
import boto3
import decimal
from botocore.exceptions import ClientError

# Custom JSON encoder for Decimal
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            # Convert to float (or int if you prefer)
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    # Read environment variable for the DynamoDB table name.
    table_name = os.environ.get("DynamoDB_TABLE")
    if not table_name:
        return {
            "statusCode": 500,
            "body": json.dumps(
                {"error": "DynamoDB_TABLE environment variable not set"},
                cls=DecimalEncoder
            )
        }
    
    # Parse incoming event and extract item_name.
    try:
        data = event if isinstance(event, dict) else json.loads(event)
        item_name = data.get("item_purchased", {}).get("item_name")
    except Exception as e:
        return {
            "statusCode": 400,
            "body": json.dumps(
                {"error": "Invalid JSON payload", "exception": str(e)},
                cls=DecimalEncoder
            )
        }

    if not item_name:
        return {
            "statusCode": 400,
            "body": json.dumps(
                {"error": "Missing field item_purchased.item_name"},
                cls=DecimalEncoder
            )
        }
    
    # Initialize a DynamoDB resource and get the table.
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table(table_name)

    try:
        # Update the key attribute name as needed.
        response = table.get_item(Key={"item_name": item_name})
        if "Item" not in response:
            return {
                "statusCode": 404,
                "body": json.dumps(
                    {"error": f"Item '{item_name}' not found"},
                    cls=DecimalEncoder
                )
            }
        item = response["Item"]
        
        # Assume the stock attribute is stored inside the item.
        stock = item.get("stock", 0)
        stock_status = "In stock" if stock > 0 else "Out of stock"
    except ClientError as e:
        return {
            "statusCode": 500,
            "body": json.dumps(
                {"error": "Query failed", "exception": str(e)},
                cls=DecimalEncoder
            )
        }
    
    return {
        "statusCode": 200,
        "response": stock_status
        #"body": json.dumps({ #if you want more info in response use this
        #    "item": item_name,
        #    "stock": stock,
        #    "status": stock_status
        #}, cls=DecimalEncoder)
    }
    