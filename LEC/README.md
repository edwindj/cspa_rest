# Linear Error Correction

## Command line interface
This directory contains the R script `LEC.R' that can be executed from the command line.

```
$ Rscript LEC.R --data file://example/input/data.csv \
                --localization file://example/input/localization.csv \
                --rules file://example/input/rules.txt \
				--adjusted file://example/result/adjusted.csv
```

It needs three parameters:
- `data` url to csv file with data to be checked
- `localization` url to csv file with localized var.
- `rules` url to text file with rules to be used in checking
- `adjusted` file path where "LEC.R" will generate a csv file

## REST interface

## Example

The directory `example` contains
- input data resources
- result data resources
- a job json file.


