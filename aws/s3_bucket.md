You can discover your S3 bucket names (and pick out the one you’re using for your site) in a few ways via the AWS CLI:

---

## 1. List all buckets in your account

This shows every bucket you own:

```bash
aws s3api list-buckets \
  --query 'Buckets[].Name' \
  --output text
```

Or the shorthand:

```bash
aws s3 ls
```

---

## 2. Identify which bucket has website hosting enabled

If you have a lot of buckets, you can filter down to just those configured for static-website hosting:

```bash
for b in $(aws s3api list-buckets --query 'Buckets[].Name' --output text); do
  if aws s3api get-bucket-website --bucket "$b" 2>/dev/null; then
    echo "✅ Website-enabled: $b"
  fi
done
```

Any bucket that prints under “Website-enabled” is one you can point your CloudFront/Route 53 setup at.

---

## 3. Pull it from your CloudFront origin

If you already have a CloudFront distribution, you can grab its origin domain directly:

```bash
aws cloudfront get-distribution-config \
  --id $DISTRIBUTION_ID \
  --query "DistributionConfig.Origins.Items[0].DomainName" \
  --output text
```

That will return something like

```
example.com.s3-website.eu-west-2.amazonaws.com
```

—strip off the `.s3-website.eu-west-2.amazonaws.com` and you have your bucket name (`example.com`).

---

Use any of those to confirm exactly which bucket name you need.

---

You can inspect virtually every aspect of an S3 bucket’s configuration with the `aws s3api` commands. 
Here’s a quick “checklist” of the most common settings you’ll want to verify, and the CLI calls to fetch them:

```bash
BUCKET=your-bucket-name
REGION=eu-west-2   # or whatever your bucket’s in
```

---

### 1. Website Hosting Configuration

```bash
aws s3api get-bucket-website \
  --bucket $BUCKET
```

Shows whether static-site hosting is enabled, and the `IndexDocument` / `ErrorDocument` keys.

---

### 2. Public-Access-Block Settings

```bash
aws s3api get-public-access-block \
  --bucket $BUCKET \
  --query 'PublicAccessBlockConfiguration'
```

Tells you if `BlockPublicPolicy`, `BlockPublicAcls`, etc., are on or off.

---

### 3. Bucket Policy (Permissions)

```bash
aws s3api get-bucket-policy \
  --bucket $BUCKET
```

Returns the JSON policy document that governs who can read/write objects.

---

### 4. CORS Configuration (if any)

```bash
aws s3api get-bucket-cors \
  --bucket $BUCKET
```

---

### 5. Versioning Status

```bash
aws s3api get-bucket-versioning \
  --bucket $BUCKET
```

Will show `Status: Enabled` or `Suspended`, plus MFA delete if set.

---

### 6. Encryption Settings

```bash
aws s3api get-bucket-encryption \
  --bucket $BUCKET
```

Shows if default-encryption (SSE-S3 or SSE-KMS) is enforced.

---

### 7. Logging Configuration

```bash
aws s3api get-bucket-logging \
  --bucket $BUCKET
```

Whether access logs are being delivered to another bucket.

---

### 8. Lifecycle Rules

```bash
aws s3api get-bucket-lifecycle-configuration \
  --bucket $BUCKET
```

---

### 9. Tags

```bash
aws s3api get-bucket-tagging \
  --bucket $BUCKET
```

---

### 10. ACL (if ACLs are still enabled)

```bash
aws s3api get-bucket-acl \
  --bucket $BUCKET
```

May error if “ACLs disabled” (the recommended “bucket-owner-enforced” mode).

---

You can run any (or all) of these commands to get a complete picture of your bucket’s configuration. 
If any command errors, it often tells you exactly what’s not set (e.g. no CORS rules) or what’s been locked down (e.g. ACLs disabled).
