## Setup for keeping a GitHub profile and a Bitbucket profile side-by-side in your WSL environment:

---

## 1. Generate two RSA key pairs

```bash
# GitHub RSA key (4096-bit)
ssh-keygen -t rsa \
  -b 4096 \
  -C "your-github-email@example.com" \
  -f ~/.ssh/id_rsa_github

# Azure DevOps RSA key (4096-bit)
ssh-keygen -t rsa \
  -b 4096 \
  -C "your-azure-email@example.com" \
  -f ~/.ssh/id_rsa_azure
```

You’ll be prompted for a passphrase—highly recommended for RSA.

---

## 2. Create per-host `known_hosts` files

```bash
# GitHub’s host key
ssh-keyscan github.com 2>/dev/null \
  > ~/.ssh/known_hosts_github

# Azure DevOps’ SSH endpoint
ssh-keyscan ssh.dev.azure.com 2>/dev/null \
  > ~/.ssh/known_hosts_azure

# Lock down permissions
chmod 600 ~/.ssh/known_hosts_github ~/.ssh/known_hosts_azure
```

---

## 3. Configure `~/.ssh/config`

Edit (or create) `~/.ssh/config` and append:

```ssh-config
# — GitHub —
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa_github
  IdentitiesOnly yes
  StrictHostKeyChecking yes
  UserKnownHostsFile ~/.ssh/known_hosts_github

# — Azure DevOps —
Host azure-devops
  HostName ssh.dev.azure.com
  User git
  IdentityFile ~/.ssh/id_rsa_azure
  IdentitiesOnly yes
  StrictHostKeyChecking yes
  UserKnownHostsFile ~/.ssh/known_hosts_azure
```

Then secure the config:

```bash
chmod 600 ~/.ssh/config
```

---

## 4. Upload your public keys

1. **GitHub**

   * Copy the public key:

     ```bash
     cat ~/.ssh/id_rsa_github.pub
     ```
   * In GitHub → **Settings** → **SSH and GPG keys** → **New SSH key** → paste and save.

2. **Azure DevOps**

   * Copy the public key:

     ```bash
     cat ~/.ssh/id_rsa_azure.pub
     ```
   * In Azure DevOps → **User Settings** (top right) → **SSH Public Keys** → **Add** → paste and save.

---

## 5. Test your setup

```bash
# Test GitHub
ssh -T git@github.com
# Expected: "Hi <your-GitHub-username>! You've successfully authenticated..."

# Test Azure DevOps (using our Host alias)
ssh -T git@azure-devops
# Expected: a greeting or confirmation from ssh.dev.azure.com
```

---

## 6. Clone repos with the correct host

* **GitHub**

  ```bash
  git clone git@github.com:YourOrg/your-repo.git
  ```

* **Azure DevOps** (using the `azure-devops` alias)

  ```bash
  git clone git@azure-devops:v3/YourOrg/YourProject/your-repo.git
  ```

  or the full SSH URL form:

  ```bash
  git clone ssh://git@ssh.dev.azure.com/v3/YourOrg/YourProject/your-repo
  ```

---

That’s it! You now have two fully isolated RSA-based SSH identities—one for GitHub and one for Azure DevOps—each with its own known-hosts file.
