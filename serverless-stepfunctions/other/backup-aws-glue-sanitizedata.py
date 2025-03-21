import sys
import json
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Retrieve the JOB_NAME and payload arguments
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'payload'])
print("Raw payload argument:", repr(args['payload']))


# Initialize Glue components
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Parse the payload passed from Step Functions
try:
    payload = json.loads(args['payload'])
except Exception as e:
    raise Exception("Failed to parse payload JSON: " + str(e))

# Remove the "payment_details" field if it exists
if "payment_details" in payload:
    del payload["payment_details"]

# For demonstration purposes, print the sanitized payload
print("Sanitized payload:")
print(json.dumps(payload, indent=2))

# Optionally, convert the single payload record into a DataFrame for further processing.
rdd = sc.parallelize([payload])
df = spark.read.json(rdd)
df.show()

job.commit()