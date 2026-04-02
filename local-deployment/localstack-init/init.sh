#!/bin/bash

echo "Initializing LocalStack resources..."

# Get region from environment variable, default to us-east-1
AWS_REGION=${AWS_REGION:-us-east-1}
echo "Using AWS region: $AWS_REGION"

# Wait for LocalStack to be ready
echo "Waiting for LocalStack to be ready..."
until awslocal dynamodb list-tables --region $AWS_REGION > /dev/null 2>&1; do
    echo "LocalStack not ready yet, retrying in 2s..."
    sleep 2
done
echo "LocalStack is ready!"

# Create DynamoDB tables
echo "Creating DynamoDB tables..."

awslocal dynamodb create-table \
    --table-name ecommerce-products \
    --attribute-definitions AttributeName=product_id,AttributeType=S \
    --key-schema AttributeName=product_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $AWS_REGION 2>/dev/null || echo "Table ecommerce-products already exists, skipping."

awslocal dynamodb create-table \
    --table-name ecommerce-cart \
    --attribute-definitions AttributeName=user_id,AttributeType=S \
    --key-schema AttributeName=user_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $AWS_REGION 2>/dev/null || echo "Table ecommerce-cart already exists, skipping."

# Create SNS topic
echo "Creating SNS topic..."
awslocal sns create-topic --name order-events --region $AWS_REGION

# Create SQS queue
echo "Creating SQS queue..."
awslocal sqs create-queue --queue-name notification-queue --region $AWS_REGION

# Subscribe SQS to SNS
echo "Subscribing SQS to SNS..."
awslocal sns subscribe \
    --topic-arn arn:aws:sns:$AWS_REGION:000000000000:order-events \
    --protocol sqs \
    --notification-endpoint arn:aws:sqs:$AWS_REGION:000000000000:notification-queue \
    --region $AWS_REGION

echo "LocalStack initialization complete!"
