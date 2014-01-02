### 各社がEDINETに提出した財務諸表から，主要な勘定科目データのみを抽出する ###
### "主要な勘定科目"については，EDINETタクソノミから生成済みであるものとする

setwd("C:/R/EDINET")
library("XML")
library("plyr")

### 2013年度版EDINETタクソノミ本体の解凍先
TaxonomySet.Path <- "C:/R/EDINET/Template/EDINET_taxonomy_2013_jp/"

### 語彙タクソノミ：商工業・その他、共通
dat.elements.path <- paste0(TaxonomySet.Path,"")
dat.elements <- read.csv(paste)

### 名称リンク・定義リンクベース


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

### 必要なelementの抽出を実行する
### 名前空間の定義を抽出
lst.Namespaces <- xmlNamespaceDefinitions(objXML.Element)
vec.Namespaces <- sapply(lst.Namespaces,function(lst){lst$uri})
names(vec.Namespaces)[ names(vec.Namespaces)=="" ] <- "default"
