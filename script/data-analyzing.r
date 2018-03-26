# data analyzing


1.  if(!require(<name>)){install.packages("<name>")}
    * it does "library(<name>)." if R doesn't have the package, R installs it.
1. library に対して、require は読み込みに失敗した時にサインを出す
1. knitr is awesome. Highly recommended!
    * [Knitr is Awesome!](https://www.r-bloggers.com/knitr-is-awesome/)
    * [Markdown テーブル](https://stats.biopapyrus.jp/r/devel/md-table.html)
1. beepr allows you not to leave while waiting.
    * [beepr-stackoverflow](https://stackoverflow.com/questions/3365657/is-there-a-way-to-make-r-beep-play-a-sound-at-the-end-of-a-script)
1. set up (set wd, import libs, and read data)

```R
getwd()
setwd("/home/kishiyama/home/thesis/ntu-ut-ling-vwp/result")

# install package required.
if(!require(lme4)){install.packages("lme4")}
if(!require(reshape)){install.packages("reshape")}
if(!require(reshape2)){install.packages("reshape2")}
if(!require(ggplot2)){install.packages("ggplot2")}
if(!require(knitr)){install.packages("knitr")}
if(!require(beepr)){install.packages("beepr")}
if(!require(lmerTest)){install.packages("lmerTest")}
# if(!require(magrittr)){install.packages("magrittr")}
if(!require(devtools)){install.packages("devtools")}
install_github("kisiyama/mudball",ref="master",force=TRUE)
require(mudball)

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

if(!require(knitr)){install.packages("knitr")}
if(!require(lmerTest)){install.packages("lmerTest")}
if(!require(devtools)){install.packages("devtools")}
install_github("kisiyama/mudball",ref="master",force=TRUE)
require(mudball)

model <- lmer(logit ~ npi * aff + (1 + npi*aff |subj) + (1 + npi*aff |item), data = data2)
model_0 <- lmer(logit ~ npi * aff + (1 |subj) + (1 |item), data = data2)

best_model = mudball::step(model,beeping=T)
best_model_summary = lmerTest::summary(best_model)
fixed_effects = best_model_summary$coefficients
model_call = best_model_summary$call
log_name = "lmer.log"
write("#############################",file=log_name, append=TRUE)
write("",file=log_name, append=TRUE)
kable(fixed_effects, format = "markdown")
write("",file=log_name, append=TRUE)
write(as.character(model_call), file=log_name, append=TRUE)
write("#############################", file=log_name, append=TRUE)

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
```
