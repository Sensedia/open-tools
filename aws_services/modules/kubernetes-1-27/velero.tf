################################################################################
# Velero
################################################################################
resource "time_sleep" "velero" {
  count = var.install_velero ? 1 : 0

  depends_on = [
    module.eks
  ]

  create_duration = var.velero_time_wait
}

module "velero_irsa_policy" {
  count = var.install_velero || var.velero_irsa ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.3"

  name        = "velero-${var.cluster_name}"
  path        = "/"
  description = "Velero policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.velero_s3_bucket_name}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.velero_s3_bucket_name}"
        ]
      }
    ]
  })

  tags = local.tags
}

# References: https://github.com/vmware-tanzu/velero
#             https://github.com/vmware-tanzu/helm-charts/tree/main/charts/velero
resource "helm_release" "velero" {
  count = var.install_velero ? 1 : 0

  depends_on = [
    kubectl_manifest.karpenter_provisioner[0],
    time_sleep.velero[0],
  ]

  namespace        = "velero"
  create_namespace = true

  name              = "velero"
  repository        = "https://vmware-tanzu.github.io/helm-charts"
  chart             = "velero"
  version           = "v4.0.2"
  dependency_update = true

  values = [yamlencode({
    configuration = {
      backupStorageLocation = [{
        provider = "aws"
        bucket   = var.velero_s3_bucket_name
        prefix   = var.velero_s3_bucket_prefix
        config = {
          region = var.velero_s3_bucket_region
        }
      }]
      features                 = "EnableAPIGroupVersions" # enables backup of all versions of a resource
      defaultVolumesToFsBackup = var.velero_default_fsbackup
    }
    snapshotsEnabled = var.velero_snapshot_enabled
    deployNodeAgent  = var.velero_deploy_fsbackup
    nodeAgent = {
      podVolumePath = "/var/lib/kubelet/pods"
      privileged    = false
      resources = {
        requests = {
          cpu    = "500m"
          memory = "512Mi"
        }
        limits = {
          cpu    = "1000m"
          memory = "1024Mi"
        }
      }
    }
    credentials = {
      useSecret = false
    }
    initContainers = [
      {
        image = "velero/velero-plugin-for-aws:v1.7.0"
        name  = "velero-plugin-for-aws"
        volumeMounts = [
          {
            mountPath = "/target"
            name      = "plugins"
          }
        ]
      }
    ]
    serviceAccount = { # creates cluster service account and maps it to AWS IAM role (IRSA)
      server = {
        create = true
        name   = "velero"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.velero_irsa_role[0].iam_role_arn
        }
      }
    }
  })]
}
