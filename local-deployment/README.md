# eCommerce Local App - Deployment Guide

A microservices-based eCommerce application running locally with LocalStack (AWS emulator).

## Architecture

### Services
- **Product Service** - Product catalog (DynamoDB)
- **Cart Service** - Shopping cart (DynamoDB)
- **User Service** - User profiles (PostgreSQL)
- **Order Service** - Order processing (PostgreSQL)
- **Notification Service** - Email notifications (SNS/SQS/SES)

### Tech Stack
- **Backend**: Python FastAPI microservices
- **Frontend**: React application
- **Database**: PostgreSQL + DynamoDB (LocalStack)
- **Auth**: AWS Cognito User Pools
- **Messaging**: SNS + SQS (LocalStack)
- **API Gateway**: Nginx (simulates AWS ALB)

## Prerequisites

### 1. AWS Account
An AWS account is needed for Cognito authentication.

### 2. Local Workstation (Linux / Mac)
- A Linux or macOS machine
- Windows users can use WSL2 (Ubuntu)

### 3. Required Tools
- **Git** — version control
- **Docker** and **Docker Compose** — for running services locally
- **Node.js 20+** and **npm** — for the React frontend
- **AWS CLI v2** — for interacting with LocalStack

### Step 1: Clone the Repository

```bash
git clone https://github.com/awswithchetan/ecommerce-local-app.git
cd ecommerce-local-app
```

### Step 2: Install Required Tools

**Option 1: Automated (Recommended)**
```bash
bash install-prerequisites.sh
```

**Option 2: Manual** — install Git, Docker, Node.js 20+, and AWS CLI v2 individually for your OS.

### Step 3: Verify

```bash
aws --version
docker --version
node --version
git --version
```

---

## Deployment Steps

### 1. Set Up AWS Cognito

Create a Cognito User Pool for authentication:

1. Go to **AWS Cognito Console** → **User pools** → **Create user pool**
2. **Define your application**: Select **Single-page application (SPA)**
3. **Name your application**: Enter `ecommerce-app`
4. **Configure options**:
   - **Sign-in identifiers**: Select **Email**
   - **Self-registration**: Enable
   - **Required attributes for sign-up**: Select **email** and **name**
5. **Add a return URL**: `http://localhost:3000`
6. Click **Create user directory**
7. Go to your User Pool → **App integration** tab → **App clients** → click your app client
8. Under **Authentication flows**, enable:
   - ✅ **ALLOW_USER_PASSWORD_AUTH**
   - ✅ **ALLOW_USER_SRP_AUTH**
   - ✅ **ALLOW_REFRESH_TOKEN_AUTH**
9. Click **Save changes**

Note down:
- **User Pool ID** (e.g., `ap-south-1_xxxxxxxxx`)
- **App Client ID** (e.g., `1a2b3c4d5e6f7g8h9i0j1k2l3m`)

### 2. Configure Frontend

Edit `frontend/react-app/src/aws-config.js`:

```javascript
const awsConfig = {
  Auth: {
    Cognito: {
      userPoolId: 'ap-south-1_xxxxxxxxx',
      userPoolClientId: '1a2b3c4d5e6f7g8h9i0j1k2l3m',
      loginWith: {
        email: true,
      },
    }
  }
};
```

### 3. Start Backend Services

```bash
cd local-deployment
AWS_REGION=<region> docker-compose up -d

# Example:
AWS_REGION=ap-south-1 docker-compose up -d
```

> **Note:** Use `docker-compose` (v1) or `docker compose` (v2 plugin) depending on your Docker installation.

> This may take 5-10 minutes on first run (image pulls + builds).

This starts:
- LocalStack (DynamoDB, SNS, SQS, SES)
- PostgreSQL
- 5 microservices (product, cart, user, order, notification)
- Nginx (API gateway on port 8080)

**Verify all containers are running:**
```bash
docker ps
```

Expected output:
```
CONTAINER ID   IMAGE                                   PORTS
...            nginx:alpine                            0.0.0.0:8080->80/tcp
...            local-deployment-order-service          0.0.0.0:8004->8004/tcp
...            local-deployment-user-service           0.0.0.0:8003->8003/tcp
...            local-deployment-cart-service           0.0.0.0:8002->8002/tcp
...            local-deployment-notification-service
...            local-deployment-product-service        0.0.0.0:8001->8001/tcp
...            localstack/localstack:latest            0.0.0.0:4566->4566/tcp
...            postgres:15-alpine                      0.0.0.0:5433->5432/tcp
```

### 4. Load Product Data

```bash
cd local-deployment/data
bash load-products-local.sh
```

This loads 20 sample products into local DynamoDB.

### 5. Start Frontend

```bash
cd frontend/react-app
npm install
npm start
```

Frontend runs on http://localhost:3000

### 6. Test the Application

1. Open http://localhost:3000
2. Sign up with email/password
3. Browse products
4. Add items to cart
5. Place an order
6. Check the **Orders** tab
7. Check order notification — a file is created under `local-deployment/emails/`:

```
To: user@example.com
Subject: Order Confirmation - #1

Order Confirmation
Thank you for your order!

Order ID: 1
Total Amount: $299.97

Items:
- Product: prod-015, Quantity: 1, Price: $19.99
- Product: prod-016, Quantity: 1, Price: $249.99
- Product: prod-012, Quantity: 1, Price: $29.99
```

## API Endpoints

All APIs available at `http://localhost:8080/api`:

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/products` | List all products |
| GET | `/api/cart` | Get user's cart |
| POST | `/api/cart/items` | Add item to cart |
| GET | `/api/users/profile` | Get user profile |
| POST | `/api/users/profile` | Create profile |
| GET | `/api/orders` | List user's orders |
| POST | `/api/orders` | Create new order |

## Development

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f product-service
```

### Rebuild a Service

```bash
docker-compose up -d --build <service-name>
```

### Access Databases

```bash
# PostgreSQL
docker-compose exec postgres psql -U postgres -d ecommercedb

# DynamoDB (via AWS CLI)
AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test \
  aws dynamodb scan --table-name ecommerce-products \
  --endpoint-url http://localhost:4566 --region <region>
```

## Troubleshooting

**LocalStack not ready** — wait a few seconds and retry; check `docker compose logs localstack`

**Images not loading** — verify nginx: `curl -I http://localhost:8080/images/prod-001.jpg`

**Products table empty** — re-run the load script from step 4

## Clean Up

```bash
cd local-deployment
docker-compose down -v
```

This removes all containers and volumes.
