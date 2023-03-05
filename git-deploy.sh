#!/bin/sh

echo "Add files and do local commit"
git add .
git commit -am "Terraform with Aws"

echo "Pushing to Github Repository"
git push
