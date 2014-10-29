# Ideas for version 2.0

## Swagger definition

Integrate/combine `service.yaml` with `swagger.json`, so the service needs to specified once.  Swagger definition should be serviced by the CSPA service

## Add an easier asyn REST interface

Add a wrapper around the job resource, so the call looks like a synchronous call, but is handled asynchronously. This is merely synthetic sugar to ease
the use of the service.

For examples see: 

- https://www.adayinthelifeof.nl/2011/06/02/asynchronous-operations-in-rest
- http://docs.jboss.org/resteasy/docs/1.1.GA/userguide/html/async_job_service.html
- https://jembiprojects.jira.com/wiki/display/RHEAPILOT/Asynchronous+RestFul+Web-Service+Endpoints

Idea: 

- When called the service return `202` in stead of `200`
- Header contains 'poll', or 'callback url'

The job interface should be kept though, since it provides a compact and complete information of the job executed.


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


