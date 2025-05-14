#######################################################
Azar's Checkpoint Devops Homework
#######################################################


############
Prerequisites
############

1. A docker hub account and an access token
2. AWS CLI installed on the local machine, and set up with administrator privileges to the cloud
3. Terraform on the local machine
4. Git Bash on the local machine

############
General overview
############

The contents of the repository are as follows:
1. A 'Terraform' folder, which will set up our cloud infrastructure. It contains .tf files, each of which is responsible
    for one aspect of the infrastructure. For example, 'Keypair.tf' holds the generation of a keypair.
2. Two Docker files, named 'Dockerfilem1' and 'Dockerfilem2'. One for each microservice.
3. Two Python scripts, named 'm1.py' and 'm2.py'. These contain the logic for the two microservices.
4. A "requirements.txt" file that will be added to the Docker images we create, so we can run the microservices.

############
Installation guide
############

1. Clone the repository's files and upload them to a brand new repository under your control.
    1.1 This can be done multiple ways: setting up an empty repository under your user, then downloading and adding the files found in my (azargh/checkpoint) main branch
    1.2 The reason we need this is for the user to control the Github secrets. We need that to set up the CI/CD process.
2. Open Git Bash and type in 'ssh-keygen', give the key a name and generate it wherever you want.
3. Navigate to ./Terraform/Keypair.tf and replace the public key with the public key of the key you generated in step 2.
    3.1 Navigate to ./Terraform/Token.tf and replace the token with your desired secret, and remove the file (or make git not track it) so you don't upload it when pushing code or making changes.
    ### IMPORTANT NOTE ###
    The "token.tf"  file contents should NOT be public as it contains the secret token. It's only public in this repository for your (Checkpoint's) ease of use.
    In a "real" setting I would package this file as a template (with an empty value for the secret), or omit it entirely and instruct the user to fill it out or create it himself,
    as well as remove it from the tracked files on github so he does not accidentally push it and make it public.
    ### END NOTE ###
4. In the ./Terraform folder, open up a Git Bash and do terraform init then terraform apply to set up the cloud infrastructure.
    4.1. Step 4 will generate a file on the local machine: ./Terraform/ec2-dns-name.txt. We will need this later.
    4.2. It will also generate ./Terraform/lb-dns-name.txt. This is mostly for convenience.
5. Head to github and your repository (the one under your control).
    5.1 Head to settings, click on 'Secrets and Variables', then click 'Actions' in the drop down menu.
    5.2 Create the following VARIABLES:
        5.2.1 DOCKER_USERNAME = [your docker username]
    5.3 Create the following SECRETS:
        5.3.1 DOCKER_PASSWORD = [your docker access token, which can be generated here: https://app.docker.com/settings/personal-access-tokens/create]
        5.3.2 EC2_DNS_NAME = [the contents of the file "ec2-dns-name.txt" generated in step 4 and talked about in step 4.1]
        5.3.3 REMOTE_USER = [the name of the user on the EC2 instance we created in step 4. Since we're using an Ubuntu AMI, this will be 'ubuntu' by default and is what you should insert here. However, if you were to change it or change AMI in the terraform files, this would have to match the remote user.]
        5.3.4 SSH_PRIVATE_KEY = [the contents of the private key we generated in step 2.]

That's it. The installation should now be complete.

############
Usage
############

The cloud infrastructure has been created by Terraform and the Github repository has been set up.
There's 2 actions that will also be automatically set up, and they are found ./.github/workflows.
Both of them will be activated when a push is done to the main branch.
Add a comment to one of the files and push the change, or alternatively, manually run the 2 actions.

Each one of these actions will perform a CI/CD process:
CI:
    1. They will log into Docker Hub
    2. They will build the Docker image from the docker file (Dockerfilem[1 or 2]) and upload it to the docker account that we set up in installation step 5.
CD:
    1. They will ssh into the EC2 instance using the credentials we set up in installation step 5.
    2. They will pull the image uploaded in the CI process.
    3. They will attempt to remove the older image (if it exists and is running)
    4. They will launch the microservice.

After these 2 actions are complete (at least once), our entire infrastructure will be done.

To test, send a POST request to the LB's DNS name (you can get it from the file generated in installation step 4.2).
An example of such a request:
"curl -H "Content-Type: application/json" --request POST --data '{"data": {"email_timestream": "1693561101", "subject": "happy birthday"}, "token": "FAKETOKEN"}' CheckPoint-lb-123456789.us-east-1.elb.amazonaws.com"
Be sure to provide the correct token or your data will not continue on in our SQS->S3 pipeline.

############
Additional notes
############

This segment will outline things I think COULD be done better, that I was not able to do.

1. I tried for a long time to figure out a way perform the CD process without letting the github actions runner ssh into the EC2 instance, but was not able to do so.
   I even tried to set up github OIDC through terraform and while it worked I couldn't figure out the continuation on how to allow the runner access into the EC2 instance.
   I believe the solution is a private, local runner but could not implement this in time.

2. In the security group for the EC2 instance, in file ./Terraform/SecGrp.tf, there's an ingress rule that allows http from everywhere.
   It would be better to only allow http from the Checkpoint-LB-Sg security group that contains the load balancer, because
   the uses for this entire stack should be that the users only communicate with the LB and not with the instance directly.
   Unfortunately, I could not find a way to create the rule so that only Checkpoint-LB-Sg security group can access the instance through HTTP.

3. In a similar vein, the instance is ssh'able from anywhere (but only the person who is using this codebase has the private key since it's part of the installation steps)
   This ties to point (1) made above.

