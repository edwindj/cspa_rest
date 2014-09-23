# Linear Rule Checking service

## Command line interface
This directory contains the R script `LRC.R' that can be executed from the command line.

```
Usage: LRC.R <data> <rules> [<data_schema>] --output=<file>

Options:
  -o <file>, --output <file> output path where LRC should write the results in CSV format.

Arguments:
  <data>  path/url to csv file with data in csv format to be checked.
  <rules> path/url to text file with linear data rules that should be run on data.
  <data_schema> path/url to json table schema file describing data.
```

## REST interface

## Example

The directory `example` contains
- input data resources
- result data resources
- a job json file.


