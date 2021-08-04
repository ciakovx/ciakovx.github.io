# working with data in lists
# https://mybinder.org/v2/gh/ciakovx/ciakovx.github.io/master?filepath=jennybc_lists_lesson.ipynb
# based on https://jennybc.github.io/purrr-tutorial/ls00_inspect-explore.html 


# load libraries
library(png)
library(repurrrsive)
library(purrr)
library(repurrrsive)



# inspect and explore -----------------------------------------------------

# extract with $
x <- list(a = "a", b = 2)
x$a
x$b


# extract with double brackets
x <- list(a = "a", b = 2)
x[["a"]]
x[[2]]
nm <- "a"
x[[nm]]
i <- 2
x[[i]]


# extract with single brackets
x <- list(a = "a", b = 2)
x["a"]
x[c("a", "b")]
x[c(FALSE, TRUE)]



# wes anderson color palettes ---------------------------------------------

library(listviewer)



str(wesanderson)


jsonedit(wesanderson, mode = "view", elementId = "wesanderson")


# game of thrones POV characters ------------------------------------------

str(got_chars, list.len = 3)
str(got_chars[[1]], list.len = 8)



jsonedit(number_unnamed(got_chars), mode = "view", elementId = "got_chars")



# github users and repositories -------------------------------------------

str(gh_users, max.level = 1)



jsonedit(number_unnamed(gh_users), mode = "view", elementId = "gh_users")



jsonedit(number_unnamed(gh_repos), mode = "view", elementId = "gh_repos")


# vectorized and "list-ized" operations -----------------------------------

(3:5) ^ 2
sqrt(c(9, 16, 25))



map(c(9, 16, 25), sqrt)


## map(YOUR_LIST, YOUR_FUNCTION)



map(got_chars[1:4], "name")



map(got_chars[5:8], 3)


got_chars %>%
  map("name")
got_chars %>%
  map(3)



map_chr(got_chars[9:12], "name")
map_chr(got_chars[13:16], 3)



got_chars[[3]][c("name", "culture", "gender", "born")]




x <- map(got_chars, `[`, c("name", "culture", "gender", "born"))
str(x[16:17])



library(magrittr)
x <- map(got_chars, extract, c("name", "culture", "gender", "born"))
str(x[18:19])



map_dfr(got_chars, extract, c("name", "culture", "gender", "id", "born", "alive"))



library(tibble)
got_chars %>% {
  tibble(
       name = map_chr(., "name"),
    culture = map_chr(., "culture"),
     gender = map_chr(., "gender"),       
         id = map_int(., "id"),
       born = map_chr(., "born"),
      alive = map_lgl(., "alive")
  )
}

