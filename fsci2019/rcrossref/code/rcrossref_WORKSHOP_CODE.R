library(tidyverse)
library(rcrossref)
library(usethis)
library(roadoi)
library(rorcid)




my_username <- Sys.getenv("USERNAME")
my_filepath <- file.path()

setwd(file.path)




# Setting up rcrossref ----------------------------------------------------

crossref_email=name@example.com

usethis::edit_r_environ()



# Getting publications from journals with cr_journals -------------------

# assign PLoS ONE ISSN to value
plosone_issn <- '1932-6203'
ploson_issn

# Query cr_journals for journal details into list (works = FALSE)
plosone_details <- rcrossref::cr_journals(issn = plosone_issn, works = FALSE)
View(plosone_details)

# Query cr_journals for journal details into dataframe (works = FALSE)
plosone_details <- rcrossref::cr_journals(issn = plosone_issn, works = FALSE) %>%
  purrr::pluck("data")
View(plosone_details)
names(plosone_details)  # see column names
str(plosone_details)  # see data types of columns

plosone_details$publisher  # see publisher
plosone_details$total_dois  # see totakl number of DOIs on file

plosone_details$deposits_funders_current  # Does PLoS ONE have current funders on file?

# Query cr_journals for article metadata into dataframe (works = TRUE)
plosone_publications <- rcrossref::cr_journals(issn = plosone_issn, works = T, limit = 25) %>%
  purrr::pluck("data")
View(plosone_publications)


# assign ISSNs for JAMA and JAH
jama_issn <- '1538-3598'
jah_issn <- '0021-8723'

# Query cr_journals for article metadata for both journals into dataframe (works = TRUE)
jah_jama_publications <- rcrossref::cr_journals(issn = c(jama_issn, jah_issn), works = T, limit = 50) %>%
  purrr::pluck("data")
View(jah_jama_publications)


# Use filter() and select() to get vol. 99, iss. 4
jah_99_4 <- jah_jama_publications %>%
  dplyr::filter(issn == jah_issn,
                volume == "99",
                issue == "4") %>%
  dplyr::select(title, doi, volume, issue, page, published.print, issn)
View(jah_99_4)

# filter() for a single article by DOI
jama_article <- jah_jama_publications %>%
  dplyr::filter(doi == "10.1001/jama.244.16.1799") %>%
  dplyr::select(title, doi, volume, issue, page, published.print, issn)
View(jama_article)


# filter() for a single article by title using str_detect()
jah_article <- jah_jama_publications %>%
  dplyr::filter(stringr::str_detect(title, "Gridiron University")) %>%
  dplyr::select(title, doi, volume, issue, page, published.print, issn)
View(jah_article)


# Filtering the `cr_journals` query with the `filter` argument ---------

# assign ISSN for JLSC
jlsc_issn <- "2162-3309"

# Filtering by publication date with `from_pub_date` and `until_pub_date`
jlsc_publications_2017 <- rcrossref::cr_journals(issn = jlsc_issn, works = T, limit = 1000,
                                                 filter = c(from_pub_date='2017-08-01')) %>%
  purrr::pluck("data")
View(jlsc_publications_2017)



# Field query by title ------------------------------------------------

# looking for "open access" in the title
jlsc_publications_oa <- rcrossref::cr_journals(issn = jlsc_issn, works = T, limit = 1000,
                                               flq = c(`query.title` = 'open access')) %>%
  purrr::pluck("data")
View(jlsc_publications_oa)



# Field query by author ---------------------------------------------------

# looking for articles by Dorothea Salo
jlsc_publications_auth <- rcrossref::cr_journals(issn = jlsc_issn, works = T, limit = 1000,
                                                 flq = c(`query.author` = 'salo')) %>%
  purrr::pluck("data")
jlsc_publications_auth




# Getting works from a typed citation in a Word document/text file --------

# read in the unformatted references
my_references <- read_csv("./data/raw/sample_references.csv")
View(my_references)


# loop through the references to gather reference information
my_references_works_list <- purrr::map(
  my_references$reference,
  function(x) {
    print(x)
    my_works <- rcrossref::cr_works(query = x, limit = 5) %>%
      purrr::pluck("data")
  })
View(my_references_works_list)


# get the first row for each reference into a data frame
my_references_works_df <- my_references_works_list %>%
  purrr::map_dfr(., function(x) {
    x[1, ]
  })
View(my_references_works_df)

# print the titles to the console
my_references_works_df$title



# Save to BibTeX file -----------------------------------------------------

# get the DOIs only
my_references_dois <- my_references_works_df$doi

# use cr_cn() to get the bibtex files
my_references_bibtex <- rcrossref::cr_cn(my_references_dois, format = "bibtex") %>%
  purrr::map_chr(., purrr::pluck, 1)

# write to disk
readr::write_lines(my_references_bibtex, "./data/results/my_references_bibtex.csv")


# Specifying field queries to `cr_works()` with `flq` ---------------------

# get all items with keyword "open access" and author "suber"
suber_oa <- cr_works(query = 'open+access', flq = c(`query.author` = 'suber')) %>%
  pluck("data")
View(suber_oa)

# get all items with author "suber" and bibliographic query for the ISBN 
suber_isbn <- cr_works(flq = c(`query.author` = 'suber',
                               `query.bibliographic` = '9780262301732')) %>%
  pluck("data")
View(suber_isbn)



# Querying Crossref works by DOI ------------------------------------------

# assign DOIs
my_references_dois <- c("10.2139/ssrn.2697412", "10.1016/j.joi.2016.08.002", "10.1371/journal.pone.0020961", "10.3389/fpsyg.2018.01487", "10.1038/d41586-018-00104-7", "10.12688/f1000research.8460.2", "10.7551/mitpress/9286.001.0001")

# Query cr_works() for those DOIs
my_references_dois_works <- rcrossref::cr_works(doi = my_references_dois) %>%
  pluck("data")

View(my_references_dois_works)



# Getting citation data with `cr_citation_count` --------------------------

# Use the DOIs to look up citation counts with cr_citation_count()
my_references_citation_count <- rcrossref::cr_citation_count(doi = my_references_dois)
View(my_references_citation_count)

# join the citation counts to the rest of the article metadata and arrange it from highest to lowest
my_references_works_citation_count_joined <- my_references_dois_works %>%
  left_join(my_references_citation_count, by = "doi") %>%
  arrange(desc(count))
View(my_references_works_citation_count_joined)



# Checking OA status with `oadoi_fetch` -----------------------------------

my_reference_dois_oa <- roadoi::oadoi_fetch(dois = my_references_dois)
View(my_reference_dois_oa)


# Getting URLs ------------------------------------------------------------

# pulling the URLs out of of the best_oa_location column
my_reference_dois_oa <- my_reference_dois_oa %>%
  dplyr::mutate(
    urls = purrr::map(best_oa_location, "url") %>% 
      purrr::map_if(purrr::is_empty, ~ NA_character_) %>% 
      purrr::flatten_chr()
  )
my_reference_dois_oa$urls

