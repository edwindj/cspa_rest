# Linear Error Localization Service

## Command line interface
This directory contains the R script `LEL.R' that can be executed from the command line.

```
$ Rscript LEL.R --data file://example/input/data.csv \
              --rules file://example/input/rules.txt \
              --weights file://example/input/weights.csv \
              --adapt example/result/adapt.csv \
              --status example/result/status.csv
```

It needs three parameters:
- `data` url to csv file with data to be checked
- `rules` url to text file with rules to be used in localizing
- `weights` url to csv file with weights to be used in localizing, optional
- `adapt` file path where "LEL.R" will generate a csv file
- `status` file path where "LEL.R" will generate a csv file

## REST interface

## Example

The directory `example` contains
- input data resources
- result data resources
- a job json file.


