import argparse
import boto3
import json
import time
import os
from datetime import datetime

# creates clients so we can upload and receive from the SQS/S3
sqs = boto3.client('sqs', region_name='us-east-1')
sqsurl = sqs.get_queue_url(QueueName='CheckPointSQS')['QueueUrl']
s3 = boto3.client('s3', region_name='us-east-1')
handled_ids = set()  # used for debug, not necessary, but is a set of the message ids we handled


def receive_and_upload_messages():
    """
    The main function that runs all the time.
    It receives message from the SQS, and if it finds any, creates a temporary file that it then uploads to the S3 bucket.
    """
    response = sqs.receive_message(QueueUrl=sqsurl)
    if 'Messages' in response:  # possible that the response has no messages, if queue is empty
        for message in response['Messages']:
            id = message['MessageId']
            if id in handled_ids:
                continue
            path = create_tmp_json_file(message['Body'])
            upload_to_s3(path)
            handled_ids.add(id)


def create_tmp_json_file(x: dict) -> str:
    """
    Creates a temporary file that we place our data in that will be used to upload to S3.
    Uses os module for platform-agnostic code.
    """
    home = os.path.expanduser('~')
    full_path = os.path.join(home, 'tmp.json')
    with open(full_path, 'w') as f:
        json.dump(x, f)
    return full_path


def upload_to_s3(path: str) -> None:
    """
    Takes path to a file and uploads it to the S3 bucket.
    """
    suffix = '.json'
    timestamp = str(datetime.now().timestamp())
    return s3.upload_file(path, "checkpoint-hw-2", timestamp + suffix)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--poll_freq', help='determines the polling frequency in seconds', type=int, default=10)
    args = parser.parse_args()  # the 3 lines above control the polling frequency
    while True:
        receive_and_upload_messages()
        time.sleep(args.poll_freq)
