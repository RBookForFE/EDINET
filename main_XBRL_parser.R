### 各社がEDINETに提出した財務諸表から，主要な勘定科目データのみを抽出する ###
### "主要な勘定科目"については，EDINETタクソノミから生成済みであるものとする

setwd("F:/R/EDINET")
library("XML")
library("plyr")

getParentSchemaLocation <- function(xsd.path){
  objXML.XSD <- xmlParse( file=xsd.path )
  vec.namespaces <- xmlNamespaceDefinitions(objXML.XSD,simplify=TRUE)
  names(vec.namespaces)[ names(vec.namespaces)=="" ] <- "default"
  vec.schema.path <- xpathSApply(objXML.XSD,path="//default:import/@schemaLocation",namespaces=vec.namespaces)
  return(vec.schema.path)
}

### EDINETタクソノミの解凍先
EDINET.URI <- "http://info.edinet-fsa.go.jp/"
TaxonomySet.Path <- "F:/R/EDINET/Taxonomy/"

### 語彙タクソノミ：商工業・その他、共通
dat.elements.path <- paste0(TaxonomySet.Path,"")
dat.elements <- read.csv(paste)

### 名称リンク・定義リンクベース


datEntry <- read.csv("downloaded_XBRL.csv")

zipFilePath <- paste0("data/",datEntry$.id[1],".zip")
# zipFileInfo <- unzip(zipFilePath,list=TRUE)
zipFileInfo <- unzip(zipFilePath,exdir="temp") # working directory直下の"temp"に展開
xbrlNo <- grep(".xbrl$",zipFileInfo) # 拡張子が"xbrl"のファイルを検索
strXBRL <- zipFileInfo[xbrlNo]

## サンプルタクソノミを使おう
xbrl.sample.dir <- "F:/R/EDINET/sample/サンプルインスタンス/X99001-000(1計算書方式)/"
xbrl.file.path <- paste0(xbrl.sample.dir,"jpfr-asr-X99001-000-2013-03-31-01-2013-06-27.xbrl")
xsd.file.path <- paste0(xbrl.sample.dir,"jpfr-asr-X99001-000-2013-03-31-01-2013-06-27.xsd")

## XBRLファイルをparse
objXML <- xmlParse( file=xbrl.file.path )
## namespaceを確保
objXML.namespaces <- xmlNamespaceDefinitions(objXML,simplify=TRUE)
# names(vec.Namespaces)[ names(vec.Namespaces)=="" ] <- "default" # 空白の名前空間はない

objXML.Company <- xmlParse( file=xsd.file.path )
objXML.Company.namespaces <- xmlNamespaceDefinitions(objXML.Company,simplify=TRUE)
names(objXML.Company.namespaces)[ names(objXML.Company.namespaces)=="" ] <- "default" # 空白の名前空間も存在する
temp <- getNodeSet(objXML.Company,"//default:import",namespaces=objXML.Company.namespaces)

str.path <- xmlGetAttr(temp[[1]],"schemaLocation")
if( grepl(pat=EDINET.URI,x=str.path) ){
  str.path <- gsub(pat=EDINET.URI,rep=TaxonomySet.Path,x=str.path)
}
getParentSchemaLocation(str.path)
setwd(dir=str.path)
dir(str.path)

#
nodes.finance <- getNodeSet(objXML,path="//jpfr-t-cte:*",namespaces=objXML.namespaces)
lst.finance <- xmlApply( nodes.finance, function(x){c(element=xmlName(x) ,xmlAttrs(x),value=xmlValue(x))} )
lst.finance <- lapply(lst.element.attrs,function(vec){ data.frame(t(data.frame(vec))) } ) # ノードの属性を，1行のdata.frameのリストに変換
dat.elements <- rbind.fill(lst.element.attrs) # Package"plyr"が提供するrbind関数，未定義のフィールドはNAで補完される
unique(dat.elements$contextRef)
unique(dat.elements$unitRef)

nodes.context <- getNodeSet(objXML,path="//xbrli:context",namespaces=objXML.namespaces)
temp <- xpathSApply(objXML,path="//xbrli:*/@id")
getNodeSet(objXML,path="//xbrli:*[@id='Prior1YearConsolidatedInstant']")
getNodeSet(objXML,path="//xbrli:context[@id]")

nodes.di <- getNodeSet(objXML,path="//jpfr-di:*",namespaces=objXML.namespaces)


# 片付け
unlink("temp",recursive=TRUE)

### 必要なelementの抽出を実行する
### 名前空間の定義を抽出
lst.Namespaces <- xmlNamespaceDefinitions(objXML.Element)
vec.Namespaces <- sapply(lst.Namespaces,function(lst){lst$uri})
names(vec.Namespaces)[ names(vec.Namespaces)=="" ] <- "default"

library(XBRL)
temp <- xbrlDoAll( strXBRL )