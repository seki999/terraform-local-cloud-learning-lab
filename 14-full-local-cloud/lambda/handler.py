"""毕业实验用的极简 Lambda——只是证明 Lambda 也是这次统一部署的一部分。
完整的 API Gateway -> Lambda -> DynamoDB -> SQS 链路请看 07-localstack，
本章不重复实现，避免毕业实验本身过于臃肿。
"""

import json


def handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "hello from the graduation project's lambda"}),
    }
