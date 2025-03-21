import json
import boto3
import os
from boto3.dynamodb.types import TypeSerializer
from decimal import Decimal

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.getenv('DYNAMODB_TABLE', 'DataProcessorLambda')
serializer = TypeSerializer()

def lambda_handler(event, context):
    try:
        # Ensure event is a dictionary
        if isinstance(event, str):
            data = json.loads(event)  # Convert JSON string to dict
        else:
            data = event  # Already a dict

        # Convert JSON to DynamoDB format, replace floats with Decimal
        dynamo_item = {k: serializer.serialize(convert_to_decimal(v)) for k, v in flatten_dict(data).items()}

        # Insert into DynamoDB
        table = dynamodb.Table(TABLE_NAME)
        table.put_item(Item={k: v['S'] if 'S' in v else v['N'] for k, v in dynamo_item.items()})

        return {"status": "success", "message": "Transaction inserted successfully"}

    except Exception as e:
        return {"status": "error", "message": str(e)}

def flatten_dict(d, parent_key='', sep='_'):
    """ Recursively flattens a nested JSON dictionary """
    items = {}
    for k, v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.update(flatten_dict(v, new_key, sep))
        else:
            items[new_key] = v
    return items

def convert_to_decimal(value):
    """ Convert floats to Decimal to be compatible with DynamoDB """
    if isinstance(value, float):
        return Decimal(str(value))
    elif isinstance(value, dict):
        return {k: convert_to_decimal(v) for k, v in value.items()}
    return value



### debugging netcat inside lambda python:



import socket
def lambda_handler(event, context):
    host = "terraform-20250210064724931100000001.cl6yy2mam16a.us-east-1.rds.amazonaws.com"
    port = 3306
    timeout = 10  
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(timeout)
    try:
        s.connect((host, port))
        print(f"Successfully connected to {host} on port {port}")
    except Exception as e:
        print(f"Connection failed: {e}")
    finally:
        s.close()
if __name__ == "__main__":
    check_connection()

