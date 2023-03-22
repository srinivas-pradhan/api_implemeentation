import boto3
def lambda_handler(event, context):
    result = {"Health": "OK"}
    return {
        'statusCode' : 200,
        'body': result
    }
