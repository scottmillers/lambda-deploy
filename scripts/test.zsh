#!/bin/zsh
# Script will:
# 1. Call the live alias lambda with parameters
# 2. Verify the results are what is expected






# Function to compare the response with the expected value
compare_response() {
    local response=$1
    local expected_response=$2

    if [[ "$response" == "$expected_response" ]]; then
        echo "Success! Response matches the expected value"
    else
        echo "Fail! Response does not match the expected value"
    fi
     echo "Here is the response: $response"
}

# load the variables
MYDIR="$(dirname "$(readlink -f "$0")")"

source $MYDIR/variables.zsh

# Define the URL of the Lambda Public endpoint to call
url="$LIVE_ALIAS_URL?$QS1"

# Call the URL and retrieve the JSON response
response=$(curl -s "$url")

# Call the function with the response and response1
compare_response "$response" "$ER1"

# Define the URL of the Lambda Public endpoint to call
url="$LIVE_ALIAS_URL?$QS2"

# Call the URL and retrieve the JSON response
response=$(curl -s "$url")

# Call the function with the response and response1
compare_response "$response" "$ER2"