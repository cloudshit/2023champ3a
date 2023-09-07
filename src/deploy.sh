#!/bin/bash
REGION="us-east-1"
ACCOUNT_ID="790946953677"

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

cd location-v1.0

docker build -t location .

docker tag location:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/location:latest

docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/location:latest

cd ../status-v1.0

docker build -t status .

docker tag status:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/status:latest

docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/status:latest

cd ../stress-v1.0

docker build -t stress .

docker tag stress:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/stress:latest

docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/stress:latest

cd ../token-v1.0

docker build -t token .

docker tag token:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/token:latest

docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/token:latest

cd ../unicorn-v1.0

docker build -t unicorn .

docker tag unicorn:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/unicorn:latest

docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/unicorn:latest
