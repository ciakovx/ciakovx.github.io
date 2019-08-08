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

install.packages("devtools")
library(devtools)
devtools::install_github("ropensci/rorcid")

library(rorcid)
library(usethis)
library(tidyverse)
library(anytime)
library(lubridate)
library(janitor)

# We start with a simple search by family name with the `family_name` argument:
carberry <- orcid_search(family_name = 'carberry')

# We can increase the number of results returned by using the `rows` argument:
carberry <- orcid_search(family_name = 'carberry',
                         rows = 50)

# add another argument: `given_name`
carberry <- orcid_search(given_name = 'josiah',
                         family_name = 'carberry')

browse(carberry$orcid[1])
browse(carberry$orcid[2])


### if you have made your ORCID profile public, do a search for yourself, or pick someone you know with a public ORCID profile, or if none of those, do a search for Karthik Ram


# `orcid_search` includes the argument `affiliation_org`, which searches across all of one's affiliation data (employment, education, invited positions, membership & service)
carberry <- orcid_search(family_name = 'carberry', 
                         affiliation_org = 'Wesleyan')


# `orcid_search` is a wrapper for another `rorcid` function--`orcid()`, which allows for a more advanced range of searching.

carberry <- orcid(query = 'family-name:carberry AND ringgold-org-id:6752')

# We can combine affiliation names, Ringgold IDs, and email addresses using the `OR` operator to cover all our bases, in case the person or people we are looking for did not hit on of those values.

clarke <- orcid(query = 'family-name:iakovakis AND(ringgold-org-id:7618 OR
                           email:*@okstate.edu OR 
                           affiliation-org-name:"Oklahoma State")')

# The maximum number of returned results is 200, which we can modify with the `rows` argument:

my_osu_orcids <- orcid(query = 'ringgold-org-id:7618 OR email:*@okstate.edu OR
                               affiliation-org-name:"Oklahoma State"',
                       rows = 200)

my_osu_orcid_count <- base::attr(orcid(query = 'ringgold-org-id:7618 OR 
                               email:*@okstate.edu OR affiliation-org-name:"Oklahoma State"'),
                                 "found")

# Build a sequence of numbers
my_pages <- seq(from = 0, to = my_osu_orcid_count, by = 200)

# Finally, we will write a small function using `map` from the `purrr` package.

my_osu_orcids <- map(
  my_pages,
  function(page) {
    print(page)
    my_orcids <- orcid(query = 'ringgold-org-id:7618 OR 
                               email:*@okstate.edu OR affiliation-org-name:"Oklahoma State"',
                       rows = 200,
                       start = page)
    return(my_orcids)
  })

# We can then use the `bind_rows()` function from `dplyr` to pull the data together into a single dataframe, and the `clean_names()` function from `janitor`
my_osu_orcids_data <- my_osu_orcids %>%
  bind_rows() %>%
  clean_names()


# biographical information with orcid_person ------------------------------

carberry_orcid <- "0000-0002-1825-0097"
carberry_person <- orcid_person(carberry_orcid)

carberry_person %>%
  map(pluck, "name", "given-names", "value", .default = NA)

carberry_person %>%
  map_chr(pluck, "name", "family-name", "value", .default = NA)

# builds a tibble piece by piece
carberry_data <- carberry_person %>% {
  tibble(
    created_date = map_dbl(., pluck, "name", "created-date", "value", .default=NA_character_),
    given_name = map_chr(., pluck, "name", "given-names", "value", .default=NA_character_),
    family_name = map_chr(., pluck, "name", "family-name", "value", .default=NA_character_),
    credit_name = map_chr(., pluck, "name", "credit-name", "value", .default=NA_character_),
    other_names = map(., pluck, "other-names", "other-name", "content", .default=NA_character_),
    orcid_identifier_path = map_chr(., pluck, "name", "path", .default = NA_character_),
    biography = map_chr(., pluck, "biography", "content", .default=NA_character_),
    researcher_urls = map(., pluck, "researcher-urls", "researcher-url", .default=NA_character_),
    emails = map(., pluck, "emails", "email", "email", .default=NA_character_),
    keywords = map(., pluck, "keywords", "keyword", "content", .default=NA_character_),
    external_ids = map(., pluck, "external-identifiers", "external-identifier", .default=NA_character_)
  )}

# you can also use orcid_person() to get data on multiple people
my_orcids <- c("0000-0002-1825-0097", "0000-0002-9260-8456")
my_orcid_person <- orcid_person(my_orcids)


# building a query to search for names
profs <- tibble("FirstName" = c("Josiah", "Clarke"),
                "LastName" = c("Carberry", "Iakovakis"))
orcid_query <- paste0("given-names:",
                      profs$FirstName,
                      " AND family-name:",
                      profs$LastName)



# Employment data ---------------------------------------------------------

clarke_employment <- orcid_employments(orcid = "0000-0002-9260-8456")

# Again it comes in a series of nested lists, but we'll just `pluck()` what we need and use `flatten_dfr()` to flatten the lists into a data frame.

clarke_employment_data <- clarke_employment %>%
  map(., pluck, "affiliation-group", "summaries") %>% 
  flatten_dfr() %>%
  clean_names()



# works -------------------------------------------------------------------

carberry_orcid <- c("0000-0002-1825-0097")

# get a person's works
carberry_works <- works(carberry_orcid) %>%
  clean_names()

# unnest external IDs
carberry_works_ids <- carberry_works %>%
  unnest(external_ids_external_id) %>%
  clean_names()

my_orcids <- c("0000-0002-1825-0097", "0000-0002-9260-8456", "0000-0002-2771-9344")
my_works <- orcid_works(my_orcids)
