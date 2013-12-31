### 金融庁が提供するEDINETタクソノミに基づき，主要な勘定科目のみを抽出する ###
### 出典：金融庁(2013),"2013年版EDINETタクソノミ及び関連資料の公表について",http://www.fsa.go.jp/search/20130301.html


setwd("C:/R/EDINET")
library("XML")

### 2013年度版EDINETタクソノミ本体の解凍先
TaxonomySet.Path <- "C:/R/EDINET/Template/EDINET_taxonomy_2013_jp/"

### 語彙タクソノミ：商工業・その他、共通
objXML.Element.Path  <- paste0(TaxonomySet.Path, "fr/gaap/t/cte/2013-03-01/jpfr-t-cte-2013-03-01.xsd")
objXML.Element <- xmlParse( file=objXML.Element.Path )

### 名称リンク・定義リンクベース
objXML.Label.Path <- paste0(TaxonomySet.Path, "fr/gaap/t/cte/2013-03-01/jpfr-t-cte-2013-03-01-label.xml")
# xmlSchemaValidate(objXML.Element,objXML.Label.Path)
objXML.Label <- xmlParse( file= objXML.Label.Path )
objXML.Definition.Path <- paste0(TaxonomySet.Path, "fr/gaap/r/cai/cm/2013-03-01/jpfr-cai-cm-2013-03-01-definition.xml")
objXML.Definition <- xmlParse( file= objXML.Definition.Path )
                          
names(vec.SchemaSet.Path) <- c("schema","label","definition")
for(str in names(vec.SchemaSet)){
  objXML.SchemaSet[[str]] <- xmlParse( file=paste0(Template))
}
# objXML.Template <- xmlParse( file="Template/EDINET_taxonomy_2013_jp/fr/gaap/t/cte/2013-03-01/jpfr-t-cte-2013-03-01-label.xml",isSchema=TRUE)

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
top.Element <- xmlRoot(objXML.Element)
dat.Elements <- xmlToDataFrame( getNodeSet(objXML.Element, "//element") )
##top.template <- xmlRoot(objXML.Element)

xmlNamespaceDefinitions(objXML.Label)
top.Label <- xmlRoot(objXML.Label)

# objXML.Label <- xmlInternalTreeParse(objXML.Label.Path,encoding="UTF-8")
objXML.Label <- xmlParse(objXML.Label.Path)
#objXML.Label <- htmlParse(objXML.Label.Path)
objXML.Label <- xmlParse(objXML.Label.Path,fullNamespaceInfo=TRUE)
temp <- getNodeSet(objXML.Label,path="//label")

## 名称リンクの加工
### 名前空間の定義を抽出
lst.Namespaces <- xmlNamespaceDefinitions(objXML.Label)
vec.Namespaces <- sapply(lst.Namespaces,function(lst){lst$uri})
names(vec.Namespaces)[ names(vec.Namespaces)=="" ] <- "default"

### 名称(=label)が定義されたノードの情報を data.frame に変換
label.nodes <- getNodeSet(objXML.Label,path="//default:label",namespaces=vec.Namespaces)
vec.label <- xmlSApply( label.nodes,xmlValue)
lst.label.attrs <- xmlApply( label.nodes,xmlAttrs )
dat.label.attrs <- data.frame(t(data.frame(lst.label.attrs))) # ノードの属性をまとめて data.frame に変換
dat.label.attrs$value <- iconv(vec.label,from="UTF-8",to="UTF-8") # 文字化け防止
dat.label.attrs$id.wo.label <- sub(pattern="^label_",replacement="",x=dat.label.attrs$id) # "labels_" を除去したID
rownames(dat.label.attrs) <- c(1:nrow(dat.label.attrs))

write.csv(file=paste0(TaxonomySet.Path,"jpfr-t-cte_labels.csv"),x=dat.label.attrs,row.names=FALSE)

# temp2 <- getNodeSet(objXML.Label,path="//labelarc[@xlink:from=\"balancesheetsabstract\"]",namespaces=vec.Namespaces[-1])
# temp2 <- getNodeSet(objXML.Label,path="//labelarc[@xlink:from]",namespaces=vec.Namespaces[-1])
# temp2 <- getNodeSet(objXML.Label,path="//labelArc",namespaces=vec.Namespaces[-1])



