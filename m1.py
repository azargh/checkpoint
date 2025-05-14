import boto3
from flask import Flask, request
from datetime import datetime

# create the clients that we will use to upload to the SQS
sqs = boto3.client('sqs', region_name='us-east-1')
sqsurl = sqs.get_queue_url(QueueName='CheckPointSQS')['QueueUrl']
app = Flask(__name__)
token = boto3.client('ssm', region_name='us-east-1').get_parameter(Name='token')['Parameter']['Value']


def _validate_timestamp(x: str) -> bool:
    """
    Receives a dict (json) and makes sure it has a valid email_timestream value (timestamp).
    """
    try:
        return 'email_timestream' in x and int(x['email_timestream']) < datetime.now().timestamp()
    except ValueError:
        return False


def _validate_token(x: str) -> bool:
    """
    Receives a string and validates that it's equal to the token stored in the SSM.
    """
    return x == token


def _forward(x: dict) -> None:
    """
    Forwards a dict (json) to the SQS.
    """
    return sqs.send_message(QueueUrl=sqsurl, DelaySeconds=10, MessageBody=str(x))


@app.route('/')
def default():
    """
    The default page if receiving a GET request. The load balancer will ping and receive this.
    Also, useful for debugging. This function is not mandatory to keep, but it would be a good idea to keep it.
    """
    return {'message': 'successfully received a GET request.'}


@app.route('/', methods=['POST'])
def handle():
    """
    The function that handles POST requests.
    Returns an appropriate message depending on the outcome.
    """
    json = request.get_json()
    cond1 = _validate_timestamp(json['data'])
    cond2 = _validate_token(json['token'])
    if cond1 and cond2:
        forward = _forward(json['data'])
        if forward['ResponseMetadata']['HTTPStatusCode'] == 200:
            return {'message': 'conditions were met - content has been uploaded to the SQS.'}
        else:
            return {'message': 'conditions were met - but encountered failure when uploading to the SQS.'}
    else:
        return {'error': 'request did not pass the conditions - please provide a valid email_timestream and the correct token.'}


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
