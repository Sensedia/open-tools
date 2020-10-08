# install_prometheus-operator_k8s

<!-- TOC -->

- [install_prometheus-operator_k8s](#install_prometheus-operator_k8s)
- [About](#about)
- [Summary](#summary)
- [Prerequisites for Prometheus Installation](#prerequisites-for-prometheus-installation)
- [Prometheus Installation](#prometheus-installation)
- [Troubleshooting](#troubleshooting)
- [Optional: Access Grafana](#optional-access-grafana)

<!-- TOC -->

# About

This repo contains config files to deploy Prometheus in Kubernetes cluster.

We use Prometheus Operator to manage the deployments of prometheis along kubernetes clusters.

More info about prometheus-operator can find in follow pages.

* https://github.com/coreos/prometheus-operator
* https://coreos.com/blog/the-prometheus-operator.html
* https://devops.college/prometheus-operator-how-to-monitor-an-external-service-3cb6ac8d5acb
* https://blog.sebastian-daschner.com/entries/prometheus-kubernetes-operator
* https://kruschecompany.com/kubernetes-prometheus-operator/
* https://containerjournal.com/topics/container-management/cluster-monitoring-with-prometheus-operator/
* https://sysdig.com/blog/kubernetes-monitoring-prometheus/
* https://sysdig.com/blog/kubernetes-monitoring-with-prometheus-alertmanager-grafana-pushgateway-part-2/
* https://sysdig.com/blog/kubernetes-monitoring-prometheus-operator-part3/

About config parameters of prometheu-operator:

* https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md
* https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#remotewritespec
* https://prometheus.io/docs/prometheus/latest/configuration/configuration/#remote_write
* https://www.robustperception.io/dropping-metrics-at-scrape-time-with-prometheus

# Summary

The directory structure is:

```bash
install_prometheus-operator_k8s/
├── deploy.sh # script for deploy prometheus-operator
├── es-index-size-exporter
│   └── es-index-size-exporter.py
├── helm_vars
│   ├── aws
│   │   ├── production
│   │   │   ├── some-k8s-cluster.yaml # values for a specific cluster deployment
|   |   |   └── values.yaml # common values for prod environment
|   │   ├── staging
|   │   │   ...
|   │   ├── testing
|   │   │   ...
|   │   ├── values.yaml # common values for AWS environment
|   ├── gcp
|   │   ├── production
|   │   │   ...
|   │   ├── staging
|   |   |   ...
|   |   ├── testing
|   |   |   ...
|   │   └── values.yaml # common values for GCP environment
│   ├── exporters
│   │   │   ├── some-exporter # directory with values for a specific exporter
|   |   |   └── values.yaml # common values for a specific exporter
│   │   │   ├── other-exporter # directory with values for a specific exporter
|   |   |   └── values.yaml # common values for a specific exporter
│   └── values.yaml # common values for all deployments
└── README.md # this documentation
```

# Prerequisites for Prometheus Installation

* kubectl ~> 1.15 or major
* helm ~> v3.1.1 or major (see version supported https://helm.sh/docs/topics/version_skew/)
* gcloud
* sops -> 3.5.0 or major
* awscli -> 1.18 or major
* git

Install plugin Helm secrets.

```bash
helm plugin install https://github.com/futuresimple/helm-secrets
```

# Prometheus Installation

Create or access Kubernetes cluster and configure the ``kubectl``.

Use the script `deploy.sh` in this repo to install/upgrade a release of prometheus-operator.

```bash
helm repo add stable https://kubernetes-charts.storage.googleapis.com

helm repo update

cd install_prometheus-operator_k8s

./deploy.sh <install|upgrade> <aws|gcp> <testing|staging|production> <cluster_name> [--dry-run] [--debug]
```

The `<cluster_name>` argument must be the ``file_cluster.yaml`` wich contains the values to apply in a prometheus-operator deployment.

The ``file_cluster.yaml`` should be created at:

On AWS:

```bash
prometheus/
├── helm_vars/
│   ├── aws
│   │   ├── production
│   │   │   ├── file_cluster.yaml
```

On GCP:

```bash
prometheus/
├── helm_vars/
|   ├── gcp/
|   |   ├── production/
|   |   |   ├── file_cluster.yaml
```

Examples:

Deploy of Prometheus in cluster ``mycluster3`` in environment ``testing`` in AWS.

```bash
./deploy.sh install aws testing mycluster3
```

Deploy of Prometheus in cluster ``mycluster6`` in environment ``testing`` in GCP.

```bash
./deploy.sh install aws testing mycluster6
```

To uninstall prometheus operator execute the follow command.

```bash
helm uninstall monitor --keep-history -n monitoring
```

# Troubleshooting

View the status of the pod with the following command.

```bash
kubectl get pods -n monitoring
```

View the Prometheus log with the following command.

```bash
kubectl logs -f prometheus-monitor-mycompany-prometheus-0 -c prometheus -n monitoring
```

Commands needed to directly perform or debug any promised content for the ``prometheus-monitor-mycompany-prometheus-0`` pod in namespace ``monitoring`` each Kubernetes clusters.

```bash
kubectl exec -it prometheus-monitor-mycompany-prometheus-0 -n monitoring -- sh
```

View configuration file of Prometheus generated by Prometheus-Operator.

```bash
cat /etc/prometheus/config_out/prometheus.env.yaml
```

View use resources.

```bash
kubectl describe pod/prometheus-monitor-mycompany-prometheus-0 -n monitoring

kubectl top pods -n monitoring

kubectl top nodes -n monitoring
```

More informations about Throubleshooting in Prometheus-Operator are available [in this page](https://github.com/coreos/prometheus-operator/blob/master/Documentation/troubleshooting.md)


# Optional: Access Grafana

If deploy grafana is defined with value ``true`` in file ``install_prometheus-operator_k8s/helm_vars/values.yaml``, then use commands follow to access Grafana:

```bash
kubectl get pods -n monitoring | grep grafana

kubectl port-forward POD_NAME 3000:3000 -n monitoring
```

Access your web navigator in URL http://localhost:3000

**login**: admin
**password**: prom-operator

To edit password default of Grafana, edit secrets of Grafana of Prometheus Operator:

```bash
kubectl edit secrets monitor-grafana -n monitoring
```

Reference: https://dev.to/rayandasoriya/comment/dckk