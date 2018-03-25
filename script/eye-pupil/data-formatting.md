<!-- # 0. 環境設定

適切なディレクトリにいることを
データの読み込みの際に確認しましょう。

```R
getwd()
setwd("/home/kishiyama/home/thesis/npi-thesis/result/main4pupil/tsv")
```
 -->

# data-formatting

csv形式でデータを保存するところまで進めます。

まずはディレクトリの中身を確認します。
Linuxの場合は `tree` コマンドが便利でしょう。

```tree
main4pupil
├── csv
└── tsv
    ├── npi_2017_New test_Rec 05_Segment 1.tsv
    ├── npi_2017_New test_Rec 05_Segment 10.tsv
    ├── npi_2017_New test_Rec 05_Segment 11.tsv
    :
    ├── npi_2017_New test_Rec 40_Segment 7.tsv
    ├── npi_2017_New test_Rec 40_Segment 8.tsv
    └── npi_2017_New test_Rec 40_Segment 9.tsv

2 directories, 790 files
```

## ファイルリスト

処理を一度に行うために、任意のパターンに対応した
ファイルリストを作成します。

眼球運動データは Tobii Studio から吐き出す際、
以下のフォーマットで自動保存されます。
`<project名>_<test名>_<被験者名>_<segment名>.tsv`
したがって、今回の `<project名>_<test名>` は
`npi_2017_New test` となります。
この `npi_2017_New test` をパターンとして指定し、
`list.files()` 関数を使ってリストを読む関数を作ります。

```R
file_pattern = "npi_2017_New test"

# input: character
# output: list OR boolean
getListWithPattern = function(file_pattern){
    data_list = as.list(list.files(pattern = file_pattern))
    if (length(data_list) == 0){
        warning('ミスマッチパターン
        1.正しいディレクトリにいるか
        2.ファイルパターンは正確か
        を確認してください。')
        return(FALSE)
    }else{
        message("file list loaded!")
        return(data_list)
    }
}

data_list = getListWithPattern(file_pattern)
```

## 1.2. 瞳孔の情報が入ってないデータを取り除く

取り除くべきファイルを取り除かないとエラーが吐かれるので、
瞳孔の情報が一個も入っていないデータを取り除いたリストを作ります。
これで既存のデータに手を加える必要性がなくなる。

```R
# input: list
# output: list
filterOutBadTrials = function(data_list){
    filtered_list = as.list(NULL)
    for(file_name in data_list){
        trial = read.table(file_name, head=T, sep="\t", na.string="NA", encoding="UTF-8")
        # PupilLeft に data がある(naで*ない*)試行を取得する
        dilations_in_trial = trial[!(is.na(trial$PupilLeft)),]
        if(nrow(dilations_in_trial) == 0){
            warning(paste("Bad trial:",file_name))
        }else{
            filtered_list = append(filtered_list, file_name)
        }
    }
    if (length(filtered_list) == length(data_list)){
        message("there's no bad trial!")
    }
    return(filtered_list)
}

filtered_data_list = filterOutBadTrials(data_list)
```


## 1.3. 全員分のデータを一つのファイルにまとめる

一つのファイルに対する作業

0. ファイル名を読み込んで data.frame を返す。
1. data.frame を入力に、Timestampを加えたり、カラムを削ったりの修正を行った data.frame を返す。
1. data.frame を入力に、同じFixationになっている時間帯を一つの行にまとめる。
1. E-prime情報を区切ってbase_data_frameの右側に(StudioEventDataの隣から)マッピングする。

以上の関数を順番にfor文で全てのファイルに適用します。


### 1.3.1. 必要な関数を定義


*0.* ファイル名を読み込んで data.frame を返す関数

入力例：

```R
"npi_2017_New test_Rec 05_Segment 1.tsv"
```

出力例：
```R
> head(getDataFrameFromFileName("npi_2017_New test_Rec 05_Segment 1.tsv"))
  ParticipantName SegmentName SegmentStart SegmentEnd SegmentDuration
1             P05   Segment 1        51212      61655           10443
2             P05   Segment 1        51212      61655           10443
3             P05   Segment 1        51212      61655           10443
4             P05   Segment 1        51212      61655           10443
5             P05   Segment 1        51212      61655           10443
6             P05   Segment 1        51212      61655           10443
  RecordingTimestamp  StudioEvent StudioEventData FixationIndex SaccadeIndex
1              51212 SceneStarted 1 3 6 d A D C B            NA            1
2              51213                                         NA            1
3              51217                                         NA            1
4              51220                                         NA           NA
5              51223                                         NA            2
6              51227                                         NA            2
  GazeEventType GazeEventDuration FixationPointX..MCSpx. FixationPointY..MCSpx.
1       Saccade                63                     NA                     NA
2       Saccade                63                     NA                     NA
3       Saccade                63                     NA                     NA
4  Unclassified                 3                     NA                     NA
5       Saccade                10                     NA                     NA
6       Saccade                10                     NA                     NA
  PupilLeft PupilRight  X
1        NA         NA NA
2      1.54       2.42 NA
3      1.70       2.00 NA
4      2.14       2.05 NA
5      1.59       2.05 NA
6      1.53       2.03 NA
>
```

