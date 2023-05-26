################################################################################
# Traefik Ingress
################################################################################
resource "time_sleep" "traefik" {
  count = var.install_traefik ? 1 : 0

  depends_on = [
    module.eks
  ]

  create_duration = var.traefik_time_wait
}

# Reference: https://artifacthub.io/packages/helm/traefik/traefik
resource "helm_release" "traefik" {
  count = var.install_traefik ? 1 : 0

  depends_on = [
    helm_release.coredns,
    helm_release.aws_vpc_cni_without_vpn[0],
    helm_release.aws_vpc_cni_with_vpn[0],
    time_sleep.traefik[0],
  ]

  namespace        = "traefik"
  create_namespace = true

  name              = "traefik"
  repository        = "https://helm.traefik.io/traefik"
  chart             = "traefik"
  version           = "23.0.1" # Install version 2.10.1 of traefik. See new changes on release notes of application: https://github.com/traefik/traefik/releases
  dependency_update = true

  values = [
    <<-YAML
    instanceLabelOverride: traefik
    nameOverride: traefik

    podDisruptionBudget:
      enabled: true
      maxUnavailable: 25%

    ingressClass:
      enabled: true
      isDefaultClass: false

    ingressRoute:
      dashboard:
        enabled: true
        annotations:
          kubernetes.io/ingress.class: traefik-internal

    updateStrategy:
      type: RollingUpdate
      rollingUpdate:
        maxUnavailable: 1
        maxSurge: 1

    readinessProbe:
      failureThreshold: 1
      initialDelaySeconds: 10
      periodSeconds: 10
      successThreshold: 1
      timeoutSeconds: 2

    livenessProbe:
      failureThreshold: 3
      initialDelaySeconds: 10
      periodSeconds: 10
      successThreshold: 1
      timeoutSeconds: 2

    providers:
      kubernetesCRD:
        enabled: true
        allowCrossNamespace: false
        allowExternalNameServices: true
        ingressClass: traefik-internal

      kubernetesIngress:
        enabled: true
        allowExternalNameServices: true
        allowEmptyServices: false
        ingressClass: traefik-internal
        publishedService:
          enabled: false

    logs:
      general:
        level: ERROR
      access:
        enabled: false
        fields:
          general:
            defaultmode: keep
          headers:
            defaultmode: keep

    metrics:
      prometheus:
        entryPoint: metrics
        addEntryPointsLabels: true
        addRoutersLabels: true

    globalArguments:
      - "--global.checknewversion"

    additionalArguments:
      - "--entryPoints.web.forwardedHeaders.trustedIPs=127.0.0.1/32,${join(",",var.vpc_cidr_block)}"
      - "--entryPoints.websecure.forwardedHeaders.trustedIPs=127.0.0.1/32,${join(",",var.vpc_cidr_block)}"
      - "--providers.kubernetesingress.ingressclass=traefik-internal"
      - "--log.level=ERROR"

    ports:
      traefik:
        port: 9000
        expose: true
        exposedPort: 9000
        protocol: TCP
      web:
        port: 8000
        expose: true
        exposedPort: 80
        protocol: TCP
        nodePort: 32080
      websecure:
        port: 8443
        expose: true
        exposedPort: 443
        protocol: TCP
        tls:
          enabled: false
          options: ""
          certResolver: ""
      metrics:
        port: 9100
        expose: true
        exposedPort: 9100
        protocol: TCP

    service:
      enabled: true
      type: NodePort

    autoscaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 4
      metrics:
      - type: Resource
        resource:
          name: cpu
          target:
            type: Utilization
            averageUtilization: 60
      - type: Resource
        resource:
          name: memory
          target:
            type: Utilization
            averageUtilization: 60


    hostNetwork: false

    rbac:
      enabled: true
      namespaced: false

    resources:
      requests:
        cpu: "100m"
        memory: "100Mi"
      limits:
        cpu: "300m"
        memory: "150Mi"

    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app.kubernetes.io/name: traefik
          namespaces:
          - traefik
          topologyKey: kubernetes.io/hostname
    YAML
  ]
}

resource "kubectl_manifest" "alb_traefik_ingress" {
  count = var.install_aws_loadbalancer_controller && var.install_traefik && var.create_traefik_ingress && var.traefik_ingress_alb_certificate_arn != null && length(var.traefik_ingress_alb_certificate_arn) != 0 ? 1 : 0

  depends_on = [
    helm_release.aws_load_balancer_controller[0],
    helm_release.traefik[0],
  ]

  yaml_body = <<-YAML
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    labels:
      app.kubernetes.io/name: traefik
      app.kubernetes.io/instance: traefik
      app.kubernetes.io/component: controller
    name: traefik
    namespace: traefik
    annotations:
      kubernetes.io/ingress.class: alb
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
      alb.ingress.kubernetes.io/ssl-redirect: "443"
      alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
      alb.ingress.kubernetes.io/healthcheck-path: "/ping"
      alb.ingress.kubernetes.io/healthcheck-port: traefik
      alb.ingress.kubernetes.io/certificate-arn: "${var.traefik_ingress_alb_certificate_arn}"
      alb.ingress.kubernetes.io/inbound-cidrs: "${var.traefik_inbound_cidrs}"
      %{ if var.scost != "" && var.scost != null }
      alb.ingress.kubernetes.io/tags: Scost=${var.scost}, Environment=${var.environment}, Terraform=true, Kubernetes=true
      %{ else }
      alb.ingress.kubernetes.io/tags: Scost=Rshared-traefik, Environment=${var.environment}, Terraform=true, Kubernetes=true
      %{ endif }
  spec:
    rules:
    - http:
        paths:
        - backend:
            service:
              name: traefik
              port:
                number: 443
          path: /*
          pathType: ImplementationSpecific
  YAML
}
