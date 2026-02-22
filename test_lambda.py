#!/usr/bin/env python3
"""
Test script for the Lambda function locally
"""
import sys
import json
from pathlib import Path

# Add lambda directory to path
sys.path.insert(0, str(Path(__file__).parent / 'lambda' / 'users'))

from handler import lambda_handler


def test_lambda_handler():
    """Test the Lambda handler function"""
    print("🧪 Testing Lambda Handler...")
    print("=" * 50)
    
    # Mock event and context
    event = {}
    context = None
    
    # Invoke the handler
    response = lambda_handler(event, context)
    
    # Print response
    print("\n📤 Response Status Code:", response['statusCode'])
    print("\n📋 Response Headers:")
    for key, value in response['headers'].items():
        print(f"  {key}: {value}")
    
    print("\n📦 Response Body:")
    body = json.loads(response['body'])
    print(json.dumps(body, indent=2))
    
    # Validate response
    assert response['statusCode'] == 200, "Expected status code 200"
    assert 'users' in body, "Response should contain users"
    assert body['success'] is True, "Response should indicate success"
    assert body['count'] == len(body['users']), "Count should match users length"
    
    print("\n✅ All tests passed!")
    print(f"✅ Found {body['count']} users")
    
    return response


if __name__ == "__main__":
    test_lambda_handler()
