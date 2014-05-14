---
author: Jan van der Laan, Edwin de Jonge
title: REST API for CSPA service
version: 0.0
---

CSPA (ref) models statistical processes in terms of statistical services that process data
in sequence. Each processing step needs input data and configuration parameters and delivers 
output data and logging data. CSPA does not enforce an interface for services because the 
partners are working on different platforms. One of proposed architectures is REST: 
representational State Transfer. 

RESTful application uses HTTP request to post data (create and /or update), read data, and 
delete data. REST uses HTTP for CRUD (Create Read Update and Delete) operations. All state is 
modelled as resources.

In this document we model a REST interface for CSPA services.
A processing step is modelled as a job resource located at the service. 

A job resource contains:

- name: Human readable name of calling process
- id: unique URL to this job.
- created: datetime (UMT)
- input:
- result:
	- Data resources: URL endpoints to input data, that are to be retrieved using GET by 
	the service
	- Configuration parameters: 

    - Simple type (string, integer, float) as value

  - URL endpoint to complex configuration objects.

o Data resources: URL endpoints to generated output data that are to be serviced by 

the service. (in the future this might be on a different server, but for now it is local 

on the service)

- status: [“created”, “running”, “finished”, “failed”]

- started: datetime

- finished: datetime


Creating a job at service runs a processing step and creates output resources that will be served by

the service.

Resources:

- Job:

`http://example.com/service`

This is the place where new jobs can be submitted to the service.

### Available methods

POST Creates a new job. On success result code 201 is returned with a link to the newly created job. 

POST message format
```
<job>
 [one could image additional information about e.g. job and submitter here 

 such as description and email]

 <serviceparams>

 <data ref="http://somewhere.org/data" type="application/json"/>

 <rules ref="http://somewhere.org/rules" type="text"/>

 </serviceparams>

</job>
```
 

`http://example.com/service/help`

Available methods

`GET` Returns information on how to use the service. 

`http://example.com/service/jobs/1234`

### Available methods

`GET` Returns information on the status of the job and when available returns links to the output data. 

`DELETE` Cancels the job and deletes all data belonging to the job from the service. 


Output message
```
<job>
 <status>running/finished/error</status>
 <results>
 <logfile ref="http://example.com/service/jobs/1234/log" type="text"/>
 <dataout ref="http://example.com/service/jobs/1234/outputdata1"
 type="application/datapackage"/>
 </results>
 <serviceparams>
 <data ref="http://somewhere.org/data" type="application/json"/>
 <rules ref="http://somewhere.org/rules" type="text"/>
 </serviceparams>
</job> 
```

Where logfile and dataout are only shown when available, e.g. when the job is running or when the job is 

finished respectively.

`http://example.com/service/jobs/1234/log`

###Available methods:

`GET`: Returns logging information from the job. 

`http://example.com/service/jobs/1234/outputdata1`

Available methods

`GET` Returns the output data.
