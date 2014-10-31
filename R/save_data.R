# needs jts functions!
save_data_plus_schema <- function(x, path, improve_schema=function(s) s){
  row.names(x) <- NULL
  cat("* Writing csv '", path, "'\n", sep="")
  write.csv( x,
             file=path,
             row.names=FALSE,
             na="",
             fileEncoding="UTF-8"
  )
  
  path_schema <- sub("(\\.csv)$", "_schema.json", path)
  x_schema <- improve_schema(derive_schema(x))
  rownames(x_schema$fields) <- NULL
  #print(x_schema)
  cat("* Writing schema '", path_schema, "'\n", sep="")
  writeLines(toJSON(x_schema, pretty = TRUE, auto_unbox = TRUE, force=TRUE), con=path_schema)
}

read_data <- function(file_loc){
  # check if it is a path or url
  is_url <- grepl("^\\w+:.*//", file_loc)
  if (is_url){
    tmp <- tempfile()
    cat("* downloading ", file_loc, "\n* ")
    download.file(file_loc, tmp)
    file_loc <- tmp
  }
  read.csv(file_loc)
}