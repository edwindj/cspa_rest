---
author: "Jan van der Laan, Edwin de Jonge"
title: REST API for CSPA service
version: 0
published: true
---

CSPA (ref) models statistical processes in terms of statistical services that process data in sequence. Each processing step needs input data and configuration parameters and delivers output data and logging data. CSPA does not enforce an interface for services because the partners are working on different platforms. One of proposed architectures is REST: representational State Transfer. 

RESTful application uses HTTP request to post data (create and /or update), read data, and delete data. REST uses HTTP for CRUD (Create Read Update and Delete) operations. All state is modelled as resources.

In this document we model a REST interface for CSPA services.
A processing step is modelled as a job resource located at the service. 

A job resource contains:
- *name*: Human readable name of calling process
- *id*: job id to be used in querying the job properties.
- *ref*: (unique) URL to this job (includes job id)
- *created*: datetime (UMT)
- *input*:
	- Data resources: URL endpoints to input data, that are to be retrieved using GET by 
	the service
	- Configuration parameters: 
    	- Simple type (string, integer, float) as value
  		- URL endpoint to complex configuration objects.
- *result*:
	Data resources: URL endpoints to generated output data that are to be serviced by the service. (in the future this might be on a different server, but for now it is local on the service)
- *status*: ["created", "scheduled", "running", "finished", "failed"]
- *started*: datetime
- *finished*: datetime

Creating a job at service runs a processing step and creates output resources that will be served by the service.

Resources:
- `/job`
	CREATE, READ and DELETE jobs
- `/help`
	Human readable help describing input and output parameters.
- `/example`
    Shows a working test example for this service.
    
This is the place where new jobs can be submitted to the service.

## /job

`POST` Creates a new job. On success result http status code 201 is returned with a url to the newly created job.

`POST` message format (in JSON) depends on the service definition of the CSPA service. The input part must equal the parameters that are needed for a particalur service.
```json
{ "input" : {
      "data": "http://allthedatayouneed.com/mydata",
      ...
  },
  "name" : "TheCallingProcess" //name of the calling process
}
```

`GET` Retrieves all active jobs

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

## `/job/<id>/result/<parameter>`
`GET`: Returns the specific resource that was generated after the job has started. May return "not available" when job is not finished

Example:
```
http://example.com/service/job/1234/result
```
Format: depends on service

## `/job/<id>/log`

`GET`: Returns specific logging information from the job. 

Example:
```
http://example.com/service/jobs/1234/log
```
# Open ends

We currently do not address:
- resource management. Services in this design are responsible for the created output. However in a next version this responsibility may be delegated to a resource management system.
- data transformation, selection and filtering. It is up to the orchestrator/caller for the service to supply the input data in the correct format and syntax. 
However this may be a general service to transform/select data, which may be combined with the resource manager (it may be implemented as transformation, mapping of filtering query on a resource.
