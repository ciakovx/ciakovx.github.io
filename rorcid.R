

#load packages
library(tidyr)
library(purrr)
library(lubridate)
library(rorcid)
library(anytime)
library(httr)
library(janitor)
library(readr)
library(glue)
library(stringr)
library(dplyr)

orcid_auth()

# Highlight and copy the API key (the letters and numbers only--exclude the word "Bearer" and the space). Now you can use the `edit_r_environ()` function from the `usethis` package to store the token in your R environment. 

usethis::edit_r_environ()



# Finding ORICID iDs with rorcid::orcid_search() -----------------------------------------------------



carberry <- rorcid::orcid_search(family_name = 'carberry')
carberry



carberry <- rorcid::orcid_search(family_name = 'carberry',
                                 rows = 50)
carberry



carberry <- rorcid::orcid_search(given_name = 'josiah',
                                 family_name = 'carberry')
carberry




carberry <- rorcid::orcid_search(family_name = 'carberry', 
                                 affiliation_org = 'Wesleyan')
carberry




clarke <- rorcid::orcid_search(email = 'clarke.iakovakis@okstate.edu')
clarke



carberry <- rorcid::orcid_search(family_name = 'carberry',
                                 keywords = 'psychoceramics')
carberry



ropensci1 <- rorcid::orcid_search(work_title = '"Building Software Building Community"')
ropensci1



ropensci2 <- rorcid::orcid_search(digital_object_ids = '"10.5334/jors.bu"')
ropensci2



carberry <- rorcid::orcid_search(family_name = 'carberry',
                               ringgold_org_id = '5468')
carberry






clarke <- rorcid::orcid_search(family_name = 'iakovakis',
                               email = '*@okstate.edu')
clarke



clarke <- rorcid::orcid(query = 'family-name:iakovakis AND(ringgold-org-id:7618 OR email:*@okstate.edu OR 
                           affiliation-org-name:"Oklahoma State")')
clarke



ringgold_id <- "7618"
email_domain <- "@okstate.edu"
organization_name <- "Oklahoma State"



my_query <- glue('ringgold-org-id:',
                 ringgold_id,
                 ' OR email:*',
                 email_domain,
                 ' OR affiliation-org-name:"',
                 organization_name,
                 '"')
my_query



my_osu_orcids <- rorcid::orcid(query = my_query,
                               rows = 25)
my_osu_orcids



my_osu_orcid_count <- base::attr(rorcid::orcid(query = my_query),
                               "found")
my_osu_orcid_count



my_pages <- seq(from = 0, to = my_osu_orcid_count, by = 200)
my_pages



my_osu_orcids <- purrr::map(
  my_pages,
  function(page) {
  print(page)
  my_orcids <- rorcid::orcid(query = 'ringgold-org-id:7618 OR email:*@okstate.edu OR affiliation-org-name:"Oklahoma State"',
                               rows = 200,
                               start = page)
  return(my_orcids)
  })



my_osu_orcids_data <- my_osu_orcids %>%
  map_dfr(., dplyr::as_tibble) %>%
  janitor::clean_names()
my_osu_orcids_data



ringgold_id <- "REPLACEME"
email_domain <- "REPLACEME"
organization_name <- "REPLACEME"



my_inst_query <- glue('ringgold-org-id:',
                 ringgold_id,
                 ' OR email:*',
                 email_domain,
                 ' OR affiliation-org-name:"',
                 organization_name,
                 '"')



my_inst_orcids <- purrr::map(
  my_inst_pages,
  function(page) {
  my_orcids <- rorcid::orcid(query = my_inst_query,
                               rows = 200,
                               start = page)
  return(my_orcids)
  })



my_orcids_data <- my_inst_orcids %>%
  map_dfr(., dplyr::as_tibble) %>%
  janitor::clean_names()



write_csv(my_orcids_data, "./data/my_orcids_data.csv")



# Finding ORICID iDs with rorcid::orcid_search() --------------------------

carberry_orcid <- "0000-0002-1825-0097"
carberry_person <- rorcid::orcid_person(carberry_orcid)



names(carberry_person[[1]])



# getting the data into a data frame --------------------------------------

carberry_data <- carberry_person %>% {
    dplyr::tibble(
      created_date = purrr::map_dbl(., purrr::pluck, "name", "created-date", "value", .default=NA_integer_),
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
    )
  } 

carberry_data



# fixing dates ------------------------------------------------------------



carberry_data$created_date



carberry_datesAndTimes <- carberry_data %>%
  dplyr::mutate(created_date = anytime::anytime(created_date/1000))
carberry_datesAndTimes$created_date



carberry_datesOnly <- carberry_data %>%
  dplyr::mutate(created_date = anytime::anydate(created_date/1000))
carberry_datesOnly$created_date


carberry_years <- carberry_datesOnly %>%
dplyr::mutate(created_year = lubridate::year(created_date))


carberry_years$created_year



# unnesting nested lists --------------------------------------------------

carberry_keywords <- carberry_data %>%
tidyr::unnest(keywords)

carberry_keywords$keywords



carberry_list_columns <- map_lgl(carberry_data, is_list)

names(carberry_data)[carberry_list_columns]



carberry_keywords <- carberry_data %>%
  tidyr::unnest(keywords, .drop = FALSE)
carberry_keywords



