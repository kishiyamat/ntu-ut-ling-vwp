getwd()
setwd("/home/kisiyama/home/thesis/ntu-ut-ling-vwp/result")

getDataFrameFromFileName <- function(file_name){
    data_frame <- read.table(file_name, head=T, sep="\t", 
    na.string="NA", encoding="UTF-8")
    return(data_frame)
}

head(getDataFrameFromFileName("npi_2017_New test_Rec 05_Segment 1.tsv"))
