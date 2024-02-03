#!/bin/zsh
# Script will:
# Pass the parameters to the test function


QS1="url=https://news.ycombinator.com&name=hackernews"
QS2="url=https://news.ycombinator.com"
QS1="url=https://news.ycombinator.com&name=hackernews"

# adding a filename
QS2="url=https://news.ycombinator.com&name=hackernews-latest"

# Define the expected JSON response
ER1='{"title":"Hacker News","s3_url":"https://storage-for-lambda-url-to-html.s3.amazonaws.com/hackernews.html"}'
ER2='{"title":"Hacker News","s3_url":"https://storage-for-lambda-url-to-html.s3.amazonaws.com/hackernews-latest.html"}'

current_script_dir=$(dirname "$0")

source "${current_script_dir}/test.zsh"