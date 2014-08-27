#! Rscript
# linear rule checking
library(getopt)
library(editrules)
library(rjson)

spec = matrix(c(
  'data'         , 'i', 1, "character",  
  'data_schema'  , 's', 2, "character",  
  'rules'        , 'r', 1, "character",
  'checks'       , 'o', 1, "character",
  'checks_schema', 'p', 2, "character"
), byrow=TRUE, ncol=4)
opt <- getopt(spec)

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
    cat("* Checking schema for ", data_url)
    schema <- read_jts(data_schema_url)
    if (!check_jts(dat, schema)){
      stop("* Invalid schema")
      #TODO expand
    }
  }

  # create an linear rule checking matrix
  E <- editmatrix(readLines(rules_url))

  # check for violatedEdits
  ve <- violatedEdits(E, dat)
  # convert to 0 and 1 (opposite of violated!) 
  checks <- data.frame(ifelse(ve, 0L, 1L))
  cat("* Writing '", checks_file, "'\n", sep="")
  
  write.csv( checks, 
             file=checks_file,
             row.names=FALSE,
             na=""
  )
  if (is.null(checks_schema)){
    checks_schema <- sub("(\\.csv)?$", "_schema.json", checks_file)
  }
  
  write_jts(checks, path=checks_schema)
}

main(opt$data, opt$data_schema, opt$rules, opt$checks, opt$checks_schema)

# data_url <- "file://example/input/data.csv"
# rules_url <- "file://example/input/rules.txt"
# checks_file <-"example/result/checks.csv"
# main(data_url, rules_url, checks_file)
