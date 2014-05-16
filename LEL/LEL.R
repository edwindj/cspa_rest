#! Rscript
# linear error localization
library(getopt)
library(rjson)
library(editrules)

spec = matrix(c(
  'data'    , 'i', 1, "character",  
  'rules'   , 'r', 1, "character",
  'weights' , 'w', 2, "character",
  'adapt'   , 'a', 1, "character",
  'status'  , 's', 1, "character"
), byrow=TRUE, ncol=4)
opt <- getopt(spec)

main <- function(data_url, rules_url, weights_url, adapt_file, status_file){
  # TODO add checks for existence of parameters

  # read data into data.frame
  dat <- read.csv(data_url)
  # create an linear rule checking matrix
  E <- editmatrix(readLines(rules_url))
  
  #TODO add weights!

  # check for violatedEdits
  le <- localizeErrors(E, dat, verbose = T, method="mip")
  
  #TODO changed adapt to 0 and 1? Or "true", "false"
  write.csv( le$adapt, 
             file=adapt_file,
             row.names=FALSE,
             na=""
  )
             
  write.csv( le$status[c("weight", "elapsed")], 
             file=status_file,
             row.names=FALSE,
             na=""
  )
}

main(opt$data, opt$rules, opt$adapt, opt$status)

# data_url <- "file://example/input/data.csv"
# rules_url <- "file://example/input/rules.txt"
# adapt_file <-"example/result/adapt.csv"
# status_file <-"example/result/status.csv"
# main(data_url, rules_url, NULL, adapt_file, status_file)