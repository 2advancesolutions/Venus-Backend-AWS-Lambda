#!/bin/bash

# Deployment script for Venus Users Lambda Function
# Usage: ./deploy.sh [serverless|terraform|aws-cli]

set -e

DEPLOYMENT_METHOD=${1:-serverless}

echo "🚀 Venus Lambda Deployment Script"
echo "=================================="
echo "Deployment method: $DEPLOYMENT_METHOD"
echo ""

case $DEPLOYMENT_METHOD in
  serverless)
    echo "📦 Deploying with Serverless Framework..."
    
    # Check if serverless is installed
    if ! command -v serverless &> /dev/null; then
        echo "❌ Serverless Framework not found. Installing..."
        npm install -g serverless
    fi
    
    # Check if plugin is installed
    if [ ! -d "node_modules/serverless-python-requirements" ]; then
        echo "📥 Installing serverless-python-requirements plugin..."
        npm install --save-dev serverless-python-requirements
    fi
    
    # Deploy
    echo "🚀 Deploying to AWS..."
    serverless deploy --stage dev --verbose
    
    echo ""
    echo "✅ Deployment complete!"
    echo "📝 Run 'serverless info' to see endpoint details"
    ;;
    
  terraform)
    echo "🏗️  Deploying with Terraform..."
    
    cd infrastructure
    
    # Initialize Terraform
    echo "🔧 Initializing Terraform..."
    terraform init
    
    # Create build directory
    mkdir -p ../.build
    
    # Plan
    echo "📋 Planning deployment..."
    terraform plan -out=tfplan
    
    # Apply
    echo "🚀 Applying Terraform configuration..."
    terraform apply tfplan
    
    # Output results
    echo ""
    echo "✅ Deployment complete!"
    terraform output
    
    cd ..
    ;;
    
  aws-cli)
    echo "⚙️  Deploying with AWS CLI..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        echo "❌ AWS CLI not found. Please install it first."
        exit 1
    fi
    
    cd lambda/users
    
    # Create deployment package
    echo "📦 Creating deployment package..."
    rm -f function.zip
    zip -r function.zip handler.py
    
    # Check if function exists
    FUNCTION_NAME="venus-get-users-dev"
    
    if aws lambda get-function --function-name $FUNCTION_NAME 2>/dev/null; then
        echo "🔄 Updating existing function..."
        aws lambda update-function-code \
            --function-name $FUNCTION_NAME \
            --zip-file fileb://function.zip
    else
        echo "❌ Function does not exist. Please create it first with proper IAM role."
        echo "Example:"
        echo "aws lambda create-function \\"
        echo "  --function-name $FUNCTION_NAME \\"
        echo "  --runtime python3.11 \\"
        echo "  --role YOUR_IAM_ROLE_ARN \\"
        echo "  --handler handler.lambda_handler \\"
        echo "  --zip-file fileb://function.zip"
        exit 1
    fi
    
    echo ""
    echo "✅ Deployment complete!"
    
    cd ../..
    ;;
    
  *)
    echo "❌ Unknown deployment method: $DEPLOYMENT_METHOD"
    echo "Usage: ./deploy.sh [serverless|terraform|aws-cli]"
    exit 1
    ;;
esac

echo ""
echo "🧪 Test the function:"
echo "curl \$(YOUR_API_ENDPOINT)/users"
