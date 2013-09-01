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

# 本来はXPathを使用することで簡単にxml treeを解析できるのだが，
# valueにマルチバイト文字列を含む関係で，"XML" Packageのparserが
# 正常に動作しない．仕方ないので，for文で処理する．
# nodes <- getNodeSet(top,"//entry")
# nodes <- getNodeSet(xmlParse(objQuery),"//entry")
# names(nodes)

lstEntry <- list()
k <- 1
for(i in 1:length(objXML_Children)){
  if( xmlName( objXML_Children[[i]] ) =="entry" ){
    objEntry <- xmlChildren( objXML_Children[[i]] )
    strTitle <- iconv( xmlValue(objEntry$title ),from="UTF-8",to="SHIFT-JIS" )
    if( length( grep("有価証券報告書",strTitle) ) != 0 ){
      strID <- xmlValue( objEntry$id ) # EDINET IDを保存
      print(strTitle)
      lstEntry$Title[k] <- strTitle
      lstEntry$ID[k] <- strID
      k <- k + 1
      for(j in 1:length(objEntry) ){ # XBRL形式の財務諸表一式をダウンロード
        if( xmlName(objEntry[[j]]) == "link" ){
          vecAttrs <- xmlAttrs(objEntry[[j]])
          if(vecAttrs["type"]=="application/zip"){
            temp <- getBinaryURL(url=vecAttrs["href"] )
            writeBin( temp, paste("data/",strID,".zip",sep="") )
          }
        }
      }
    }
  }
}

## ダウンロードリストをファイルに保存
write.csv(data.frame(lstEntry),"downloaded_XBRL.csv",row.names=FALSE)

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