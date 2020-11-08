<!-- TOC -->

- [Install AWC-CLI](#install-awc-cli)
- [Configure AWS Credentials](#configure-aws-credentials)

<!-- TOC -->

# Install AWC-CLI

Run the following commands to install ``awscli`` package.

```bash
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

unzip awscli-bundle.zip

sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

aws --version

rm -rf awscli-bundle.zip awscli-bundle
```

More information about ``aws-cli``: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html

Reference: https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html

# Configure AWS Credentials

[OPTIONAL] You will need to create an Amazon AWS account. Create a **Free Tier** account at Amazon https://aws.amazon.com/ follow the instructions on the pages: https://docs.aws.amazon.com/chime/latest/ag/aws-account.html and https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-limits.html. When creating the account you will need to register a credit card, but since you will create instances using the features offered by the **Free Tier** plan, nothing will be charged if you do not exceed the limit for the use of the features and time offered and described in the previous link.

After creating the account in AWS, access the Amazon CLI interface at: https://aws.amazon.com/cli/

Click on the username (upper right corner) and choose the **Security Credentials** option. Then click on the **Access Key and Secret Access Key** option and click the **New Access Key** button to create and view the ID and Secret of the key.

Create the directory below.

```bash
echo $HOME

mkdir -p $HOME/.aws/

touch $HOME/.aws/credentials
```

Open ``$HOME/.aws/credentials`` file and add the following content and change the access key and secret access key.
```
[default]
aws_access_key_id = YOUR_ACCESS_KEY_HERE
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY_HERE
```

In this case, the profile name AWS is **default**.

Reference: https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html