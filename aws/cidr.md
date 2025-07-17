## 1. What is CIDR notation?

CIDR is a compact way to represent IP address ranges. It combines an IP address with a suffix indicating how many bits are fixed (the network portion):

```
<network-address>/<prefix-length>
```

* **Network address**: e.g. `10.0.0.0`
* **Prefix length**: e.g. `16` means the first 16 bits are network bits, leaving the remaining 16 for hosts.

So `10.0.0.0/16` covers all IPs from `10.0.0.0` up to `10.0.255.255` (65 536 addresses).

---

## 2. Why AWS uses CIDR for EC2

Every EC2 instance lives in a **VPC**, and each VPC (and each subnet within it) is defined by a CIDR block:

* **VPC CIDR** – the supernet for your entire private network. For example:

  ```text
  10.0.0.0/16    # supports up to 65k IPs across all subnets
  ```
* **Subnet CIDR** – carved‑out segments of the VPC. You might create:

  ```text
  10.0.0.0/24    # 256 IPs for “public” subnet
  10.0.1.0/24    # 256 IPs for “private” subnet
  ```

When you launch an EC2 instance, you choose a subnet, and AWS assigns it a free IP from that subnet’s CIDR.

---

## 3. Choosing CIDR ranges

1. **Pick a VPC range** comfortable for your scale:

   * Small: `10.0.0.0/24` (256 addresses)
   * Medium: `10.0.0.0/16` (65 536 addresses)
   * Large: `10.0.0.0/12` (1 048 576 addresses)

2. **Divide into subnets** per Availability Zone and role (public, private, database):

   ```text
   10.0.0.0/24  → Public subnet AZ‑a
   10.0.1.0/24  → Public subnet AZ‑b
   10.0.10.0/24 → Private subnet AZ‑a
   10.0.11.0/24 → Private subnet AZ‑b
   10.0.20.0/28 → DB subnet AZ‑a  (16 addresses)
   10.0.20.16/28→ DB subnet AZ‑b
   ```

3. **Avoid overlap** with your on‑prem or peered networks to prevent routing conflicts.

---

## 4. CIDR in Security Groups & NACLs

* **Security Group rules** also use CIDR to define what source/destination IPs are allowed:

  ```text
  0.0.0.0/0      # everyone (public Internet)
  10.0.0.0/16    # any instance in your VPC
  192.168.1.0/24 # specific internal subnet
  ```
* **Network ACLs** act at the subnet level, also keyed by CIDR.

---

## 5. Quick CLI examples

```bash
# Create a VPC with a /16 CIDR
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Create a subnet with a /24 CIDR in that VPC
aws ec2 create-subnet --vpc-id vpc-abc123 \
  --cidr-block 10.0.1.0/24 --availability-zone eu-west-2a
```

---

### TL;DR

* **CIDR** defines IP ranges: `<network>/<bits>`.
* AWS VPCs and subnets are CIDR‑based.
* EC2 instances get addresses from the subnet’s CIDR.
* Plan your CIDR to fit size, segmentation, and avoid overlaps.
