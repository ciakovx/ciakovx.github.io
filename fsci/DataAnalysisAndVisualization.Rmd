---
title: "Session 3: Data Analysis"
author: "Clarke Iakovakis"
date: "May, 2018"
output: 
  pdf_document:
    number_sections: yes
    highlight: tango
    toc: true
    toc_depth: 2
    df_print: tibble
header-includes:
  - \usepackage{xcolor}
  - \usepackage{fancyhdr}
urlcolor: blue
fontsize: 12pt
---

\pagestyle{fancy}
\fancyhead[LE,RO]{}
\fancyhead[LO,RE]{}
\renewcommand{\headrulewidth}{0.4pt}
\renewcommand{\footrulewidth}{0pt}

```{r setup, include=FALSE}
library(png)
library(tinytex)
library(knitr)
library(printr)
library(xtable)
setwd("C:/Users/iakovakis/Documents/Instruction/R Webinar/doc")
knitr::opts_chunk$set(echo = TRUE, cache = TRUE, tidy.opts=list(width.cutoff=70),tidy=TRUE)
opts_knit$set(root.dir = getwd())

#color_block = function(color) {
#  function(x, options) sprintf('\\color{%s}\\begin{verbatim}%s\\end{verbatim}'
#                               , color, x)
#}
#knitr::knit_hooks$set(error = color_block('red'))
```

