# data trimming

To investigate the eye-movements, we need at least

1. the area where they focused (AOI)
1. the content on the area of interest (AOI1,AOI2,...)
1. the time when they focused on the area (GazeStart, GazeEnd)
1. the information about the participants (ParticipantName)
1. the condition of the trial (Condition)
1. the item in the trial (ItemNo)

And they will look like this:

```csv
"ParticipantName","SegmentName","FixationPointX","FixationPointY","GazeStart","GazeEnd","Order","List","ItemNo","Condition","AOI1","AOI2","AOI3","AOI4","AOI"
"P05","Segment 1",839,446,88,188,"1","3","6","d","A","D","C","B",1
"P05","Segment 1",927,449,215,368,"1","3","6","d","A","D","C","B",1
"P05","Segment 1",589,340,425,575,"1","3","6","d","A","D","C","B",1
"P05","Segment 1",417,256,615,801,"1","3","6","d","A","D","C","B",1
"P05","Segment 1",424,181,831,1048,"1","3","6","d","A","D","C","B",1
```

By contrast, the outputs from Tobii have

1. x y coordinate of the gaze event
    * but not AOI information
    > we need to specify the AOI from the coordinates
1. time stamp from the onset of the trial
    * but not the exact time when they focused on the area (GazeStart, GazeEnd)
1. mixed information of the gaze event type 
    * not only fixation but also saccade and unclassified
1. information from E-Prime(StudioEvent)
    * somehow we need to retrieve it from the row.

And look like this:

```tsv
ParticipantName SegmentName     SegmentStart    SegmentEnd      SegmentDuration RecordingTimestamp      StudioEvent     StudioEventData FixationIndex   SaccadeIndex    GazeEventType   GazeEventDuration       FixationPointX (MCSpx)  FixationPointY (MCSpx)  PupilLeft       PupilRight      
P05     Segment 1       51212   61655   10443   51212   SceneStarted    1 3 6 d A D C B         1       Saccade 63                                      
P05     Segment 1       51212   61655   10443   51213                           1       Saccade 63                      1.54    2.42    
P05     Segment 1       51212   61655   10443   51217                           1       Saccade 63                      1.70    2.00    
P05     Segment 1       51212   61655   10443   51220                                   Unclassified    3                       2.14    2.05    
P05     Segment 1       51212   61655   10443   51223                           2       Saccade 10                      1.59    2.05    
```

### Makine some functions
#### Practice
```R
doubleMe <- function(argument){
    doubled_argument = argument * 2
    return((doubled_argument)) 
}
```

To make a function, you need:
* purpose
* name for new function
* function `function` which returns a function
* argument(s) if you want.

#### Data trimming

1. get the data frame from a file name
> here, I'd like to get a data from file name.
> but I don't want to repeat calling `read.table`
> because it requires some arguments.

```R
getDataFrameFromFileName <- function(file_name){
    data_frame <- read.table(file_name, head=T, sep="\t", 
    na.string="NA", encoding="UTF-8")
    return(data_frame)
}
```

```R
getwd()
# set dir to result
setwd("/home/kisiyama/home/thesis/ntu-ut-ling-vwp/result")
head(getDataFrameFromFileName("npi_2017_New test_Rec 05_Segment 1.tsv"))
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

Then, I would like to remove some colums.
1. removing columns not needed and adding Timestamps
1. extracting fixations(remove saccade and unclassified)
1. removing StudioEvent

#### Removing columns not needed and adding Timestamps

```R
# we assign the data frame to `raw` for test purpose.
# we can check the contents using `head` function
raw =  getDataFrameFromFileName("npi_2017_New test_Rec 05_Segment 1.tsv")

