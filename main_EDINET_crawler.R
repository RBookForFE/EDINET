## 2013/10/2 
setwd("F:/R/EDINET")
# options(encoding="UTF-8")

library("RCurl")
library("XML")

lststrUfoCatcher <- list()
lststrUfoCatcher[["EDINET"]] <- "http://resource.ufocatch.com/atom/edinetx"

strSIC <- "1301" # 対象企業の証券コード

strURL <- paste(lststrUfoCatcher[["EDINET"]],"/query/",strSIC,sep="") # http://resource.ufocatch.com/atom/edinetx/query/証券コード
objQuery <- httpGET(strURL) # クエリ発行，レスポンスを取得

### htmlParseだとちゃんと動く．どうやらUfoCatcherのResponse XMLがvalidでないらしい
objXML <- htmlParse(objQuery,isURL=FALSE,encoding="UTF-8")
nodes_entry <- getNodeSet(objXML,"//entry")
nodes_title <- getNodeSet(objXML,"//entry/title") # title一覧を取得する
nodes_id <- getNodeSet(objXML,"//entry/id") # EDINET ID一覧を取得する
nodes_zip <- getNodeSet(objXML,"//entry/link[@type='application/zip']") # zip形式へのlink一覧を取得する

isYUHO <- grep(x=unlist(lapply(nodes_title,xmlValue) ),pattern="*有価証券報告書*" ) # titleに"有価証券報告書" を含むentryの番号を返す
vecYUHO.TITLE <- unlist(lapply(nodes_title[isYUHO],xmlValue))
vecYUHO.ID <- unlist(lapply(nodes_id[isYUHO],xmlValue))
vecYUHO.URI <- unlist(lapply(nodes_zip[isYUHO],xmlGetAttr,"href")) # 発見したentryのlinkを取得する

dir.create("data") # "data"フォルダを作成

## XBRLをダウンロード，"data"フォルダに保存
for(i in 1:length(vecYUHO)){
  temp <- getBinaryURL(url=vecYUHO.URI[i] )
  writeBin( temp, paste("data/",vecYUHO.ID[i],".zip",sep="") )
}

## ダウンロードしたリストをデータフレームに変換
datDownloadedList <- data.frame(edinetid=vecYUHO.ID,title=vecYUHO.TITLE)

## CSV形式で保存
write.csv(x=datDownloadedList,file="downloaded_XBRL.csv")