# Sys.setlocale(category='LC_ALL',"")
setwd("C:/R/EDINET")
# options(encoding="UTF-8")

library("RCurl")
library("XML")

lststrUfoCatcher <- list()
lststrUfoCatcher[["EDINET"]] <- "http://resource.ufocatch.com/atom/edinetx"

strSIC <- "1301" # Securities Identification Code
strURL <- paste(lststrUfoCatcher[["EDINET"]],"/query/",strSIC,sep="")
objQuery <- httpGET(strURL,.encoding="UTF-8")

objXML <- xmlTreeParse(strURL,encoding="UTF-8")
top <- xmlRoot(objXML)
objXML_Children <- xmlChildren(objXML$doc$children$feed)

# nodes <- getNodeSet(top,"//entry")
# nodes <- getNodeSet(xmlParse(objQuery),"//entry")
# names(nodes)

### write xml to file
# saveXML(,"data/temp.xml")

vecURI <- vector(mode="character")
for(i in 1:length(objXML_Children)){
  if( xmlName( objXML_Children[[i]] ) =="entry" ){
    objEntry <- xmlChildren( objXML_Children[[i]] )
    strTitle <- iconv( xmlValue(objEntry$title ),from="UTF-8",to="SHIFT-JIS" )
    if( length( grep("有価証券報告書",strTitle) ) != 0 ){
      print(strTitle)
      strID <- xmlValue( objEntry$id )
      for(j in 1:length(objEntry) ){
        if( xmlName(objEntry[[j]]) == "link" ){
          vecAttrs <- xmlAttrs(objEntry[[j]])
          if(vecAttrs["type"]=="application/zip"){
            temp <- getBinaryURL(url=vecAttrs["href"] )
            writeBin( temp, paste("data/",strID,".zip",sep="") )
          }
        }
      }
    }    
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