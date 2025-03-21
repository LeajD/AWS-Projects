# Amnazon Managed Streaming for Apache Kafka
This project demonstrates a robust streaming architecture that integrates AWS managed services (RDS, MSK, S3) and open-source tools (Debezium, Kafka Connect) to facilitate real-time data replication from a transactional database into a data lake environment.


![MSK AWS](kafka.png)

Project is based on following guideline:
https://github.com/JayaprakashKV/streaming-pipeline-aws


## Project Flow & key aspects:
- Data is ingested and captured from the SQL Server database using SQL Server’s Change Data Capture (CDC) feature
- SQL Server has CDC enabled on the tables we want to track -> it  reads the CDC change logs from the source database and continuously pools for new changes with trackoing offsets so that it only captures and forwards new data to Kafka topic
- Debezium-based Kafka Connect uses Kafka producer API to send data from RDS into MSK Kafka cluster
- Kafka S3 Sink Connector regularly polls the configured Kafka topics for new records. This continuous polling allows it to notice when new messages are produced
- Once records are received, the connector buffers them. When predefined conditions are met (for example, a certain number of records have been collected or a time interval has passed) the connector writes the buffered data to S3
- Based on the configuration (for example, using the JSON format as set by format.class=io.confluent.connect.s3.format.json.JsonFormat), the connector converts the buffered records into a file format suitable for storage
- After a successful upload, the connector commits the Kafka offsets. This prevents reprocessing the same records and ensures that only new records are considered in subsequent polling cycles.


# Key Components:

## AWS Infrastructure:
A SQL Server database instance is created on AWS RDS in a private subnet.
SQL scripts create a sample database (“myapp”), create a Users table, enable Change Data Capture (CDC) on the table, and insert sample records. The CDC configuration enables capturing data modifications like inserts, updates, and deletes, and makes change details available for downstream processing.
Kafka (MSK) Cluster & Connectors:
## MSK Cluster:
An Amazon MSK cluster is provisioned to run Apache Kafka with IAM-based authentication and TLS encryption for secure communication.
## Kafka Connectors:
Custom connectors are configured:
**RDS Connector:**
Uses Debezium’s SQL Server connector configuration (stored in an external file) to capture CDC events from the RDS database. The configuration files set properties such as the JDBC connection, security details (SASL_SSL and AWS_MSK_IAM), and topics format.
**S3 Sink Connector:**
Ingests Kafka topics (populated with CDC data) and writes the streamed data to an S3 bucket, with appropriate configurations for data formatting and error handling.
**Custom Plugins:**
Custom plugins (S3 Connector and RDS Connector) for Kafka Connect are uploaded to S3 and referenced in the connector configurations.
## EC2 Instance & Supporting Tools:
An EC2 instance is deployed (in a public subnet) as a management host. This instance can be used to run command-line tools (such as sqlcmd or kafka-console-consumer.sh) to interact with the RDS and Kafka systems.

- In order to run this project on your own make sure to deploy "KMS connectors" using config files (provide also your rds/kafka/s3 connection settings in those files) from "files/kafka_rds_connector" and "files/kafka_s3_connector" + attach it to provided via Terraform LogGroup and IAM Role (named 'KafkaConnectPolicy'). 
^This is due to problems with creating "connector_configuration" section using provided file for resource "aws_mskconnect_connector"
- Make sure to download "connector-sqlserver.zip" and "kafka-connect-s3.zip" in newest versions. Zip files in this repo are empty -> just for template purpose. Sources:
https://www.confluent.io/hub/debezium/debezium-connector-sqlserver
https://www.confluent.io/hub/confluentinc/kafka-connect-s3
