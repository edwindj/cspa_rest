#!/usr/bin/env bash

# Install R
echo "deb http://cran.rstudio.com/bin/linux/ubuntu saucy/" > /etc/apt/sources.list.d/r.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

apt-get update

apt-get install -y r-base-dev r-base 
apt-get install -y git nodejs npm

R -e "install.packages(c('editrules','getopt'), repos='http://cran.rstudio.com/')"

# TODO clone git repository and start nodejs server
git clone http://github.com/edwindj/cspa_rest

cd cspa_rest
npm install
npm start



