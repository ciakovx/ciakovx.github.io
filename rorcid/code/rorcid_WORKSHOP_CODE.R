library(tidyverse)
library(rcrossref)
library(usethis)
library(roadoi)
library(rorcid)


# Setting up rorcid -------------------------------------------------------

orcid_auth()

ORCID_TOKEN="copy and paste your token here"

usethis::edit_r_environ()

library(rorcid)

orcid_auth()



# Finding ORICID iDs with `rorcid::orcid()` -------------------------------

# name
carberry <- rorcid::orcid(query = 'josiah carberry')
View(carberry)

# boolean
carberry <- rorcid::orcid(query = 'josiah AND carberry')
View(carberry)

# keyword
carberry <- rorcid::orcid(query = 'josiah AND psychoceramics')
View(carberry)

# using name fields
carberry <- rorcid::orcid(query = 'given-names:josiah AND family-name:carberry') %>%
  janitor::clean_names()
View(carberry)

# searching by ORCID iD
carberry <- rorcid::orcid(query = 'orcid:0000-0002-1825-0097') %>%
  janitor::clean_names()
View(carberry)


# affiliation organization
carberry <- rorcid::orcid(query = 'family-name:carberry AND affiliation-org-name:Wesleyan') %>%
  janitor::clean_names()

# Ringgold ID
carberry <- rorcid::orcid(query = 'family-name:carberry AND ringgold-org-id:6752') %>%
  janitor::clean_names()
View(carberry)

# Combining affiliation name, Ringgold, and email address domain
iakovakis <- rorcid::orcid(query = 'family-name:iakovakis AND(ringgold-org-id:7618 OR
                           email:*@okstate.edu OR 
                           affiliation-org-name:"Oklahoma State")') %>%
  janitor::clean_names()
View(iakovakis)



# Finding biographical information with `rorcid::orcid_person()` ----------

# assign carberry's ORCID iD
carberry_orcid <- carberry$orcid_identifier_path

# query orcid_person()
carberry_person <- rorcid::orcid_person(carberry_orcid) %>%
  janitor::clean_names()
View(carberry_person)

# Getting the data into a data frame
carberry_data <- carberry_person %>% {
  tibble(
    created_date = purrr::map_dbl(., purrr::pluck, "last-modified-date", "value", .default=NA_character_),
    last_modified_date = purrr::map_dbl(., purrr::pluck, "name", "created-date", "value", .default=NA_character_),
    given_name = purrr::map_chr(., purrr::pluck, "name", "given-names", "value", .default=NA_character_),
    family_name = purrr::map_chr(., purrr::pluck, "name", "family-name", "value", .default=NA_character_),
    credit_name = purrr::map_chr(., purrr::pluck, "name", "credit-name", "value", .default=NA_character_),
    other_names = purrr::map(., purrr::pluck, "other-names", "other-name", "content", .default=NA_character_),
    orcid_identifier_path = purrr::map_chr(., purrr::pluck, "name", "path", .default = NA_character_),
    biography = purrr::map_chr(., purrr::pluck, "biography", "content", .default=NA_character_),
    researcher_urls = purrr::map(., purrr::pluck, "researcher-urls", "researcher-url", .default=NA_character_),
    emails = purrr::map(., purrr::pluck, "emails", "email", "email", .default=NA_character_),
    keywords = purrr::map(., purrr::pluck, "keywords", "keyword", "content", .default=NA_character_),
    external_ids = purrr::map(., purrr::pluck, "external-identifiers", "external-identifier", .default=NA_character_)
  )}
View(carberry_data)



# Unnesting nested lists

carberry_keywords <- carberry_data %>%
  tidyr::unnest(keywords)
View(carberry_keywords)


# Searching by multiple ORCID iDs

# assign multiple iDs
my_orcids <- c("0000-0002-1825-0097", "0000-0002-9260-8456")

# run the query
my_orcid_person <- rorcid::orcid_person(my_orcids)




# Getting Works with `rorcid::works()` and `rorcid::orcid_works()` --------

carberry_orcid <- c("0000-0002-1825-0097")
carberry_works <- rorcid::works(carberry_orcid) %>%
  janitor::clean_names()
View(carberry_works)


