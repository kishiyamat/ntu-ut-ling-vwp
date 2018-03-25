# data-visualizing

* グラフの作成
    1. コンディションごと
    1. x に時間軸
    1. y に割合

1. データの整形(本来はformattingの部分ですべきだが、formatの時点ではbaseの区間が分からない。)
1. データの可視化

## PupilDilationRate を加える。

BEFORE

```R
> head(data_all)
  ParticipantName SegmentName PupilLeft Timestamp hoge piyo ItemNo Condition
1             P05   Segment 1  1.867083       100    1    3      6         d
2             P05   Segment 1  2.041333       200    1    3      6         d
3             P05   Segment 1  2.044483       300    1    3      6         d
4             P05   Segment 1  2.049333       400    1    3      6         d
5             P05   Segment 1  2.099667       500    1    3      6         d
```

AFTER

```R
> head(DataFrameWithPupilDilationRate[DataFrameWithPupilDilationRate$ParticipantName == "P08",])
     ParticipantName SegmentName PupilLeft Timestamp hoge piyo ItemNo Condition
4531             P08   Segment 1  3.390667       100    2    3     15         d
4532             P08   Segment 1  3.346333       200    2    3     15         d
4533             P08   Segment 1  3.380333       300    2    3     15         d
4534             P08   Segment 1  3.431818       400    2    3     15         d
4535             P08   Segment 1        NA       500    2    3     15         d
4536             P08   Segment 1        NA       600    2    3     15         d
     PupilDilationRate
4531         0.9545089
4532         0.9420286
4533         0.9516000
4534         0.9660935
4535                NA
4536                NA
```

## 方法

* グラフ化の前の前処理
    * `date frame` に
    * `任意の区間` の瞳孔経の平均に対する rate を
    * append する関数を作る。

```R
appendPupilDilationRate = function(data_frame, begin_ms, end_ms){

    # initialize
    pupil_dilation_rate = data.frame(NULL)

    # check if the data frame fulfills the prerequisite.
    col_names = colnames(data_frame)
    if(
        "ParticipantName" %in% col_names &
        "SegmentName" %in% col_names &
        "PupilLeft" %in% col_names &
        "Timestamp" %in% col_names
    ){}else{
        warning("wrong data frame has come")
    }

    # 全ての被験者内の全てのセグメントで平均を求め、DF<means>に追加する。
    participant_names = levels(droplevels(data_frame$ParticipantName))
    for(participant_name in participant_names){
        participant_data = data_frame[data_frame$ParticipantName==participant_name,]
        segment_names = levels(droplevels(participant_data$SegmentName))
        for(segment_name in segment_names){
            segment_data = participant_data[participant_data$SegmentName==segment_name,]
            pupil_mean_data = segment_data[segment_data$Timestamp >= begin_ms & segment_data$Timestamp <= end_ms,]$PupilLeft
            mean_for_segment = mean(pupil_mean_data, na.rm=TRUE)
            # 44. データの加工と抽出
            # http://cse.naro.affrc.go.jp/takezawa/r-tips/r/44.html
            # transform の項に含まれる=の左辺がそのままカラム名になる。
            temp = transform(data_frame[data_frame$ParticipantName==participant_name & data_frame$SegmentName==segment_name,],
                PupilDilationRate=data_frame[data_frame$ParticipantName==participant_name & data_frame$SegmentName==segment_name,]$PupilLeft / mean_for_segment)
            pupil_dilation_rate = rbind(pupil_dilation_rate, temp)
        }
    }
    return(pupil_dilation_rate)
}

getwd()
setwd("/home/kishiyama/home/thesis/npi-thesis/result/main4pupil/tsv")
load("../csv/data_all.dat")
pupil_dilation_rate_data = appendPupilDilationRate(data_all, 0, 2000)
# pupil_dilation_rate_data$Condition = factor(pupil_dilation_rate_data$Condition, levels=c("a","b","c","d"))
save(pupil_dilation_rate_data, file="../csv/pupil_dilation_rate_data.dat")
rm(pupil_dilation_rate_data)
load("../csv/pupil_dilation_rate_data.dat")
```

