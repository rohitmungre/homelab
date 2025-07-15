An **AMI** (Amazon Machine Image) is a pre-configured, read-only “snapshot” that contains the information needed to launch an EC2 instance. Think of it as the “golden image” for your server.

---

## Key points about AMIs

* **What it includes**

  * A **root filesystem** (an operating system—e.g. Amazon Linux, Ubuntu, Windows)
  * Optional **application layers** (you can bake in databases, web servers, or your own code)
  * **Launch permissions** and **block-device mappings** (defines which EBS volumes or instance-store volumes get attached, and how)

* **Types of AMIs**

  * **EBS-backed** (most common) – boots from an EBS volume, so you can stop/start and retain data.
  * **Instance-store–backed** – boots from ephemeral storage that’s lost on stop (used less frequently).

* **Virtualization**

  * **HVM** (Hardware Virtual Machine) – full virtualization, best performance for modern instance types.
  * **PV** (Paravirtual) – older virtualization, rare for new AMIs.

* **Ownership & sharing**

  * **Public** AMIs – published by AWS (Amazon-provided) or the community (e.g. Ubuntu, Bitnami).
  * **Private** AMIs – owned by your account (your custom build).
  * You can **share** your AMI with specific AWS accounts or make it **public**.

* **Region-specific**
  AMIs are tied to a Region. If you want the same image elsewhere, you either use the AWS-provided regional parameter store (“latest” SSM parameter) or **copy** your AMI to other Regions.

---

## Typical workflow

1. **Find a base AMI**

   ```bash
   aws ssm get-parameter \
     --name /aws/service/ami-amazon-linux-latest/amzn2023-ami-hvm-x86_64-gp2 \
     --region eu-west-2 --query 'Parameter.Value' --output text
   ```

2. **Launch an EC2 instance** using that AMI:

   ```bash
   aws ec2 run-instances \
     --image-id ami-0abcdef1234567890 \
     --instance-type t4g.micro \
     …other flags…
   ```

3. **Customize & create your own AMI**:

   * SSH in, install/configure software, then
   * `aws ec2 create-image --instance-id i-0123456789abcdef0 --name my-custom-ami`

4. **Use your AMI** in Auto Scaling groups, CloudFormation templates, or “git-ops” pipelines to ensure consistent, repeatable server builds.

---

By standardizing on AMIs, you guarantee that every EC2 instance you launch starts from the same known, tested baseline—making your infrastructure more reliable and maintainable.
