#! Rscript
"Usage: LRC.R <data> <rules> [<data_schema>] --output=checks.csv

Options:
  -o --output output path where LRC should write the results in CSV format.

Arguments:
  <data>  path/url to csv file with data in csv format to be checked.
  <rules> path/url to text file with linear data rules that should be run on data.
  <data_schema> path/url to json table schema file describing data.
" -> doc

library(docopt, quietly = TRUE)
opt <- docopt(doc)
library(editrules)
library(jsonlite)

# use this function to make sourcing work for both from command line as well as
# from server.js
source_relative <- function(fname){
  argv <- commandArgs(trailingOnly = FALSE)
  base_dir <- dirname(substring(argv[grep("--file=", argv)], 8))  
  if (length(base_dir) == 0){
    base_dir = "."
  }
  source(paste(base_dir, fname, sep="/"), chdir = TRUE)
}

source_relative("../R/jts.R")
source_relative("../R/save_data.R")


#job <- fromJSON(file = args[1])
main <- function( data_url
                , data_schema_url = NULL
                , rules_url
                , checks_file
                , checks_schema = NULL){  
  # TODO add checks for existence of parameters

  # read data into data.frame
  dat <- read.csv(data_url)
  
  if (is.null(data_schema_url)){
    cat("* No json table schema supplied for ", data_url, ".\n", sep="")
    cat("* Skipping structure check\n\n")
  } else {
    cat("* Checking schema for ", data_url, "\n")
    schema <- read_jts(data_schema_url)
    dat <- check_jts(dat, schema)
  }

  # create an linear rule checking matrix
  E <- editmatrix(readLines(rules_url))

  # check for violatedEdits
  ve <- violatedEdits(E, dat)
  # convert to 0 and 1 (opposite of violated!) 
  checks <- data.frame(ifelse(ve, 0L, 1L))
  
  save_data_plus_schema(checks, checks_file, function(schema){
    rules <- as.character(E)
    schema$fields <- lapply(schema$fields, function(field){
      field$title <- paste("Rule", field$name)
      field$description <- unname(rules[field$name])
      field
    })
    schema
  })
}

main(opt$data, opt$data_schema, opt$rules, opt$output)

# data_url <- "file://example/input/data.csv"
# rules_url <- "file://example/input/rules.txt"
# checks_file <-"example/result/checks.csv"
# main(data_url, rules_url, checks_file)
