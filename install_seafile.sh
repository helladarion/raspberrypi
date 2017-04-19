# Install docker on Raspberry Pi
curl -sSL https://get.docker.com | sh

# Create a network to setup a fixed ip address to the container
sudo docker network create --subnet 10.18.18.0/24 seafilenet

# MySql Server
#sudo docker run --name mysql -v $(pwd)/database:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mysql-server -d mysql

sudo docker run --name mysql --net seafilenet --ip 10.18.18.2 -e MYSQL_ROOT_PASSWORD=mysql-server -d rpi-mysql

# Config server
sudo docker run -it --name seafile --net seafilenet --ip 10.18.18.3 -p 10001:10001 -p 12001:12001 -p 8000:8000 -p 8080:8080 -p 8082:8082 -v $(pwd)/rafacloud:/opt/seafile -e autostart=false jenserat/seafile /bin/bash

# AutoStart server after configured
sudo docker run -d --name seafile --net seafilenet --ip 10.18.18.3 -p 10001:10001 -p 12001:12001 -p 8000:8000 -p 8080:8080 -p 8082:8082 -v $(pwd)/rafacloud:/opt/seafile -e autostart=true jenserat/seafile


sudo docker run -d --name seafile \
    --net seafilenet --ip 10.18.18.3 \
    -p 10001:10001 \
    -p 12001:12001 \
    -p 8000:8000 \
    -p 8080:8080 \
    -p 8082:8082 \
    -e SEAFILE_NAME=RafaCloud \
    -e SEAFILE_ADDRESS=rafael.dnsfor.me \
    -e SEAFILE_ADMIN=helladarion@gmail.com \
    -e SEAFILE_ADMIN_PW=b7B3w5h6 \
  -e MYSQL_SERVER=10.18.18.2 \
  -e MYSQL_USER=seafile \
  -e MYSQL_USER_PASSWORD=seafile \
  -e MYSQL_ROOT_PASSWORD=mysql-server \
    -v $(pwd):/seafile \
  m3adow/seafile
  yuriteixeira/rpi-seafile
