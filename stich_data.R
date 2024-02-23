library(tidyverse)
library(eyetools)

# this bit reads in the files and uses part of the filename to make a new "subj" variable
fnams <- list.files("CSV Data", "ids", full.names = TRUE) # needed for reading data
subjs <- list.files("CSV Data", "ids") # needed for identifying subject numbers
data <- NULL
for (subj in 1:length(fnams)) {
  print(fnams[subj])
  pData <- read_csv(fnams[subj], col_types = cols(), col_names = FALSE) # read the data from csv
  pData <-
    pData %>%
    mutate(pNum = substr(subjs[subj],1,3)) %>%
    select(pNum, everything())
  data <- rbind(data, pData) # combine data array with existing data
}

id_data <- data %>% rename(trial_ID = X1)


# Process eye data

for (p in 1:2){

  if (p == 1){
    file_key = "fix"

  }
  else{
    file_key = "stim"
  }

  fnams <- list.files("CSV Data", file_key, full.names = TRUE) # needed for reading data
  subjs <- list.files("CSV Data", file_key) # needed for identifying subject numbers

  data <- NULL

  for (subj in 1:length(fnams)) {

    print(fnams[subj])
    print(p)

    pData <- read_csv(fnams[subj], col_types = cols(), col_names = FALSE) # read the data from csv

    pData[pData==-1] <- NA

    pData <-
      pData %>%
      select(time = X6, left_x = X1, left_y = X2,
             right_x = X3, right_y = X4, trial = X5)

    # combine eyes
    pData <- combine_eyes(pData, "average")

    # interpolate
    pData <- interpolate(pData)

    # mutate x/y to screen res
    pData <-
    pData %>%
      mutate(x = x*1920, y = y*1080,
             time = round(time/1000)) %>%
      group_by(trial) %>%
      mutate(time = time - time[1])

    fix_d <- fix_dispersion(pData)

    fix_d <- fix_d %>%
      mutate(pNum = substr(subjs[subj],1,3), .before = trial)

    data <- rbind(data, fix_d) # combine data array with existing data


  }

  if (p == 1){
    eg_fix <- data
  } else{
    eg_stim <- data
  }

}

save(id_data, eg_fix, eg_stim, file = "inj_unsw_data.RData")


save(data, file = "AGP_5R_data.RData")

# spatial_plot(AOIs = AOI_AGP)
