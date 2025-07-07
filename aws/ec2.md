Here’s a concise primer on Amazon EC2—what it is, its key concepts, and the AWS CLI commands you’ll use most often to manage your instances.

---

## 1. What is Amazon EC2?

Amazon Elastic Compute Cloud (EC2) is a core AWS service that provides resizable virtual servers (“instances”) in the cloud. You choose an **AMI** (Amazon Machine Image) that bundles an OS and software stack, pick an **instance type** (CPU/RAM/network profile), and launch in a given **Region** and **Availability Zone**. EC2 integrates with networking (VPC, Security Groups), storage (EBS, instance store), and identity (IAM roles, key pairs).

---

## 2. Key Concepts

* **Instance**
  A running virtual machine. Instances have states (pending → running → stopping → stopped → terminating → terminated).

* **AMI**
  Templates for instance launches. Can be public, shared, or your own.

* **Instance Types**
  Families optimized for compute, memory, storage, or GPU workloads (e.g. t3.micro, m5.large, c6g.medium).

* **Key Pair**
  SSH key pair used for secure login. Public key is injected at launch; private key you keep locally.

* **Security Group**
  Virtual “firewall” controlling inbound/outbound port access at the instance level.

* **EBS Volume**
  Network‐attached block storage you can attach/detach independently of instance lifecycle.

* **Elastic IP**
  Static, public IPv4 address you can allocate and attach to instances.

* **VPC & Subnets**
  Your own virtual network; instances live in subnets (public or private).

* **IAM Role**
  Permissions you assign to instances to let them call AWS APIs without embedding credentials.

---

## 3. EC2 Instance Lifecycle

1. **Launch**: choose AMI, instance type, VPC/subnet, security group, key pair
2. **Configure**: attach EBS volumes, assign Elastic IP, user-data scripts
3. **Operate**: SSH/RDP in, monitor (via CloudWatch), adjust capacity (Auto Scaling)
4. **Stop/Start**: preserves EBS‐backed root volume (instance store lost)
5. **Terminate**: deletes instance and (optionally) its volumes

---

## 4. Essential AWS CLI Setup

Before you begin, make sure you have the AWS CLI installed and configured:

```bash
# Install
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip && sudo ./aws/install

# Configure (set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, default region & output)
aws configure
```

Use profiles if you manage multiple accounts:

```bash
aws configure --profile myproject
aws ec2 describe-instances --profile myproject --region eu-west-1
```

---

## 5. Common EC2 CLI Commands

| Command                                    | Description                              | Example                                                                                                                                                                   |
| ------------------------------------------ | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `aws ec2 describe-regions`                 | List all AWS Regions                     | `aws ec2 describe-regions`                                                                                                                                                |
| `aws ec2 describe-availability-zones`      | List AZs in a Region                     | `aws ec2 describe-availability-zones --region us-east-1`                                                                                                                  |
| `aws ec2 create-key-pair`                  | Generate a new SSH key pair              | `aws ec2 create-key-pair --key-name MyKey --query 'KeyMaterial' --output text > MyKey.pem`                                                                                |
| `aws ec2 create-security-group`            | Create a new security group              | `aws ec2 create-security-group --group-name web-sg --description "Web traffic"`                                                                                           |
| `aws ec2 authorize-security-group-ingress` | Open ports in a security group           | `aws ec2 authorize-security-group-ingress --group-id sg-12345678 --protocol tcp --port 22 --cidr 0.0.0.0/0`                                                               |
| `aws ec2 run-instances`                    | Launch one or more EC2 instances         | `aws ec2 run-instances --image-id ami-0abcdef1234567890 --count 1 --instance-type t3.micro --key-name MyKey --security-group-ids sg-12345678 --subnet-id subnet-aaaabbbb` |
| `aws ec2 describe-instances`               | View details/status of your instances    | `aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"`                                                                                          |
| `aws ec2 stop-instances`                   | Stop running instances (EBS-backed only) | `aws ec2 stop-instances --instance-ids i-0123456789abcdef0`                                                                                                               |
| `aws ec2 start-instances`                  | Start stopped instances                  | `aws ec2 start-instances --instance-ids i-0123456789abcdef0`                                                                                                              |
| `aws ec2 reboot-instances`                 | Reboot one or more instances             | `aws ec2 reboot-instances --instance-ids i-0123456789abcdef0`                                                                                                             |
| `aws ec2 terminate-instances`              | Permanently delete instances             | `aws ec2 terminate-instances --instance-ids i-0123456789abcdef0`                                                                                                          |
| `aws ec2 allocate-address`                 | Allocate a new Elastic IP                | `aws ec2 allocate-address --domain vpc`                                                                                                                                   |
| `aws ec2 associate-address`                | Attach an Elastic IP to an instance      | `aws ec2 associate-address --instance-id i-0123456789abcdef0 --allocation-id eipalloc-12345678`                                                                           |
| `aws ec2 describe-volumes`                 | List EBS volumes                         | `aws ec2 describe-volumes`                                                                                                                                                |
| `aws ec2 create-volume`                    | Create an EBS volume                     | `aws ec2 create-volume --size 20 --volume-type gp3 --availability-zone us-west-2a`                                                                                        |

> **Tip:** Append `--output table` or `--output json` to format the output for readability or scripting.

---

## 6. Best Practices

* **Tagging:** Always tag your instances, volumes, and snapshots (`--tag-specifications`) for cost allocation and organization.
* **IAM Roles over Keys:** Use IAM instance profiles instead of embedding credentials.
* **Auto Scaling:** Combine EC2 with Auto Scaling groups to handle demand spikes.
* **Monitoring & Logging:** Enable detailed CloudWatch metrics and CloudTrail for auditing.
* **Cost Controls:** Set budgets/alerts, use spot instances or savings plans for cost savings.
