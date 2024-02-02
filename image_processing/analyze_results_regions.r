library(tidyr)
library(dplyr)
library(stringr)
library(data.table)

setwd(getwd())
# place script in parent dir
# of folder with csv files from extract_regionprobs.py



# Get the list of CSV files in the folder
csv_files <- list.files("./output_GFP", pattern = ".csv", full.names = TRUE)

merged_data <- data.frame()

# Loop through the files and merge them into a single dataframe
for (file in csv_files) {

  data <- fread(file)
  filename <- basename(file)
  # Extract the time from the filename
  time <- str_extract(filename, "\\d{2}(?=hpf)")
  data <- data %>% mutate(filename = filename, time = time)
  merged_data <- bind_rows(merged_data, data)
}

# Add the experiment column
merged_data <- merged_data %>% 
  mutate(experiment = str_extract(filename, "(?<=_)(.*?)(?=_)"))

merged_data$filename <- NULL


merged_data <- merged_data %>% mutate(region = case_when(label == 2 ~ "V",
                                                         label == 3 ~ "AVC",
                                                         label == 4 ~ "OFT"))

merged_data <- merged_data %>%
  group_by(experiment) %>%
  mutate(samples = n() / 3)

merged_data <- merged_data %>% 
  group_by(experiment) %>% 
  mutate(sample = rep(1:ceiling(n() / 3), each = 3)[seq_len(n())])

my_comparisons <- list(
  c("ventricle", "AV canal"),
  c("AV canal", "OT"),
  c("ventricle", "OT"))


merged_data$experiment_w_sample_no <- paste(
  merged_data$experiment,
  ", N=",
  merged_data$samples,
  sep = " ")

df_final <- merged_data %>%
  group_by(experiment, region, sample) %>%
  summarise(median_intensity = median(median_intensity)) %>%
  pivot_wider(names_from = region, values_from = median_intensity)

# calculate the relative difference between the regions
df_final$rel_diff_V_AVC <- (df_final$`AVC` - df_final$V)/abs(df_final$V)
df_final$rel_diff_V_OFT <- (df_final$OFT - df_final$V)/abs(df_final$V)

write.csv(df_final, file = "test.csv")
