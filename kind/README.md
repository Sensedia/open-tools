<!-- TOC -->

- [Contributing](#contributing)
- [About Visual Code (VSCode)](#about-visual-code-vscode)

<!-- TOC -->

# Creating a k8s cluster with kind

* Install ``kind`` binary following this [tutorial](REQUIREMENTS.md).

* Create a Kubernetes cluster with three nodes using kind.

```bash
cp kind/kind-3nodes.yaml $HOME/kind-3nodes.yaml

kind create cluster --name kind-multinodes --config $HOME/kind-3nodes.yaml
```

To view your clusters using kind, run the following command.

```bash
kind get clusters
```

To destroy the cluster, run the following command which will select and remove all local clusters created in Kind.

```bash
kind delete clusters $(kind get clusters)
```

References:

* https://github.com/badtuxx/DescomplicandoKubernetes/blob/master/day-1/DescomplicandoKubernetes-Day1.md#kind 
* https://kind.sigs.k8s.io/docs/user/quick-start/
* https://github.com/kubernetes-sigs/kind/releases
* https://kubernetes.io/blog/2020/05/21/wsl-docker-kubernetes-on-the-windows-desktop/#kind-kubernetes-made-easy-in-a-container