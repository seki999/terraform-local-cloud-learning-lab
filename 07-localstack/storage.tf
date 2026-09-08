# ============================================================
# storage.tf —— S3 + DynamoDB
# ============================================================

resource "aws_s3_bucket" "archive" {
  bucket = "${var.project_prefix}-archive"

  # force_destroy = true：真实踩过的坑——S3 bucket 默认拒绝删除
  # "非空"的桶（`terraform destroy` 会报
  # "BucketNotEmpty: The bucket you tried to delete is not empty"）。
  # 本章的 Lambda 会真的往这个桶里写对象（见 serverless.tf 里
  # handler.py 的 s3.put_object 调用），所以每次 destroy 前手动清空
  # 桶很不现实——force_destroy 让 Terraform 在删除 bucket 前自动
  # 先清空里面的所有对象。真实生产环境要谨慎使用这个选项
  # （意味着"删这个 bucket 资源定义"就能连带清空所有数据，
  # 对于存有重要数据的桶，通常更希望保留这层"必须先手动清空"的保护）。
  force_destroy = true

  depends_on = [null_resource.wait_for_localstack]
  # 每一个"第一次真正调用 LocalStack API"的资源都需要显式
  # depends_on 这个健康检查资源——因为它们之间没有任何参数引用，
  # Terraform 无法从配置本身推断出这层"必须等 LocalStack 就绪"
  # 的依赖关系（回顾 docs/02-terraform-fundamentals.md 第 8 节
  # 关于隐式/显式依赖的讲解，以及 02-docker 章节 nginx 依赖 webapp
  # 的类似场景）。
}

resource "aws_dynamodb_table" "records" {
  name         = "${var.project_prefix}-records"
  billing_mode = "PAY_PER_REQUEST"
  # PAY_PER_REQUEST（按需计费）：不需要提前规划读写容量单位，
  # 适合本地学习场景（真实 AWS 账单模式下也常用于流量不可预测的场景）。
  hash_key = "id"

  attribute {
    name = "id"
    type = "S" # S = String，DynamoDB 的属性类型简写（S/N/B 分别对应字符串/数字/二进制）
  }

  depends_on = [null_resource.wait_for_localstack]
}
