import json

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))
    for record in event['Records']:
        print("Message Body:", record['body'])
    return {'statusCode': 200, 'body': 'Processed SQS message'}