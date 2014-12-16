# Ideas for version 2.0

## Temporary storage
Extend the frame work, so the service can specify where job info, input, and output should be stored. Currently this is in a subdirectory of the service.

## Swagger definition

Integrate/combine `service.yaml` with `swagger.json`, so the service needs to specified once.  Swagger definition should be serviced by the CSPA service

## RAML

Find out if [raml](http://raml.org) if better than swagger.

## Add an easier async REST interface

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

## Split project in logical parts
Split the project in a:

- cspa REST frame work 
- each cspa service in a separate project (using the framework) including Dockerfile

## Port mappings / Redirect server

CSPA rest services run in one or more webservers with different ips and ports. For easy deployment and robust software it is
wise to manage urls to ip:port centrally. Maybe implement a simple redirect service?

e.g. 
`http://cspa.<name of nsi>.<country>/LRC` redirects to `http://xxx.xxx.xxx/LRC:8080` and `http://cspa.<name of nsi>.<country>/LEL` to `http://xxx.xxx.yyyy/LRC:8081`

## Deployment archictecture

Multiple options:

1. 1 (docker) image (server), 1 web server with multiple services. 
   
   - Advantage: simple, no port mappings and redirection necessary. 
   - Disadvantage: not scalable. 
2. 1 (docker) image (server), each service it's own web server. 

   - Advantage: isolated services, low resources
   - disadvantage: port mappings needed (webservers can not run on same port), not scalable
3. multiple (docker) images, each services it's own web server. 

   - Advantage: scalable, isolated, D
   - Disadvantage: more complex management, resource hungry, each image has complete installation (may be shared).
