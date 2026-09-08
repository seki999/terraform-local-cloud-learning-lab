"""
handler.py —— 本章 Serverless 演示用的 Lambda 函数。

架构里的位置：API Gateway --> 这个 Lambda --> DynamoDB / S3 / SQS
一次调用同时演示三种下游集成，避免额外搭建 S3 事件触发、
SQS 事件源映射这类需要更多移动部件的高级配置——本章重点是
"体会 Terraform 如何声明式地拼出一个 Serverless 架构"，
而不是穷尽所有触发器组合方式。

LocalStack 的 Lambda 执行环境会自动把标准 AWS SDK（boto3）调用
重定向回本地 LocalStack 实例，所以这里的代码和"以后部署到真实
AWS 上"需要的代码几乎完全一样，不需要任何 LocalStack 专用改造
——这正是 LocalStack 学习价值的核心体现。
"""

import json
import os
import uuid

import boto3

dynamodb = boto3.resource("dynamodb")
s3 = boto3.client("s3")
sqs = boto3.client("sqs")


def handler(event, context):
    body_raw = event.get("body") or "{}"
    try:
        body = json.loads(body_raw)
    except json.JSONDecodeError:
        body = {}

    item_id = str(uuid.uuid4())
    message = body.get("message", "hello from terraform-local-cloud-learning-lab")

    # 1) 写入 DynamoDB —— 结构化数据的主记录
    table = dynamodb.Table(os.environ["TABLE_NAME"])
    table.put_item(Item={"id": item_id, "message": message})

    # 2) 写入 S3 —— 同一份数据的一份"归档副本"（模拟真实项目里
    #    "既要能快速查询，又要保留原始请求存档"的常见双写模式）
    s3.put_object(
        Bucket=os.environ["BUCKET_NAME"],
        Key=f"requests/{item_id}.json",
        Body=json.dumps({"id": item_id, "message": message}),
        ContentType="application/json",
    )

    # 3) 发送到 SQS —— 通知下游异步处理这条新记录
    #    （真实项目里，下游可能是另一个 Lambda 通过事件源映射消费这个队列，
    #    本章只做到"消息成功入队"为止，不再实现消费端）
    sqs.send_message(
        QueueUrl=os.environ["QUEUE_URL"],
        MessageBody=json.dumps({"id": item_id, "message": message}),
    )

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"id": item_id, "status": "ok"}),
    }
