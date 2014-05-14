
# Suf programma wat iedere (numerieke) kolom deelt door zijn gemiddelde

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
  stop("Need two arguments")
  quit(save="no", status = 1)
}

data <- read.csv(args[1])

for (col in names(data)) {
  if (is.numeric(data[[col]])) {
    data[[col]] <- data[[col]] / mean(data[[col]], na.rm = TRUE)
  }
}

write.csv(data, args[2], row.names=FALSE)

quit(save = "no", status = 0)

