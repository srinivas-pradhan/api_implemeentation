from itertools import permutations

def lambda_handler(event, context):
    result = [''.join(p) for p in permutations(event['combination'])]
    return {
        'statusCode' : 200,
        'body': result
    }
