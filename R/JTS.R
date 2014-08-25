# utility functions for JSON table schema

library(rjson) # replace with jsonlite?

#' Read JSON table schema from file
read_JTS <- function(file, ...){
  schema <- fromJSON(file=file)
  structure(schema, class="jts")
}

write_JTS <- function(schema, path, ...){
  writeLines(toJSON(schema), con = path)
}

#' Checks if a data.frame conforms to a schema
#' @param x a data.frame
#' @param schema 
check_schema <- function(x, schema, ...){
  jts <- derive_schema(x)
  stopifnot(inherits(schema, "jts"))
  stopifnot(length(jts$fields) == length(schema$fields))
  for (i in seq_along(jts$fields)){
    f1 <- jts$fields[[i]]
    f2 <- schema$fields[[i]]
    if (f1$name != f2$name || f1$type != f2$type){
      stop("Field ", i, " does not conform.\n", f1,"\nvs\n", f2)
    }
  }
  invisible(TRUE)
}

#' 
derive_schema <- function(x, ...){
  stopifnot(inherits(x, "data.frame"))
  fields <- lapply(names(x), function(name){
    v <- x[[name]]
    l <- list(name=name, title=name)
    type = class(v)
    l$type = switch( type,
                     numeric    = "number",
                     integer   = "integer",
                     character = "string",
                     factor    = "string",
                     Date      = "datetime",
                     "Any"
    )
    l
  })
  structure(list(fields = fields), class="jts")
}

# Testing 
# s <- derive_schema(iris)
# s$fields[[2]]$name <- "bla"
# check_schema(iris, s)
