### 金融庁が提供するEDINETタクソノミに基づき，主要な勘定科目のみを抽出する ###
### 出典：金融庁(2013),"2013年版EDINETタクソノミ及び関連資料の公表について",http://www.fsa.go.jp/search/20130301.html
### タクソノミ本体内部のファイル構成については，"企業別タクソノミ作成ガイドライン[添付資料]"を参照するとよい．

setwd("F:/R/EDINET")
library("XML")
library("plyr")

## 2013年度版EDINETタクソノミ本体の解凍先
TaxonomySet.Path <- "F:/R/EDINET/Template/EDINET_taxonomy_2013_jp/"

## タクソノミ本体から，語彙タクソノミ・名称リンク・定義リンクを読み込む

### 語彙タクソノミ：商工業・その他、共通 -> fr/gaap/t/cte/2013-03-01/jpfr-t-cte-2013-03-01.xsd
objXML.Element.Path  <- paste0(TaxonomySet.Path, "fr/gaap/t/cte/2013-03-01/jpfr-t-cte-2013-03-01.xsd")
objXML.Element <- xmlParse( file=objXML.Element.Path )
# objXML.Element.Schema <- xmlParse( file=objXML.Element.Path, isSchema=TRUE ) # XML Schemaとして読み込むことも可能

### 名称リンク：商工業・その他、共通 -> fr/gaap/t/cte/2013-03-01/jpfr-t-cte-2013-03-01-label.xml
objXML.Label.Path <- paste0(TaxonomySet.Path, "fr/gaap/t/cte/2013-03-01/jpfr-t-cte-2013-03-01-label.xml")
objXML.Label <- xmlParse( file= objXML.Label.Path )
# xmlSchemaValidate(objXML.Element.Schema,objXML.Label.Path) # XML文書のvalidateを行うことも可能(要XML Schema)

### 定義リンク：一般商工業 -> fr/gaap/r/cai/cm/2013-03-01/jpfr-cai-cm-2013-03-01-definition.xml
objXML.Definition.Path <- paste0(TaxonomySet.Path, "fr/gaap/r/cai/cm/2013-03-01/jpfr-cai-cm-2013-03-01-definition.xml")
objXML.Definition <- xmlParse( file= objXML.Definition.Path )
# xmlSchemaValidate(objXML.Element.Schema,objXML.Definition.Path) # XML文書のvalidateを行うことも可能(要XML Schema)

## 語彙タクソノミから，elementを取得
### 名前空間の定義を抽出
# lst.Namespaces <- xmlNamespaceDefinitions(objXML.Element)
vec.Namespaces <- xmlNamespaceDefinitions(objXML.Element,simplify=TRUE)
# vec.Namespaces <- sapply(lst.Namespaces,function(lst){lst$uri})
names(vec.Namespaces)[ names(vec.Namespaces)=="" ] <- "default"

### 語彙(=element)が定義されたノードの情報を data.frame に変換
element.nodes <- getNodeSet(objXML.Element,path="//default:element",namespaces=vec.Namespaces)
lst.element.attrs <- xmlApply( element.nodes, xmlAttrs)
lst.element.attrs <- lapply(lst.element.attrs,function(vec){ data.frame(t(data.frame(vec))) } ) # ノードの属性を，1行のdata.frameのリストに変換
dat.elements <- rbind.fill(lst.element.attrs) # Package"plyr"が提供するrbind関数，未定義のフィールドはNAで補完される

write.csv(file=paste0(TaxonomySet.Path,"jpfr-t-cte_elements.csv"),x=dat.elements,row.names=FALSE)


## 名称リンクから，elementの和文名称を取得
### 名前空間の定義を抽出
lst.Namespaces <- xmlNamespaceDefinitions(objXML.Label)
vec.Namespaces <- sapply(lst.Namespaces,function(lst){lst$uri})
names(vec.Namespaces)[ names(vec.Namespaces)=="" ] <- "default"

### 名称(=label)が定義されたノードの情報を data.frame に変換
label.nodes <- getNodeSet(objXML.Label,path="//default:label",namespaces=vec.Namespaces)
vec.label <- xmlSApply( label.nodes,xmlValue) # 名称
lst.label.attrs <- xmlApply( label.nodes,xmlAttrs ) # 名称が定義されたノードの属性
lst.label.attrs <- lapply(lst.label.attrs,function(vec){ data.frame(t(data.frame(vec))) } ) # ノードの属性を，1行のdata.frameのリストに変換
dat.label.attrs <- rbind.fill(lst.label.attrs) # 単一のdata.frameに変換
dat.label.attrs$value <- iconv(vec.label,from="UTF-8",to="UTF-8") # data.frameに名称を追加
dat.label.attrs$id.wo.label <- sub(pattern="^label_",replacement="",x=dat.label.attrs$id) # "labels_" を除去したID

write.csv(file=paste0(TaxonomySet.Path,"jpfr-t-cte_labels.csv"),x=dat.label.attrs,row.names=FALSE)


## 定義リンクから，要素間の相対関係を取得
### 名前空間の定義を抽出
lst.Namespaces <- xmlNamespaceDefinitions(objXML.Definition)
vec.Namespaces <- sapply(lst.Namespaces,function(lst){lst$uri})
names(vec.Namespaces)[ names(vec.Namespaces)=="" ] <- "default"

### 要素間の相対関係(=definitionArc)が定義されたノードの情報を data.frame に変換
# vec.role <- c("BalanceSheets","StatementsOfIncome","StatementsOfCashFlows")
# vec.role <- paste0("http://info.edinet-fsa.go.jp/fr/gaap/role/",vec.role)
arc.nodes <- getNodeSet(objXML.Definition,path="//default:definitionLink/default:definitionArc",namespaces=vec.Namespaces)
lst.arc.attrs <- xmlApply(arc.nodes,xmlAttrs ) # 相対関係が定義されたノードの属性
lst.arc.attrs <- lapply(lst.arc.attrs,function(vec){ data.frame(t(data.frame(vec))) } )
dat.arc.attrs <- rbind.fill(lst.arc.attrs)
lst.arc.parent.attrs <- xmlApply(arc.nodes,function(node){ xmlAttrs( xmlParent(node) ) }) # 相対関係定義ノードの親ノードの情報を取得する
lst.arc.parent.attrs <- lapply(lst.arc.parent.attrs,function(vec){ data.frame(t(data.frame(vec))) } )
dat.arc.parent.attrs <- rbind.fill(lst.arc.parent.attrs)
dat.arc.attrs <- cbind(dat.arc.parent.attrs,dat.arc.attrs)

write.csv(file=paste0(TaxonomySet.Path,"jpfr-cai-cm_definitions.csv"),x=dat.arc.attrs,row.names=FALSE)