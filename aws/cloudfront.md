## 1. What Is CloudFront?

Amazon CloudFront is a **Content Delivery Network** that caches and delivers your web content (static and dynamic) from **edge locations** around the world. By bringing your content physically closer to end-users, CloudFront reduces latency, speeds up downloads, and offloads traffic from your origin servers.

---

## 2. Key Concepts

* **Edge Locations**
  Over 450 PoPs (points of presence) globally. User requests route to the nearest edge for fastest response.

* **Origins**
  The source of truth for your content—this can be an S3 bucket (static website), an Application Load Balancer (for containers/EC2), an EC2 instance, an AWS Elemental MediaPackage endpoint, or even a custom HTTP server.

* **Distributions**
  A configuration that ties together one or more origins with caching rules, SSL/TLS settings, custom domain names (CNAMEs), and behaviors. Two types exist:

  * **Web** distributions for HTTP/HTTPS delivery.
  * **RTMP** distributions (legacy) for streaming media.

* **Cache Behaviors**
  Rules you define per path pattern (e.g. `/*.jpg`, `/api/*`) that specify which origin to use, which HTTP methods are allowed, whether to forward cookies or query strings, and TTL settings (MinTTL, DefaultTTL, MaxTTL).

* **Viewer Certificates**
  SSL/TLS settings that determine how HTTPS is terminated at the edge—either with the default `*.cloudfront.net` certificate or a custom ACM‐provisioned certificate (must reside in **us-east-1**).

* **Invalidations**
  When you update content at your origin, invalidations let you purge cached objects (by path or wildcard) so CloudFront fetches the newest version.

---

## 3. How CloudFront Works

1. **DNS Resolution**
   A user requests `https://www.example.com/index.html`. DNS points that domain to your CloudFront distribution’s domain name (e.g. `d1234abcd.cloudfront.net`).

2. **Edge Routing**
   The request goes to the nearest edge location. If the object is **cached** (and unexpired), CloudFront returns it immediately.

3. **Cache Miss / Origin Fetch**
   If not in cache, the edge proxies the request to your defined origin. The origin serves the object, and CloudFront caches it at the edge.

4. **Subsequent Requests**
   New requests for the same object hit the edge cache directly until the TTL expires (or you invalidate).

---

## 4. Common Use Cases

* **Static Website Hosting**
  S3 + CloudFront for HTML, CSS, JS, images—fast global delivery with HTTPS.

* **Dynamic Content & APIs**
  Front API Gateway, ALB, or EC2 endpoints—cache where safe, forward the rest.

* **Video Streaming & Media**
  With signed URLs/cookies, Lambda\@Edge for custom logic, and integration with AWS Media Services.

* **Software Distribution**
  Large downloads (binaries, installers) delivered quickly and reliably.

---

## 5. Pricing Overview

* **Data Transfer Out**: charged per GB, varies by region and edge location.
* **HTTP/HTTPS Requests**: per 10,000 or 1,000,000 requests.
* **Invalidation Paths**: first 1,000 paths per month free; thereafter a small per‐path fee.
* **Lambda\@Edge**: billed by invocation count and duration separately.

You only pay for what you use—no upfront fees or minimum commitments.

---

## 6. Getting Started (High Level)

1. **Prepare Origin**: e.g. enable S3 static hosting or launch your web servers behind an ALB.
2. **Request ACM Cert** (in us-east-1) for your custom domain.
3. **Create a Web Distribution**:

   * Point Origin Domain Name to your S3 website endpoint or ALB DNS name.
   * Add your domain(s) under **Alternate Domain Names (CNAMEs)**.
   * Select your ACM certificate.
   * Configure default/root object, cache behaviors, viewer protocol policy (e.g., redirect HTTP to HTTPS).
4. **Point DNS**: use Route 53 (Alias record) or any DNS provider to map your domain to the CloudFront distribution.
5. **Invalidate & Monitor**: use invalidations when content updates, watch cache hit ratios and latency in CloudWatch.

---

## 7. Best Practices

* **Use Cache Policies** (managed or custom) over legacy TTL fields for finer control of headers, cookies, and query strings.
* **Enable Gzip/Brotli Compression** at the origin or via CloudFront.
* **Set Minimal TLS Versions** (e.g. TLSv1.2\_2021) and enable HTTP/2 for better performance.
* **Leverage Lambda\@Edge** for A/B testing, authentication, geolocation redirects, or custom headers.
* **Monitor & Alert** with CloudWatch metrics (Requests, 4xx/5xx rates, CacheHitRate) and alarms.
* **Protect with AWS WAF**: integrate Web Application Firewall rules at the edge to block malicious traffic.

---

## 8. Alternatives & Complementary Services

* **Amazon Global Accelerator** for static IP front-ends to optimize routing for TCP/UDP workloads.
* **AWS Shield Advanced** for DDoS protection at scale.
* **API Gateway + CloudFront** implicitly use CloudFront under the hood for your APIs.

---

With this foundation, you should have a solid understanding of **what CloudFront is**, **how it speeds up your application**, and **how to get started** serving your content globally with low latency and high reliability.
