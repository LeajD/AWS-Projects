from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.transforms import ApplyMapping
from awsglue.utils import getResolvedOptions
import sys

# Initialize Glue Context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session


# Read JSON data from Glue Catalog (created by crawler)
datasource = glueContext.create_dynamic_frame.from_catalog(
    database= "${catalogdatabase}",
    table_name= "${catalogtable}",
)

# Flatten the nested JSON schema
flattened_df = ApplyMapping.apply(
    frame=datasource,
    mappings=[
        ("transactionId", "string", "transactionId", "string"),
        ("user_id", "string", "user_id", "string"),
        ("game", "string", "game", "string"),
        ("item_purchased.item_id", "string", "item_id", "string"),
        ("item_purchased.item_name", "string", "item_name", "string"),
        ("item_purchased.item_type", "string", "item_type", "string"),
        ("item_purchased.price.currency", "string", "currency", "string"),
        ("item_purchased.price.amount", "double", "amount", "double"),
        ("payment_details.payment_method", "string", "payment_method", "string"),
        ("payment_details.card_last4", "string", "card_last4", "string"),
        ("payment_details.transaction_status", "string", "transaction_status", "string"),
        ("payment_details.gateway", "string", "gateway", "string"),
        ("event_timestamp", "string", "event_timestamp", "string"),
        ("server_region", "string", "server_region", "string"),
        ("client_ip", "string", "client_ip", "string")
    ]
)

# Redshift Connection Options
redshift_conn_options = {
    "dbtable": "${redshifttable}",
    "connectionName": "${glueredshiftconnection}",  # Specify the Glue connection name
    "redshiftTmpDir": "s3://${bucket}/temp/", #this is proper declaration for TmpDir
    "useConnectionProperties": "true"
}

# Write to Redshift
glueContext.write_dynamic_frame.from_options(
    frame=flattened_df,
    connection_type="redshift",
    connection_options=redshift_conn_options
)