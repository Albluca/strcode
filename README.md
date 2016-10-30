README
================

The strcode (short for structure code) package is an [RStudio Add-in](https://rstudio.github.io/rstudioaddins/) that lets you quickly add code block separators so you can organize your code better. You can learn more about structuring code in [Bono Usu](https://github.com/lorenzwalthert/bonousu/blob/devel/docs/commenting-code.html), a guide for good practice in R programming.

Installation
============

You can install the package from github.

``` r
# install.packages("devtools")
devtools::install_github("lorenzwalthert/strcode")
```

Overview
========

We suggest three levels of granularity in code structuring. Of course, higher-level blocks can contain lower-level blocks.

-   level 1 sections, which are high-level blocks that can be separated as follows

``` r
#   ____________________________________________________________________________
#   I: import xzy
```

-   level 2 sections, which are medium-level blocks that can be separated as follows

``` r
##  ............................................................................
##  A: pre-process t2
```

-   level 3 sections, which are low-level blocks that can be separated as follows

``` r
### .. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
### a
```

You can notice from above that

-   The number of `#` used in front of the break character (`___`, `...`, `. .`) corresponds to the level of granularity that is separated.
-   l1 sections have roman numbers, l2 sections upper-case letters and l3 sections letters have lower-case letters.
-   The breaks characters `___`, `...`, `. .` were choosen such that they reflect the level of granularity, namely `___` has a much higher visual density than `. .`.
-   Each block has an (optional) short comment on what the next block is about.

The separators do all have length 80. The value is looked up in the global option `strcode.char.lenght` and can be changed by the user (either every session manually or using .Rprofile).
For each of the introduced separator, there is an Add-in function. You can also call them from the console:

-   `strcode::insert_l1_break()`
-   `strcode::insert_l2_break()`
-   `strcode::insert_l3_break()`

Example
=======

To demonstrate the improvement to legibility, we give an extended example of garbage code.

``` r
#   ____________________________________________________________________________
#   function test 
test <- function(x) {
##  ............................................................................
##  A: pre-processing
### .. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
### a: assertive tests
  # x
  if(missing(x) || is.null(x)){ 
    x <- character()
  }
  assert(
    # use check within assert
    check_character(x),
    check_factor(x),
    check_numeric(x)
  )
  
  # levels 
  if(!missing(levels)){
    assert(
      check_character(levels),
      check_integer(levels),
      check_numeric(levels))
    levels <- na.omit(levels)
    
  }
  
  # labels
  if(!missing(labels)){
    assert(
      check_character(labels),
      check_numeric(labels),
      check_factor(labels)
      )
  }
  
### .. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
### b: coercion / remove missing
  x <- as.character(x)
  uniq_x <- unique(na.omit(x), nmax = nmax)
  
### .. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
### c: warnings
  
  if(length(breaks) == 1) {
    if(breaks > max(x) - min(x) + 1) {
      stop("range too small for the number of breaks specified")
    }
    if(length(x) <= breaks) {
      warning("breaks is a scalar not smaller than the length of x")
    }
  }  
  
##  ............................................................................
##  B: actual function 
   variable < -paste("T", period, "nog_", sector, sep = "")
   variable <- paste(variable, "==", 1, sep = "")
        
   arg<-substitute(variable)
   r<-eval(arg, idlist.data[[1]])
   a<<-1
   
   was_factor <- FALSE
   if (is.factor(yes)) {
     yes <- as.character(yes)
     was_factor <- TRUE
   } 
   if (is.factor(no)) {
     no <- as.character(no)
     was_factor <- TRUE
   }
   out <- ifelse(test, yes, no)
   if(was_factor) {
     cfactor(out)
   } else {
     out
   } 
   
##  ............................................................................
}
#   ____________________________________________________________________________
#   function test2
test2 <- function(x) {
##  ............................................................................
##  A: pre-processing
### .. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
### a: assertive tests
  # x
  if(missing(x) || is.null(x)){ 
    x <- character()
  }
  assert(
    # use check within assert
    check_character(x),
    check_factor(x),
    check_numeric(x)
  )
  
  # levels 
  if(!missing(levels)){
    assert(
      check_character(levels),
      check_integer(levels),
      check_numeric(levels))
    levels <- na.omit(levels)
    
  }
  
  # labels
  if(!missing(labels)){
    assert(
      check_character(labels),
      check_numeric(labels),
      check_factor(labels)
      )
  }
  
### .. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
### b: coercion / remove missing
  x <- as.character(x)
  uniq_x <- unique(na.omit(x), nmax = nmax)
  
### .. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
### c: warnings
  
  if(length(breaks) == 1) {
    if(breaks > max(x) - min(x) + 1) {
      stop("range too small for the number of breaks specified")
    }
    if(length(x) <= breaks) {
      warning("breaks is a scalar not smaller than the length of x")
    }
  }  
  
##  ............................................................................
##  B: actual function 
   variable < -paste("T", period, "nog_", sector, sep = "")
   variable <- paste(variable, "==", 1, sep = "")
        
   arg<-substitute(variable)
   r<-eval(arg, idlist.data[[1]])
   a<<-1
   
   was_factor <- FALSE
   if (is.factor(yes)) {
     yes <- as.character(yes)
     was_factor <- TRUE
   } 
   if (is.factor(no)) {
     no <- as.character(no)
     was_factor <- TRUE
   }
   out <- ifelse(test, yes, no)
   if(was_factor) {
     cfactor(out)
   } else {
     out
   } 
   
##  ............................................................................
}
```