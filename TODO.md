# Ideas for version 2.0

## Input resource handling

Make the node.js framework responsible for the downloading of input resources.
This makes it possible to support uniformly multiple protocols:

- http
- https
- ftp
- file

It also makes it easier to implement a new service, since they need not know how to retrieve the input resources.

## Authentication
Integrate authentication (OAuth) into the framework.


