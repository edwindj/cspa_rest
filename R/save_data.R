# needs jts functions!
save_data_plus_schema <- function(x, path, improve_schema=function(s) s){
  
  cat("* Writing csv '", path, "'\n", sep="")
  write.csv( x,
             file=path,
             row.names=FALSE,
             na=""
  )
  
  path_schema <- sub("(\\.csv)$", "_schema.json", path)
  x_schema <- improve_schema(derive_schema(x))
  
  cat("* Writing schema '", path_schema, "'\n", sep="")
  writeLines(toJSON(x_schema, pretty = TRUE, auto_unbox = TRUE, force=TRUE), con=path_schema)
}