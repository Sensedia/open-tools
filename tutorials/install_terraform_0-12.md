<!-- TOC -->

- [Install Terraform 0.12.x](#install-terraform-012x)

<!-- TOC -->

# Install Terraform 0.12.x

Run the following commands to install ``terraform``.

```bash
sudo su

TERRAFORM_ZIP_FILE=terraform_0.12.28_linux_amd64.zip
TERRAFORM=https://releases.hashicorp.com/terraform/0.12.28
TERRAFORM_BIN=terraform12

function install_terraform12 {
if [ -z $(which $TERRAFORM_BIN) ]; then
    wget ${TERRAFORM}/${TERRAFORM_ZIP_FILE}
    unzip ${TERRAFORM_ZIP_FILE}
    sudo mv terraform /usr/local/bin/${TERRAFORM_BIN}
    ln -sf /usr/local/bin/${TERRAFORM_BIN} /usr/local/bin/terraform
    rm -rf ${TERRAFORM_ZIP_FILE}
	chmod +x /usr/local/bin/${TERRAFORM_BIN}
else
    echo "Terraform 0.12 is most likely installed"
fi
}

install_terraform12

which ${TERRAFORM_BIN}

${TERRAFORM_BIN} version

exit
```

More information about ``terraform``: https://www.terraform.io/docs/index.html