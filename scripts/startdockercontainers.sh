#https://github.com/v2tec/watchtower

#ensure this droplet owns the volume files
#sudo chown -R root:root /mnt/applicationdata

sudo docker run -d -p 8081:8081 \
  --name nexus \
  -v /mnt/applicationdata/volumes/nexus-data:/nexus-data \
  --restart unless-stopped \
  sonatype/nexus3

sudo docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart unless-stopped \
  v2tec/watchtower

sudo docker run --init -d \
  --name="home-assistant" \
  -v /mnt/applicationdata/volumes/ha:/config \
  -v /etc/localtime:/etc/localtime:ro \
  --net=host \
  --restart unless-stopped \
  homeassistant/home-assistant

#Build latest image from docker
docker build https://github.com/TinyAngryKitten/sshdDockerImage.git\#: -t sshd
sudo docker run -d \
  -p 6666:6666 \
  --name testServer \
  --restart unless-stopped \
  sshd
