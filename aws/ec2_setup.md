Here’s a complete “from zero” recipe—using the AWS CLI—to spin up a **t4g.micro** EC2 instance in **eu-west-2** (London), secure it for SSH + HTTP, and install Docker Engine on it.

---

## 0. Prerequisites

* AWS CLI v2 installed and configured (`aws configure`) with credentials that can create EC2, SGs, and KeyPairs.
* `jq` installed locally (for parsing JSON).
* Your local IP (you can find at [https://icanhazip.com/](https://icanhazip.com/)).

---

## 1. Set some variables

```bash
export AWS_REGION=eu-west-2
export KEY_NAME=my-t4g-key
export SG_NAME=t4g-docker-sg
export INSTANCE_NAME=my-t4g-micro
export YOUR_IP=$(curl -s https://icanhazip.com)/32
```

---

## 2. Create an SSH keypair

```bash
aws ec2 create-key-pair \
  --region $AWS_REGION \
  --key-name $KEY_NAME \
  --query 'KeyMaterial' --output text \
> ${KEY_NAME}.pem

chmod 400 ${KEY_NAME}.pem
echo "Saved key → ${KEY_NAME}.pem"
```

---

## 3. Create a security group allowing SSH & HTTP

```bash
SG_ID=$(
  aws ec2 create-security-group \
    --region $AWS_REGION \
    --group-name $SG_NAME \
    --description "SSH+HTTP for t4g.micro" \
    --query 'GroupId' --output text
)
echo "Created SG: $SG_ID"

# Allow SSH from your IP
aws ec2 authorize-security-group-ingress \
  --region $AWS_REGION \
  --group-id $SG_ID \
  --protocol tcp --port 22 --cidr $YOUR_IP

# Allow HTTP from anywhere
aws ec2 authorize-security-group-ingress \
  --region $AWS_REGION \
  --group-id $SG_ID \
  --protocol tcp --port 80 --cidr 0.0.0.0/0
```

---

## 4. Find the latest Amazon Linux 2 ARM64 AMI

```bash
AMI_ID=$(
  aws ec2 describe-images \
    --region $AWS_REGION \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-*-arm64-gp2" "Name=state,Values=available" \
    --query 'Images | sort_by(@,&CreationDate)[-1].ImageId' \
    --output text
)
echo "Using AMI: $AMI_ID"
```

---

## 5. Launch the t4g.micro instance

```bash
INSTANCE_ID=$(
  aws ec2 run-instances \
    --region $AWS_REGION \
    --image-id $AMI_ID \
    --instance-type t4g.micro \
    --key-name $KEY_NAME \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --query 'Instances[0].InstanceId' --output text
)
echo "Launched instance: $INSTANCE_ID"
```

---

## 6. Wait until it’s running, then fetch its public DNS

```bash
aws ec2 wait instance-running \
  --region $AWS_REGION \
  --instance-ids $INSTANCE_ID

PUBLIC_DNS=$(aws ec2 describe-instances \
  --region $AWS_REGION \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicDnsName' --output text)

echo "Instance is ready at: $PUBLIC_DNS"
```

---

## 7. SSH in and install Docker Engine

```bash
ssh -o StrictHostKeyChecking=no -i ${KEY_NAME}.pem ec2-user@$PUBLIC_DNS << 'EOF'
  # Update OS and install Docker
  sudo yum update -y
  sudo amazon-linux-extras install docker -y
  sudo systemctl enable --now docker

  # Allow ec2-user to run Docker
  sudo usermod -aG docker ec2-user

  # Quick test
  docker run --rm hello-world

  echo "Docker installed successfully!"
EOF
```

> **Note:** You may need to log out and back in (or start a new SSH session) for the `docker` group membership to take effect.

---

## 8. Verify

1. **SSH back in**:

   ```bash
   ssh -i ${KEY_NAME}.pem ec2-user@$PUBLIC_DNS
   ```
2. **Run**:

   ```bash
   docker version
   docker ps
   ```

   You should see Docker’s client & server info, and no running containers.

---

You now have a **t4g.micro** EC2 instance in London running Docker Engine, ready to host your containers.
