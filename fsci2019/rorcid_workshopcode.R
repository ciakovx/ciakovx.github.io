library(tidyverse)
library(janitor)

install.packages("usethis")
library(usethis)

install.packages("repurrrsive")
library(repurrrsive)

install.packages("devtools")
library(devtools)
devtools::install_github("ropensci/rorcid")


# lists -------------------------------------------------------------------

install.packages("tidyverse")
install.packages("repurrrsive")

library(purrr)
library(repurrrsive)

x <- list(a = "a", b = 2)
View(x)

# The $ operator. Extracts a single element by name. 
x$a
x$b

# [[ a.k.a. double square bracket. Extracts a single element by name or position. Name must be quoted, if provided directly. Name or position can also be stored in a variable.
x[["a"]]
x[[2]]

i <- 2
x[[i]]


# [ a.k.a. single square bracket. Regular vector indexing. For a list input, this always returns a list!
x["a"]


# pepper shaker example
x <- list("a" = c(1, 2, 3, 4))
x[1]
x[[1]]
x[[1]][[1]]

# pluck allows you to index deeply and flexibly into data structures
pluck(x, 1)
pluck(x, 1, 1)

y <- list("a" = list(1, 2, 3, 4),
          "b" = list(11, 12, 13, 14))
pluck(y, 1)

### how would you pluck "b"? 


# returns a list item with the first value of each list
map(y, pluck(1))

# returns a numberic item with the first value of each list
map_dbl(y, pluck(1))


View(got_chars)

# Get all the data for the first name
View(pluck(got_chars, 1))

# Get all the name values only
got_names <- map(got_chars, pluck(3))

# Can also use column names
got_names <- map(got_chars, pluck("name"))

# Clearer to use pipes
got_names <- got_chars %>%
  map(pluck("name"))

### Use names() to inspect the names of the list elements associated with a single character. What is the index or position of the playedBy element? Use the character and position shortcuts to extract the  playedBy elements for all characters.


# map() always returns a list, even if all the elements have the same flavor and are of length one. But in that case, you might prefer a simpler object: an atomic vector.

# map() makes a list.
# map_lgl() makes a logical vector.
# map_int() makes an integer vector.
# map_dbl() makes a double vector.
# map_chr() makes a character vector.

got_names <- got_chars %>%
  map_chr(pluck("name"))

# When programming, it is safer, but more cumbersome, to explicitly specify type and build your data frame the usual way.

got_data <- got_chars %>% {
  tibble(
    name = map_chr(., "name"),
    culture = map_chr(., "culture"),
    gender = map_chr(., "gender"),       
    id = map_int(., "id"),
    born = map_chr(., "born"),
    alive = map_lgl(., "alive")
  )
}
  



# Setting up rorcid -------------------------------------------------------

orcid_auth()

ORCID_TOKEN="copy and paste your token here"

usethis::edit_r_environ()

library(rorcid)

orcid_auth()

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

### Use filter to get only the ORCID iD 0000-0002-1028-6941


### if you have made your ORCID profile public, do a search for yourself, or pick someone you know with a public ORCID profile, or if none of those, do a search for Karthik Ram



# `orcid_search` includes the argument `affiliation_org`, which searches across all of one's affiliation data (employment, education, invited positions, membership & service)
carberry <- orcid_search(family_name = 'carberry', 
                         affiliation_org = 'Wesleyan')


### Do an affiliation search for Scott Chamberlain at organization rOpenSci



# search by ringgold or grid

# you can use ringgold_org_id to search by Ringgold, or grid_org_id
carberry <- orcid_search(family_name = "carberry",
                         ringgold_org_id = "6752")

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

# get a character string of all ORCID iDs
my_osu_orcids_ids <- my_osu_orcids_data$orcid_identifier_path

### get the orcid IDs for people affiliated with your institution, or an institution of your choosing. Return the iDs only to a new vector.
# Ask me if you need your institution's Ringgold.




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

my_osu_person <- orcid_person(my_osu_orcids_ids)



# building a query to search for names

paste("hello", "world")
paste0("hello", "world")

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
