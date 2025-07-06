
## Prerequisites

* Install & configure the AWS CLI with credentials that can manage Route 53, S3, ACM, CloudFront.
* Replace every occurrence of `example.com` (and the AWS account placeholders) below with your actual domain/account values.

```bash
# 1. Set variables
export DOMAIN=example.com
export WWW_DOMAIN=www.$DOMAIN
export AWS_REGION="eu-west-1"         # for S3, Route53
export CF_REGION="us-east-1"          # ACM in us-east-1 for CloudFront
```

---

### 1. Create a Route 53 Hosted Zone

```bash
# Create the zone
ZONE_OUTPUT=$(aws route53 create-hosted-zone \
  --name $DOMAIN \
  --caller-reference "$(date +%s)" \
  --hosted-zone-config Comment="Hosted zone for $DOMAIN",PrivateZone=false \
  --query 'HostedZone.Id' --output text)

# Extract the pure ID (strip the "/hostedzone/" prefix)
HOSTED_ZONE_ID=${ZONE_OUTPUT#*/}

echo "Hosted zone created: $HOSTED_ZONE_ID"
```

---

### 2. Request an ACM Certificate (us-east-1)

```bash
CERT_ARN=$(aws acm request-certificate \
  --region $CF_REGION \
  --domain-name $DOMAIN \
  --subject-alternative-names $WWW_DOMAIN \
  --validation-method DNS \
  --query CertificateArn --output text)

echo "Certificate ARN: $CERT_ARN"
```

Fetch the DNS validation record values, then push them into Route 53:

```bash
# Pull the validation record info
read VAL_NAME VAL_VALUE <<<$(aws acm describe-certificate \
  --region $CF_REGION \
  --certificate-arn $CERT_ARN \
  --query "Certificate.DomainValidationOptions[0].ResourceRecord.[Name,Value]" \
  --output text)

# Create the CNAME in Route 53 for validation
cat > dns-validation.json <<EOF
{
  "Changes":[
    {
      "Action":"CREATE",
      "ResourceRecordSet":{
        "Name":"$VAL_NAME",
        "Type":"CNAME",
        "TTL":300,
        "ResourceRecords":[{"Value":"$VAL_VALUE"}]
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file://dns-validation.json

echo "DNS validation record created. Wait ~5–10 min for ACM to issue."
```

---

### 3. Create & Configure the S3 Bucket

```bash
# 3.1 Create the bucket
aws s3api create-bucket \
  --bucket $DOMAIN \
  --region $AWS_REGION \
  --create-bucket-configuration LocationConstraint=$AWS_REGION

# 3.2 Attach a public-read policy
cat > bucket-policy.json <<EOF
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"PublicRead",
    "Effect":"Allow",
    "Principal":"*",
    "Action":"s3:GetObject",
    "Resource":"arn:aws:s3:::$DOMAIN/*"
  }]
}
EOF

aws s3api put-bucket-policy \
  --bucket $DOMAIN \
  --policy file://bucket-policy.json

# 3.3 Enable static website hosting
aws s3 website s3://$DOMAIN \
  --index-document index.html \
  --error-document 404.html

echo "S3 static site bucket ready: http://$DOMAIN.s3-website-$AWS_REGION.amazonaws.com"
```

Upload your built site (assumes local folder `./site/`):

```bash
aws s3 sync ./site/ s3://$DOMAIN --acl public-read
```

---

### 4. Create the CloudFront Distribution

First, prepare a JSON config `cf-config.json`:

```json
{
  "CallerReference": "cf-$(date +%s)",
  "Comment": "CloudFront distribution for example.com",
  "Aliases": {
    "Quantity": 2,
    "Items": ["example.com", "www.example.com"]
  },
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [{
      "Id": "S3-$DOMAIN",
      "DomainName": "example.com.s3-website.eu-west-1.amazonaws.com",
      "OriginPath": "",
      "CustomOriginConfig": {
        "HTTPPort": 80,
        "HTTPSPort": 443,
        "OriginProtocolPolicy": "http-only",
        "OriginSslProtocols": {
          "Quantity": 1,
          "Items": ["TLSv1.2"]
        }
      }
    }]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-$DOMAIN",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"],
      "CachedMethods": {
        "Quantity": 2,
        "Items": ["GET", "HEAD"]
      }
    },
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {"Forward": "none"}
    },
    "TrustedSigners": {"Enabled": false, "Quantity": 0},
    "MinTTL": 0,
    "DefaultTTL": 86400,
    "MaxTTL": 31536000
  },
  "ViewerCertificate": {
    "ACMCertificateArn": "REPLACE_WITH_CERT_ARN",
    "SSLSupportMethod": "sni-only",
    "MinimumProtocolVersion": "TLSv1.2_2021"
  },
  "Enabled": true
}
```

Edit `"ACMCertificateArn"` to your `$CERT_ARN` and the domain names to your real domain. Then:

```bash
DISTRIBUTION_ID=$(aws cloudfront create-distribution \
  --distribution-config file://cf-config.json \
  --query 'Distribution.Id' --output text)

echo "CloudFront Distribution Created: $DISTRIBUTION_ID"
```

Grab its domain name and the CloudFront zone ID (always `Z2FDTNDATAQYW2`):

```bash
CF_DOMAIN=$(aws cloudfront get-distribution \
  --id $DISTRIBUTION_ID \
  --query 'Distribution.DomainName' --output text)
CF_ZONE_ID="Z2FDTNDATAQYW2"
```

---

