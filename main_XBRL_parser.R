setwd("C:/R/EDINET")
library("XML")
# library("")

datEntry <- read.csv("downloaded_XBRL.csv")

zipFilePath <- paste("data/",datEntry$ID[1],".zip",sep="")
# zipFileInfo <- unzip(zipFilePath,list=TRUE)
zipFileInfo <- unzip(zipFilePath,exdir="temp") # working directory直下の"temp"に展開
xbrlNo <- grep(".xbrl",zipFileInfo) # .xbrl ファイルを読み込み
strXBRL <- zipFileInfo[xbrlNo]

objXML <- xmlParse( file=strXBRL )
top <- xmlRoot(objXML)
nodes <- getNodeSet(top,"//jpfr-t-cte:Goodwill")
xmlAttrs(nodes[[1]])

# 片付け
unlink("temp",recursive=TRUE)