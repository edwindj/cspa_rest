#!/usr/bin/env bash

# Install R
echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" > /etc/apt/sources.list.d/r.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

apt-get update

apt-get install -y r-base-dev r-base 
apt-get install -y nodejs npm vim

R -e "install.packages(c('editrules','docopt', 'rspa', 'jsonlite'), repos='http://cran.rstudio.com/')"

# get latest cspa_rest version
wget http://github.com/edwindj/cspa_rest/archive/master.zip
unzip master.zip
# rename it to cspa_rest
mv cspa_rest-master cspa_rest
rm master.zip

cd cspa_rest
npm install
nodejs server.js&
