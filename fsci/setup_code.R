
# This is code intended to help you get setup for the TCDL session on 
# Querying & Accessing Scholarly Literature metadata: Using rcrossref, 
# rorcid, and roadoi

# Consult the accompanying setup_instructions.pdf document for more detail.

# Installing and loading packages -----------------------------------------

install.packages("rorcid")
library(rorcid)

install.packages("tidyverse")
library(tidyverse)

install.packages("anytime")
library(anytime)

install.packages("httpuv")
library(httpuv)

install.packages("rcrossref")
library(rcrossref)

install.packages("usethis")
library(usethis)

install.packages("janitor")
library(janitor)

install.packages("roadoi")
library(roadoi)


# Setting up rorcid -------------------------------------------------------

orcid_auth()

ORCID_TOKEN="copy and paste your token here"

usethis::edit_r_environ()

library(rorcid)

orcid_auth()


# Setting up rcrossref ----------------------------------------------------

crossref_email=name@example.com

usethis::edit_r_environ()
















