---
name: aws-pricing
description: Generate a calculator.aws public URL from infrastructure specifications
argument-hint: <path to spec or description>
---

# AWS Pricing Estimate Generator

## Overview

Read infrastructure specifications, look up AWS pricing, and generate a calculator.aws public URL.

## Workflow

1. Read service configuration from the spec (service type, instance type, region, count, number of environments, etc.)
2. Look up the serviceCode and version for each service
3. Retrieve unit prices via the AWS Pricing API
4. Build the Save API payload
5. POST to the Save API to obtain the public URL

## API Endpoints

| Purpose | URL |
|---------|-----|
| Save | `POST https://dnd5zrqcec4or.cloudfront.net/Prod/v2/saveAs` |
| Read | `GET https://d3knqfixx3sbls.cloudfront.net/<savedKey>` |
| Manifest | `GET https://d1qsjq9pzbk1k6.cloudfront.net/manifest/en_US.json` |
| Service Definition | `GET https://d1qsjq9pzbk1k6.cloudfront.net/data/<serviceCode>/en_US.json` |
| Pricing API | `GET https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/<billingServiceCode>/current/<region>/index.json` |
| Public URL | `https://calculator.aws/#/estimate?id=<savedKey>` |

Notes:
- The Save API requires no authentication (CORS `*`). A `Content-Type: application/json` header is required
- Pricing API responses are large (tens of MB). Use Python in Bash to fetch and filter
- These endpoints are internal to the calculator.aws SPA and may change. If an endpoint stops responding, inspect calculator.aws network traffic to find the current URL

## Payload Format

JSON structure to POST to the Save API:

```json
{
  "name": "見積もり名",
  "services": {
    "<serviceCode>-<uuid>": {
      "serviceCode": "<serviceCode>",
      "version": "<version>",
      "region": "ap-northeast-1",
      "description": "サービスの説明（環境名など）",
      "subServices": [],
      "serviceCost": {"monthly": 82.49, "upfront": 0},
      "serviceName": "表示名",
      "regionName": "Asia Pacific (Tokyo)",
      "configSummary": "InstanceUsage:db.t4g.medium (730 Hrs)"
    }
  },
  "groups": {},
  "groupSubtotal": {"monthly": 82.49, "upfront": 0},
  "totalCost": {"monthly": 82.49, "upfront": 0},
  "support": {},
  "metaData": {
    "locale": "en_US",
    "currency": "USD",
    "createdOn": "<現在時刻を ISO 8601 形式で動的に生成>",
    "source": "calculator-platform"
  }
}
```

Field descriptions:
- `serviceCode`: Public serviceCode obtained from the Manifest
- `version`: Version obtained from the Service Definition
- `region`: AWS region code
- `description`: Free text (environment name, resource name, etc.)
- `subServices`: Always an empty array `[]`. Service usage is expressed via the `configSummary` text
- `configSummary`: Usage summary (display text)
- `serviceCost.monthly`: Monthly cost
- `groupSubtotal` / `totalCost`: Sum of all services

## How to Look Up serviceCode

### Step 1: Search the Manifest for the Service

```
GET https://d1qsjq9pzbk1k6.cloudfront.net/manifest/en_US.json
```

Search by service name (e.g., "ElastiCache", "Fargate", "Aurora") to identify the `serviceCode`.

Note: The public Calculator serviceCode often differs from the AWS Billing serviceCode.
Example: Billing uses `AmazonECS`, but the public Calculator uses `awsFargate`.

### Step 2: Get the version from the Service Definition

```
GET https://d1qsjq9pzbk1k6.cloudfront.net/data/<serviceCode>/en_US.json
```

Use the `version` field from the response. A version mismatch causes the SPA to show a "Sorry, something went wrong" error.

### Step 3: When Multiple Candidates Exist

A single AWS service may have multiple serviceCodes.
Example: RDS has separate serviceCodes per DB engine (`amazonRDSPostgreSQLDB`, `amazonRDSMySQLDB`, `amazonRDSAuroraPostgreSQLCompatibleDB`, etc.).

Read the Service Definition contents to confirm the target instance type or engine is included.

## Retrieving Prices via the Pricing API

```
GET https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/<billingServiceCode>/current/<region>/index.json
```

- `billingServiceCode`: The AWS Billing service code (e.g., `AmazonRDS`, `AmazonEC2`). This differs from the public Calculator serviceCode
- Filter `products` by instance type, engine, etc., then extract the hourly unit price from `terms.OnDemand`
- Because the response is large, use Python to fetch, parse, and extract the needed information

### How to Look Up billingServiceCode

Look up the billingServiceCode in the AWS Pricing Bulk API service index:

```
GET https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/index.json
```

The `offers` in the response lists all service `offerCode` values. These correspond to the `billingServiceCode`. Search by service name to identify it (e.g., `AmazonRDS`, `AmazonEC2`, `AmazonElastiCache`, `AmazonSES`).

### Converting Unit Prices to Monthly Cost

| Billing Model | Formula | Examples |
|---------------|---------|----------|
| Compute (hourly) | Hourly price x 730 hours/month | EC2, RDS, ElastiCache |
| Storage | Per-GB price x capacity (GB) | EBS, S3, RDS Storage |
| Data transfer | Per-GB price x transfer volume (GB) | CloudFront, Data Transfer |
| Usage-based | Unit price x usage | SES (messages), Lambda (requests) |

730 hours/month is the official AWS monthly figure (365 days x 24 hours / 12 months).

## Constraints

- **`"groups"` must always be empty `{}`.** A shared estimate with non-empty groups causes the SPA to discard all services and show "Empty Estimate"
- **version must match exactly.** Always verify the latest version from the Service Definition
- **Service keys must use the `<serviceCode>-<v4 UUID>` format.** Use v4 UUIDs. Even when multiple entries share the same serviceCode, each must have a unique UUID
- Extract `savedKey` from the Save API response: `json.loads(json.loads(response)["body"])["savedKey"]`
- **Error handling**: If the Save API returns an error, suspect payload structure issues (version mismatch, missing required fields). If a product is not found in the Pricing API, check filter conditions (databaseEngine, instanceType, etc.)
