#!/bin/zsh
# Script will:
# 1. Install the npm packages
# 2. Package the code into a archive.zip file
# 3. Copy the archive.zip file to the deploy/latest.zip
cd ../src
npm install
npm run build
mv archive.zip deploy/latest.zip 
exit_status=$?
if [ $exit_status -eq 0 ]; then
    echo "Success! You can find the latest lambda package in ../src/deploy/latest.zip"
else
    echo "Fail!"
fi
