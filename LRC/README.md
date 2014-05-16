# Linear Rule Checking service

## Command line interface
This directory contains the R script `LRC.R' that can be executed from the command line.

```
$ Rscript LRC.R --data file://example/input/data.csv \
                --rules file://example/input/rules.txt \
                --checks example/result/checks.csv
```

It needs three parameters:
- `data` url to csv file with data to be checked
- `rules` url to text file with rules to be used in checking
- `checks` file path where "LRC.R" will generate a csv file

## REST interface

## Example

The directory `example` contains
- input data resources
- result data resources
- a job json file.


