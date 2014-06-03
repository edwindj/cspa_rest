library(whisker)

DDI_TMPL <-
'<?xml version="1.0" encoding="UTF-8"?>
<DDIInstance xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="ddi:instance:3_1" xmlns:g="ddi:group:3_1" xmlns:r="ddi:reusable:3_1" xmlns:l="ddi:logicalproduct:3_1" id="{{id}}" agency="{{agency}}" version="{{version}}">
  <g:ResourcePackage id="{{id}}" agency="{{agency}}" version="{{version}}">
    <g:Purpose id="metadataDescription">
      <r:Content>
      {{description}}
      </r:Content>
    </g:Purpose>
    <g:LogicalProduct>
      <l:LogicalProduct id="dataSetHeader">
        <l:VariableScheme id="headerVariables" agency="{{agency}}" version="{{version}}">
          {{#variables}}
          <l:Variable id="{{id}}" version="{{version}}">
          <l:VariableName>{{name}}</l:VariableName>
          <l:Representation>
            {{#is_numeric}}
            <l:NumericRepresentation type="Double"/>
            {{/is_numeric}}
            {{#is_integer}}
            <l:NumericRepresentation type="Integer"/>
            {{/is_integer}}
            {{#is_factor}}
            <l:CodeRepresentation blankIsMissingValue="true">
              <r:CodeScheme>
              {{#levels}}
                <l:Code>
                  <l:Value>{{.}}</l:Value>
                </l:Code>
              {{/levels}}
              </r:CodeScheme>
            </l:CodeRepresentation>
            {{/is_factor}}
          </l:Representation>
          </l:Variable>
          {{/variables}}       
        </l:VariableScheme>
      </l:LogicalProduct>
    </g:LogicalProduct>
  </g:ResourcePackage>
</DDIInstance>
'

writeDDISchema <- function(x, name, description="", agency="", version="1.0.0", ...){
  #DDI_TMPL <- readLines("ddi.xml")
  
  variables=lapply(names(x), function(name){
    l <- list(name=name, id=name)
    x_c <- x[[name]]
    type = class(x_c)
    is_type <- paste0("is_", type)
    l[[is_type]] = TRUE
    l$levels = levels(x_c)
    l
  })
  
  #print(variables)
  schema <- whisker.render(DDI_TMPL,
    list( agency = agency
        , id = name
        , version = version
        , description = description
        , variables = variables
        , ...
        )
  )
  ddi <- paste0(name, ".xml")
  writeLines(schema, ddi)
}

#writeDDISchema(iris, "iris")