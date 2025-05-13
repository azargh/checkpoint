import boto3
from flask import Flask, request
from datetime import datetime


sqs = boto3.client('sqs', region_name='us-east-1')
sqsurl = sqs.get_queue_url(QueueName='CheckPointSQS')['QueueUrl']
app = Flask(__name__)
token = boto3.client('ssm', region_name='us-east-1').get_parameter(Name='token')['Parameter']['Value']


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


@app.route('/')
def default():
    return {'message': 'successfully received a GET request.'}


@app.route('/', methods=['POST'])
def handle():
    json = request.get_json()
    cond1 = _validate_timestamp(json['data'])
    cond2 = _validate_token(json['token'])
    if cond1 and cond2:
        forward = _forward(json)
        if forward['ResponseMetadata']['HTTPStatusCode'] == 200:
            return {'message': 'conditions were met - content has been uploaded to the S3 bucket.'}
        else:
            return {'message': 'conditions were met - but encountered failure when uploading to the S3 bucket.'}
    else:
        return {'error': 'request did not pass the conditions - please provide a valid email_timestream and the correct token.'}


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)