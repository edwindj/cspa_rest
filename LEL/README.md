# Linear Error Localization Service

## Command line interface
This directory contains the R script `LEL.R' that can be executed from the command line.

```
Usage: LEL.R --adapt=<file> --status=<file> <data> <rules> [<data_schema> <weights>]

Options:
  --adapt=<file>   csv file in which the error for each record of 'data' will be written.
  --status=<file>  csv file in which the status for each record of 'data' will be written.

Arguments:
  <data>        path/url to csv file with data to be checked.
  <rules>       path/url to text file with linear edit rules to be used.
  <data_schema> path url to json table schema file describing the structure
  <weights>     path url to csv file with weights per record/per column. 
                If the csv file contains one row, all records will have the
                same weights.
```

## REST interface

See [Swagger definition file](./swagger.yaml)

## Example

The directory `example` contains
- input data resources
- result data resources
- a job json file.


