#!/bin/bash

# Variables
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
NAMESPACE="default"                  # Default namespace for QuickSight
NEXT_TOKEN=""                        # For pagination

# Function to update users to ADMIN_PRO role
update_user_role() {
    local username=$1
    local email=$2
    
    echo "Updating user: $username to ADMIN_PRO"
    aws quicksight update-user \
        --aws-account-id "$AWS_ACCOUNT_ID" \
        --user-name "$username" \
        --namespace "$NAMESPACE" \
        --email "$email" \
        --role "ADMIN_PRO"
}

# Function to list and process users
process_users() {
    while :; do
        echo "Fetching users..."
        
        # Fetch users with pagination
        if [ -z "$NEXT_TOKEN" ]; then
            RESPONSE=$(aws quicksight list-users \
                --aws-account-id "$AWS_ACCOUNT_ID" \
                --namespace "$NAMESPACE")
        else
            RESPONSE=$(aws quicksight list-users \
                --aws-account-id "$AWS_ACCOUNT_ID" \
                --namespace "$NAMESPACE" \
                --next-token "$NEXT_TOKEN")
        fi

        # Extract user information from the response
        USERS=$(echo "$RESPONSE" | jq -c '.UserList[]')
        
        for USER in $USERS; do
            USERNAME=$(echo "$USER" | jq -r '.UserName')
            EMAIL=$(echo "$USER" | jq -r '.Email')
            ROLE=$(echo "$USER" | jq -r '.Role')
            
            # Only update if the user is not already an ADMIN_PRO
            if [ "$ROLE" != "ADMIN_PRO" ]; then
                update_user_role "$USERNAME" "$EMAIL"
            else
                echo "User $USERNAME is already an ADMIN_PRO. Skipping."
            fi
        done

        # Check for pagination token
        NEXT_TOKEN=$(echo "$RESPONSE" | jq -r '.NextToken')
        
        if [ "$NEXT_TOKEN" == "null" ]; then
            break
        fi
    done
}

# Main script execution
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is required but not installed. Please install it and try again."
    exit 1
fi

process_users

echo "All users have been processed."