reduceRawDataFrame <- function(raw){
    # removing some columns
    selected_column <- raw[,c("ParticipantName", "SegmentName", "SegmentStart", "SegmentEnd", "SegmentDuration",
        "RecordingTimestamp", "FixationIndex", "SaccadeIndex", "GazeEventType", "GazeEventDuration",
        "FixationPointX..MCSpx.", "FixationPointY..MCSpx.", "PupilLeft", "PupilRight")]
    # renaming some of them
    renamed_column <- NULL
    colnames(selected_column) <- c("ParticipantName", "SegmentName", "SegmentStart", "SegmentEnd", "SegmentDuration",
        "RecordingTimestamp", "FixationIndex", "SaccadeIndex", "GazeEventType", "GazeEventDuration",
        "FixationPointX", "FixationPointY", "PupilLeft", "PupilRight")
    renamed_column <- selected_column
    # you can see the new data frame with tiny changes
    # head(renamed_column)

    # I would like to add Timestamps as new column
    # run the code before explaining it
    column_with_timestamp <- NULL
    renamed_column$Timestamp <- renamed_column$RecordingTimestamp - renamed_column$SegmentStart
    column_with_timestamp <- renamed_column
    # head(column_with_timestamp)
    # SegmentStart: onset of trial(e.g: 500)
    # RecordingTimestamp: recording point(e.g: 500--1000)

    # remove some columns(again)
    # now we don't need some of them.
    # ~~SegmantStart, SegmentEnd, SegmentDuration, RecordingTimestamp, PupilLeft, PupilRight~~
    selected_column <- column_with_timestamp[,c("ParticipantName", "SegmentName", "FixationIndex",
        "GazeEventType", "GazeEventDuration", "FixationPointX", "SaccadeIndex", "FixationPointY", "Timestamp")]

    # extacting Fixation and Saccade (other than Unclassified)
    # GazeEventType (Unclassified, Fixation, Saccade)
    selected_column <- selected_column[selected_column$GazeEventType != "Unclassified",]
    # Now, if FixationIndex is an NA,
    # the data in the row is about saccade.
    # so we can replace the NA with SaccadeIndex.
    selected_column$FixationIndex <- ifelse(is.na(selected_column$FixationIndex),
        selected_column$SaccadeIndex,
        selected_column$FixationIndex)

    # If the fixation point is NA, 
    # that means that they didn't see the display.
    # we replace NA with -1 so that we can tell that.
    selected_column$FixationPointX <- ifelse(is.na(selected_column$FixationPointX),
        -1,
        selected_column$FixationPointX)
    selected_column$FixationPointY <- ifelse(is.na(selected_column$FixationPointY),
        -1,
        selected_column$FixationPointY)

    # data for Index is in FixationIndex
    # So we can delete SaccadeIndex
    selected_column$SaccadeIndex <- NULL
    refined_column <- selected_column

    return(refined_column)
}

