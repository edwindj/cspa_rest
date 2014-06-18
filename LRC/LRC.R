#! Rscript
# linear rule checking
library(getopt)
library(editrules)
library(rjson)

spec = matrix(c(
  'data'  , 'i', 1, "character",  
  'rules' , 'r', 1, "character",
  'checks', 'o', 1, "character",
  'checks_schema', 's', 2, "character"
), byrow=TRUE, ncol=4)
opt <- getopt(spec)

#job <- fromJSON(file = args[1])
main <- function(data_url, rules_url, checks_file, checks_schema){  
  # TODO add checks for existence of parameters

  # read data into data.frame
  dat <- read.csv(data_url)

  # create an linear rule checking matrix
  E <- editmatrix(readLines(rules_url))

  # check for violatedEdits
  ve <- violatedEdits(E, dat)
  # convert to 0 and 1 (opposite of violated!) 
  checks <- data.frame(ifelse(ve, 0L, 1L))
  write.csv( checks, 
             file=checks_file,
             row.names=FALSE,
             na=""
  )
  if (is.null(checks_schema)){
    checks_schema <- sub("\\.csv$", ".json", checks_file)
  }
  writeJTS(checks, path=checks_schema)
}

writeJTS <- function(x, path, ...){
  fields <- lapply(names(x), function(name){
    v <- x[[name]]
    l <- list(name=name, title=name)
    type = class(v)
    l$type = switch( type,
                     double    = "number",
                     integer   = "integer",
                     character = "string",
                     factor    = "string",
                     Date      = "datetime",
                     "Any"
                    )
    l
  })
  schema <- list(fields = fields)
  writeLines(toJSON(schema), con = path)
}

main(opt$data, opt$rules, opt$checks, opt$checks_schema)

# data_url <- "file://example/input/data.csv"
# rules_url <- "file://example/input/rules.txt"
# checks_file <-"example/result/checks.csv"
# main(data_url, rules_url, checks_file)
