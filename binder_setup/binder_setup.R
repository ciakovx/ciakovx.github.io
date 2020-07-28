library(holepunch)
library(usethis)
library(rmarkdown)
library(jsonlite)

# https://karthik.github.io/holepunch/reference/write_dockerfile.html

# 
# options( usethis.full_name = "Clarke", usethis.description = list( `Authors@R` = 'person("Iakovakis", "Clarke", email = "clarke.iakovakis@okstat.edu", role = c("aut", "cre"), comment = c(ORCID = "0000-0002-9260-8456"))', License = "CC BY") )
# 
# write_compendium_description(type = "Compendium",
#                              package = "Compendium for FSCI 2020: W24", 
#                             description = "This is a compendium file for my FSCI 2020 W24 course")


# ipynb conversion --------------------------------------------------------

# notedown DataExploration.Rmd | sed '/%%r/d' > DataExploration.ipynb

# rmarkdown:::convert_ipynb("./fsci2020/rcrossref.ipynb", output = xfun::with_ext("./fsci2020/rcrossref", "Rmd"))


# write_dockerfile(maintainer = "clarike_iakovakis") 
# 