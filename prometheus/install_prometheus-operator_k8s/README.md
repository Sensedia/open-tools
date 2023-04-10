# install_prometheus-operator_k8s

<!-- TOC -->

- [install\_prometheus-operator\_k8s](#install_prometheus-operator_k8s)
- [About](#about)
- [Summary](#summary)
- [Prerequisites for Prometheus Installation](#prerequisites-for-prometheus-installation)
- [Prometheus Installation](#prometheus-installation)
- [Accessing Prometheus](#accessing-prometheus)
- [Prometheus Uninstallation](#prometheus-uninstallation)
- [Troubleshooting of Prometheus installation](#troubleshooting-of-prometheus-installation)
- [Accessing AlertManager](#accessing-alertmanager)
- [Accessing Grafana](#accessing-grafana)

<!-- TOC -->

# About

This directory contains config files to deploy Prometheus in Kubernetes cluster.

We use Prometheus Operator to manage the deployments of prometheis along kubernetes clusters.

More info about prometheus-operator can find in follow pages.

* https://github.com/coreos/prometheus-operator
* https://prometheus-operator.dev/
* https://devops.college/prometheus-operator-how-to-monitor-an-external-service-3cb6ac8d5acb
* https://blog.sebastian-daschner.com/entries/prometheus-kubernetes-operator
* https://kruschecompany.com/kubernetes-prometheus-operator/
* https://containerjournal.com/topics/container-management/cluster-monitoring-with-prometheus-operator/
* https://sysdig.com/blog/kubernetes-monitoring-prometheus/
* https://sysdig.com/blog/kubernetes-monitoring-with-prometheus-alertmanager-grafana-pushgateway-part-2/
* https://sysdig.com/blog/kubernetes-monitoring-prometheus-operator-part3/

About config parameters of prometheus-operator:

* https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md
* https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#remotewritespec
* https://prometheus.io/docs/prometheus/latest/configuration/configuration/#remote_write
* https://www.robustperception.io/dropping-metrics-at-scrape-time-with-prometheus

# Summary

The directory structure is:

```bash
install_prometheus-operator_k8s/
├── deploy.sh # script for deploy prometheus-operator
├── lib.sh # auxiliary script used by deploy.sh
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

Install all packages and binaries following the instructions on the [REQUIREMENTS.md](../../REQUIREMENTS.md) file.

# Prometheus Installation

---

  ATTENTION: If you have the follow problem in installation of Prometheus-Operator:

**Problem**:

```
wait.go:48: [debug] beginning wait for 2 resources with timeout of 1m0s
Error: INSTALLATION FAILED: unable to build kubernetes objects from release manifest: error validating "": error validating data: [ValidationError(Prometheus.spec): unknown field "probeNamespaceSelector" in com.coreos.monitoring.v1.Prometheus.spec, ValidationError(Prometheus.spec): unknown field "probeSelector" in com.coreos.monitoring.v1.Prometheus.spec, ValidationError(Prometheus.spec): unknown field "shards" in com.coreos.monitoring.v1.Prometheus.spec]
helm.go:88: [debug] error validating "": error validating data: [ValidationError(Prometheus.spec): unknown field "probeNamespaceSelector" in com.coreos.monitoring.v1.Prometheus.spec, ValidationError(Prometheus.spec): unknown field "probeSelector" in com.coreos.monitoring.v1.Prometheus.spec, ValidationError(Prometheus.spec): unknown field "shards" in com.coreos.monitoring.v1.Prometheus.spec]
```

**Solution**: Remove old CRDs of Prometheus-Operator. Bug: https://github.com/bitnami/charts/issues/3775 and https://github.com/bitnami/charts/issues/4043. Run the follow command:

```bash
kubectl delete crd alertmanagerconfigs.monitoring.coreos.com

kubectl delete crd alertmanagers.monitoring.coreos.com

kubectl delete crd podmonitors.monitoring.coreos.com

kubectl delete crd probes.monitoring.coreos.com

kubectl delete crd prometheuses.monitoring.coreos.com

kubectl delete crd prometheusrules.monitoring.coreos.com

kubectl delete crd servicemonitors.monitoring.coreos.com

kubectl delete crd thanosrulers.monitoring.coreos.com
```

**Problem**:

```
install.go:206: [debug] WARNING: This chart or one of its subcharts contains CRDs. Rendering may fail or contain inaccuracies.
Error: INSTALLATION FAILED: unable to build kubernetes objects from release manifest: [unable to recognize "": no matches for kind "Alertmanager" in version "monitoring.coreos.com/v1", unable to recognize "": no matches for kind "Prometheus" in version "monitoring.coreos.com/v1", unable to recognize "": no matches for kind "PrometheusRule" in version "monitoring.coreos.com/v1", unable to recognize "": no matches for kind "ServiceMonitor" in version "monitoring.coreos.com/v1"]
helm.go:88: [debug] [unable to recognize "": no matches for kind "Alertmanager" in version "monitoring.coreos.com/v1", unable to recognize "": no matches for kind "Prometheus" in version "monitoring.coreos.com/v1", unable to recognize "": no matches for kind "PrometheusRule" in version "monitoring.coreos.com/v1", unable to recognize "": no matches for kind "ServiceMonitor" in version "monitoring.coreos.com/v1"]
unable to build kubernetes objects from release manifest
```

**Solution**: Use Kubernetes >= 1.22 and install CRDs.

For release 0.63.0 of prometheus-operator:

```bash
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml

kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml

kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml

kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml

kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml

kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml

kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml

kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.63.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```
---

Create or access Kubernetes cluster and configure the ``kubectl``.

Use the script `deploy.sh` in this repo to install/upgrade a release of prometheus-operator.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

cd install_prometheus-operator_k8s

./deploy.sh <install|upgrade> <aws|gcp> <testing|staging|production> <cluster_name> [--dry-run]
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

# Accessing Prometheus

Use command follow to access Prometheus:

```bash
kubectl port-forward svc/monitor-mycompany-prometheus -n monitoring 9090:9090
```

Access your web navigator in URL http://localhost:9090

# Prometheus Uninstallation

To uninstall prometheus operator execute the follow command:

```bash
helm uninstall monitor -n monitoring
```

# Troubleshooting of Prometheus installation

See the status of the pod with the following command:

```bash
kubectl --namespace monitoring get pods -l "release=monitor"
```

See the Prometheus log with the following command:

```bash
kubectl logs -f prometheus-monitor-mycompany-prometheus-0 -c prometheus -n monitoring
```

Commands needed to directly perform or debug any promised content for the ``prometheus-monitor-mycompany-prometheus-0`` pod in namespace ``monitoring`` each Kubernetes clusters.

```bash
kubectl exec -it prometheus-monitor-mycompany-prometheus-0 -n monitoring -- sh
```

See configuration file of Prometheus inside Pod generated by Prometheus-Operator:

```bash
cat /etc/prometheus/config_out/prometheus.env.yaml

ls /etc/prometheus/rules/*
```

See resources of pods in use:

```bash
kubectl describe pod/prometheus-monitor-mycompany-prometheus-0 -n monitoring

kubectl top pods -n monitoring

kubectl top nodes -n monitoring
```

More informations about Throubleshooting in Prometheus-Operator are available [in this page](https://github.com/coreos/prometheus-operator/blob/master/Documentation/troubleshooting.md)

# Accessing AlertManager

If deploy alertmanager is defined with value ``true`` in file ``install_prometheus-operator_k8s/helm_vars/values.yaml``, then use command follow to access AlertManager:

```bash
kubectl port-forward svc/alertmanager-operated -n monitoring 9093:9093
```

Access your web navigator in URL http://localhost:9093

# Accessing Grafana

If deploy grafana is defined with value ``true`` in file ``install_prometheus-operator_k8s/helm_vars/values.yaml``, then use command follow to access Grafana:

```bash
kubectl port-forward svc/monitor-grafana 3000:80 -n monitoring
```

Access your web navigator in URL http://localhost:3000

* **login**: admin
* **password**: prom-operator

To edit password default of Grafana, edit secrets of Grafana of Prometheus Operator:

```bash
kubectl edit secrets monitor-grafana -n monitoring
```

Reference: https://dev.to/rayandasoriya/comment/dckk