定義：
```R

# object: ファイル名を読み込んで data.frame を返す
# input ： character
    # name of the file
# return: data.frame
    # [1] "ParticipantName"        "SegmentName"            "SegmentStart"           "SegmentEnd"             "SegmentDuration"        "RecordingTimestamp"    
    # [7] "StudioEvent"            "StudioEventData"        "FixationIndex"          "SaccadeIndex"           "GazeEventType"          "GazeEventDuration"     
    # [13] "FixationPointX..MCSpx." "FixationPointY..MCSpx." "PupilLeft"              "PupilRight"             "X"

getDataFrameFromFileName = function(file_name){
    data_frame = read.table(file_name, head=T, sep="\t", na.string="NA", encoding="UTF-8")
    return(data_frame)
}
```

*1.* data.frame を入力に、Timestamp を加え、必要なデータに削減する関数

元々は以下のカラムが存在するテーブルを、
```R
colnames(selected_column) = c("ParticipantName", "SegmentName", "SegmentStart", "SegmentEnd", "SegmentDuration",
    "RecordingTimestamp", "FixationIndex", "SaccadeIndex", "GazeEventType", "GazeEventDuration",
    "FixationPointX", "FixationPointY", "PupilLeft", "PupilRight")
```

以下のカラムが存在するテーブルに削る。

```R
  ParticipantName SegmentName PupilLeft PupilRight Timestamp
2             P05   Segment 1      1.54       2.42         1
3             P05   Segment 1      1.70       2.00         5
4             P05   Segment 1      2.14       2.05         8
5             P05   Segment 1      1.59       2.05        11
6             P05   Segment 1      1.53       2.03        15
7             P05   Segment 1      2.05       2.02        18
```

この段階で削るのはいかがでしょうか。
segment ごとに扱ってますし。

```R

# object: data.frameの 一次整形
# input : data.frame
    # ParticipantName, SegmentName,
        # SegmentStart, SegmentEnd, SegmentDuration, RecordingTimestamp, StudioEvent, StudioEventData,
    # FixationIndex,
        # SaccadeIndex,
    # GazeEventType, GazeEventDuration
    # FixationPointX..MCSpx., FixationPointY..MCSpx.,
        # PupilLeft, PupilRight, X
# return : data.frame
    # ParticipantName, SegmentName,
    # PupilLeft, Timestamp

reduceRawDataFrame = function(raw){
    # Segmentの開始時を0としたTimestampを得る
    # SegmentStart: trialの開始点
    # RecordingTimestamp: recording point の時間点
    selected_column = raw[,c("ParticipantName",
        "SegmentName", "SegmentStart", "RecordingTimestamp",
        "PupilLeft")]
    column_with_timestamp = NULL
    selected_column$Timestamp = selected_column$RecordingTimestamp - selected_column$SegmentStart
    column_with_timestamp = selected_column

    # 必要なカラム、レコードのみ選択する
    selected_column = column_with_timestamp[,c("ParticipantName", "SegmentName",
        "PupilLeft", "Timestamp")]
    segment = selected_column[!(is.na(selected_column$PupilLeft)),]

    # 100ms ごとで平均をとってデータを削減する。
    participant_name = levels(droplevels(segment$ParticipantName))
    segment_name = levels(droplevels(segment$SegmentName[1]))

    # 100msごとにくぎるため、もっとも大きいスタンプを取得する
    ceiling_timestamp = max(segment$Timestamp)
    bin = 50
    segment_base = seq(bin, ceiling_timestamp+bin, bin)

    # ここに格納する
    segment_means = as.list(NULL)

    for(i in segment_base){
        data_frame_between_breaks = segment[segment$Timestamp > i-bin & segment$Timestamp <= i,]
        # 値が存在しないとNaNになります。
        mean_between_breaks = mean(data_frame_between_breaks$PupilLeft)
        segment_means = append(segment_means, mean_between_breaks)
    }

    # 被験者名やセグメント名をスタンプの数だけ複製し、データフレームに埋め込む
    reduced_segment = data.frame(
        ParticipantName=rep(participant_name,length(segment_base)),
        SegmentName=rep(segment_name,length(segment_base)),
        PupilLeft=unlist(segment_means, use.names=FALSE),
        Timestamp=segment_base)

    return(reduced_segment)
}

# ここは一応、まだ区切る段階ではない。データ整形の範疇
# もともとのデータフレームにレベルの情報が残ってしまっているため、一度 droplevels 関数を当てる
# segment = data_all[data_all$ParticipantName=="P05" & data_all$SegmentName=="Segment 1",]

```
*2.1* E-prime情報を区切ってbase_data_frameの右側に(StudioEventDataの隣から)マッピング