### 4.1. Determine Public vs. Private Hosted Zone

#### A. In the AWS Console

1. Sign in to the AWS Console and open **Route 53 → Hosted zones**.
2. Look at the **Type** column for your zone:

   * **Public** → Answers DNS queries from the Internet.
   * **Private** → Answers only within one or more VPCs.

#### B. Via the AWS CLI

Replace `<HOSTED_ZONE_ID>` with your zone ID (e.g. `Z1ABCDEF...`):

```bash
aws route53 get-hosted-zone \
  --id <HOSTED_ZONE_ID> \
  --query '{Name:HostedZone.Name,Private:HostedZone.Config.PrivateZone}' \
  --output text
```

* If `Private` is `False`, it’s a **public** zone.
* If `Private` is `True`, it’s a **private** zone.

---

### 5. Point Route 53 Records at CloudFront

```bash
cat > cf-dns.json <<EOF
{
  "Changes":[
    {
      "Action":"CREATE",
      "ResourceRecordSet":{
        "Name":"$DOMAIN",
        "Type":"A",
        "AliasTarget":{
          "HostedZoneId":"$CF_ZONE_ID",
          "DNSName":"$CF_DOMAIN",
          "EvaluateTargetHealth":false
        }
      }
    },
    {
      "Action":"CREATE",
      "ResourceRecordSet":{
        "Name":"$WWW_DOMAIN",
        "Type":"A",
        "AliasTarget":{
          "HostedZoneId":"$CF_ZONE_ID",
          "DNSName":"$CF_DOMAIN",
          "EvaluateTargetHealth":false
        }
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file://cf-dns.json

echo "Route 53 A-alias records created for CloudFront."
```

---

## 6. Update GoDaddy Nameservers

AWS CLI can’t speak to GoDaddy DNS out of the box. Log into GoDaddy’s dashboard (or use their API SDK) and replace your current nameservers with the four NS records shown in the Route 53 hosted‐zone details

### 6.1. Retrieve Your Route 53 Nameservers

Every public hosted zone comes with a delegation set (4 NS records). To list them:

```bash
aws route53 get-hosted-zone \
  --id <HOSTED_ZONE_ID> \
  --query 'DelegationSet.NameServers' \
  --output text
```

You’ll see four names like:

```
ns-123.awsdns-45.com
ns-678.awsdns-90.org
ns-234.awsdns-56.net
ns-789.awsdns-12.co.uk
```

---

### 6.2. Point Your GoDaddy Domain at Those NS Records

1. **Log in** to GoDaddy and go to **My Products → Domains**.
2. Find your domain (`example.com`) and click **DNS** or **Manage DNS**.
3. Under **Nameservers**, click **Change**.
4. Select **Custom** (instead of “Default” or “Premium DNS”).
5. **Enter the four AWS nameservers** exactly as listed (one per line).
6. **Save** your changes.

---

### 6.3. Verify Delegation

After you update GoDaddy, check globally:

```bash
dig +short NS example.com
```

You should see the same four `ns-*.awsdns-*` names. Once they match, your public hosted zone in Route 53 is live and ready to serve DNS for your domain.
After that, visiting:

```
https://example.com  and  https://www.example.com
```

will serve your static site via CloudFront, backed by S3, with SSL from ACM.

---

## 7. Verify routing

To verify that your Route 53 hosted zone is correctly routing to your S3 bucket (even before you have real front-end content), you can do two things: (1) use Route 53’s DNS-testing API, and (2) upload a minimal “placeholder” object so you can actually hit the bucket’s website endpoint via your domain.

---

## A. Test DNS via the AWS CLI

Route 53 provides a handy `test-dns-answer` command that simulates a DNS lookup against your hosted zone:

```bash
# (1) Make sure these env vars are set:
export HOSTED_ZONE_ID=Z123456ABCDEFG   # your zone’s ID, e.g. "Z2ABCDEF..."
export DOMAIN=example.com              # or your real domain

# (2) Test the A-record answer
aws route53 test-dns-answer \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --record-name $DOMAIN \
  --record-type A \
  --query 'RecordData' --output text
```

* If you see back the alias target (e.g. your CloudFront or S3 website endpoint domain), DNS is wired correctly.
* You can also test the “www” record by changing `--record-name` to `www.$DOMAIN`.

---

## B. Upload a Placeholder to S3 and Hit It

Because S3 static-website hosting returns 404 (or 403) when there’s no `index.html`, let’s create a tiny test page:

1. **Create a test HTML file**

   ```bash
   echo "<!doctype html><html><body><h1>🛠 DNS → S3 OK!</h1></body></html>" \
     > test-index.html
   ```

2. **Upload it as `index.html`**

   ```bash
   aws s3 cp test-index.html s3://$DOMAIN/index.html \
     --acl public-read
   ```

3. **Invalidate your CloudFront cache** (if using CloudFront)

   ```bash
   aws cloudfront create-invalidation \
     --distribution-id YOUR_CF_ID \
     --paths "/index.html"
   ```

4. **Hit your domain**

   ```bash
   # HTTP
   curl -I http://$DOMAIN/
   # HTTPS (via CloudFront)
   curl -I https://$DOMAIN/
   ```

   You should get `200 OK` and see your custom HTML.

---

## C. Check with `dig` or `nslookup`

From any shell (even your local laptop), you can confirm the final DNS resolution:

```bash
dig +short example.com
# or for www:
dig +short www.example.com
```

It should resolve to your CloudFront or S3 website endpoint’s DNS name (for alias records), not to an IP.

---
