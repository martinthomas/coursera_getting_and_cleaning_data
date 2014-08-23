#setwd('/Users/mthomas')

# Download dataset and unzip unless already present and unzipped
if (!file.exists("activity")){
  dir.create("activity")
}
setwd('activity')
if (!file.exists('dataset.zip')){
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url, destfile="dataset.zip", method="curl", quiet=TRUE)
}
if (!file.exists('UCI HAR Dataset')){
  unzip("dataset.zip")
}
setwd('UCI HAR Dataset')

# Merge each pair of train and test files
tmpXtrain <- read.table('train/X_train.txt')
tmpXtest <- read.table('test/X_test.txt')
tmpX <- rbind(tmpXtrain, tmpXtest)

tmpYtrain <- read.table('train/Y_train.txt')
tmpYtest <- read.table('test/Y_test.txt')
tmpY <- rbind(tmpYtrain, tmpYtest)

tmpStrain <- read.table('train/subject_train.txt')
tmpStest <- read.table('test/subject_test.txt')
tmpS <- rbind(tmpStrain, tmpStest)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.

features <- read.table("features.txt")
features_indexes <- grep("-mean\\(\\)|-std\\(\\)", features[, 2])
tmpX <- tmpX[, features_indexes]
names(tmpX) <- features[features_indexes, 2] 
names(tmpX) <- gsub("\\(|\\)", "", names(tmpX)) # remove parens
names(tmpX) <- tolower(names(tmpX)) 

activities <- read.table("activity_labels.txt")
activities[, 2] = tolower(as.character(activities[, 2]))
tmpY[,1] = activities[tmpY[,1], 2]
names(tmpY) <- "activity"

names(tmpS) <- "subject"
combined <- cbind(tmpS, tmpY, tmpX)
write.table(combined, "../combined_data.txt", row.name=F)

combined$activity <- as.factor(combined$activity)
combined$subject <- as.factor(combined$subject)
tidy = aggregate(combined, by=list(activity = combined$activity, subject=combined$subject), mean)
tidy[4] <- NULL  #remove the meaningless aggregate of subject and activity
tidy[3] <- NULL

write.table(tidy, "../tidy.txt", sep="\t", row.name=F)
