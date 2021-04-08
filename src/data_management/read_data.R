### Plan:
# Create a searchable database of claim codes from SSSY (claims) excel file.
# Translate description into English.


rm(list=ls())

### LIBRARIES
library("readxl")
library("tidyverse")

### LANGUAGES
Sys.setlocale("LC_TIME", "US")

### GLOBAL SETTINGS
args = commandArgs(trailingOnly=TRUE)
global_filename_sssy <- args[1]

## xls files
raw_data_specialist_type <- read_excel(global_filename_sssy, sheet = "Yderes speciale", col_types = "text")
raw_data_claims_number <- read_excel(global_filename_sssy, sheet = "Ydelsesnummer", col_types = "text")
raw_data_claims_details <- read_excel(global_filename_sssy, sheet = "Ydelsesoversigt", col_types = "text")

## Appended data: Rename, select variables and generate variables in correct datatype
append_data_specialist_type <- raw_data_specialist_type %>%
  rename_with(tolower) %>%
  rename(c(str_speciale = k_speciale, str_speciale_label = v_betydning, str_speciale_use_from = k_fradto, str_speciale_use_til = d_tildto)) %>%
  select(-v_initial) %>%
  mutate(speciale = as.integer(str_speciale), speciale_label = str_speciale_label, speciale_use_from = as.Date(str_speciale_use_from, "%d%b%Y"), speciale_use_til = as.Date(str_speciale_use_til, "%d%b%Y"))

append_data_claims_number <- raw_data_claims_number %>%
  rename_with(tolower) %>%
  rename(c(str_speciale = k_speciale, str_claims_code = k_ydelsesnr, str_claims_label_short = v_betydning, str_speciale_use_from = k_fradto, str_speciale_use_til = d_tildto)) %>%
  select(-v_initial) %>%
  mutate(speciale = as.integer(str_speciale), claims_code = as.integer(str_claims_code), claims_label_short = str_claims_label_short, speciale_use_from = as.Date(str_speciale_use_from, "%d%b%Y"), speciale_use_til = as.Date(str_speciale_use_til, "%d%b%Y"))

# NOTE: data_claims_details contains codes with "xxx" that can't be cast into integers --- I don't know what they mean anyways, so I drop them for now
append_data_claims_details <- raw_data_claims_details %>%
  rename_with(tolower) %>% rename(c(str_speciale = c_speciale, str_claims_code = c_ydelsesnr, str_claims_label_short = v_korttekst, str_claims_label_long = v_langtekst)) %>%
  rename_with(~ gsub("t_", "str_use_", .x, fixed = TRUE)) %>%
  mutate(speciale = as.integer(str_speciale), claims_code = as.integer(str_claims_code), claims_label_short = str_claims_label_short, claims_label_long= str_claims_label_long) %>%
  mutate_at(vars(matches("str_use")), ~replace_na(., "0")) %>% #mutate 0s for use_year
  mutate_at(vars(matches("str_use")), ~recode(., `X`="1")) %>% #mutate Xs for use_year
  mutate_at(vars(matches("str_use")), list(cat = ~as.logical(as.integer(.)))) %>% #boolean form for use_year
  rename_at(vars(contains("_cat")), list(~ paste("cat", gsub("_cat", "", .), sep = "_"))) %>%
  rename_with(~ gsub("cat_str_use_", "use_", .x, fixed = TRUE))

## Modified data: Select variables and observations with non-missing index
mod_data_specialist_type <- append_data_specialist_type %>%
  select(-contains("str_")) %>%
  filter(is.na(speciale)==FALSE)

mod_data_claims_number <- append_data_claims_number %>%
  select(-contains("str_")) %>%
  filter(is.na(speciale)==FALSE & is.na(claims_code)==FALSE)

mod_data_claims_details_wide <- append_data_claims_details %>%
  select(-contains("str_")) %>%
  filter(is.na(speciale)==FALSE & is.na(claims_code)==FALSE)

# reshape wide to long
mod_data_claims_details <- mod_data_claims_details_wide %>%
  gather(str_use_year, use_value, -c(speciale, claims_code, claims_label_short, claims_label_long)) %>%
  mutate(use_year = as.integer(str_replace(str_use_year, pattern = 'use_', replacement = ''))) %>%
  select(-contains("str_")) %>%
  relocate(speciale, claims_code, use_year, use_value) %>%
  arrange(speciale, claims_code, use_year, use_value)

## Remove duplicates
# NOTE: data_claims_details contains duplicate codes --- I don't know what that means, I drop those duplicates for now
nodups_mod_data_specialist_type <- mod_data_specialist_type %>%
  group_by(speciale) %>%
  filter(n()==1)

nodups_mod_data_claims_number <- mod_data_claims_number %>%
  group_by(speciale, claims_code) %>%
  filter(n()==1)

nodups_mod_data_claims_details <- mod_data_claims_details %>%
  group_by(speciale, claims_code, use_year, use_value) %>%
  filter(n()==1)

## Save
write.csv(nodups_mod_data_specialist_type, file=args[2])
write.csv(nodups_mod_data_claims_number, file=args[3])
write.csv(nodups_mod_data_claims_details, file=args[4])

data_specialist_type <- nodups_mod_data_specialist_type
data_claims_number <- nodups_mod_data_claims_number
data_claims_details <- nodups_mod_data_claims_details
save(data_specialist_type, data_claims_number, data_claims_details, file=args[5])