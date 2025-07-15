A **security group** in AWS acts as a virtual firewall at the instance level. It controls inbound and outbound traffic by allowing you to specify which ports, protocols, and source/destination IP ranges are permitted.

---

## 1. How to list your Security Groups

### Via AWS CLI

```bash
# List all security groups in your region
aws ec2 describe-security-groups \
  --region $AWS_REGION \
  --query 'SecurityGroups[*].{Name:GroupName,ID:GroupId,Vpc:VpcId,Desc:Description}' \
  --output table
```

If you want to filter by VPC or name:

```bash
# Only show SGs in a specific VPC
aws ec2 describe-security-groups \
  --region $AWS_REGION \
  --filters Name=vpc-id,Values=vpc-0abc1234de56f7890 \
  --query 'SecurityGroups[*].{Name:GroupName,ID:GroupId}' \
  --output table

# Only show SGs with “github-runner” in their name
aws ec2 describe-security-groups \
  --region $AWS_REGION \
  --filters Name=group-name,Values='*github-runner*' \
  --query 'SecurityGroups[*].{Name:GroupName,ID:GroupId}' \
  --output table
```

### Via the AWS Console

1. Sign in to the AWS Console and go to **VPC** (or **EC2** → **Network & Security** → **Security Groups**).
2. You’ll see a list of all SGs, their IDs, VPC associations, and rules.

---

## 2. How to create a new Security Group

You’ll need:

* **Group name** (unique within the VPC)
* **Description**
* **VPC ID** where it lives

### Step‑by‑step with AWS CLI

1. **Create the Security Group**

   ```bash
   aws ec2 create-security-group \
     --region $AWS_REGION \
     --group-name my-sg \
     --description "Allow SSH & HTTP for my app" \
     --vpc-id vpc-0abc1234de56f7890 \
     --query 'GroupId' \
     --output text
   ```

   This returns the new **GroupId** (e.g. `sg-0123abcd4567efgh8`).

2. **Add inbound (ingress) rules**
   For example, SSH from your IP and HTTP from anywhere:

   ```bash
   # SSH from your current IP only
   MY_IP=$(curl -s https://checkip.amazonaws.com)/32

   aws ec2 authorize-security-group-ingress \
     --region $AWS_REGION \
     --group-id sg-0123abcd4567efgh8 \
     --protocol tcp \
     --port 22 \
     --cidr $MY_IP

   # HTTP from anywhere
   aws ec2 authorize-security-group-ingress \
     --region $AWS_REGION \
     --group-id sg-0123abcd4567efgh8 \
     --protocol tcp \
     --port 80 \
     --cidr 0.0.0.0/0
   ```

3. **(Optional) Add outbound (egress) rules**
   By default, new SGs allow all outbound traffic. To lock it down, you can revoke the default rule and add specific ones:

   ```bash
   # Revoke the “allow all egress” rule
   aws ec2 revoke-security-group-egress \
     --region $AWS_REGION \
     --group-id sg-0123abcd4567efgh8 \
     --protocol -1 \
     --cidr 0.0.0.0/0

   # Allow DNS (UDP/53) outbound
   aws ec2 authorize-security-group-egress \
     --region $AWS_REGION \
     --group-id sg-0123abcd4567efgh8 \
     --protocol udp \
     --port 53 \
     --cidr 0.0.0.0/0
   ```

---

## 3. Attaching your Security Group to instances

When you launch or modify an EC2 instance, reference your new SG by its **GroupId**:

```bash
# Launch new instance with your SG
aws ec2 run-instances \
  --region $AWS_REGION \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids sg-0123abcd4567efgh8 \
  …other options…
```

Or to attach to an existing instance:

```bash
aws ec2 modify-instance-attribute \
  --region $AWS_REGION \
  --instance-id i-0a1b2c3d4e5f6g7h8 \
  --groups sg-0123abcd4567efgh8
```

---

### Summary

* **Security Groups** = instance‑level virtual firewalls (stateful).
* **Describe** them with `aws ec2 describe-security-groups`.
* **Create** one with `aws ec2 create-security-group`, then add rules via `authorize-security-group-ingress`/`egress`.
* **Attach** to EC2 either at launch or via `modify-instance-attribute`.

With these commands you can list, create, and configure security groups entirely from the AWS CLI.
