#!/bin/bash
set -e

# NGINX
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y nginx
echo "Hello World from host" $HOSTNAME "!" | sudo tee -a /var/www/html/index.html

sudo touch /etc/nginx/nginx.conf
# TODO idempotent
sudo tee -a /etc/nginx/nginx.conf <<EOF
stream {
	upstream dns_servers {
		server 168.63.129.16:53;
	}

	server {
		listen x.x.x.x:53  udp;
		listen x.x.x.x:53; #tcp
		proxy_pass dns_servers;
		proxy_responses 1;
		error_log  /var/log/nginx/dns.log info;
	}
}
EOF

myip=`hostname -i | cut -d ' ' -f1`
sudo sed -i "s/x.x.x.x/$myip/" /etc/nginx/nginx.conf


sudo nginx -t && sudo service nginx reload