StudioEventData のみを撮ってくる関数を作ったほうが良さそう。
E-prime から Tobii に送る信号は StudioEventData に記録される
それを取り出して別の object にしておいて後で区切る

<!--
l = extractStudioEventDataList("npi_2017_New test_Rec 05_Segment 1.tsv")
-->


```R
# input: file_name(character)
extractStudioEventDataList = function(file_name) {
    # excel などだと2行目だが、head=T で読んでいるので1行目は head 扱い。
    raw_data_frame = getDataFrameFromFileName(file_name)
    eventdata = raw_data_frame[1,]$StudioEventData

    # 文字形式（Factorでも数値でもない）に変換して base_data_frame に加える
    StudioEventData = as.character(eventdata)

    # E-prime情報を空白で区切ってlistにまとめる。
    list_of_eventdata = unlist(strsplit(StudioEventData, " "))

    return(list_of_eventdata)
}
```

*2.2* E-prime情報を区切ってbase_data_frameの右側に(StudioEventDataの隣から)マッピング


```R

# input1： list
# input2: data.frame(with StudioEventData)
    # [1] "ParticipantName"        "SegmentName"            "SegmentStart"           "SegmentEnd"             "SegmentDuration"        "RecordingTimestamp"    
    # [7] "StudioEvent"            "StudioEventData"        "FixationIndex"          "SaccadeIndex"           "GazeEventType"          "GazeEventDuration"     
    # [13] "FixationPointX..MCSpx." "FixationPointY..MCSpx." "PupilLeft"              "PupilRight"             "X"
# return: data.frame (with E-prime情報)

addStudioEventDataList = function(list_of_eventdata, base_data_frame) {
    # matrix()関数を使って、一列しかなかった list を8ずつ切って横にならべ、
    # base_data_frame と同数の行を持つ data_frame にします。
    mat_of_eventdata = matrix(data=list_of_eventdata,
        nrow=nrow(base_data_frame), ncol=length(list_of_eventdata), byrow=T)
    eventdata_data_frame = as.data.frame(mat_of_eventdata)
    colnames(eventdata_data_frame) = c("hoge", "piyo", "ItemNo", "Condition",
        "AOI1", "AOI2", "AOI3", "AOI4")  
    eventdata_data_frame = eventdata_data_frame[,c("hoge", "piyo", "ItemNo", "Condition")]

    # Tobii の計測データ と E-prime からの eventdata を合併します。
    data_with_eventdata = cbind(base_data_frame, eventdata_data_frame)

    return(data_with_eventdata)
}
```

### 1.3.2. 実行部分

tempを使わないように書き換える。

```R
getwd()
setwd("/home/kishiyama/home/thesis/npi-thesis/result/main4pupil/tsv")

# initialize

# 必要なpackage # cast(), melt()などデータの分解、横/縦立て直し
# library(reshape)

# 処理した全員分のデータをループ式で足していく
data_all = NULL

# E-prime から Tobii に送る信号の項目数を先に指定しておく。
# 実験デザイン時に必要な項目を指定する
numcol = 8

file_pattern = "npi_2017_New test"
file_list = getListWithPattern(file_pattern)
data_list = filterOutBadTrials(file_list)

measureTime = function(f_name){
    timestamp(stamp = date(),
        prefix = paste(f_name,"-> "),
        suffix = "",
        quiet = FALSE)}

# TODO: bottle neck を探す
# どんどん遅くなる
for(i in 1:length(data_list)){
    print(paste("now access to:", data_list[i]))

    # ファイル名を読み込んで data.frame を返す
    # measureTime("getDataFrameFromFileName")
    raw_data_frame = getDataFrameFromFileName(as.character(data_list[i]))

    # measureTime("reduceRawDataFrame")
    # data.frame に Timestamp を加え、必要な情報のみに reduce する。
    reduced_data_frame = reduceRawDataFrame(raw_data_frame)

    list_of_eventdata = extractStudioEventDataList(as.character(data_list[i]))

    # numcol=8 と StudioEventData の数が一致していることを確認
    if (length(list_of_eventdata)!=numcol){
        warning(paste("Bad trial: ", data_list[i]))
    }

    # measureTime("addStudioEventDataList")
    # E-prime情報を区切って base_data_frame の右側にマッピングします。
    data_with_eventdata = addStudioEventDataList(list_of_eventdata, reduced_data_frame)

    # できたデータを一人分ずつdata_allの下から付け加える。
    data_all = rbind(data_all, data_with_eventdata)
}

# このままやると100mbのデータになる…。
# bin を 50 にしてみた。動けばコミット。それでも1/10の大きさになってるはず。
# file IO は1/10でも結構変わるかも。
write.csv(data_all, "../csv/output.csv", row.names=F)

# ファイル data_all.dat はテキストデータではない！
# 直接編集しないから、バイナリーにしちゃって良いかも。
save(data_all, file="../csv/data_all.dat")
rm(data_all)
load("../csv/data_all.dat")
```
