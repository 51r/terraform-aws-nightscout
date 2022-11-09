# Deploy Nightscout in AWS by using Terraform

This repo can be used to deploy immutable Nightscout Docker container in T2.nano EC2 instance by using Terraform automation. 

The Nightscout image is from my [Docker Repo](https://hub.docker.com/r/51rspasov/cgm-nightscout) and it contains modified Nightscout version [14.2.6](https://github.com/nightscout/cgm-remote-monitor/releases/tag/14.2.6) for easy AWS deployment.

# Prerequisite
[Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli) >= v1.3.1 installed on you workstation. 
[MongoDB](cloud.mongodb.com) instance with M0 sandbox (The Free tier)
[AWS Account](aws.amazon.com) 

# How to use the repo

* Clone this repo locally to a folder of your choice
```
git clone https://github.com/51r/terraform-aws-nightscout.git
```

* Make sure you are in the main directory of the repo:

```
cd terraform-aws-nightscout
```

* Make sure you have allowed Terraform to access your IAM user credentials, set your AWS access key ID as an environment variable
```
export AWS_ACCESS_KEY_ID="<YOUR_AWS_ACCESS_KEY_ID>"
```

* Then set your secret key:
```
export AWS_SECRET_ACCESS_KEY="<YOUR_AWS_SECRET_ACCESS_KEY>"
```

# Configuration:

Mandatory:

Modify the init.sh script file:

1. Under #Configuring NginX reverse proxy, you have to specify your domain:

	server_name cgm.example.com;
  
2. Add your MongoDB_URI, MongoDB_DB name and your API_Secret to the docker command:

```
docker run -e "MONGODB_URI=your-mongodb-URI" -e "MONGODB_DB=your-database-name" -e "API_SECRET=your-api-secret" --name 51r-nightscout -p 1337:1337 -d 51rspasov/cgm-nightscout 
```

The MONGODB_URI should be something similar:

```
"MONGODB_URI=mongodb+srv://user:password@your-cluster.mongodb.net/database-name?retryWrites=true&w=majority"
```

IMPORTANT:

In case you want to use it with Shuggah, you will need to issue a SSL certificate, which can be done for free by LetsEncrypt. I have included a script in the configuration, that automatically issues certificate after 5 minutes (300 seconds). You only need to replace your-domain (e.g. domain.com) to the command:

```
(sleep 300; echo 'Triggering certbot' ; sudo certbot --nginx --register-unsafely-without-email --agree-tos -n  -d your-domain)  &
```

If you need more time, you can adjust the sleep command to more or less seconds. I have configured my subdomain TTL to be 1 minute, and it propagates for less than 5 minutes and it is enough for me.

Optional:

If you wish you can modify the region in which the EC2 instance will be deployed. I have used eu-central-1 (Frankfurt) as it is closest to me. Keep in mind that if you change the AWS Region, you will need to supply new AMI, that is available in the region.

# Deployment:

* Initialize the Terraform:
```
terraform init
```

You should see the following message:
```
Terraform has been successfully initialized!
```

* Apply the plan which terraform is going to execute based on our configuration
```
terraform apply
```

* Terraform will output your public-ip. Use it to enter it as an A record to your DNS records, you have 5 minutes to do it, since the LE certbot will be triggered and will issue the certificate, so you can use the Nightscout over HTTPS(443 port).

# QA:

Do not hesitate to open a Issue in the repo if you have questions or you have troubles with the installation. 
