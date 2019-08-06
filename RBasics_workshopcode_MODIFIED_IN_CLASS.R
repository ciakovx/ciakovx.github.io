
### Type the expression 2 + 2 into your console and press Enter, or type it into this script and press Ctrl + Enter while your cursor is on that line.  




# Assigning values & Evaluating expressions -------------------------------

# Assign operators with <- . For example x <- 100 will assign 100 to the x variable.

### Assign the value 5 to y


### Evaluate y by typing it into the console and pressing enter


### Print y to the console with print(y)


# The [1] indicates that the number 5 is the first element of this vector.
# You can assign anything to nearly any variable, and then perform operations on or with that variable. 

### Add 20 to y


### Assign the number 10 to variable `x`. Add `x` and `y` and evaluate the expression.


### Assign x + y to variable myTotal. Look in the Environment pane to see what myTotal contains.


### Run View(myTotal) to see it in the Data Viewer




# Calling a function ------------------------------------------------------

# R is a "functional programming language," meaning it contains a number of functions you use to do something with your data. Call a function on a variable by entering the function into the console, followed by parentheses and the variables.

### confirm that sum is a function
is.function(sum)

### sum takes an unlimited number (. . .) of numeric elements
sum(3, 4, 5, 6, 7)

### evaluating a sum with missing values will return NA
sum(3, 4, NA)

### but setting the argument na.rm to TRUE will remove the NA
sum(3, 4, na.rm = TRUE)


# Reading help pages ------------------------------------------------------

# To load the help page for a function you can use either:
?sum
help(sum)

# In the case of `sum()`, the ellipses `. . .` represent an unlimited number of numeric elements. `sum()` also takes the argument `na.rm`. This is a logical (`TRUE/FALSE`) argument specifying if NA values (missing data) should be removed when the argument is evaluated.


# str() and c() -----------------------------------------------------------

# Call str() on an R object to compactly display information about it, including the data type, the number of elements, and a printout of the first few elements. Evaluate the results of the following. What do you think num and chr mean?

y <- 5
str(y)

x <- "hello"
str(x)


# c() will combine arguments to form a vector.

z <- c(5, 10, 15)
q <- c(2, 4, 6, 8, 10, 12)

# Congratulations! You have created your first vectors in R. A vector is a sequence of elements of the same type. Vectors can only contain "homogenous" data--in other words, all data must be of the same type. The class of a vector determines what kind of analysis you can do on it.

### Use length() to find the length of z.


### call str() on z. Is it the same type as y?


### Add y and z


### R is vectorized: y is added to each element of z. What do yoiu think will happen when you add q and z?



### Read the help page for sum(). What do you think will happen when you run sum(y, z)?


# Data classes --------------------------------------------------------------


# numeric
checkouts <- c(25, 15, 18)
class(checkouts)
is.numeric(checkouts)
is.character(checkouts)


# character
title <- c("Macbeth","Dracula","1984")
author <- c("Shakespeare","Stoker","Orwell")

# logical
available <- c(TRUE, FALSE, FALSE)
class(available)

### you can also create logical vectors to use as an index
q <- c(2, 4, 6, 8, 10, 12)

### create an index of TRUE/FALSE values where x is greater than 2
my_index <- q > 7
print(my_index)


### subset x using that `my_index` in brackets (more on this later)
q[my_index]


# If you mix different objects in one vector, R will coerce the vector to be a single class. You can also coerce a vector to be a specific data type. 

my_mixed_vector <- c(1:10, "a")
class(my_mixed_vector)

### coerce the vector to an integer. What do you think the warning message means?
my_coerced_vector <- as.integer(my_mixed_vector)
print(my_coerced_vector)

# R replaces the "a" with NA because `a` is not an integer

### What do you think the result of this will be?
as.logical(c(1, 0, 0, 1))


# You can also make a sequence of numbers using seq(). Read the help page for seq and then create a sequence of numbers from 0 to 50 in increments of 5 (i.e. 0, 5, 10, 15...)
seq()



# Missing values ----------------------------------------------------------

# If our data is missing values, we can use `NA` to represent those. R functions have special actions when they encounter NA. is.na() and conversely complete.cases() can test your vectors for missing values:

my_nas <- c(letters[1:5], rep(NA, 5))
print(my_nas)

