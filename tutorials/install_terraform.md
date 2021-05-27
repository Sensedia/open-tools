<!-- TOC -->

- [[OPTION_1] Install Binary of Terraform](#option_1-install-binary-of-terraform)
- [[OPTION_2] Install tfenv for management of Terraform versions](#option_2-install-tfenv-for-management-of-terraform-versions)

<!-- TOC -->

# [OPTION_1] Install Binary of Terraform

Run the following commands to install ``terraform``.

```bash
sudo su

TERRAFORM_ZIP_FILE=terraform_0.12.31_linux_amd64.zip
TERRAFORM_BASE_URL=https://releases.hashicorp.com/terraform/0.12.31

function install_terraform {
if [ -z $(which terraform) ]; then
    wget ${TERRAFORM_BASE_URL}/${TERRAFORM_ZIP_FILE}
    unzip ${TERRAFORM_ZIP_FILE}
    sudo mv terraform /usr/local/bin/terraform
    rm -rf ${TERRAFORM_ZIP_FILE}
    chmod +x /usr/local/bin/terraform
else
    echo "Terraform is most likely installed"
fi
}

install_terraform
which terraform
terraform version

exit
```

More information about ``terraform``: https://www.terraform.io/docs/index.html

# [OPTION_2] Install tfenv for management of Terraform versions

Run the following commands to install ``tfenv``.

```bash
cd $HOME
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
sudo ln -s ~/.tfenv/bin/* /usr/local/bin
```

Install Terraform version using ``tfenv`` command:

```bash
tfenv install 0.12.31
```

More information about ``tfenv``: https://github.com/tfutils/tfenv

List Terraform versions to install:

```bash
tfenv list-remote
```

Using specific Terraform version installed:

```bash
tfenv use <VERSION>
```

Uninstall Terraform version with ``tfenv`` command:

```bash
tfenv uninstall <VERSION>
```

List Terraform versions installed:

```bash
tfenv list
```

Only when developing code that makes use of Terraform, you can force the project to use a specific version:
Create the ``.terraform-version`` file at the root of the project with the desired version number. Example:

```bash
echo "0.12.31" > .terraform-version
```
