## 2014/03/28 
setwd("F:/R/EDINET")
# options(encoding="UTF-8")

library("RCurl")
library("XML")
library("plyr")

api.service.url <- "http://resource.ufocatch.com/atom/edinetx"
strSIC <- "1301" # 対象企業の証券コード

# リクエストを送信する
strURL <- paste0(api.service.url,"/query/",strSIC,sep="") # http://resource.ufocatch.com/atom/edinetx/query/証券コード
objQuery <- httpGET(strURL) # クエリ発行，レスポンスを取得

# xmlParseにより，UfoCatcherのResponse XMLをXMLInternalDocument形式に変換する
objXML <- xmlParse(objQuery,encoding="UTF-8")
# 名前空間の定義を取得する
objXML.namespaces <- xmlNamespaceDefinitions(objXML,simplify=TRUE)
# デフォルトの名前空間に接頭辞を付け直す
names(objXML.namespaces)[ names(objXML.namespaces)=="" ] <- "default"
# 要素ノード：entryを指定する
nodes.entry <- getNodeSet(objXML,"//default:entry",namespaces=objXML.namespaces)

# 有価証券報告書のみを抽出
lst.YUHO <- list()
for(node in nodes.entry){ # <entry>タグをひとつずつ処理
  lst.temp <- list()
  # 提出書類のタイトルを取得
  title.value <- xpathSApply(node,path="default:title",fun=xmlValue,namespaces=objXML.namespaces)
  # 提出書類のタイトルに「有価証券報告書」を含むか判定
  is.YUHO <- grepl(pat="*有価証券報告書*",x=title.value)
  if(is.YUHO){
    # IDを取得
    lst.temp$id <- xpathSApply(node,path="default:id",fun=xmlValue,namespaces=objXML.namespaces)
    lst.temp$title <- title.value
    # <link>タグのうち，type='application/zip'のhref属性を取得
    lst.temp$url <- xpathSApply(node,path="default:link[@type='application/zip']/@href",namespaces=objXML.namespaces)
    lst.YUHO[[lst.temp$id]] <- lst.temp
  }
}

# 抽出した情報をデータフレームに変換
datDownloadedList <- ldply(lst.YUHO,.fun=data.frame)
datDownloadedList

# XBRL形式の財務諸表をダウンロード，"data"フォルダに保存
dir.create("data") # "data"フォルダを作成
for(lst in lst.YUHO){
  temp <- getBinaryURL(url=lst$url ) # バイナリ形式でダウンロード
  writeBin( temp, paste0("data/",lst$id,".zip") ) # zipファイルとして保存
}

# CSV形式で保存
write.csv(x=datDownloadedList,file="downloaded_XBRL.csv",row.names=FALSE)