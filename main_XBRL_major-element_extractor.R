### 金融庁が提供するEDINETタクソノミから，主要な勘定科目のみを抽出する
### タクソノミ本体から，語彙タクソノミ・名称リンク・定義リンクをparse済みであるものとする
### タクソノミ本体のparseについては，"main_XBRL_Taxonomy_parser.R" を参照のこと．

setwd("C:/R/EDINET")

## 2013年度版EDINETタクソノミ本体の解凍先
TaxonomySet.Path <- "C:/R/EDINET/Template/EDINET_taxonomy_2013_jp/"

dat.elements <- read.csv(paste0(TaxonomySet.Path,"jpfr-t-cte_elements.csv"),stringsAsFactors=FALSE) # 語彙タクソノミ
dat.labels <- read.csv(paste0(TaxonomySet.Path,"jpfr-t-cte_labels.csv"),stringsAsFactors=FALSE) # 名称リンク
dat.arcs <- read.csv(paste0(TaxonomySet.Path,"jpfr-cai-cm_definitions.csv"),stringsAsFactors=FALSE) # 定義リンク

## BS・PL・CF項目の定義リンクのみ抽出
vec.role <- c("BalanceSheets","StatementsOfIncome","StatementsOfCashFlows")
vec.role <- paste0("http://info.edinet-fsa.go.jp/jp/fr/gaap/role/",vec.role)
names(vec.role) <- c("BS","PL","CF")
is.BS_PL_CF <- dat.arcs$role %in% vec.role
dat.arcs.BS_PL_CF <- dat.arcs[is.BS_PL_CF,]

## 定義リンクに現れる全てのElementを出発点にして，主要な勘定科目のみを保持したdata.frameを構築する
vec.elements <- unique( c(dat.arcs.BS_PL_CF$from, dat.arcs.BS_PL_CF$to) ) # 定義リンクに現れる全てのElement
dat.BS_PL_CF <- data.frame(name=vec.elements,depth=NA)

### 1. Elementごとに，財務諸表における"深さ"を付与する
vec.elements.children <- unique(dat.arcs.BS_PL_CF$to) # 親を持つElement
vec.elements.root <- vec.elements[ !(vec.elements %in% vec.elements.children) ] # 親を持たない(=rootの)Element

vec.elements.parent <- vec.elements.root # root.Elementの深さを"1"として，子Elementを順次探索
current.depth <- 1
while( any(is.na(dat.BS_PL_CF$depth)) ){ # 深さが付与されていないElementがなくなるまで繰り返す
  dat.BS_PL_CF$depth[ dat.BS_PL_CF$name %in% vec.elements.parent ] <- current.depth # 現在の親Elementに深さを付与
  current.depth <- current.depth+1 # 深さをインクリメント
  vec.elements.children <- dat.arcs.BS_PL_CF$to[ dat.arcs.BS_PL_CF$from %in% vec.elements.parent ] # 現在の親に直結する子を抽出
  vec.elements.parent <- vec.elements.children # 親Elementを更新
}

## 2. Elementごとに，属する財務諸表種類(BS・PL・CF)を付与
lst.temp <- list()
for(t in 1:length(vec.role)){
  role_t <- vec.role[t]
  role_t.name <- names(vec.role)[t]
  dat.arcs.role_t <- dat.arcs.BS_PL_CF[dat.arcs.BS_PL_CF$role == role_t,]
  lst.temp[[role_t.name]] <- unique(c(dat.arcs.role_t$from,dat.arcs.role_t$to))
}