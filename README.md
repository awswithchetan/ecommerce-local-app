# eCommerce Local App

This repo is a part of my youtube video where I have explained the architecture and detailed steps to deploy this application:

Video: [https://youtu.be/KUjDQNJBAks](https://youtu.be/XNTDCvtYTLw)

Local development environment for the eCommerce microservices application.
Uses Docker Compose + LocalStack to simulate AWS services entirely on your machine.

**Author**: Chetan Agrawal  
**Website**: [www.awswithchetan.com](https://www.awswithchetan.com)

> For AWS deployment, see the [ecommerce-web-app](https://github.com/awswithchetan/ecommerce-web-app) repo.

## Architecture

### AWS Reference Architecture
<img width="800" height="450" alt="project-architecture" src="https://github.com/user-attachments/assets/b08a6351-e907-49aa-8c4b-4a796e301c15" />

### Local Stack
| AWS Service | Local Equivalent |
|---|---|
| DynamoDB | LocalStack |
| SNS / SQS / SES | LocalStack |
| RDS PostgreSQL | PostgreSQL container |
| ALB + API Gateway | Nginx |
| Cognito | Real AWS Cognito (free tier) |

## What You'll Build

A fully functional eCommerce application running entirely on your local machine:

- **Product catalog** — browse 20 sample products with images, descriptions, and pricing
- **User authentication** — sign up and sign in via AWS Cognito (real Cognito, free tier)
- **Shopping cart** — add/remove items, persisted per user in DynamoDB (LocalStack)
- **Order placement** — checkout from cart, inventory updated, order saved to PostgreSQL
- **Email notifications** — order confirmation emails generated via SNS → SQS → notification service, saved as files locally for inspection
- **API gateway** — Nginx routes all frontend requests to the correct microservice, simulating AWS ALB + API Gateway

All AWS services (DynamoDB, SNS, SQS, SES) run locally via LocalStack. Only Cognito uses real AWS (no cost for the usage in this tutorial).

## Project Structure

```
ecommerce-local-app/
├── services/
│   ├── product-service/
│   ├── cart-service/
│   ├── user-service/
│   ├── order-service/
│   └── notification-service/
├── frontend/
│   └── react-app/
├── local-deployment/
│   ├── docker-compose.yml
│   ├── nginx.conf
│   ├── localstack-init/
│   └── data/
└── install-prerequisites.sh
```

## Getting Started

See [local-deployment/README.md](local-deployment/README.md) for step-by-step instructions.
