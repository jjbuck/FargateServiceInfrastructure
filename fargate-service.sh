#!/usr/bin/env bash
set -e

# Update these environment variables.
export AWS_ACCOUNT_ID="784757526031"
export APP_NAME="CatsVsDogs"
export AWS_REGION="us-west-2"
export GITHUB_USER="jjbuck"
export INFRASTRUCTURE_TEMPLATE="infrastructure_cloudformation.template.yml"

# Dervied variables
export APP_NAME_LOWERCASE=$(echo ${APP_NAME} | tr "[:upper:]" "[:lower:]")
export INFRASTRUCTURE_STACK_NAME="${APP_NAME}Infrastructure"
export BUILD_BUCKET="${APP_NAME_LOWERCASE}-build"


if [ $# -eq 0 ]; then
    echo "You must specify either \"create\" or \"update\"."
    exit 1
elif [ $# -ne 1 ]; then
    echo "You must specify either \"create\" or \"update\"."
    exit 1
elif [ $1 == "create" ]; then
    # In order to set up the ECS service, we have to have an ECR repository and a docker image available.
    # Store your github personal access token in AWS secrets manager. Name the secret GithubPersonalAccessToken,
    # and set the JSON key to GithubPersonalAccessToken

    echo "Bootstrapping ${INFRASTRUCTURE_STACK_NAME}..."

    echo "Creating ECR repository ${APP_NAME_LOWERCASE}..."
    aws ecr create-repository --repository-name ${APP_NAME_LOWERCASE} 
    $(aws ecr get-login --no-include-email)

    echo "Building Docker image ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME_LOWERCASE}:latest..."
    docker build . -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME_LOWERCASE}:latest
    
    echo "Pushing Docker image ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME_LOWERCASE}:latest to ECR..."
    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME_LOWERCASE}:latest
    
    # Create new Github repository for project
    echo "Creating new Github repository ${APP_NAME}..."
    cd ../${AppName}
    git init
    touch README.md
    git add README.md
    git add Dockerfile
    git add app/*
    git commit -m "first commit"

    curl -u "$GITHUB_USER" https://api.github.com/user/repos -d "{\"name\":\"$APP_NAME\"}"

    git remote add origin git@github.com:${GITHUB_USER}/${APP_NAME}.git
    git push -u origin master

    cd -

    # Create infrastructure Cloudformation stack.
    echo "Creating CloudFormation stack ${INFRASTRUCTURE_STACK_NAME}..."
    aws cloudformation deploy --template-file ${INFRASTRUCTURE_TEMPLATE} --stack-name ${INFRASTRUCTURE_STACK_NAME} --capabilities CAPABILITY_NAMED_IAM --parameter-overrides AppNameLowercase=${APP_NAME_LOWERCASE} AppName=${APP_NAME} GithubUser=${GITHUB_USER}

    echo "Creation complete."
    echo "Your CI/CD pipeline is https://${AWS_REGION}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${AppName}Pipeline/view"
    echo "Your Cloudformation stack is https://${AWS_REGION}.console.aws.amazon.com/cloudformation/home?region=${AWS_REGION}#/stacks/stackinfo?stackId=arn%3Aaws%3Acloudformation%3A${AWS_REGION}%3A784757526031%3Astack%2F${APP_NAME_INFRASTRUCTURE}"

elif [ $1 == "update" ]; then
    # Update infrastructure Cloudformation stack.
    echo "Updating CloudFormation stack ${INFRASTRUCTURE_STACK_NAME}..."
    aws cloudformation deploy --template-file ${INFRASTRUCTURE_TEMPLATE} --stack-name ${INFRASTRUCTURE_STACK_NAME} --capabilities CAPABILITY_NAMED_IAM --parameter-overrides AppNameLowercase=${APP_NAME_LOWERCASE} AppName=${APP_NAME} GithubUser=${GITHUB_USER}

    echo "Update complete."
    echo "Your Cloudformation stack is https://${AWS_REGION}.console.aws.amazon.com/cloudformation/home?region=${AWS_REGION}#/stacks/stackinfo?stackId=arn%3Aaws%3Acloudformation%3A${AWS_REGION}%3A784757526031%3Astack%2F${APP_NAME_INFRASTRUCTURE}"
else
    echo "You must specify either \"create\" or \"update\"." 
fi










# Setup Github OAUTH credentials through CLI. Will need to modify by hand
# aws codebuild list-source-credentials