carberry_keywords_otherNames <- carberry_data %>%
  tidyr::unnest(keywords, .drop = FALSE) %>%
  tidyr::unnest(other_names, .drop = FALSE)
carberry_keywords_otherNames



carberry_researcherURLs <- carberry_data %>%
  tidyr::unnest(researcher_urls, .drop = FALSE)
carberry_researcherURLs




# Writing to CSV ----------------------------------------------------------


# this will give you an error
write_csv(carberry_data, "data/carberry_data.csv")



carberry_data_keywords <- carberry_data %>%
  tidyr::unnest(keywords, .drop = TRUE)
write_csv(carberry_data_keywords, "data/carberry_data_keywords.csv")



carberry_data_short <- carberry_data %>%
  dplyr::select_if(purrr::negate(is_list))



my_orcid_person_data <- my_orcid_person %>% {
    dplyr::tibble(
      created_date = purrr::map_dbl(., purrr::pluck, "name", "created-date", "value", .default=NA_character_),
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
    )
  } %>%
  dplyr::mutate(created_date = anytime::anydate(created_date/1000))
my_orcid_person_data



# getting data on multiple people -----------------------------------------

my_orcids <- c("0000-0002-1825-0097", "0000-0002-9260-8456")
my_orcid_person <- rorcid::orcid_person(my_orcids)



my_orcid_person_data <- my_orcid_person %>% {
    dplyr::tibble(
      created_date = purrr::map_dbl(., purrr::pluck, "name", "created-date", "value", .default=NA_character_),
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
    )
  } %>%
  dplyr::mutate(created_date = anytime::anydate(created_date/1000))
my_orcid_person_data



my_orcids_person_data <- my_inst_person %>% {
    dplyr::tibble(
      created_date = purrr::map_dbl(., purrr::pluck, "name", "created-date", "value", .default=NA_character_),
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
    )
  } %>%
  dplyr::mutate(created_date = anytime::anydate(created_date/1000))
my_orcids_person_data



write_csv(my_orcids_person_data, "data/my_orcids_person_data.csv")



# splitting names ---------------------------------------------------------



profs <- dplyr::tibble("FirstName" = c("Josiah", "Clarke"),
                     "LastName" = c("Carberry", "Iakovakis"))
profs
orcid_query <- paste0("given-names:",
                      profs$FirstName,
                      " AND family-name:",
                      profs$LastName)
orcid_query



my_orcids_df <- purrr::map(
  orcid_query,
  function(x) {
    print(x)
    orc <- rorcid::orcid(x)
  }
  ) %>%
    map_dfr(., dplyr::as_tibble) %>%
  janitor::clean_names()
my_orcids_df



my_orcids_df <- my_orcids_df %>%
  dplyr::filter(orcid_identifier_path != "0000-0002-1028-6941")
my_orcids_df



my_orcids <- my_orcids_df$orcid_identifier_path
my_orcid_person <- rorcid::orcid_person(my_orcids)
my_orcid_person_data <- my_orcid_person %>% {
    dplyr::tibble(
      created_date = purrr::map_dbl(., purrr::pluck, "name", "created-date", "value", .default=NA_character_),
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
    )
} %>%
  dplyr::mutate(created_date = anytime::anydate(created_date/1000))
my_orcid_person_data



my_names <- dplyr::tibble("name" = c("Josiah Carberry", "Clarke Iakovakis"))
my_names
my_clean_names <- my_names %>%
  tidyr::extract(name, c("FirstName", "LastName"), "([^ ]+) (.*)")
my_clean_names



my_orcid_person_keywords <- my_orcid_person_data %>%
  tidyr::unnest(keywords)
my_orcid_person_keywords




# employment data ---------------------------------------------------------

# see rorcid_employments file at https://osf.io/f638j/


# Getting works -----------------------------------------------------------


carberry_orcid <- c("0000-0002-1825-0097")
carberry_works <- rorcid::works(carberry_orcid) %>%
  dplyr::as_tibble() %>%
  janitor::clean_names() %>%
  dplyr::mutate(created_date_value = anytime::anydate(created_date_value/1000))
carberry_works



carberry_works_ids <- carberry_works %>%
  tidyr::unnest(external_ids_external_id) %>%
  janitor::clean_names()
carberry_works_ids



my_orcids <- c("0000-0002-1825-0097", "0000-0002-9260-8456", "0000-0002-2771-9344")
my_works <- rorcid::orcid_works(my_orcids)



my_works_data <- my_works %>%
purrr::map_dfr(pluck, "works") %>%
janitor::clean_names() %>%
dplyr::mutate(created_date_value = anytime::anydate(created_date_value/1000))


my_works_data



my_works_externalIDs <- my_works_data %>%
tidyr::unnest(external_ids_external_id)



my_works_externalIDs <- my_works_data %>%
dplyr::filter(!purrr::map_lgl(external_ids_external_id, purrr::is_empty)) %>%
tidyr::unnest(external_ids_external_id)

my_works_externalIDs



my_works_externalIDs_keep <- my_works_data %>% 
  dplyr::filter(!purrr::map_lgl(external_ids_external_id, purrr::is_empty)) %>% 
  tidyr::unnest(external_ids_external_id, .drop = TRUE) %>% 
  dplyr::bind_rows(my_works_data %>% 
                     dplyr::filter(map_lgl(external_ids_external_id, is.null)) %>%
                     dplyr::select(-external_ids_external_id))
my_works_externalIDs_keep

