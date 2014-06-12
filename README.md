Designing a REST interface for CSPA command line services


### To install:

First install **node.js** and **npm**, see (http://nodejs.org)

Then goto the "cspa_rest/" directory and run
```
$ npm install
```
This will nodejs dependencies for cspa_rest. (The dependencies are given in file "./packages.json")


Install **R** and run
```S
R -e "install.packages('getopt','editrules','whisker')"
```
This will install R packages on which the services depend.


###To run the server:

```
$ npm start
```
or (on Ubuntu)
```
$ nodejs server.js
```

###Services
Directory [LEL](LEL)  and [LRC](LRC) contain services for Error Localization and Rule Checking.

# Testing the service

- Start service
- Goto [LRC/example](LRC/example) (or [LEL/example](LEL/example), or [LEC/example](LEL/example))
- execute `post.sh`, this will `POST`  the `job.json` file and create a job (`id = 0`) in the service
- http://localhost:8080/LRC/job/0 will show the job information
- http://localhost:8080/LRC/job/0/result/checks will return the output data.
- http://localhost:8080/LRC/job/0/log will return the logging information


## Vagrant
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


