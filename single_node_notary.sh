#!/usr/bin/env bash

NOTARY_DIR="/root/notary"

sudo apt-get update -y
sudo apt-get remove docker docker-engine docker.io containerd runc -y
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common vim jq -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu b_release -cs) le"
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo git clone https://github.com/theupdateframework/notary.git $NOTARY_DIR

sudo docker-compose build -f $NOTARY_DIR/docker-compose.yml
sudo docker-compose up -d -f $NOTARY_DIR/docker-compose.yml

sudo curl -sSfLo /usr/local/bin/notary https://github.com/theupdateframework/notary/releases/download/v0.6.1/notary-Linux-amd64
sudo chmod +x /usr/local/bin/notary

sudo cat <<\EOT > ~/.notary/config.json
{
	"trust_dir" : "~/.docker/trust",
	"remote_server": {
		"url": "https://notary-server:4443",
		"root_ca": "root-ca.crt"
	}
}
EOT

sudo docker run -d -p 5000:5000 --restart always --name registry registry:2
sudo mkdir -p ~/.docker/tls/127.0.0.1:4443/
sudo cp $NOTARY_DIR/fixtures/notary-server.crt ~/.docker/tls/127.0.0.1\:4443/ca.crt

sudo echo -e "Now run\n export DOCKER_CONTENT_TRUST_SERVER=https://127.0.0.1:4443"