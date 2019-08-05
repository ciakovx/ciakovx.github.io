# Let's start by 




library(tidyverse)
library(rcrossref)
library(usethis)
library(roadoi)
library(rorcid)


# Installing the latest version -------------------------------------------

# Because the newest version of `rorcid` came out in June, new features and bug fixes have since been added. Let's install the latest version directly from GitHub by using the following code:

install.packages("devtools")
library(devtools)
devtools::install_github("ropensci/rorcid")


# Setting up rorcid -------------------------------------------------------

# Create an ORCID account at https://orcid.org/signin

# Authenticate with an ORCID API key

orcid_auth()

# You should see a message stating: `no ORCID token found; attempting OAuth authentication` and a window will open in your default internet browser. Log-in to your orcid account. You will be asked to give `rorcid` authorization to access your ORCID Record for the purposes of getting your ORCID iD. Click "Authorize."

# Return to R Studio and you should see in your R console the word **Bearer**, followed by a long string of letters and numbers. These letters and numbers are your API key.

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


