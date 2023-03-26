import json

def lambda_handler(event, context):
    source_ip = event['requestContext']['identity']['sourceIp']

    response = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'ip': source_ip
        })
    }
    return response
