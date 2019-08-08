install.packages("tidyverse")
library(tidyverse)


# For this session, we will be reading a CSV from a web connection rather than saving the data to our computer and loading it into R.

# To get our sample data into our R session, we will use the `read_csv()` function and connect to a CSV saved on my GitHub using the `url()` function.

books_url <- url("https://raw.githubusercontent.com/ciakovx/ciakovx.github.io/master/workshop_files/data/books.csv")
books <- readr::read_csv(books_url)
books

# shorter dataset
books <- read_csv(url("https://raw.githubusercontent.com/ciakovx/ciakovx.github.io/master/workshop_files/data/books2.csv")


# head will print the first few rows (you can specify more with n)
head(books, n = 10)

# The dollar sign `$` is used to distinguish a specific variable (column) in a data frame:
head(books$X245.ab)

# print the mean number of checkouts
mean(books$TOT.CHKOUT)

# print a summary of checkouts
summary(books$TOT.CHKOUT)

# print a simply histogram of checkouts
hist(books$TOT.CHKOUT)


# Use `unique()` to see all the distinct values in a variable:
unique(books$LOCATION)

# Take that one step further with `table()` to get quick frequency counts on a variable:
table(books$LOCATION)

# you can use it with relational operators:
table(books$TOT.CHKOUT > 50)

### how many books have over 100 checkouts?


# what are the titles?



# duplicated --------------------------------------------------------------

# `duplicated()` will give you the a logical vector of duplicated values.
mydupes <- tibble("identifier" = c("111", "222", "111", "333", "444"),
                  "birthYear" = c(1980, 1940, 1980, 2000, 1960))

duplicated(mydupes$identifier)

# you can put an exclamation mark before it to get non-duplicated values
!duplicated(mydupes$identifier)

### subset that row out of the data frame using brackets
mydupes[]


# # which() is also a useful function for identifying the specific element in the vector that is duplicated
which(duplicated(mydupes$identifier))

# missing values ----------------------------------------------------------

# How many total missing values?
sum(is.na(books))
## [1] 5591

# Total missing values per column
colSums(is.na(books))

# use table() and is.na() in combination
table(is.na(books$isbn))



# Renaming variables ------------------------------------------------------

# It is often necessary to rename variables to make them more meaningful. If you print the names of the sample `books` dataset you can see that some of the vector names are not particularly helpful:

names(books)

# There are many ways to rename variables in R, but I find the `rename()` function in the `dplyr` package to be the easiest and most straightforward. The new variable name comes first.

rename(books, "title" = X245.ab)

# Make sure you assign (<-) the output to your variable, otherwise it will just print it to the console
books <- rename(books, "title" = X245.ab)

### rename the X245.c to "author"
books <- rename()


### rename the rest of the columns
books <- dyplr::rename(books,
                       callnumber = CALL...BIBLIO.,
                       isbn = ISN,
                       pubyear = X008.Date.One,
                       subCollection = BCODE1,
                       format = BCODE2)


# clean messy names with janitor ------------------------------------------
install.packages("janitor")
library(janitor)
books <- janitor::clean_names(books)
names(books)

# It is often necessary to recode or reclassify values in your data. For example, in the sample dataset provided to you, the `sub_collection` (formerly `BCODE1`) and `format` (formerly `BCODE2`) variables contain single characters.

# first print to the console all of the unique values you will need to recode
unique(books$sub_collection)

# Use the recode function to assign them. 
# Unlike rename, the old value comes first here. 
books$sub_collection <- dyplr::recode(books$sub_collection,
                                      "-" = "general collection",
                                      u = "government documents",
                                      r = "reference",
                                      b = "k-12 materials",
                                      j = "juvenile",
                                      s = "special collections",
                                      c = "computer files",
                                      t = "theses",
                                      a = "archives",
                                      z = "reserves")

books$format <- dyplr::recode(books$format,
                              a = "book",
                              e = "serial",
                              w = "microform",
                              s = "e-gov doc",
                              o = "map",
                              n = "database",
                              k = "cd-rom",
                              m = "image",
                              "5" = "kit/object",
                              "4" = "online video")

# In the same way we used brackets to subset vectors, we also use them to subset dataframes. However, vectors have only one direction, but dataframes have two. Therefore we have to use two values in the brackets: the first representing the row, and the second representing the column: `[[row, column]]`. 

# When using tibbles, single brackets will return a tibble, but double brackets will return the individual vectors or values without names.

# subsetting a vector 
c("do", "re", "mi", "fa", "so") [1]

# subsetting a data frame:
# pull a single variable into a tibble with names
books[5, 2]
## # A tibble: 1 x 1
##   X245.ab                                              
##   <chr>                                                
## 1 The control room :~how television calls the shots in~

### pull out a single variable without names
books[[5, 2]]

### use names to pull data
books[[2, "title"]]

# Subsetting using brackets is important to understand, but as with other R functions, the `dplyr` package makes it much more straightforward, using the `filter()` function.

# filter books to return only those items where the format is books
booksOnly <- filter(books, format == "book")

# use multiple filter conditions, 
# e.g. books to include only books with more than zero checkouts
bookCheckouts <- filter(books,
                        format == "book",
                        tot_chkout > 0)

### How many are there? 
nrow(bookCheckouts)

### What percentage of all books have at least one checkout?



### Run `unique(books$location)` and `unique(books$sub_collection)` to confirm the values in each of these fields.



### Create a new data frame filtering to keep format == books and tot_chkout > 20. Use the `table()` function to see the breakdown of booksOnly by `sub_collection`. Which sub-collection has the most items with 20 or more checkouts?



### Create a data frame consisting of `format` books and `sub_collection` juvenile materials. What is the average number of checkouts `tot_chkout` for juvenile books?







# Selecting variables -----------------------------------------------------

# The `select()` function allows you to keep or remove specific variables. It also provides a convenient way to reorder variables.
# specify the variables you want to keep by name
booksTitleCheckouts <- select(books, title, tot_chkout)

# specify the variables you want to remove with a -
books <- select(books, -call_item)

# reorder columns, combined with everything()
booksReordered <- select(books, title, tot_chkout, loutdate, everything())


# Arranging data ----------------------------------------------------------

# The `arrange()` function in the `dplyr` package allows you to sort your data by alphabetical or numerical order. 

booksTitleArrange <- arrange(books, title)

# use desc() to sort a variable in descending order
booksHighestChkout <- arrange(books, desc(tot_chkout))

# order data based on multiple variables (e.g. sort first by checkout, then by publication year)
booksChkoutYear <- arrange(books, desc(tot_chkout), desc(pubyear))


# Creating new variables --------------------------------------------------

# The `mutate()` function allows you to create new variables.

library(stringr)
# # use the str_sub() function from the stringr package to extract the first character of the callnumber variable (the LC Class)
booksLC <- mutate(books
                  , lc_class = str_sub(callnumber, 1, 1))



# Putting it all together with %>% ----------------------------------------

# The Pipe Operator] `%>%` is loaded with the `tidyverse`. It takes the output of one statement and makes it the input of the next statement. You can think of it as "then" in natural language.

myBooks <- books %>%
  filter(format == "book") %>%
  select(title, tot_chkout) %>%
  arrange(desc(tot_chkout))

### Create a new data frame from books with these conditions:
  # filter to include subCollection juvenile & k-12 materials and format books
  # select only title, call number, total checkouts, and pub year
  # arrange by total checkouts in descending order



### Create a new data frame from books with these conditions:
  # rename call_item column to call_number
  # filter out NA values in the call number column
  # filter to include only books published after 1990
  # arrange from oldest to newest publication year






