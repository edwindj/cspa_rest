# linear rule checking
library(rjson)
library(editrules)

args <- commandArgs(trailingOnly = TRUE)
#job <- fromJSON(file = args[1])
rules <- "file://./rules.txt"
data <- "file//./data.csv"

dat <- read.csv(data)
E <- editmatrix(readLines(rules))

result.checks <- violatedEdits(E, dat)
write.csv(result.checks, file="checks.csv")