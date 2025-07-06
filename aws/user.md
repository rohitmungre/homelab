Here are two ways to generate an AWS Access Key ID and Secret Access Key—via the AWS Management Console (web UI) and via the AWS CLI.

---

## Method 1: AWS Management Console

1. **Sign in to the AWS Console**
   • Go to [https://console.aws.amazon.com/](https://console.aws.amazon.com/) and log in with an IAM user or root account that has permission to manage IAM users.

2. **Open the IAM Dashboard**
   • In the top-left “Services” menu, choose **Security, Identity, & Compliance** → **IAM**.

3. **Select (or Create) the User**
   • In the left sidebar, click **Users**.
   • Click the user who should get an access key.
   • If you need a new user, click **Add users**, give them a name, check **Programmatic access**, attach the appropriate policies, and finish the wizard.

4. **Create Access Keys**
   • On the user’s **Summary** page, switch to the **Security credentials** tab.
   • Scroll to **Access keys** and click **Create access key**.
   • In the dialog, choose the **AWS CLI** credential type (that gives Access Key ID + Secret).
   • Click **Next**, then **Create access key**.

5. **Save Your Credentials**
   • You’ll see the **Access key ID** and **Secret access key** exactly once.
   • **Download the .csv** or copy them into your secure vault/password manager now—AWS does *not* let you retrieve the secret later.
   • If you lose the secret, you must delete this key and generate a new one.

---

## Method 2: AWS CLI

> **Prerequisite**: You must already have an AWS CLI profile configured that has IAM permissions.

1. **Run the Create-Access-Key Command**

   ```bash
   aws iam create-access-key --user-name YOUR_IAM_USERNAME \
     --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text
   ```

   This will print two strings: your new **AccessKeyId** and **SecretAccessKey**.

2. **Store Them Securely**
   As with the console method, make sure to copy these into your secure vault immediately. AWS will not show the secret again.

---

### Best Practices

* **Least-Privilege**: Only grant the permissions the user truly needs.
* **Rotate Regularly**: Delete old keys and create new ones on a schedule (e.g. every 90 days).
* **Avoid Root Keys**: Never create or use access keys for the root account—always use an IAM user or role.
* **Use IAM Roles**: Wherever possible (e.g. EC2, Lambda, ECS), attach an IAM role instead of distributing long-lived keys.

Once you have your Access Key ID and Secret Access Key, run `aws configure` (or set them as environment variables) to start using the AWS CLI or SDKs.
