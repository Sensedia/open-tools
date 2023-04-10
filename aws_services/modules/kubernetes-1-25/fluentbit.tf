################################################################################
# fluentbit
################################################################################
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_iam_policy_document" "fluentbit_irsa" {
  statement {
    sid       = "PutLogEvents"
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.partition}:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*"]
    actions = [
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
    ]
  }

  statement {
    sid       = "CreateCWLogs"
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.partition}:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:TagResource",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
  }
}

resource "aws_iam_policy" "aws_for_fluentbit" {
  name        = "${var.cluster_name}-fluentbit"
  description = "IAM Policy for AWS for FluentBit"
  policy      = data.aws_iam_policy_document.fluentbit_irsa.json
  tags        = local.tags
}


#-----------------
# LEGACY_CODE
#
# 2022/11/16:
# After to analise the effort to use helm chart of aws-for-fluent-bit and considering about the new strategy of collect of logs using 'AWS Distro for OpenTelemetry'
# Aécio Pires and Danilo Rocha decided don't migrate for use helm chart. 
# In the future can be used AWS Distro for OpenTelemetry for to substitute fluentbit.
#
# References:
# https://artifacthub.io/packages/helm/aws/aws-for-fluent-bit
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-logs-FluentBit.html
# https://aws-otel.github.io
#-----------------
data "kubectl_path_documents" "fluentbit_00" {
  pattern = "${path.module}/templates/fluentbit-00-compatible.yaml"

  vars = {
    cluster_name = var.cluster_name
    region       = var.region
  }
}

resource "kubectl_manifest" "fluentbit_00" {
  for_each = data.kubectl_path_documents.fluentbit_00.manifests

  depends_on = [
    kubectl_manifest.karpenter_provisioner
  ]

  yaml_body = each.value
}

resource "kubectl_manifest" "fluentbit_01" {
  depends_on = [
    kubectl_manifest.fluentbit_00
  ]

  yaml_body = templatefile(
    "${path.module}/templates/fluentbit-01-compatible.yaml",
    {
      irsa_iam_role_arn = module.fluentbit_irsa.iam_role_arn
    }
  )
}

data "kubectl_path_documents" "fluentbit_02" {

  pattern = "${path.module}/templates/fluentbit-02-compatible.yaml"

  vars = {
    cw_retention_in_days = var.fluentbit_cw_log_group_retention_in_days
    tags                 = join(",",([for k, v in var.tags : "${k}=${v}"]))
  }
}

resource "kubectl_manifest" "fluentbit_02" {
  for_each = data.kubectl_path_documents.fluentbit_02.manifests

  depends_on = [
    kubectl_manifest.fluentbit_01
  ]

  yaml_body = each.value
}