# run the function definition and check if it works
raw =  getDataFrameFromFileName("npi_2017_New test_Rec 05_Segment 1.tsv")
test = refineRawDataFrame(raw) 
head()
```

1. make data simpler based on Fixation
> integrate rows with the same fixation index into a row
1. make it clear when the fixation begins and ends

> Aggregate splits the data into subsets, computes summary statistics for each, and returns the result in a convenient form.

```R
addGazeFlag <- function(refined_data){
    # Making subset by FixationIndex
    # Getting min of timestamp in the subset...
    # is to specify the time when the fixation began
    min_table <- aggregate(
        x = refined_data$Timestamp,
        by = list(refined_data$ParticipantName, refined_data$SegmentName,
            refined_data$FixationIndex,refined_data$GazeEventType, refined_data$GazeEventDuration,
            refined_data$FixationPointX, refined_data$FixationPointY),
        FUN = min
    )
    colnames(min_table) <- c("ParticipantName", "SegmentName", "FixationIndex",
        "GazeEventType", "GazeEventDuration", "FixationPointX", "FixationPointY", "GazeStart")
    min_table <- min_table[order(min_table$ParticipantName,
    min_table$SegmentName, min_table$GazeStart),]

    # Specifying the time when the fixation ended 
    max_table <- aggregate(
        x = refined_data$Timestamp,
        by = list(refined_data$ParticipantName, refined_data$SegmentName, refined_data$FixationIndex,
        refined_data$GazeEventType, refined_data$GazeEventDuration,
        refined_data$FixationPointX, refined_data$FixationPointY),
        FUN = max
    )
    colnames(max_table) <- c("ParticipantName", "SegmentName", "FixationIndex",
        "GazeEventType", "GazeEventDuration", "FixationPointX", "FixationPointY", "GazeEnd")
    max_table <- max_table[order(max_table$ParticipantName,
        max_table$SegmentName, max_table$GazeEnd),]

    # conbine min_table and max_table('s GazeEnd)
    # it is in the 8th column
    data_with_gaze_flag <- cbind(min_table, max_table[,8])

    colnames(data_with_gaze_flag) <- c("ParticipantName", "SegmentName", "FixationIndex",
        "GazeEventType", "GazeEventDuration",
        "FixationPointX", "FixationPointY",
        "GazeStart", "GazeEnd")

    return(data_with_gaze_flag)
}
```

1. Extracting information of E-prime from a file taking a file name as an argument

<!--
l = extractStudioEventDataList("npi_2017_New test_Rec 05_Segment 1.tsv")
-->

```R
extractStudioEventDataList = function(file_name) {
    raw_data_frame = getDataFrameFromFileName(file_name)
    eventdata = raw_data_frame[1,]$StudioEventData
    StudioEventData = as.character(eventdata)
    list_of_eventdata = unlist(strsplit(StudioEventData, " "))
    return(list_of_eventdata)
}
```

1. Adding the extracted information

matrix function


```R
addStudioEventDataList = function(list_of_eventdata, base_data_frame) { # Using matrix function, 
    # this make a matrix object, which has 
    # the same number of rows as the base data frame
    # the same number of cols as the event data
    mat_of_eventdata = matrix(data=list_of_eventdata,
        nrow=nrow(base_data_frame), ncol=length(list_of_eventdata), byrow=T)
    eventdata_data_frame = as.data.frame(mat_of_eventdata)
    colnames(eventdata_data_frame) = c("Order", "List", "ItemNo", "Condition",
        "AOI1", "AOI2", "AOI3", "AOI4")  

    # combine the base data frame and event data
    data_with_eventdata = cbind(base_data_frame, eventdata_data_frame)

    return(data_with_eventdata)
}
```

### Main part

#### List of files

We need to make a list of files,
so that we can apply the functions we made to all files.

Data from Tobii has a format.
It looks like... 
`<project>_<test>_<participant>_<segment>.tsv`

This time it is `npi_2017_New test` and we 
1. set this pattern to the variable `file_pattern`
1. let R find the files with the pattern and set them to `data_list`
1. check if we correctly get the files

```R
getwd()
setwd("/home/kishiyama/home/thesis/ntu-ut-ling-vwp/result")
setwd("/home/kisiyama/home/thesis/ntu-ut-ling-vwp/result")

