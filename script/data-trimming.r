# for data trimming

getDataFrameFromFileName <- function(file_name){
    data_frame <- read.table(file_name, head=T, sep="\t",
    na.string="NA", encoding="UTF-8")
    return(data_frame)
}

reduceRawDataFrame <- function(raw){
    # 1. Renaming two columns for fixations
    # just selecting. "X.U.FEFF.ParticipantName" for Win. "ParticipantName" for Mac/Linux.
    selected_column <- raw[,c("X.U.FEFF.ParticipantName", "SegmentName", "SegmentStart", "SegmentEnd", "SegmentDuration",
        "RecordingTimestamp", "FixationIndex", "SaccadeIndex", "GazeEventType", "GazeEventDuration",
        "FixationPointX..MCSpx.", "FixationPointY..MCSpx.", "PupilLeft", "PupilRight")]
    # renaming some of them
    renamed_column <- NULL
    colnames(selected_column) <- c("ParticipantName", "SegmentName", "SegmentStart", "SegmentEnd", "SegmentDuration",
        "RecordingTimestamp", "FixationIndex", "SaccadeIndex", "GazeEventType", "GazeEventDuration",
        "FixationPointX", "FixationPointY", "PupilLeft", "PupilRight")
    renamed_column <- selected_column

    # 2. Adding Timestamps
    # I would like to add Timestamps as new column
    # run the code before explaining it
    column_with_timestamp <- NULL
    renamed_column$Timestamp <- renamed_column$RecordingTimestamp - renamed_column$SegmentStart
    column_with_timestamp <- renamed_column
    # head(column_with_timestamp)
    # SegmentStart is the  onset of trial(51212)
    # SegmentEnd is the offset of trial(61655)
    # RecordingTimestamp is the recording points(51212 to 61655)
    # Therefore, Timestamp -> 0 (51212-51212) to 10443(61655-51212)

    # 3. Removing columns not needed
    # now we don't need some of them.
    # because we have timestamp now.
    # ~~SegmantStart, SegmentEnd, SegmentDuration, RecordingTimestamp, PupilLeft, PupilRight~~
    selected_column <- column_with_timestamp[,c("ParticipantName", "SegmentName", "FixationIndex",
        "GazeEventType", "GazeEventDuration", "FixationPointX", "SaccadeIndex", "FixationPointY", "Timestamp")]

    # 4. Extacting Fixation and Saccade (other than Unclassified)
    selected_column <- selected_column[selected_column$GazeEventType != "Unclassified",]
    # Now, if FixationIndex is an NA,
    # the data in the row is about saccade.
    # so we can replace the NA with SaccadeIndex.
    selected_column$FixationIndex <- ifelse(is.na(selected_column$FixationIndex),
        selected_column$SaccadeIndex,
        selected_column$FixationIndex)

    # 5. Removing NA
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
    # So we can delete SaccadeIndex (see 4)
    selected_column$SaccadeIndex <- NULL
    refined_column <- selected_column

    return(refined_column)
}

addGazeFlag <- function(refined_data){
    # when the saccade/fixation starts
    min_table <- aggregate(
        x = refined_data$Timestamp,
        by = list(refined_data$ParticipantName, refined_data$SegmentName,
            refined_data$FixationIndex,refined_data$GazeEventType,
            refined_data$GazeEventDuration,
            refined_data$FixationPointX, refined_data$FixationPointY),
        FUN = min
    )
    colnames(min_table) <- c("ParticipantName", "SegmentName", "FixationIndex",
        "GazeEventType", "GazeEventDuration", "FixationPointX", "FixationPointY", "GazeStart")
    min_table <- min_table[order(min_table$ParticipantName,
        min_table$SegmentName, min_table$GazeStart),]

    # when the saccade/fixation ends
    max_table <- aggregate(
        x = refined_data$Timestamp,
        by = list(refined_data$ParticipantName, refined_data$SegmentName,
        refined_data$FixationIndex,
        refined_data$GazeEventType, refined_data$GazeEventDuration,
        refined_data$FixationPointX, refined_data$FixationPointY),
        FUN = max
    )
    colnames(max_table) <- c("ParticipantName", "SegmentName", "FixationIndex",
        "GazeEventType", "GazeEventDuration", "FixationPointX", "FixationPointY", "GazeEnd")
    max_table <- max_table[order(max_table$ParticipantName,
        max_table$SegmentName, max_table$GazeEnd),]

    # conbine min_table(GazeStart) and max_table(GazeEnd)
    # it is in the 8th column
    data_with_gaze_flag <- cbind(min_table, max_table[,8])

    colnames(data_with_gaze_flag) <- c("ParticipantName", "SegmentName", "FixationIndex",
        "GazeEventType", "GazeEventDuration",
        "FixationPointX", "FixationPointY",
        "GazeStart", "GazeEnd")

    return(data_with_gaze_flag)
}

