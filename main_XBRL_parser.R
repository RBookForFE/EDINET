setwd("F:/R/EDINET")
library("XML")
# library("")

objXML.Template <- xmlParse( file="Template/EDINET_taxonomy_2013_jp/fr/gaap/t/cte/2013-03-01/jpfr-t-cte-2013-03-01-label.xml")

datEntry <- read.csv("downloaded_XBRL.csv")

zipFilePath <- paste("data/",datEntry$edinetid[1],".zip",sep="")
# zipFileInfo <- unzip(zipFilePath,list=TRUE)
zipFileInfo <- unzip(zipFilePath,exdir="temp") # working directory直下の"temp"に展開
xbrlNo <- grep(".xbrl$",zipFileInfo) # 拡張子が"xbrl"のファイルを検索
strXBRL <- zipFileInfo[xbrlNo]

objXML <- xmlParse( file=strXBRL )
top <- xmlRoot(objXML)
## namespaceを確保
objXML.namespaces <- xmlNamespaceDefinitions(top,simplify=TRUE)
namespacedef.path <- unlist( objXML.namespaces["jpfr-t-cte"] )
getNodeSet(top,path=paste("//jpfr-t-cte","CashAndDeposits",sep=":"))
getNodeSet(top,path="//CashAndDeposits") # Nullが返る＝namespace省略不可


)#namespace:jpfr-t-cte;商工業、その他、一般業種
#jpfr-t-cte以下，attributeで抜けばよい
#type==monetaryItemType
#depth<=3
#purpose==
nodes <- getNodeSet(top,"//jpfr-t-cte:Goodwill")
xmlAttrs(nodes[[1]])

# 片付け
unlink("temp",recursive=TRUE)