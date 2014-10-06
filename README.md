## Designing a REST interface for CSPA command line services
This repo contains two services for the common statistical processing architecture.

- Linear Rule Checking (LRC), for checking records for validity
- Linear Error Localization (LEL), for finding erronuous values in records, given a set of restrictions.

Both services can be run as command-line tools (CLI) or via a Web API- REST interface.

## To install

There are (at least) three options for installing the services:

- By running a prebuild [docker](http://docker.io)  image (edwindj/cspa-rest).
- By downloading the repo and installing software on Windows or Linux
- By using [Vagrant](https://www.vagrantup.com/), which will create an Ubuntu virtualbox VM. 


### Docker
- install [docker](http://docker.io)
- Run
```
$ sudo docker run -d -p8080:8080 edwindj/cspa-rest
```
This will start a docker container with both services running that exposes port 8080 to the OS.
The docker image is automatically build from the `vagrant/Dockerfile`.

### Complete install

- Install **R** and run
```S
R -e "install.packages('docopt','editrules', 'jsonlite','rspa')"
```
This will install R packages on which the services depend.
The command-line interface should work after this installation.

For the REST interface:
- install **[node.js](http://nodejs.org)** and **npm**, see (http://nodejs.org)
- download this [repo](http://github.com/edwindj/cspa_rest/archive/master.zip)
- Then goto the "cspa_rest/" directory and run

```
$ npm install
```

This will install nodejs dependencies for cspa_rest. (The dependencies are given in file "./packages.json")


- Run the server:

```
$ npm start
```
or (on Ubuntu)
```
$ nodejs server.js
```
### Vagrant
Alternatively you can install a VM image that contains all the software and a running CSPA service that can be tested on `localhost:8080`. 

To install you will need to install [vagrant](http://www.vagrantup.com/) and [virtualbox](https://www.virtualbox.org/).

```
$ cd vagrant
$ vagrant up
```

To test the service run:
```
$ ./LRC/example/post.sh
```


# Testing the service

- Start service
- Goto [LRC/example](LRC/example) (or [LEL/example](LEL/example), or [LEC/example](LEL/example))
- execute `post.sh`, this will `POST`  the `job.json` file and create a job (`id = 0`) in the service
- http://localhost:8080/LRC/job will show a list of current jobs
- http://localhost:8080/LRC/job/{id} will show job information


