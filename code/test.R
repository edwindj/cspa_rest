
# Suf programma wat iedere (numerieke) kolom deelt door zijn gemiddelde

options(warn = 2)

log <- file("log", open = "wt")
sink(file = log, type="output")
sink(file = log, type="message")

cat("Starting", date(), "\n")

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {
  stop("Need at least argument")
  quit(save="no", status = 1)
}

library(rjson)

job <- fromJSON(file = args[1])

filename <- job$input$data

data <- read.csv(filename)

for (col in names(data)) {
  if (is.numeric(data[[col]])) {
    data[[col]] <- data[[col]] / mean(data[[col]], na.rm = TRUE)
  }
}

cat("Number of rows processed:", nrow(data), "\n")

write.csv(data, "dataout.csv", row.names=FALSE)

cat("Finished", date(), "\n")

quit(save = "no", status = 0)

