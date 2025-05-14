import argparse
import boto3
import json
import time
import os
from datetime import datetime


sqs = boto3.client('sqs', region_name='us-east-1')
sqsurl = sqs.get_queue_url(QueueName='CheckPointSQS')['QueueUrl']
s3 = boto3.client('s3', region_name='us-east-1')
handled_ids = set()


def receive_and_upload_messages():
    response = sqs.receive_message(QueueUrl=sqsurl)
    if 'Messages' in response:
        for message in response['Messages']:
            id = message['MessageId']
            if id in handled_ids:
                continue
            path = create_tmp_json_file(message['Body'])
            upload_to_s3(path)
            handled_ids.add(id)


def create_tmp_json_file(x: dict) -> str:
    home = os.path.expanduser('~')
    full_path = os.path.join(home, 'tmp.json')
    with open(full_path, 'w') as f:
        json.dump(x, f)
    return full_path


def upload_to_s3(path: str) -> None:
    suffix = '.json'
    timestamp = str(datetime.now().timestamp())
    return s3.upload_file(path, "checkpoint-hw-2", timestamp + suffix)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--poll_freq', help='determines the polling frequency in seconds', type=int, default=10)
    args = parser.parse_args()
    while True:
        receive_and_upload_messages()
        time.sleep(args.poll_freq)
