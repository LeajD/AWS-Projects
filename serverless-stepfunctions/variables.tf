

variable "region" {
  description = "region name"
  type        = string
  default     = "us-east-1"
}


variable "data_processor_lambda" {
  description = "first lambda function name"
  type        = string
  default     = "DataProcessorLambda"
}

variable "api_gateway" {
  description = "api_gateway name"
  type        = string
  default     = "StepFunctionsAPI"
}

variable "dynamodb_table" {
  description = "dynamdb_table name"
  type        = string
  default     = "DataProcessorLambda"
}

variable "sqs_queue" {
  description = "sqs_queue name"
  type        = string
  default     = "ErrorQueue"
}

variable "sns_topic" {
  description = "sns_topic name"
  type        = string
  default     = "NotificationTopic"
}

variable "state_machine" {
  description = "stepfunction state_machine name"
  type        = string
  default     = "MyStateMachine"
}

variable "stepfunctions" {
  description = "stepfunctions file name"
  type        = string
  default     = "stepfunctions.json"
}


