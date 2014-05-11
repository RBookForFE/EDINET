library(XBRL)

setwd("F:/R/EDINET")

# 2013年版EDINETタクソノミ：サンプルインスタンス
xbrl.dir <- "F:/R/EDINET/sample/サンプルインスタンス/X99001-000(1計算書方式)/"
xbrl.path <- paste0(xbrl.dir,"jpfr-asr-X99001-000-2013-03-31-01-2013-06-27.xbrl")

# XBRLパッケージにより報告書インスタンスを処理
xbrl.parsed <- xbrlDoAll(xbrl.path)

# 金額の定義および、文書情報の定義を抽出
dat.facts <- xbrl.parsed$fact
# 文字コードをUTF-8からShift-JISに修正
dat.facts$fact <- iconv(x=dat.facts$fact,from="UTF-8",to="Shift-JIS")

# 名称リンクの情報を抽出
dat.labels <- xbrl.parsed$label
dat.labels$labelString <- iconv(x=dat.labels$labelString,from="UTF-8",to="Shift-JIS")
# 日本語(lang=="ja")かつ，ドキュメンテーション用(labelRole=…/role/documentation) 
dat.labels <- subset(dat.labels,lang=="ja" & labelRole=="http://www.xbrl.org/2003/role/documentation",select=c("elementId","labelString"))
dat.labels <- unique(dat.labels) # 重複を消去

# dat.elements <- unique( xbrl.parsed$element )

# 金額・文書情報と名称リンクを結合
dat.FI <- merge(x=dat.facts,y=dat.labels,by="elementId")


# dat.FI <- merge(x=dat.FI,y=dat.elements,all.x=TRUE)

# 当期・連結有価証券報告書＝contextIdが"CurrentYearConsolidated"から始まる要素
target <- grepl(pattern="^CurrentYearConsolidated",x=dat.FI$contextId)
dat.FI.CurrentYearConsolidated <- dat.FI[target,]
head(dat.FI.CurrentYearConsolidated[,c("labelString","fact")])

# 文書情報
target <- grepl(pattern="^DocumentInfo",x=dat.FI$contextId)
dat.Presenter.Info <- dat.FI[target,]
# 開示対象者の名称
print( subset( dat.Presenter.Info, elementId == "jpfr-di_EntityNameJaEntityInformation" )$fact )

# コンテキスト情報
dat.contexts <- xbrl.parsed$context
# 期首・期末
print( subset( dat.contexts, contextId == "CurrentYearConsolidatedDuration")$startDate )
print( subset( dat.contexts, contextId == "CurrentYearConsolidatedDuration")$endDate )

# 表示リンクの情報を抽出
dat.ps <- xbrl.parsed$presentation

# 子孫要素を再帰的に抽出する関数
gather.descendant <- function(df, parent){
  children <- as.vector( df$toElementId[df$fromElementId==parent] )
  return( c(children,unlist( sapply(children,function(child){ gather.descendant(df,child) }) ) ) )
}

dat.ps.CYC <- subset(dat.ps,subset=grepl(pattern="*role/ConsolidatedBalanceSheets$",x=roleId))

# 「流動資産」に対応する要素名を確認
subset( dat.labels,subset=grepl(pattern="^流動資産*",x=labelString) )
vec.descendants <- gather.descendant(dat.ps.CYC,parent="jpfr-t-cte_CurrentAssetsAbstract")

# 「流動資産」の子孫要素を取得
dat.FI.CYC.CAA <- subset(dat.FI.CurrentYearConsolidated,subset=(elementId %in% vec.descendants) )
dat.FI.CYC.CAA[,c("labelString","fact")]