file_pattern <- "npi_2017_New test"
data_list <- list.files(pattern = file_pattern)
if (length(data_list) == 0){
    print('you might want to make some changes')
}else{
    print('loaded')
}
```

#### filter out files without fixation

1. make a blank list for the files with fixation
1. read each `file_name` and check if it has fixation
1. append the data with fixation to `filtered_list` 

```R
# input: list
# output: list
filterOutBadTrials = function(data_list){
    # create a list
    filtered_list = as.list(NULL)
    for(file_name in data_list){
        trial = read.table(file_name, head=T, sep="\t",
            na.string="NA", encoding="UTF-8")
        fixations_in_trial = trial[trial$GazeEventType == "Fixation",]
        if(nrow(fixations_in_trial) == 0){
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

## integrate data in each segment and participants

For each file, we are going to

1. get a data frame from a file name
    * string -> data frame
1. add Timestamps and remove columns not needed
    * data frame -> data frame
1. make data simpler based on Fixation
    * data frame -> data frame
1. append information from E-prime

We are going to append the formatted data to the variable `data_all`

```R
getwd()
setwd("/home/kishiyama/home/thesis/ntu-ut-ling-vwp/result")
setwd("/home/kisiyama/home/thesis/ntu-ut-ling-vwp/result")

data_all <- NULL

# make sure the number of columns which we let E-primesend to Tobi
numcol = 8
i = 1
for(i in 1:length(filtered_data_list)){
    print(paste("now access to:", data_list[i]))
    raw_data_frame = getDataFrameFromFileName(as.character(data_list[i]))
    # head(raw_data_frame)
    reduced_data_frame = reduceRawDataFrame(raw_data_frame)
    # head(reduced_data_frame)
    data_with_gaze= addGazeFlag(reduced_data_frame)
    # head(data_with_gaze)
    list_of_eventdata = extractStudioEventDataList(as.character(data_list[i]))
    # head(list_of_eventdata )
    # check if numcol of StudioEventData is 8
    if (length(list_of_eventdata)!=numcol){
        warning(paste("Bad trial: ", data_list[i]))
    }
    data_with_eventdata = addStudioEventDataList(list_of_eventdata,data_with_gaze)
    # head(data_with_eventdata)
    data_all = rbind(data_all, data_with_eventdata)
    # head(data_all)
}

```

## Mapping x y coordiante to AOI
1. the area where they focused (AOI)

```R
# we need to have data_all globally

# split 1080*1920 into four panes.
#  1  2
#  3  4
data_all$AOI <- ifelse(data_all$FixationPointX >= 0 & data_all$FixationPointX < 960
    & data_all$FixationPointY >= 0 & data_all$FixationPointY < 540,
    1,
    0)
data_all$AOI <- ifelse(data_all$FixationPointX >= 960 & data_all$FixationPointX < 1920
    & data_all$FixationPointY >= 0 & data_all$FixationPointY < 540,
    2,
    data_all$AOI)
data_all$AOI <- ifelse(data_all$FixationPointX >= 0 & data_all$FixationPointX < 960
    & data_all$FixationPointY >= 540 & data_all$FixationPointY < 1080,
    3,
    data_all$AOI)
data_all$AOI <- ifelse(data_all$FixationPointX >= 960 & data_all$FixationPointX < 1920
    & data_all$FixationPointY >= 540 & data_all$FixationPointY < 1080,
    4,
    data_all$AOI)

# extract Fixation
data_with_fixation <-data_all[data_all$GazeEventType == "Fixation",]

# remove unneccessary infomation
data_with_fixation$GazeEventDuration <- NULL
data_with_fixation$StudioEventData <- NULL
data_with_fixation$FixationIndex <- NULL
data_with_fixation$GazeEventType <- NULL

# before
head(getDataFrameFromFileName("npi_2017_New test_Rec 05_Segment 1.tsv"))
# after
head(data_with_fixation)

table(data_with_fixation$ParticipantName, data_with_fixation$SegmentName)

# savef as csv
# write.csv(data_with_fixation, "./csv/output.csv", row.names=F)
```

1. the area where they focused (AOI)
1. the content on the area of interest (AOI1,AOI2,...)
1. the time when they focused on the area (GazeStart, GazeEnd)
1. the information about the participants (ParticipantName)
1. the condition of the trial (Condition)
1. the item in the trial (ItemNo)

```R
# before
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

# after
   ParticipantName SegmentName FixationPointX FixationPointY GazeStart GazeEnd
35             P05  Segment 10           1338            306       443     566
34             P05  Segment 10           1338            305       723     886
41             P05  Segment 10            320            699      1489    1642
30             P05  Segment 10            505            277      1869    1999
26             P05  Segment 10            365            199      2042    2219
25             P05  Segment 10            406            176      2239    2362
   Order List ItemNo Condition AOI1 AOI2 AOI3 AOI4 AOI
35     1   26     23         c    D    C    A    B   2
34     1   26     23         c    D    C    A    B   2
41     1   26     23         c    D    C    A    B   3
30     1   26     23         c    D    C    A    B   1
26     1   26     23         c    D    C    A    B   1
25     1   26     23         c    D    C    A    B   1
> 
```