<!-- データの区切り方というか、`break`のパラメターを変えたい場合は formatting のコードをいじってください。 -->
aggregate してコンディション毎にする。

```R

# グラフの作成

# ディレクトリの確認から
getwd()
setwd("/home/kishiyama/home/thesis/npi-thesis/result/main4pupil")

# pupil_dilation_rate_data が落ちてくる
load("csv/pupil_dilation_rate_data.dat")
full_data = pupil_dilation_rate_data

# タイムスタンプを揃える
begin = 2000
end = 7900
selected_data = full_data[full_data$Timestamp >= begin & full_data$Timestamp <= end,]

# aggregate for each trial (participants x items)
mean_pupil_dilations = aggregate(
    x=selected_data$PupilDilationRate,
    by=list(selected_data$Timestamp, selected_data$Condition),
    FUN=mean,
    na.rm=TRUE)

colnames(mean_pupil_dilations) = c("Timestamp", "Condition", "PupilDilationRate")
mean_pupil_dilations = mean_pupil_dilations

save(mean_pupil_dilations, file="../csv/mean_pupil_dilations.dat")
rm(mean_pupil_dilations)
load("../csv/mean_pupil_dilations.dat")
```

グラフ化します。

```R

# ライブラリーとデータの読み込み
library(ggplot2)
library(reshape)
library(plyr)

load("../csv/mean_pupil_dilations.dat")

# たまにconditionのレベルの並びが変
# http://deerfoot.exblog.jp/7900094/
mean_pupil_dilations$Condition = factor(mean_pupil_dilations$Condition, levels=c("a","b","c","d"))
# rename
mean_pupil_dilations$Condition =
    revalue(mean_pupil_dilations$Condition,
        c("a"="NPI+AFF+:(sika->aru)",
        "b"="NPI-AFF+:(dake->aru)",
        "c"="NPI+AFF-:(sika->nai)",
        "d"="NPI-AFF-:(dake->nai)")
    )

# 縦ライン
# d = data.frame(t = c(2000 , 2800 , 3300 , 3500 , 4100, 4700 , 5500, 5700, 5900, 7700,7900),
#         region = c(""   , "N1" , "NPI", ""   , "V1", "POL", "N2", "wo", "",   "V2",""))

begin = 4300
end = 5100

selected_data =mean_pupil_dilations[
    mean_pupil_dilations$Timestamp >= begin &
    mean_pupil_dilations$Timestamp <= end,]

graph =
    ggplot(data=selected_data, aes(x=Timestamp, y=PupilDilationRate, colour=Condition)) +
    # geom_vline(data=d, mapping=aes(xintercept=t), linetype=3, color="black") +
    # geom_text(data=d, mapping=aes(x=t, y=1.125, label=region),
    #    size=5, angle=90, vjust=-0.4, hjust=0 , color="#222222", family="mono") +
    geom_line(aes(group=Condition, color=Condition)) +
    scale_x_continuous("Time", breaks=seq(begin, end, by=500)) +
    scale_y_continuous(limits=c(1,1.13), name="Proportion of pupil size") +
    scale_color_discrete("Condition") +
    theme(axis.title.y = element_text(size=16)) +
    theme(axis.title.x = element_text(size=20)) +
    theme(axis.text.x = element_text(angle=45, hjust=1))+
    theme(legend.title = element_text(size=16)) +
    theme(legend.text = element_text(size=20)) +
    # theme_bw() +
    theme_classic()+
    ggtitle("The proportion of pupil size for each 100 ms time window")  

ppi = 600
graph
pdf_name = sprintf("scaled_pupil_%s_to_%s.pdf",begin,end)
dev.copy(pdf, sprintf("../pdf/%s",pdf_name))
dev.off()
```

* 区間選択がちょっとかしこい
* ファイル名の生成も自動化されてる
