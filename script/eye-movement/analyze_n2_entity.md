# data analyzing

1. set up (set wd, import libs, and read data)

```R
getwd()
setwd("/home/kishiyama/home/thesis/ntu-ut-ling-vwp/result")

library(lme4)
library(reshape)

data <- read.csv("./output.csv", header =T)
head(data)
# check its distribution
table(data$ParticipantName, data$Condition)
table(data$Condition)

# AOIs has numbers . see the content in the AOI.
# as same as the way we took in the visualization step
data$target <- ifelse(data$AOI == 1, as.character(data$AOI1), "BackGround")
data$target <- ifelse(data$AOI == 2, as.character(data$AOI2), data$target)
data$target <- ifelse(data$AOI == 3, as.character(data$AOI3), data$target)
data$target <- ifelse(data$AOI == 4, as.character(data$AOI4), data$target)

data <-data[order(data$ParticipantName, data$ItemNo, data$GazeStart),]
```

1. We want to extract the data in the region we are interested in.

```R
# define the span for the graph here
onset_var <- 4700
offset_var <- 5100
span <- offset_var - onset_var

# start lapse and end lapse
data$slapse <- data$GazeStart - onset_var
data$elapse <- data$GazeEnd - onset_var
head(data)

# The lapse(slapse) until the onset become negative values
# we will ignore the negatives later
# not taking them into account

#  slapse elapse
#1   -824   -670
#2   -603   -397
#3      3    173
#4    177    680
#5    926   1523
#6   1220   1603

data$slapse <- ifelse(data$slapse < 0, 0, data$slapse)
data$elapse <- ifelse(data$elapse >= span, span, data$elapse)

#  slapse elapse
#1      0   -199
#2      0    -10
#3      3      3
#4    177    177
#5    926   1000
#6   1220   1000

data$dur <- data$elapse - data$slapse
data$dur <- ifelse(data$dur < 0, 0, data$dur)

# by subtracting slapse from elapse,
# we can focus on the area with positive value(dur)

data <- data[,c("ParticipantName", "ItemNo", "target", "Condition", "slapse","elapse","dur")]
data <- data[order(data$ParticipantName,data$ItemNo,data$slapse),]

# CALUCULATING SUM (aggregation for each trial)
data <-aggregate(
    data$dur,
    by=list(data$ParticipantName, data$ItemNo, data$target, data$Condition),
    FUN=sum,
    na.rm=TRUE)
colnames(data) = c("subj","item","AOI","cond","sum")

# sort
data <- data[order(data$subj, data$item),]

# set colname "variable","value" to use cast()
colnames(data) = c("subj","item","variable","cond","value")
head(data)
# cast creates separate columns for each object fixated

data2 <- cast(data)
head(data2)

# replace NULL
data2$BackGround <- ifelse(is.na(data2$BackGround), 0, data2$BackGround)
data2$A<- ifelse(is.na(data2$A), 0, data2$A)
data2$B<- ifelse(is.na(data2$B), 0, data2$B)
data2$C<- ifelse(is.na(data2$C), 0, data2$C)
data2$D<- ifelse(is.na(data2$D), 0, data2$D)

data2$Target <- ifelse((data2$cond == "a" | data2$cond == "b"), data2$C, data2$D)
head(data2)

#  head(data2)
# # subj item cond   A   B BackGround   C D Target all      logit
# 1  P05    1    a   0 195          0  99 0     99 294 -0.6754027
# 2  P05    2    d   0 400          0   0 0      0 400 -6.6858609
# 3  P05    3    c 391   0          0   0 0      0 391 -6.6631327
# 4  P05    4    b   0   0          0 347 0    347 347  6.5439118
# 5  P05    5    a 328   0          0   0 0      0 328 -6.4876840
# 6  P05    6    d 101 223          0   0 0      0 324 -6.4754327

# calculate ALL column
data2$all <-  (data2$BackGround
              + data2$A
              + data2$B
              + data2$C
              + data2$D)

data2$logit <- log((data2$Target + 0.5) / (data2$all - data2$Target + 0.5))

# making 2 by 2
data2$npi <- ifelse(data2$cond == "a" | data2$cond == "c", 1, 0)
data2$aff <- ifelse(data2$cond == "a" | data2$cond == "b", 1, 0)

# scaling
data2$npi <- scale(data2$npi, scale=T)
data2$aff <- scale(data2$aff, scale=T)

# data2$logit<-data2$logit_c
tapply(data2$logit, list(data2$npi, data2$aff), mean)

sum(data2[data2$cond == "a",]$Target)
sum(data2[data2$cond == "b",]$Target)

ここでmadballつかえたら楽しいだろうなぁ。

# data
# dependent :ｙ
# ...: predictor
# rondom1: subj
# rondom2: item

# selectLmeModel <- function(dependent, fix1, fix2, rondom1, rondom2){
#   m10 <- lmer(
#     dependent ~ fix1 * fix2
#     + (1 + fix1 + fix2 + fix1:fix2 |rondom1)
#     + (1 + fix1 + fix2 + fix1:fix2 |rondom2))
#   # ランダム変数名と固定変数名を取得して、それを予測式から外す関数が必要
#   summary(m10)
#   print(VarCorr(m10), comp=c("Variance"))
#   capture.output(print(VarCorr(m10), comp=c("Variance")))
#
#   length(capture.output(print(VarCorr(m10), comp=c("Variance"))))
#
#   modelvar <- print(VarCorr(m10), comp=c("Variance","Std.Dev"))
#   print(modelvar)
#   m00 <- lmer(dependent ~ fix1 * fix2 + (1 | rondom1) + (1 | rondom2))
#   anova(m10, m00)
# }
#
# selectLmeModel(data2$logit, data2$npi, data2$aff, data2$subj, data2$item)

#   m00 <- lmer(dependent ~ fix1 * fix2 + (1 | rondom1) + (1 | rondom2))
#   anova(m10, m00)

# # #汎用性LMEモデル
m10 <- lmer(logit ~ npi * aff + (1 + npi*aff |subj) + (1 + npi*aff |item), data = data2)
# m09 <- lmer(logit ~ npi * aff + (1 + aff+npi:aff |subj) + (1 + npi*aff |item), data = data2)
m00 <- lmer(logit ~ npi * aff + (1 |subj) + (1 |item), data = data2)

anova(m10, m00)

# m10wi <- lmer(logit ~ npi * aff + (1 + npi*aff |subj) + (1 + npi*aff |item), data = data2)
# m10woi <- lmer(logit ~ npi + aff + (1 + npi*aff |subj) + (1 + npi*aff |item), data = data2)
# anova(m10wi, m10woi)
# m10 <- lmer(logit ~ npi * aff + (1 + npi*aff |subj) + (1 + npi*aff |item), data = data2)
# m10 <- lmer(logit ~ npi * aff + (1 + npi*aff |subj) + (1 + npi*aff |item), data = data2)



# m10_noccor <- lmer(logit ~ npi * aff + (1 + npi*aff ||subj) + (1 + npi*aff || item), REML=F, data = data2)

# # # conv
# m09 <- lmer(logit ~ npi * aff + (1 + aff + npi |subj) + (1 + npi*aff |item), data = data2)
#
# m08 <- lmer(logit ~ npi * aff + (1 + aff |subj) + (1 + npi*aff |item), data = data2)
# m07 <- lmer(logit ~ npi * aff + (1 + aff |subj) + (1 + npi+aff |item), data = data2)
# m06 <- lmer(logit ~ npi * aff + (1 + aff |subj) + (1 + npi |item), data = data2)
# m07 <- lmer(logit ~ npi * aff + (1 + aff + npi:aff |subj) + (1 + npi:aff |item), data = data2)
# # conv
# m06 <- lmer(logit ~ npi * aff + (1 + npi:aff |subj) + (1 + npi:aff |item), data = data2)
#
# # signif
# anova(m09,m06)
#
# m09wi <- lmer(logit ~ npi * aff + (1 + aff + npi:aff |subj) + (1 + npi*aff |item), data = data2)
# m09woi <- lmer(logit ~ npi + aff + (1 + aff + npi:aff |subj) + (1 + npi*aff |item), data = data2)
# m09won <- lmer(logit ~ aff * npi:aff + (1 + aff + npi:aff |subj) + (1 + npi*aff |item), data = data2)
# m09woa <- lmer(logit ~ npi + npi:aff + (1 + aff + npi:aff |subj) + (1 + npi*aff |item), data = data2)
#
#anova(m09wi, m09woi)
#
# m08 <-     lmer(logit ~ aff * npi:aff + (1 + npi+aff |subj) + (1 + npi+aff |item), data = data2)
# m08wi  <-  lmer(logit ~ npi * aff + (1 + npi+aff |subj) + (1 + npi+aff |item), data = data2)
# m08woi  <-  lmer(logit ~ npi + aff + (1 + npi+aff |subj) + (1 + npi+aff |item), data = data2)
# m08won  <-  lmer(logit ~ aff + npi:aff + (1 + npi+aff |subj) + (1 + npi+aff |item), data = data2)
# m08woa  <-  lmer(logit ~ npi + npi:aff + (1 + npi+aff |subj) + (1 + npi+aff |item), data = data2)

# m09wi <- lmer(logit ~ npi * aff + (1 + aff + npi |subj) + (1 + npi*aff |item), data = data2)
# m09woi <- lmer(logit ~ npi + aff + (1 + aff + npi |subj) + (1 + npi*aff |item), data = data2)
# m09won <- lmer(logit ~ aff + npi:aff + (1 + aff + npi |subj) + (1 + npi*aff |item), data = data2)
# m09woa <- lmer(logit ~ npi + npi:aff + (1 + aff + npi |subj) + (1 + npi*aff |item), data = data2)
#
# summary(m09wi)
#
# # npi
# anova(m09wi, m09won)
#
# # aff
# anova(m09wi, m09woa)
#
# # npi:aff(interaction)
# anova(m09wi, m09woi)
#
m00wi  <-  lmer(logit ~ npi * aff + (1|subj) + (1|item), data = data2)
m00woi  <-  lmer(logit ~ npi + aff + (1|subj) + (1|item), data = data2)
m00won  <-  lmer(logit ~ aff + npi:aff + (1|subj) + (1|item), data = data2)
m00woa  <-  lmer(logit ~ npi + npi:aff + (1|subj) + (1|item), data = data2)

summary(m00wi)

# npi
anova(m00wi, m00won)

# aff
anova(m00wi, m00woa)

# npi:aff(interaction)
anova(m00wi, m00woi)

# みねみんのスライドに
# backward stepwise の方法が書いてあったので参照。
#
# latex(m00, file='',booktabs=T,dcolumn=T)
# library(xtable)
```