extractStudioEventDataList = function(file_name) {
    raw_data_frame = getDataFrameFromFileName(file_name)
    eventdata = raw_data_frame[1,]$StudioEventData
    StudioEventData = as.character(eventdata)
    list_of_eventdata = unlist(strsplit(StudioEventData, " "))
    return(list_of_eventdata)
}

addStudioEventDataList = function(list_of_eventdata, base_data_frame) {
    # Using matrix function, 
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

# Start to make a list

getwd()
setwd("/home/kisiyama/home/thesis/ntu-ut-ling-vwp/result")

file_pattern <- "npi_2017_New test"
data_list <- list.files(pattern = file_pattern)

if (length(data_list) == 0){
    print('you might want to make some changes')
}else{
    print('loaded')
}

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

# Main part
# integrate data in each segment and participants

data_all <- NULL

# make sure the number of columns which we let E-primesend to Tobi
numcol = 8
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

## Mapping x y coordiante to AOI

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

# save as csv
# write.csv(data_with_fixation, "./csv/output.csv", row.names=F)

# for Mac/Linux
reduceRawDataFrame <- function(raw){
    # 1. Renaming two columns for fixations
    # just selecting. "X.U.FEFF.ParticipantName" for Win. "ParticipantName" for Mac/Linux.
    selected_column <- raw[,c("X.U.FEFF.ParticipantName", "SegmentName", "SegmentStart", "SegmentEnd", "SegmentDuration",
        "RecordingTimestamp", "FixationIndex", "SaccadeIndex", "GazeEventType", "GazeEventDuration",
        "FixationPointX..MCSpx.", "FixationPointY..MCSpx.", "PupilLeft", "PupilRight")]
    # renaming some of them
    renamed_column <- NULL
    colnames(selected_column) <- c("ParticipantName", "SegmentName", "SegmentStart", "SegmentEnd", "SegmentDuration",
        "RecordingTimestamp", "FixationIndex", "SaccadeIndex", "GazeEventType", "GazeEventDuration",
        "FixationPointX", "FixationPointY", "PupilLeft", "PupilRight")
    renamed_column <- selected_column

    # 2. Adding Timestamps
    # I would like to add Timestamps as new column
    # run the code before explaining it
    column_with_timestamp <- NULL
    renamed_column$Timestamp <- renamed_column$RecordingTimestamp - renamed_column$SegmentStart
    column_with_timestamp <- renamed_column
    # head(column_with_timestamp)
    # SegmentStart is the  onset of trial(51212)
    # SegmentEnd is the offset of trial(61655)
    # RecordingTimestamp is the recording points(51212 to 61655)
    # Therefore, Timestamp -> 0 (51212-51212) to 10443(61655-51212)

    # 3. Removing columns not needed
    # now we don't need some of them.
    # because we have timestamp now.
    # ~~SegmantStart, SegmentEnd, SegmentDuration, RecordingTimestamp, PupilLeft, PupilRight~~
    selected_column <- column_with_timestamp[,c("ParticipantName", "SegmentName", "FixationIndex",
        "GazeEventType", "GazeEventDuration", "FixationPointX", "SaccadeIndex", "FixationPointY", "Timestamp")]

    # 4. Extacting Fixation and Saccade (other than Unclassified)
    selected_column <- selected_column[selected_column$GazeEventType != "Unclassified",]
    # Now, if FixationIndex is an NA,
    # the data in the row is about saccade.
    # so we can replace the NA with SaccadeIndex.
    selected_column$FixationIndex <- ifelse(is.na(selected_column$FixationIndex),
        selected_column$SaccadeIndex,
        selected_column$FixationIndex)

    # 5. Removing NA
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
    # So we can delete SaccadeIndex (see 4)
    selected_column$SaccadeIndex <- NULL
    refined_column <- selected_column

    return(refined_column)
}
