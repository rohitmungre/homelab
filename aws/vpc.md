A **VPC ID** is simply the unique identifier AWS assigns to a Virtual Private Cloud (VPC) when it’s created. It looks like `vpc-0abc1234de56f7890` and marks the network boundary for your EC2 instances, subnets, routing tables, etc.

---

### Why you need the VPC ID

* **Security groups & subnets** must be associated with a specific VPC.
* When you create resources (EC2, RDS, ELB), you often need to tell AWS which VPC—by its ID—they belong in.
* In scripts/automation, grabbing the right VPC ID ensures you’re operating in the correct network.

---

### How to find your VPC ID via the AWS CLI

#### 1. List *all* VPCs in your region

```bash
aws ec2 describe-vpcs \
  --region $AWS_REGION \
  --query 'Vpcs[*].{ID:VpcId,CIDR:CidrBlock,State:State,IsDefault:IsDefault}' \
  --output table
```

This will show a table of every VPC’s ID, CIDR block, state, and whether it’s the default one.

#### 2. Get *only* the default VPC’s ID

Most accounts have a “default” VPC per region. To fetch just its ID:

```bash
aws ec2 describe-vpcs \
  --region $AWS_REGION \
  --filters Name=isDefault,Values=true \
  --query 'Vpcs[0].VpcId' \
  --output text
```

Replace `$AWS_REGION` (e.g. `eu-west-2`) with your target region. The command will print something like:

```
vpc-0a1b2c3d4e5f6g7h
```

---

Keep that VPC ID handy for any further EC2, subnet, or security‑group operations in that network!
