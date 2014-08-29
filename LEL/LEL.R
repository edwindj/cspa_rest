#! Rscript
# linear error localization
library(getopt)
library(editrules)
library(jsonlite)
spec = matrix(c(
  'data'          , 'i', 1, "character",  
  'data_schema'   , 'j', 2, "character",
  'rules'         , 'r', 1, "character",
  'weights'       , 'w', 2, "character",
  'adapt'         , 'a', 1, "character",
  'status'        , 's', 1, "character"
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
source_relative("../R/save_data.R")

main <- function(data_url, data_schema_url, rules_url, weights_url, adapt_file, status_file){
  # read data into data.frame
  dat <- read.csv(data_url)
  
  if (is.null(data_schema_url)){
    cat("* No json table schema supplied for ", data_url, ".\n", sep="")
    cat("* Skipping structure check\n\n")
    schema <- get_jts(dat)
  } else {
    schema <- read_jts(data_schema_url)
    dat <- check_jts(dat, schema)
  }
  
  if (is.null(weights_url)){
    weight <- sapply(names(dat), function(x) 1)
    cat("No weight supplied, assuming weight=1\n")
  } else {
    weight <- read.csv(weights_url)
    check_jts(weight, schema)
    if (nrow(weights) != 1 && nrow(weights) != nrow(dat)){
      stop("Number of rows of weight is not equal to 1 or ", nrow(dat))
    }
  }
  
  # create an linear rule checking matrix
  E <- editmatrix(readLines(rules_url))
  
  #TODO add weights!

  # check for violatedEdits
  le <- localizeErrors(E, dat, weight=weight, verbose = T, method="mip")
  
  #TODO changed adapt to 0 and 1? Or "true", "false"
  adapt <- data.frame(ifelse(le$adapt, 1L, 0L))
  save_data_plus_schema(adapt, adapt_file)
  
  status <- le$status[c("weight", "elapsed")]
  save_data_plus_schema(status, status_file, function(schema){
    
    schema$fields[[1]]$description <- "Weight of the solution found: sum of the weights
    of the fields that are considered erroneous"
    
    schema$fields[[2]]$description <- "Time in seconds for finding solution"
    schema
  })
}

main(opt$data, opt$data_schema, opt$rules, opt$weights, opt$adapt, opt$status)

# data_url <- "file://example/input/data.csv"
# rules_url <- "file://example/input/rules.txt"
# adapt_file <-"example/result/adapt.csv"
# status_file <-"example/result/status.csv"
# main(data_url, rules_url, NULL, adapt_file, status_file)
