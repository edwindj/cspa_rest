#!/usr/bin/env bash
echo "deb http://cran.rstudio.com/bin/linux/ubuntu precise/" >> /etc/apt/sources.list
apt-get update

# --force-yes to handle the un-verified deb
apt-get install r-base-dev r-base -y --force-yes
apt-get install -y git nodejs npm

R -e "install.packages(c('editrules','getopt'), repos='http://cran.rstudio.com/')"

# TODO clone git repository and start nodejs server
git clone http://github.com/edwindj/cspa_rest

cd cspa_rest
npm install
npm start



