# Fargate Service Infrastructure

Hello world - from Fargate!

Fargate is an AWS service that allows you to run Docker containers without managing servers. It is well-suited to, among other things, long-running jobs, use cases that require custom runtimes or dependencies, or whenever your package size exeeds the Lambda limit of 250 MB.

This repository gives you a script to set up a starter AWS Fargate service with a basic Docker image running a Flask server. 

## What You'll Get
1. A Fargate service, which consists of an ECR repository, an ECS cluster, and other related components (VPC, load balancer, etc.). Once the service is created, you can find a DNS name in the "Load Balancers" section of the EC2 console that can be used to invoke the service.
2. A new local git repository (in a directory location at the same hierarchy as the current repository). Github repository for the Docker image that will run in your Fargate service. This docker image contains a basic Flask server. When you're ready to start developing the service further, you can clone this repository or navigate to the local git repository that is created for you.
3. A CI/CD pipeline that will listen to your Github repository and deploy updates to your Fargate service.
4. A Cloudformation stack that defines all this infrastructure as code. All infrastructure updates should be made through the Cloudformation stack.

## Prerequisites
1. Install the AWS CLI.
2. Setup an AWS account.
3. Ensure you can connect to Github via SSH.
4. Create a Github personal access token.
5. Store your personal access token in AWS Secrets Manager with the name "GithubPersonalAccessToken" and the key "GithubPersonalAccessToken".

## Setup and Running
1. The driver for all of this is a script called "fargate-service.sh". If you are running this for the first time, be sure to update all the environment variables at the top of the script (e.g., AWS Account ID).
2. The script accepts two arguments: "create" or "update."  
    1. If you are running this for the first time to create a new Fargate service, pass in "create," e.g., "./fargate-service.sh create".
    2. If you have already run the script to set up your infrastructure, but need to update the infrastructure, modify the "infrastructure_cloudformation.template.yml" file as desired, and run "./fargate-service.sh update".



# Credits
This is heavily inspired by (with code sometimes lifted from):
1. https://github.com/aws-samples/aws-modern-application-workshop


# Opportunities for Enhancement
1. A proper cli for the setup/update operations.
