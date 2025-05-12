import boto3
from flask import Flask, request
from datetime import datetime


sqs = boto3.client('sqs')
sqsurl = sqs.get_queue_url(QueueName='CheckPointSQS')['QueueUrl']
app = Flask(__name__)
token = boto3.client('ssm').get_parameter(Name='token')['Parameter']['Value']


def _update_token():
    response = boto3.client('ssm').get_parameter(Name='token')
    print(response['Parameter']['Value'])


def _validate_timestamp(x: str) -> bool:
    try:
        return 'email_timestream' in x and int(x['email_timestream']) < datetime.now().timestamp()
    except ValueError:
        return False


def _validate_token(x: str) -> bool:
    return x == token


def _forward(x: dict) -> None:
    return sqs.send_message(QueueUrl=sqsurl, DelaySeconds=10, MessageBody='hello')


@app.route('/', methods=['POST'])
def handle():
    json = request.get_json()
    cond1 = _validate_timestamp(json['data']['email_timestream'])
    cond2 = _validate_token(json['token'])
    if cond1 and cond2:
        return _forward(json)
