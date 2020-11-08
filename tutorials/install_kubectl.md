<!-- TOC -->

- [Install Kubectl](#install-kubectl)

<!-- TOC -->

# Install Kubectl

Run the following commands to install ``kubectl``.

```bash
sudo su

VERSION=v1.18.10
KUBECTL_BIN=kubectl

function install_kubectl {
if [ -z $(which $KUBECTL_BIN) ]; then
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$VERSION/bin/linux/amd64/$KUBECTL_BIN
    chmod +x ${KUBECTL_BIN}
    sudo mv ${KUBECTL_BIN} /usr/local/bin/${KUBECTL_BIN}
    sudo ln -sf /usr/local/bin/${KUBECTL_BIN} /usr/bin/${KUBECTL_BIN}
else
    echo "Kubectl is most likely installed"
fi
}

install_kubectl

which kubectl

kubectl version --client

exit
```

More information about ``kubectl``: https://kubernetes.io/docs/reference/kubectl/overview/

Reference: https://kubernetes.io/docs/tasks/tools/install-kubectl/