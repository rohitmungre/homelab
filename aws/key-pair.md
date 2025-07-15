In AWS EC2, a **key pair** is simply an SSH public‑key cryptographic key pair that AWS uses to secure SSH (or RDP) access to your instances:

* **Public key**
  When you create (or import) a key pair in AWS, the public half of that key is stored by AWS. When you launch an EC2 instance with that key pair, AWS automatically places the public key into the instance’s `~/.ssh/authorized_keys` (for Linux) or into the Windows administrator’s RDP configuration.

* **Private key**
  You download (and keep) the private half—typically in a `.pem` file. When you SSH into your EC2 instance, your SSH client uses that private key to cryptographically prove to the instance that you hold the matching private key for the installed public key.

---

### Why use a key pair?

* **Security**: No passwords are transmitted over the network; instead, SSH uses challenge‑response cryptography.
* **Access control**: Only someone with the correct private key file can log in.
* **Automation**: You can script deployments and logins without embedding passwords.

---

### How it works in practice

1. **Create or import a key pair**

   ```bash
   # Create a new key pair in us‑west‑2, saving the private key locally
   aws ec2 create-key-pair \
     --key-name my‑ec2-key \
     --region us‑west‑2 \
     --query 'KeyMaterial' \
     --output text > my-ec2-key.pem

   chmod 400 my-ec2-key.pem
   ```

2. **Launch an EC2 instance using that key**

   ```bash
   aws ec2 run‑instances \
     --image-id ami‑0123456789abcdef0 \
     --instance-type t4g.micro \
     --key-name my‑ec2-key \
     …other arguments…
   ```

3. **SSH in**

   ```bash
   ssh -i my-ec2-key.pem ec2-user@<PUBLIC_IP>
   ```

   The SSH client uses your private key (`my‑ec2‑key.pem`) to authenticate against the instance’s stored public key.

---

### Best practices

* **Protect your private key**: Never share it or check it into source control.
* **Use passphrases**: You can add a passphrase to your private key for an extra layer of security.
* **Rotate keys periodically**: If a private key is ever exposed, generate a new key pair, update your instances, and revoke the old one.
* **Limit SSH access**: Restrict your security group so only known IPs can connect over port 22.
