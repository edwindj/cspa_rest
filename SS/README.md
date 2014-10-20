# Sample Selection service

## Command-line interface
This directory will contain the .NET 4.5 console application that can be executed from the command line.

```
Usage: CSPA.SampleSelectionWrapper.exe 
         --populationdata <populationdata>
         --populationdata_schema <populationdata_schema>
         --surveygroup <surveygroup>
         --survey <survey>
		 --output <outputpath>

Arguments:
  <populationdata>         path/url to csv file with the populationdata.
  <populationdata_schema>  path/url to json table schema file describing populationdata.
  <surveygroup>            path/url to XML file with surveygroup parameters.
  <survey>                 path/url to XML file with survey parameters.
  <outputpath>             path where SS should write the resulting sample.csv as well as it's describing json table schema.
```

## REST interface

see [swagger definition file](./swagger.yaml)

## Example

The directory `example` contains
- input data resources
- result data resources
- a job json file.