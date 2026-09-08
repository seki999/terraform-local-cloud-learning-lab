# ============================================================
# tests/basic.tftest.hcl —— Terraform 原生测试文件
# ------------------------------------------------------------
# `terraform test` 会按顺序执行文件里的每一个 run block，
# 每个 run block 可以是 plan（只计算不创建）或 apply（真正创建，
# 测试结束后自动 destroy），并对结果做断言（assert）。
# ============================================================

# --------------------------------------------------------------
# 用 plan 阶段的测试验证变量确实被正确传递、校验规则确实生效——
# 不需要真正创建资源，运行速度快，适合大量验证输入组合。
# --------------------------------------------------------------
run "valid_replica_count_passes_plan" {
  command = plan

  variables {
    replica_count = 3
    name_prefix   = "test"
  }

  assert {
    condition     = var.replica_count == 3
    error_message = "replica_count 变量没有被正确传入"
  }
}

# --------------------------------------------------------------
# 验证 variable 的 validation block 确实会拦截非法输入——
# expect_failures 声明"我预期这个变量会校验失败"，
# 如果实际没有失败，这条测试本身反而会被判定为失败。
# --------------------------------------------------------------
run "replica_count_out_of_range_is_rejected" {
  command = plan

  variables {
    replica_count = 99
  }

  expect_failures = [
    var.replica_count,
  ]
}

run "empty_name_prefix_is_rejected" {
  command = plan

  variables {
    name_prefix = ""
  }

  expect_failures = [
    var.name_prefix,
  ]
}

# --------------------------------------------------------------
# 用 apply 阶段的测试验证"真正创建资源后，output 是否符合预期"——
# 这类测试更慢（真的会创建/销毁资源），应该只用在关键路径上。
# 测试结束后 Terraform 会自动销毁这次 apply 创建的资源，
# 不需要手动清理。
# --------------------------------------------------------------
run "apply_creates_expected_server_count" {
  command = apply

  variables {
    replica_count = 2
    name_prefix   = "apply-test"
  }

  assert {
    condition     = output.server_count == 2
    error_message = "server_count 输出应该等于传入的 replica_count"
  }

  assert {
    condition     = length(output.server_names) == 2
    error_message = "server_names 列表长度应该等于 replica_count"
  }
}
