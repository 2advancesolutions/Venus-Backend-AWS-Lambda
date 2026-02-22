"""
AWS Lambda function to return a list of users.
"""
import json
from typing import Dict, Any, List
from datetime import datetime


def get_users() -> List[Dict[str, Any]]:
    """
    Return a list of mock users.
    In production, this would query a database (DynamoDB, RDS, etc.)
    """
    users = [
        {
            "id": "1",
            "username": "john.doe",
            "email": "john.doe@example.com",
            "first_name": "John",
            "last_name": "Doe",
            "created_at": "2024-01-15T10:30:00Z",
            "is_active": True
        },
        {
            "id": "2",
            "username": "jane.smith",
            "email": "jane.smith@example.com",
            "first_name": "Jane",
            "last_name": "Smith",
            "created_at": "2024-02-20T14:45:00Z",
            "is_active": True
        },
        {
            "id": "3",
            "username": "bob.johnson",
            "email": "bob.johnson@example.com",
            "first_name": "Bob",
            "last_name": "Johnson",
            "created_at": "2024-03-10T09:15:00Z",
            "is_active": False
        },
        {
            "id": "4",
            "username": "alice.williams",
            "email": "alice.williams@example.com",
            "first_name": "Alice",
            "last_name": "Williams",
            "created_at": "2024-03-25T16:20:00Z",
            "is_active": True
        }
    ]
    return users


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    AWS Lambda handler function.
    
    Args:
        event: API Gateway event or direct invocation event
        context: Lambda context object
        
    Returns:
        API Gateway compatible response with user list
    """
    try:
        # Get users
        users = get_users()
        
        # Prepare response
        response_body = {
            "success": True,
            "count": len(users),
            "users": users,
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }
        
        # Return API Gateway compatible response
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",  # CORS support
                "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                "Access-Control-Allow-Methods": "GET,OPTIONS"
            },
            "body": json.dumps(response_body)
        }
        
    except Exception as e:
        # Error handling
        error_response = {
            "success": False,
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }
        
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps(error_response)
        }
