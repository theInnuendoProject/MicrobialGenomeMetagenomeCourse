## YOUR COMPUTER

# Connect to VM
ssh -i </path/to/provided/private/ssh/key/mgmc.key> cloud-user@<VM.IP.193.166.24.142>
# SSH key produced with
# ssh-keygen -t rsa -f /home/cloud-user/mgmc.key



## VM

# Give colour to your console
# Edit ~/.bashrc
# Uncomment 
# force_color_prompt=yes

# Install Docker
# https://www.docker.com/
# Get Docker > For Servers > Ubuntu
# https://store.docker.com/editions/community/docker-ce-server-ubuntu
:'
sudo apt-get remove docker docker-engine docker.io
sudo apt-get update
sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
# key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce

sudo docker run hello-world
'
# Run Docker without type sudo
# Google search: docker avoid sudo
# https://askubuntu.com/questions/477551/how-can-i-use-docker-without-sudo
:'
sudo groupadd docker
sudo gpasswd -a $USER docker
# log out/in to activate the changes to groups

docker run hello-world
'

# Install getSeqENA
# https://github.com/B-UMMI/getSeqENA
#
# Install dependencies
# Aspera Connect
# http://downloads.asperasoft.com/connect2/
# See all installers > Linux > Linux - Select Version > Direct download
# Copy Link Location (Direct download)
wget <copied.link>
# Add Aspera Connect bin folder to PATH environment
# Google search: add path to PATH linux
# https://unix.stackexchange.com/questions/26047/how-to-correctly-add-a-path-to-path
:'
wget http://download.asperasoft.com/download/sw/connect/3.7.4/aspera-connect-3.7.4.147727-linux-64.tar.gz
tar xf aspera-connect-3.7.4.147727-linux-64.tar.gz
bash aspera-connect-3.7.4.147727-linux-64.sh
echo "export PATH=$HOME/.aspera/connect/bin"':$PATH' >> ~/.profile
'
# NCBI SRA Toolkit
# https://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?view=software
# Ubuntu Linux 64 bit architecture
# Copy Link Location (Ubuntu Linux 64 bit architecture)
wget <copied.link>
# Add SRA Toolkit bin folder to PATH environment
:'
wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2-1/sratoolkit.2.8.2-1-ubuntu64.tar.gz
tar xf sratoolkit.2.8.2-1-ubuntu64.tar.gz
echo "export PATH=$HOME/sratoolkit.2.8.2-1-ubuntu64/bin"':$PATH' >> ~/.profile
'
# Install getSeqENA
# Clone or download > Copy to clipboard
git clone <paste whatever is in clipboard>
# Add getSeqENA folder to PATH environment
:'
git clone https://github.com/B-UMMI/getSeqENA.git
echo "export PATH=$HOME/getSeqENA"':$PATH' >> ~/.profile
'
