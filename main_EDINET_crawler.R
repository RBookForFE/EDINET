library("RCurl")
library("XML")

lststrUfoCatcher <- list()
lststrUfoCatcher[["EDINET"]] <- "http://resource.ufocatch.com/atom/edinetx"

strSIC <- "1301" # Securities Identification Code
strURL <- paste(lststrUfoCatcher[["EDINET"]],"/query/",strSIC,sep="")
objQuery <- httpGET(strURL)
objXML <- xmlRoot(xmlTreeParse(objQuery,getDTD=FALSE))
objData <- xmlParse(objQuery)
lstData <- xmlToList(objData)

for(i in 1:length(lstData)){
  vecNames <- names(lstData[[i]])
  if(length(vecNames)!=0){
    if("title" %in% vecNames ){
      strDocTitle <- lstData[[i]]$title
      print(strDocTitle)
    }
  }
}


### garbage hereafter ###
vecTemp <- names(objXML)
xmlName(objXML)
names(objXML[["entry"]])

xmlSApply(objXML[[1]],xmlName)
tmp <- xmlSApply(objXML, function(x) xmlSApply(x, xmlValue))
objXML[["entry"]]
iconv( tmp$entry$title ,from="UTF-8",to="SHIFT_JIS")
