#! Rscript
# linear rule checking
library(getopt)
library(rjson)
library(editrules)


spec = matrix(c(
  'data'  , 'i', 1, "character",  
  'rules' , 'r', 1, "character",
  'checks', 'o', 1, "character"
), byrow=TRUE, ncol=4)
opt <- getopt(spec)

#job <- fromJSON(file = args[1])
main <- function(data_url, rules_url, checks_file){  
  dat <- read.csv(data_url)
  E <- editmatrix(readLines(rules_url))
  
  checks <- ifelse(violatedEdits(E, dat), 0, 1)
  write.csv( checks, 
             file=checks_file,
             row.names=FALSE,
             na=""
  )
}

main(opt$data, opt$rules, opt$checks)

# data_url <- "file://example/input/data.csv"
# rules_url <- "file://example/input/rules.txt"
# checks_file <-"example/result/checks.csv"
# main(data_url, rules_url, checks_file)
