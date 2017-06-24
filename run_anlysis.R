library(reshape2)
library(plyr)
library(dplyr)

filename<-"data.zip"

## Download the dataset from the website given
if(!file.exists(filename)){
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl,filename)
}
if(!file.exists("UCI HAR Dataset")){
        unzip(filename)
}


## Loading the activity_labels and fetures into R
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", colClasses = c("integer","character"))
features <- read.table("UCI HAR Dataset/features.txt", colClasses = c("integer","character"))

## Making activity_labels and features lower case
activity_labels[,2] <- tolower(activity_labels[,2])
features[,2] <- tolower(features[,2])

## Select features with mean or standard deviation (I picked any feature where mean of std showed up in anyway)
featuresUsed_vec <- grep(".*mean.*|.*std.*", features[,2])
featuresUsed <- features[featuresUsed_vec,2]

## Loading the train and test datasets to R
train <- read.table("UCI HAR Dataset/train/X_train.txt")
trainactivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainsubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
test <- read.table("UCI HAR Dataset/test/X_test.txt")
testactivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testsubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")

## Select only the feature we want from the train and test data frames and bind columns
train <- select(train, featuresUsed_vec)
test <- select(test, featuresUsed_vec)
train <- cbind(trainsubjects, trainactivities, train)
test <- cbind(testsubjects, testactivities, test)

## merge the datasets and label
data <- rbind(train, test)
colnames(data) <- c("subject", "activity", featuresUsed)

## make activities and subjects into factors
data <- mutate(data, activity = factor(activity, levels = activity_labels[,1], labels = activity_labels[,2]))
data <- mutate(data, subject=factor(subject))

## create a new data set with average of each variable for each activity and each subject
data_melted <- melt(data, id = c("subject", "activity"))
data_mean <- dcast(data_melted, subject+ activity ~ variable, mean)


## Create tidy file
write.table(data_mean, file = "tidy.txt", quote = FALSE, row.names = FALSE)
