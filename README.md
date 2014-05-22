Designing a REST interface for CSPA command line services


### To install:

First install node.js and npm, see (http://nodejs.org)

Then run
```
$ npm install
```
to install dependencies.


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

# Vagrant
The directory [vagrant] contains a virtual image box that contains all the software and a running CSPA service that can be tested on `localhost:8080`

To install you will need to install `vagrant` and `virtualbox`.

```
$ cd vagrant
$ vagrant up
```

To test the service run:
```
$ ./LRC/example/post.sh
```