\pagebreak
# Cleaning up strings with stringr
```{r,fig.height=.8,echo=FALSE}
stringrpng <- readPNG("./images/stringr.png")
grid::grid.raster(stringrpng, just = 4.5)
```
There is no end to the number of problems you will run into when cleaning your data. It is a truism that data cleanup and preparation generally takes 80% of the time in a data project, leaving the remaining 20% for analysis and visualization. Strings can be one of the most problematic parts of the data cleanup process, which makes `stringr` one of the most useful packages in R. Read the [chapter on strings](http://r4ds.had.co.nz/strings.html) in R for Data Science, and then visit <http://stringr.tidyverse.org/> to read uses of it. You can also run `vignette("stringr")` in your console.

For libraries, common strings include titles, authors, subject headings, ISBNs (even though they are digits, they are treated as characters because they are identifiers), publishers, vendors, and more. `stringr` contains a number of functions to manipulate characters, trim whitespace from the beginning and ending of a string, and execute pattern matching operations (for example, recognize all 13 digit numbers beginning with 978 as ISBNs).

Below we will explore one small example of a string cleanup issue in the **ebooks.csv** file, included in the course documents.

## Replace characters with str_replace()

First read the data in. Notice we have to use the `colClasses` argument on the ISBN fields, otherwise they're read in incorrectly as integers. Use `View()` to examine the data, and call `str()` on it to see a glimpse of it in the console. 
```{r clean, comment=NA, eval=F, tidy=F}
ebooks <- read.csv("./ebooks.csv"
                   , stringsAsFactors = F
                   , colClasses = c(ISBN.Print = "character"
                                    , ISBN.Electronic = "character"))
View(ebooks)
str(ebooks)
```

There are several fields here we can do some analysis with, including **Pages.Viewed** and **User.Sessions.** Let's say we want to see the mean number of user sessions:
```{r clean0, comment=NA, eval=F}
mean(ebooks$User.Sessions)
## Warning message:
## In mean.default(ebooks$User.Sessions) :
##  argument is not numeric or logical: returning NA
```

Calling `class(ebooks$User.Sessions)` we see that R read this variable in as **character,** as it did with Total.Pages, Pages.Viewed, and Pages.Printed. You cannot take the mean of a character, only a **numeric** or **integer**. The reason R read these variables in as characters is because the vendor put a comma in numbers 1,000 and higher. R detected the comma, and determined that these vectors are **characters**, not **numeric.** 

Now, we could coerce it to integer by calling `ebooks$User.Sessions <- as.integer(ebooks$User.Sessions)` however this would be a serious error. If we coerced this field to integer, it would replace any value including a comma with `NA`, which means we would have no data for our highest usage items!

So we need to do two things: 

1. Remove the comma
2. Coerce the vectors from characters to integers using `as.integer()` 

The `str_replace` function is similar to **Find/Replace** in Microsoft Excel. Call `help(str_replace)` to see it has three arguments: `string`, `pattern`, and `replacement.` Remember you cannot feed an entire **data frame** to this function. You must work with one vector at a time.

```{r clean1, comment=NA, eval=F}
vec <- c("800", "900", "1,000")

# Remember you have to load stringr first.
# When you load tidyverse, stringr is automatically loaded
library(tidyverse)

# scan through each item in vec and replace the pattern 
# (a comma: ",") with nothing (an empty set of quotes "")
vec2 <- str_replace(vec
                    , pattern = ","
                    , replacement = "")
vec2
## [1] "800"  "900"  "1000"

# notice that this is still a character vector
# you can also tell by the quotation marks around the numbers.
class(vec2)
## [1] "character"

# so we must coerce it to an integer
vec2 <- as.integer(vec2)

# now we can perform mathematical operations on it
mean(vec2)
## [1] 900
```

We can do exactly the same thing on the ebooks data, except on multiple vectors at once using the `mutate()` function from `dplyr`. Note that you do not have to include the `pattern =` and `replacement =` in your argument. This will overwrite the existing variables Total.Pages, Pages.Viewed, Pages.Printed, and User.Sessions and remove the commas in all these fields.

Of course, that means those vectors will still be in character class, which means we can't do mathematical operations on them. So in sum, the easiest way to handle this is to do it all at once, by nesting the `str_replace` function within `as.integer`.

```{r clean3, comment=NA, eval=F, tidy=F}
ebooks <- mutate(ebooks
          , Total.Pages = as.integer(str_replace(ebooks$Total.Pages, ",", ""))
          , Pages.Viewed = as.integer(str_replace(ebooks$Pages.Viewed, ",", ""))
          , Pages.Printed = as.integer(str_replace(ebooks$Pages.Printed, ",", ""))
          , User.Sessions = as.integer(str_replace(ebooks$User.Sessions, ",", ""))) 
```

## Extract characters with str_sub()
Another data manipulation task we can do is to create a new variable **LC.Class** using the `str_sub()` function. This function takes a vector, a starting character, and an ending character, and grabs the characters in between those points (i.e. a **substring**). For example:
```{r clean41, comment=NA, eval=F, tidy=F}
vec3 <- "Macbeth"

# Start at character 1 and end at character 3
str_sub(vec3, 1, 3)
## [1] "Mac"
```

With our LC class, since we only want the first character, our starting point and ending point are both 1. We can put this into `mutate()` from the `dplyr` package to create the new variable all at once.
```{r clean4, comment=NA, eval=F, tidy=F}
ebooks <- mutate(ebooks
                 , LC.Class = str_sub(LC.Call
                                    , start = 1
                                    , end = 1))
```

## Remove whitespace with str_trim()
Sometimes blank spaces can end up before or after a string. You can remove these automatically with the `str_trim()` function.
```{r clean5, comment=NA, eval=F, tidy=F}
vec4 <- c(" a", "b ", " c ")

str_trim(vec4) 
## [1] "a" "b" "c"
```

## Detect patterns with str_detect()
The `str_detect()` function takes a character vector and a pattern, and looks for that pattern in each element in the vector. If the pattern is found, a TRUE value is returned. Use `str_detect()` in combination with the `filter()` function from `dplyr` to creat custom subsets

```{r clean6, comment=NA, eval=F, tidy=F}
titles <- c("Macbeth", "Dracula", "1984")

str_detect(titles, "Dracula")
## [1] FALSE  TRUE FALSE

# use in combination with which()
which(str_detect(titles, "Dracula"))
## [1] 2

# or use in combination with filter to create a subset
# this will scan through the Title column in the ebooks dataset
# and return all values that contain the word "Chemistry"
ebooksScience <- filter(ebooks
                        , str_detect(Title, "Chemistry"))

head(ebooksScience$Title)
## [1] "Specialist Periodical Reports, Volume 29 : Organometallic Chemistry"                     
## [2] "Advanced Organic Chemistry, Part A:  Structure and Mechanisms (4th Edition)"             
## [3] "Advanced Organic Chemistry, Part B : Reactions and Synthesis (4th Edition)"              
## [4] "Guide to Chalogen-Nitrogen Chemistry"                                                    
## [5] "Bioanalytical Chemistry"                                                                 
## [6] "Environmental Laboratory Exercises for Instrumental Analysis and Environmental Chemistry"

# the ignore_case argument will get the word regardless of upper or lower case
ebooksScience <- filter(ebooks
                        , str_detect(Title, fixed("Chemistry", ignore_case = T)))

# Perhaps it will be more effective to also get books where the word chemistry 
# appears in the Sub.Category as well. Here I use the | symbol to represent a Boolean OR
ebooksScience2 <- ebooks %>%
  filter(str_detect(Title, fixed("Chemistry", ignore_case = T)) 
         | str_detect(Sub.Category, fixed("Chemistry", ignore_case = T)))
```

You can leverage `stringr` by learning Regular Expressions (regex). Take a regex tutorial at <https://regexone.com/> and test your regular expressions at <https://regexr.com/>.

---

**TRY IT YOURSELF**

1. Execute the following operations and see what happens
```{r clean7, comment=NA, eval=F}
titles <- c("Dracula", "Macbeth", "1984", "Jane Eyre", "The Great Gatsby", "The Iliad", "Moby Dick")
str_detect(titles, "The")
titles[str_detect(titles, "The")]
str_subset(titles, "The")
str_to_lower(titles)
str_to_upper(titles)
str_c(titles, collapse = ", ")
str_length(titles)
which(str_length(titles) >= 9)
titles[str_length(titles) >= 9]
titles[str_length(titles) < 9]

x <- c("a ", " b", " c ")
str_trim(x)
```

2. Click on the Packages tab in the navigation pane in R Studio, then click on stringr. Read some of the help pages for these functions.
3. Use `str_detect()` with `filter()` to get all books with the word "Britain" in the title. Write another expression to get all books with Britain in the title or in the sub category.



---

\pagebreak

# Group and summarize data
Last session we reviewed several `dplyr` functions including `filter()`, `select()`, `mutate()` and `arrange()`. 

`group_by()` and `summarize()` are two more powerful `dplyr` functions. Use `group_by()` to cluster the dataset together in the variables you specify. For example, if you group by LC Call number class, then you can sum up the total number of ebook user sessions per call number class using `summarize()`. `summarize()` will collapse many values down into a single summary statistics.

Here is an example using the **LC.Class** variable created in Section 1.2 above.
```{r groupby, comment=NA, eval=F, tidy=F}
# First, create the grouped variable
byLC <- group_by(ebooks, LC.Class)

# Then, summarize by User.Sessions
UserSessions_byLC <- summarize(byLC, totalSessions = sum(User.Sessions))
View(UserSessions_byLC)

# Arrange it
UserSessions_byLC <- arrange(UserSessions_byLC, desc(totalSessions))
View(UserSessions_byLC)
```

We can use the %>% operator to do both these operations at the same time.
```{r groupby2, comment=NA, eval=F, tidy=F}
UserSessions_byLC <- byLC %>%
  summarize(totalSessions = sum(User.Sessions)) %>%
  arrange(desc(totalSessions))
```

The top 5 are H, Q, B, T, and L. If we were ambitious, we could use the `recode()` function to assign each call number class with its classification name:
```{r groupby32, comment=NA, eval=F, tidy=F}
recode(UserSessions_byLC$LC.Class
       , H = "Social Sciences"
       , Q = "Science"
       , B = "Philosophy"
       , T = "Technology"
       , L = "Education")
```


We may also want to see the total number of books in each call number class, and also calculate the mean user sessions per class:

* use `n()` to sum up the total number of ebooks per call number class. Add it as a column called `count.`
* use `sum(User.Sessions)` to add up the cumulative total user sessions per call number class. Add it as a column called `totalSessions`.
* use `mean(User.Sessions)` to calculate the mean user sessions per call number class. Add it as a column called `avgSessions`.

```{r groupby3, comment=NA, eval=F, tidy=F}
byLCSummary <- byLC %>%
  summarize(
    count = n()
    , totalSessions = sum(User.Sessions)
    , avgSessions = mean(User.Sessions)) %>%
  arrange(desc(avgSessions))
```

This will become much more powerful as we put it into a visualization.

---

**TRY IT YOURSELF**

1. Group the ebooks data set by the `Category` variable and assign it to `byCategory`
2. With the `byCategory` variable, use `summarize` to create three new variables: `count` 



\pagebreak

# Visualizing data with ggplot2
sfdasfda


