# data visualizing

we are going to see the eye-movements of participants
toward the target entity.

1. set up (set wd, import libs, and read data)

```R
getwd()
setwd("/home/kishiyama/home/thesis/ntu-ut-ling-vwp/result")
# kishiyama for linux, kisiyama for windows
setwd("/home/kisiyama/home/thesis/ntu-ut-ling-vwp/result")

library(ggplot2)
library(reshape)

data_all <- read.csv("./output.csv", header =T)
summary(data_all)
head(data_all)
```

1. digitalize the data

```R
# define the span for the graph here
span_begin <- 4100
span_end <- 5500

# Generating a sequence from span_begin to span_end by 20 ms.
pol_n2 <- seq(from=span_begin,to=span_end,20)

# make a table for binary data 
# nrow(data_all) == 20621
binary_data <- matrix(span_begin, nrow=nrow(data_all), ncol=length(pol_n2))
colnames(binary_data) <- pol_n2

# from span begin to end, check if there is gaze event
for (i in 1:length(pol_n2)){
    binary_data[,i] <- ifelse(
        (data_all$GazeStart < (span_begin + i * 20) &
        data_all$GazeEnd > (span_begin + i * 20)),
        1,
        0)}

# combine the binary data with all data
gr <- cbind(data_all, as.data.frame(binary_data))　

# AOIs has numbers . see the content in the AOI.
gr$Target <- ifelse(gr$AOI == 1, as.character(gr$AOI1), "BackGround")
gr$Target <- ifelse(gr$AOI == 2, as.character(gr$AOI2), gr$Target)
gr$Target <- ifelse(gr$AOI == 3, as.character(gr$AOI3), gr$Target)
gr$Target <- ifelse(gr$AOI == 4, as.character(gr$AOI4), gr$Target)

# participant,item, cond, AOI,Target,bin
gr<- gr[,c(1, 9, 10, 15, ncol(gr), 16:(ncol(gr)-1))]
head(gr)

# melt time binaries into one column.
gr2 <- melt(gr,id=c("ParticipantName", "ItemNo", "Condition", "AOI", "Target"))
gr2$variable <- as.numeric(as.character(gr2$variable))
gr2 <- gr2[order(gr2$ParticipantName, gr2$ItemNo),]

# in the recording of Tobii, count 1 if the AOI is seen in the 20m
# this causes many duplicates bacause of counting 0 for other AOIs.
# aggregate remove dups so that no dup in a bin
gr3 <-aggregate(
    gr2$value,
    by = list(gr2$ParticipantName, gr2$ItemNo, gr2$Condition,  gr2$AOI, gr2$Target, gr2$variable),
    FUN = sum,
    na.rm = TRUE)
colnames(gr3) = c("subj","item","cond", "AOI", "variable", "bin","value")
gr3$AOI <- NULL
head(gr3)

# gr3 has 2 columns: `variable` and `value`
# function `cast` makes
# 1. new cols based on levels in `variable` 
# 1. new rows based on levels in `value`
gr.temp <- cast(gr3)
head(gr.temp)

# N1_V1_t :A
# N1_V1_f :B
# N2_V1_t :C
# N2_V1_f :D
gr.temp$A <- ifelse(is.na(gr.temp$A),0,gr.temp$A)
gr.temp$B <- ifelse(is.na(gr.temp$B),0,gr.temp$B)
gr.temp$C <- ifelse(is.na(gr.temp$C),0,gr.temp$C)
gr.temp$D <- ifelse(is.na(gr.temp$D),0,gr.temp$D)

# If you need regard two(or more) area as one area,
# you might want to make some changes here.
# gr.temp$Combined <- gr.temp$TargetCompound + gr.temp$CompetitorCompound
# gr.temp$IrrelevantCompound <- gr.temp$IrrelevantCompoundA + gr.temp$IrrelevantCompoundB

# (t1) N1_V1_t (t2) N1_V1_f (t3) N2_V1_t (t4) N2_V1_f
gr.temp$t1 <- gr.temp$A
gr.temp$t2 <- gr.temp$B
gr.temp$t3 <- gr.temp$C
gr.temp$t4 <- gr.temp$D

# c: correct
# w: wrong
gr.temp$c <- ifelse((gr.temp$cond == "a" | gr.temp$cond == "b"), gr.temp$C, gr.temp$D)
gr.temp$w <- ifelse((gr.temp$cond == "a" | gr.temp$cond == "b"), gr.temp$D, gr.temp$C)

gr.temp$cn1 <- ifelse((gr.temp$cond == "a" | gr.temp$cond == "b"), gr.temp$A, gr.temp$B)
gr.temp$wn1 <- ifelse((gr.temp$cond == "a" | gr.temp$cond == "b"), gr.temp$B, gr.temp$A)

#aggregate for graph (Use t1~t4)
gra <- aggregate(
    gr.temp$c,
    by=list(gr.temp$bin, gr.temp$cond),
    mean)
colnames(gra) <- c("bin", "cond", "mean")

# a: NPI+AFF
# gra$cond <- ifelse((gra$cond == 1), "NPI_t_AFF_t", gra$cond)
# gra$cond <- ifelse((gra$cond == 2), "NPI_f_AFF_t", gra$cond)
# gra$cond <- ifelse((gra$cond == 3), "NPI_t_AFF_f", gra$cond)
# gra$cond <- ifelse((gra$cond == 4), "NPI_f_AFF_f", gra$cond)

# rename the cond name
library(ggplot2)
library(reshape)
library(plyr)
gra$cond=
    revalue(gra$cond,
        c("a"="NPI+AFF+:(sika->aru)",
        "b"="NPI-AFF+:(dake->aru)",
        "c"="NPI+AFF-:(sika->nai)",
        "d"="NPI-AFF-:(dake->nai)")
    )

# make a graph
d = data.frame(t = c(4100, 4700 , 5500),
          region = c("V1", "POL", "N2"))
g.Combined.Region6000 <-
    ggplot(data=gra, aes(x=bin, y=mean, colour = cond))+
    # we can draw some vertical lines
    geom_vline(data=d, mapping=aes(xintercept=t), linetype=3, color="black") +
    geom_text(data=d, mapping=aes(x=t, y=0.45, label=region),
        size=5, angle=90, vjust=-0.4, hjust=0 , color="#222222", family="mono") +
    # geom_line(aes(group=cond, color=cond, alpha = 0.99)) +
    geom_line(aes(group=cond, color=cond)) +
    # geom_point(aes(group=cond, color=cond)) +
    scale_x_continuous("Time") +
    scale_y_continuous(limits=c(0,0.5), name="Proportion of looks to target N2") +
    scale_color_discrete("Condition") +
    theme(axis.title.y = element_text(size = 16)) +
    theme(axis.title.x = element_text(size = 20)) +
    theme(legend.title = element_text(size = 16)) +
    theme(legend.text = element_text(size = 20))+
    # theme_bw() +
    theme_classic()+
    ggtitle("Proportion of gaze to N2 doing V1"
)  

ppi <- 600
g.Combined.Region6000
# png("../png/n2_target_full.png", width=12*ppi, height=6*ppi, res=ppi)
dev.copy(pdf, "../pdf/n2_v1_full.pdf")

dev.off()
```
