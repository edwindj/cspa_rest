# utility functions for JSON table schema .

library(jsonlite)

#' Read JSON table schema from file
read_jts <- function(file, ...){
  schema <- fromJSON(readLines(file))
  structure(schema, class="jts")
}

write_jts <- function(schema, path, ...){
  writeLines(toJSON(schema), con = path)
}

#' Checks if a data.frame conforms to a schema
#' @param x a data.frame
#' @param schema 
check_schema <- function(x, schema, ...){
  jts <- derive_schema(x)
  stopifnot(inherits(schema, "jts"))
  
  idx <- match(schema$fields$name, jts$fields$name)
  if (any(is.na(idx))){
    stop("Missing fields: ", schema$fields$name[is.na(idx)])
  }
  
  # set fields in same order and size as schema$fields
  fields <- jts$fields[idx,,drop=FALSE]
  check_type <- fields$type != schema$fields$type
  contain_type <- fields$type == "integer" & schema$fields$type == "number"
  check_type <- check_type 
  if (any(check_type)){
    warning("Types do not match: ", paste(fields$name[check_type], collapse = ", "))
  }
  invisible(x[idx,,drop=FALSE])
}

#' 
derive_schema <- function(x, ...){
  stopifnot(inherits(x, "data.frame"))
  name <- names(x)
  type <- sapply(x, function(v){
    switch(class(v),
           numeric    = "number",
           integer   = "integer",
           character = "string",
           factor    = "string",
           Date      = "datetime",
           "Any"
    )
  })
  fields <- data.frame(name=name, title=name, type=type)
  structure(list(fields = fields), class="jts")
}

# Testing 
# s <- derive_schema(iris)
# s$fields[[2]]$name <- "bla"
# check_schema(iris, s)
