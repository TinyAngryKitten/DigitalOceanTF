#https://github.com/v2tec/watchtower

#ensure this droplet owns the volume files
#sudo chown -R root:root /mnt/applicationdata

sudo docker run -d -p 8081:8081 --name nexus -v /mnt/applicationdata/volumes/nexus-data:/nexus-data sonatype/nexus3
sudo docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  v2tec/watchtower

#Build latest image from docker
docker build https://github.com/TinyAngryKitten/sshdDockerImage.git\#: -t sshd
sudo docker run -d -p 6666:6666 --name testServer sshd
