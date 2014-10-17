#! Rscript
"Linear Error Localization

With a set of rules that the data must obey, find the fields within records, that
are likely to be errors.

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
" -> doc
library(docopt, quietly=T)
opt <- docopt(doc)
#print(opt)

library(editrules)

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

main <- function(data_url, data_schema_url, rules_url, weights_url, adapt_file, status_file){
  # read data into data.frame
  cat("\n***************************************\n")
  dat <- read_data(data_url)
  #print(dat)
  
  if (is.null(data_schema_url)){
    cat("* No json table schema supplied for ", data_url, ".\n", sep="")
    cat("* Skipping structure check\n\n")
    schema <- derive_schema(dat)
  } else {
    cat("* Checking file structure: ")
    schema <- read_jts(data_schema_url)
    dat <- check_schema(dat, schema)
    cat("ok.\n")
  }
  
  if (is.null(weights_url)){
    weight <- sapply(names(dat), function(x) 1)
    cat("* No weight supplied, assuming weight=1\n")
  } else {
    weight <- read.csv(weights_url)
    weight <- check_schema(weight, schema)
    if (nrow(weights) != 1 && nrow(weights) != nrow(dat)){
      stop("Number of rows of weight is not equal to 1 or ", nrow(dat))
    }
  }
  
  # create an linear rule checking matrix
  E <- editmatrix(readLines(rules_url))
  
  # check for violatedEdits
  le <- localizeErrors(E, dat, weight=weight, verbose = T, method="mip")
  
  #TODO changed adapt to 0 and 1? Or "true", "false"
  adapt <- data.frame(ifelse(le$adapt, 1L, 0L))
  save_data_plus_schema(adapt, adapt_file)
  
  status <- le$status[c("weight", "elapsed")]
  save_data_plus_schema(status, status_file, function(schema){
    schema$fields$description <- c( "Weight of the solution found: sum of the weights of the fields that are considered erroneous",
                                    "Time in seconds for finding solution")
    schema
  })
}

main(opt$data, opt$data_schema, opt$rules, opt$weights, opt$adapt, opt$status)

# data_url <- "file://example/input/data.csv"
# rules_url <- "file://example/input/rules.txt"
# adapt_file <-"example/result/adapt.csv"
# status_file <-"example/result/status.csv"
# main(data_url, NULL ,rules_url, NULL, adapt_file, status_file)
