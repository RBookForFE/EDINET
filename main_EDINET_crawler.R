library("RCurl")
library("XML")

lststrUfoCatcher <- list()
lststrUfoCatcher[["EDINET"]] <- "http://resource.ufocatch.com/atom/edinetx"

strSIC <- "1301" # Securities Identification Code
strURL <- paste(lststrUfoCatcher[["EDINET"]],"/query/",strSIC,sep="")
objQuery <- httpGET(strURL)
objXML <- xmlTreeParse(objQuery)
objXML_Children <- xmlChildren(objXML$doc$children$feed)

vecNames <- names(objXML_Children)
for(i in 1:length(objXML_Children)){
  if(vecNames[i]=="entry"){
    objEntry <- xmlChildren( objXML_Children[[i]] )
    strTitle <- iconv( xmlValue(objEntry$title ),from="UTF-8",to="SHIFT-JIS" )
    print(strTitle)
    
    # $link のうち，拡張子が .xbrl になってるやつがbody
  }
}

### working... ###
# for(i in 1:length(objXML_Children)){
#   if(vecNames[i]=="title")
#   if(length(vecNames)!=0){
#     if("title" %in% vecNames ){
#       strDocTitle <- lstData[[i]]$title
#       strTemp <- strsplit(strDocTitle,split=" ")
#       print(strDocTitle)
#       print(lstData[[i]]$link[1])
#     }
#   }
# }


### garbage hereafter ###
vecTemp <- names(objXML)
xmlName(objXML)
names(objXML[["entry"]])

xmlSApply(objXML[[1]],xmlName)
tmp <- xmlSApply(objXML, function(x) xmlSApply(x, xmlValue))
objXML[["entry"]]
iconv( tmp$entry$title ,from="UTF-8",to="SHIFT_JIS")