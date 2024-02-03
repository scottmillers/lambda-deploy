#!/bin/zsh
# Script will:
# 1. Make a version of the latest Lambda function
# 2. Point the live alias to it

MYDIR="$(dirname "$(readlink -f "$0")")"

source $MYDIR/variables.zsh


# Create a new version of the Lambda function
new_version=$(aws lambda publish-version --region $REGION --function-name $FUNCTION_NAME | jq -r '.Version')

# Update the live alias to point to the new version
aws lambda update-alias --region $REGION --function-name $FUNCTION_NAME --name $LIVE_ALIAS_NAME --function-version $new_version
