import argparse
import boto3
import json
import time
from datetime import datetime


sqs = boto3.client('sqs')
sqsurl = sqs.get_queue_url(QueueName='CheckPointSQS')['QueueUrl']
s3 = boto3.client('s3')


def receive_and_upload_messages():
    response = sqs.receive_message(QueueUrl=sqsurl)
    for message in response['Messages']:
        path = create_tmp_json_file(message)
        upload_to_s3(path)


def create_tmp_json_file(x: dict) -> str:
    with open('tmp.json', 'w') as f:
        json.dump(x, f)
    return 'tmp.json'


def upload_to_s3(path: str) -> None:
    return s3.upload(path, "checkpoint-hw-2", str(datetime.now().timestamp()))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--poll_freq', help='determines the polling frequency in seconds', type=int, default=10)
    args = parser.parse_args()
    while True:
        receive_and_upload_messages()
        time.sleep(args.p)