### Which values are NA? What class of vector is this?
is.na(my_nas)
complete.cases(my_nas)

# How many of each?
table(is.na(my_nas))



# Subsetting vectors ------------------------------------------------------

# You can use the brackets to subset a vector. Brackets can take either numeric values (which will correspond to the element in the order it exists in the vector) or logical (T/F) values. You can also use functions such as which(), that return numeric values.

### state.name is a built in vector in R of all U.S. states
state.name


### access state.names using indices
state.name[1]
state.name[50]
state.name[1:5]

### If we use negative numbers, R will return every element except for the one specified. Use -1 to subset out the first state name.


### Try to find the first, 10th, and 20th state name at the same time. If you got an error, think about how you can make the 1, 10, 20 into a vector and use that as an index


# There's only one state called Alabama
table(state.name == "Alabama")


### create a numeric vector of state names where "California" == TRUE. 
calif <- which(state.name == "California")
calif
state.name[calif]


# nchar() can be used to count the number of characters in a string. 
nchar(state.name)

### How many states have 7 characters?
nchar(state.name) == 7

### Let's put that into a table:
table(nchar(state.name) == 7)


### Use nchar() , the > symbol, and brackets [] to get only state names with more than 10 characters:
ten_characters <- 
  state.name[ten_characters]



# Data frames -------------------------------------------------------------

# A data frame is the term in R for a spreadsheet style of data: a grid of rows and columns. The number of columns and rows is virtually unlimited, but each column must be a vector of the same length. A dataframe can comprise heterogeneous data: in other words, each column can be a different data type. However, because a column is a vector, it has to be a single data type.

# A tibble is the same thing as a data frame, but is constructed more efficiently. It is imported from the dplyr package. We will be using tibbles in this course.

library(tidyverse)

### create three vectors
title <- c("Macbeth","Dracula","1984")
checkouts <- c(25, 15, 18)
available <- c(TRUE, FALSE, FALSE)

# Use dplyr:: to indicate the package name the function comes from:
ebooks <- dplyr::tibble(title, checkouts, available)

View(ebooks)

### display information about the data frame
str(ebooks)
is_tibble(ebooks)

### dimensions dim()


### number of rows nrow()


### number of columns ncol()


### column names names()


### Create a new tibble of author names
author <- tibble("author" = c("Shakespeare","Stoker","Orwell"))
author

ebooks <- ebooks %>%
  dplyr::bind_cols(author)

# This makes use of a pipe operator, which we will explain and use later

# You can use the $ and/or [] symbols to work with particular variables:
print(ebooks$title)
print(ebooks[1])

### Get the class() of the checkouts column. Get the class() of the available column:



# Unlike vectors, data frames have two dimensions: [row, column]
ebooks[1, ]
ebooks[, 1]
ebooks[, "title"]


### Use brackets to answer these questions: How many checkouts does Dracula have? Is Macbeth currently available?
ebooks[]
ebooks[]

# use summary() for more detail on a variable
summary(ebooks$checkouts)
sum(ebooks$checkouts)



# Lists -------------------------------------------------------------------

# Unlike vectors and data frames, you can put anything you want into a list:

myList <- list(a = 10:20, 
               b = "list example", 
               c = TRUE,
               d = ebooks)
View(myList)

### A single bracket returns the element from the list, but still in list form
myList[2]
class(myList[2])

### To extract individual elements of a list, you need to use the double-square bracket function: [[.
myList[[2]]
class(myList[[2]])

# Notice that the result is now a character, not a list

# You can also use names of the list items and $
myList[["b"]]
myList$d

# If the list is deeper than a single element, you can use a combination of double and single brackets
myList[[1]][3]
myList$a[3]

# The purrr package in R is designed for working with lists and contains a function pluck() that allows us to extract items in the same way

### These do the same thing:
purrr::pluck(myList, 4)
purrr::pluck(myList, "d")

### These do the same thing:
purrr::pluck(myList, "d", "title")
purrr::pluck(myList, "d", 1)

### Use pluck to extract "Stoker" (the 2nd element of the "author" column) 


# You can also use map() to run a function over each element of the list

### This will print the class of each list item
purrr::map(myList, class)

### This will pluck the first element out of each list item
purrr::map(myList, pluck, 1)

