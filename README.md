# Venus-Backend-AWS-Lambda

AWS Lambda function built with Python that returns a list of users.

## 📁 Project Structure

```
.
├── lambda/
│   └── users/
│       ├── handler.py          # Lambda function code
│       └── requirements.txt    # Python dependencies
├── infrastructure/
│   └── lambda.tf              # Terraform IaC configuration
├── serverless.yml             # Serverless Framework config (alternative)
└── README.md
```

## 🚀 Lambda Function

The Lambda function (`lambda/users/handler.py`) provides:
- Returns a list of mock users with id, username, email, name, and status
- API Gateway compatible response format
- CORS support for frontend integration
- Proper error handling
- Type hints (Python 3.11+)

### Response Format

```json
{
  "success": true,
  "count": 4,
  "users": [
    {
      "id": "1",
      "username": "john.doe",
      "email": "john.doe@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "created_at": "2024-01-15T10:30:00Z",
      "is_active": true
    }
  ],
  "timestamp": "2024-03-26T10:00:00Z"
}
```

## 🛠️ Deployment Options

### Option 1: Serverless Framework (Recommended for quick deployment)

```bash
# Install Serverless Framework
npm install -g serverless
npm install --save-dev serverless-python-requirements

# Deploy
serverless deploy --stage dev

# Test the endpoint
curl https://your-api-gateway-url/users
```

### Option 2: Terraform

```bash
cd infrastructure

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Deploy
terraform apply

# Get API endpoint
terraform output api_gateway_url
```

### Option 3: AWS CLI (Manual deployment)

```bash
# Create deployment package
cd lambda/users
zip -r function.zip handler.py

# Create Lambda function (replace ROLE_ARN with your IAM role)
aws lambda create-function \
  --function-name venus-get-users \
  --runtime python3.11 \
  --role YOUR_IAM_ROLE_ARN \
  --handler handler.lambda_handler \
  --zip-file fileb://function.zip

# Test invocation
aws lambda invoke \
  --function-name venus-get-users \
  --payload '{}' \
  response.json

cat response.json
```

## 🧪 Local Testing

```python
# Test the handler locally
cd lambda/users
python3 -c "
from handler import lambda_handler
import json
result = lambda_handler({}, None)
print(json.dumps(json.loads(result['body']), indent=2))
"
```

## 🔒 IAM Permissions

The Lambda function requires:
- `logs:CreateLogGroup`
- `logs:CreateLogStream`
- `logs:PutLogEvents`

Additional permissions needed if querying DynamoDB/RDS:
- `dynamodb:Query`, `dynamodb:Scan`, `dynamodb:GetItem`
- `rds:Connect` for RDS access

## 🌐 API Gateway Integration

The function is configured with:
- HTTP GET method at `/users` endpoint
- CORS enabled for frontend integration
- Proxy integration with Lambda

## 📝 Future Enhancements

- [ ] Connect to DynamoDB/RDS for real user data
- [ ] Add authentication (API Key, JWT, Cognito)
- [ ] Implement pagination for large user lists
- [ ] Add filtering and sorting query parameters
- [ ] Add input validation
- [ ] Implement caching with CloudFront/API Gateway

## 🔗 Frontend Integration

React component example:

```jsx
import { useState, useEffect } from 'react';

function UsersList() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('https://your-api-gateway-url/users')
      .then(res => res.json())
      .then(data => {
        setUsers(data.users);
        setLoading(false);
      });
  }, []);

  if (loading) return <div>Loading...</div>;

  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>
          {user.first_name} {user.last_name} ({user.email})
        </li>
      ))}
    </ul>
  );
}
```

---

Built with ❤️ by Venus 🌟
