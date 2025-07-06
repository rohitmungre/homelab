Step-by-step guide to get the AWS CLI v2 up and running on your WSL Ubuntu instance, and configure it with your credentials.

---

## 1. Open Your WSL Ubuntu Shell

Launch your Ubuntu terminal in Windows Subsystem for Linux.

---

## 2. Update the Package Index & Install Prereqs

```bash
sudo apt update
sudo apt install -y curl unzip
```

---

## 3. Download and Install AWS CLI v2

```bash
# Download the latest AWS CLI v2 bundle
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip the installer
unzip awscliv2.zip

# Run the installer (requires sudo)
sudo ./aws/install

# Verify installation
aws --version
# You should see something like: aws-cli/2.x.x Python/3.x.x Linux/5.x.x botocore/2.x.x
```

*If you ever need to upgrade later:*

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
```

---

## 4. Configure Your AWS Credentials (“Logging In”)

The simplest way is with an IAM user’s access keys:

```bash
aws configure
```

You’ll be prompted for four values:

```
AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
Default region name [None]: eu-west-1      # or whatever region you use
Default output format [None]: json         # or yaml, table, text
```

These get stored in `~/.aws/credentials` and `~/.aws/config`.

---

### Optional: Using AWS SSO / IAM Identity Center

If your organization uses AWS SSO, you can set up a named profile instead:

```bash
aws configure sso
```

Follow the prompts to:

1. Select your SSO start URL.
2. Choose the AWS region where SSO is configured (e.g. `eu-west-1`).
3. Pick the account and permission set.
4. Give the profile a name (e.g. `my-sso-profile`).

Then run:

```bash
aws sso login --profile my-sso-profile
```

to authenticate via browser.

---

## 5. Test Your Setup

Try a simple command to confirm you’re “logged in”:

```bash
aws sts get-caller-identity
```

You should see your AWS account, user/role ARN, and user ID.

---
