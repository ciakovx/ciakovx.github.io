ringgold_id <- "enter your institution's ringgold"
email_domain <- "enter your institution's email domain"
organization_name <- "enter your organization's name"
# you want to use enough keywords so you won't get false positives, but not so many that youll miss variations in the name from user inputs.

my_query <- paste0('ringgold-org-id:',
                   ringgold_id,
                   'OR email:*',
                   email_domain,
                   'OR affiliation-org-name:',
                   organization_name,
                   '"')

orcid_count <- base::attr(rorcid::orcid(query = my_query),
                          "found")

my_pages <- seq(from = 0, to = orcid_count, by = 200)

my_orcids <- purrr::map(
  my_pages,
  function(page) {
    print(page)
    my_orcids <- rorcid::orcid(query = my_query,
                               rows = 200,
                               start = page)
    return(my_orcids)
  })

my_orcids_data <- my_orcids %>%
  dplyr::bind_rows() %>%
  janitor::clean_names()


my_orcid_employments <- rorcid::orcid_employments(my_orcids_data$orcid_identifier_path)

my_employment_data <- my_orcid_employments %>%
  purrr::map(., purrr::pluck, "affiliation-group", "summaries") %>% 
  purrr::flatten_dfr() %>%
  janitor::clean_names() %>%
  dplyr::mutate(employment_summary_end_date = anytime::anydate(employment_summary_end_date/1000),
                employment_summary_created_date_value = anytime::anydate(employment_summary_created_date_value/1000),
                employment_summary_last_modified_date_value = anytime::anydate(employment_summary_last_modified_date_value/1000))

