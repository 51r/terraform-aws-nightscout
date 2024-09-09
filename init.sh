#!/bin/bash
apt update
apt-get install apt-transport-https ca-certificates curl software-properties-common

#installing Docker and nginx
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce
apt install -y nginx

#Configuring NginX reverse proxy

echo 'server {
	server_name your-domain;
location / {
        proxy_pass http://127.0.0.1:1337;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
'| tee /etc/nginx/sites-available/server.conf

# enable server
ln -s /etc/nginx/sites-available/server.conf /etc/nginx/sites-enabled/

#disable default server nginx
rm /etc/nginx/sites-enabled/default

#install certbot
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

#Restart nginx services
service nginx reload

#Start Docker
systemctl start docker
systemctl enable docker

#Adding user for Docker
groupadd docker
usermod -aG docker ubuntu

#Start Nightscout Container
docker pull 51rspasov/cgm-nightscout
docker run -e "MONGODB_URI=your-mongodb-URI" -e "MONGODB_DB=your-database-name" -e "API_SECRET=your-api-secret" --name 51r-nightscout -p 1337:1337 -d 51rspasov/cgm-nightscout 

#Install certbot for the domain below after 5 minutes
(sleep 300; echo 'Triggering certbot' ; sudo certbot --nginx --register-unsafely-without-email --agree-tos -n  -d your-domain)  &
