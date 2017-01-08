#' Summarize the code structure
#'
#' Create a summary of one or multiple code files based on the section
#' separators and their comments.
#' @param dir_in The directory where the file(s) can be found.
#' @param dir_out The directory to print the output to. "" implies the console.
#' @param file_in The name of a file which should be summarized. If this is
#'   \code{NULL}, the summary will be for all files in the specified directory.
#'   The default value uses the RStudio API to produce a summary of content from
#'   the source editor. This requires that
#'   the file is saved before \code{sum_str} is called.
#' @param file_in_extension If \code{file_in} is \code{NULL}, all files with the
#'   \code{file_in_extension} are considered.
#' @param file_out A connection or character string naming the file to print to.
#'   The argument is irrelevant if \code{output_dir} is set to "".
#' @param file_out_extension A file extension for the file to be created.
#' @param width The character width of the output. If NULL, it is set to the
#'   length of the longest separator comment.
#' @param line_nr A boolean value that indicates whether the line numbers should
#'   be printed along with the structure summary.
#' @param granularity Indicates the lowest level of granularity that should be
#'   included in the summary.
#' @param lowest_sep A boolean value indicating whether or not the separating
#'   lines should be reported along with their comments.
#' @param title A boolean value indicating whether the reported summary should
#'   contain a title or not.
#' @param header A boolean value indicating whether a column header should
#'   indicate the name of the columns (line, level, section).
#' @param ... futher arguments to be passed from and to other methods, in
#'   particular \code{\link{list.files}} for reading in multiple files.
#' @details To create the summary, \code{sum_str} uses regular expressions.
#'   Hence it is crucial that the code separators and the separator comments
#'   match the regular expression pattern. We recommend inserting
#'   separators and their comments using the RStudio Add-in that is contained
#'   in this package. The definition is rather intuitive as can be seen in the
#'   example section below. However, we shall provide a formal definition here
#'   as well.
#'   \itemize{
#'     \item A code separator is defined as a line that starts with n hashes,
#'     followed by 4-n spaces where 0 < n < 4. This sequence is followed by one
#'     or more either \code{.} or \code{_}.
#'     \item A comment associated with a code separator is defined as a line
#'     that starts with n hashes, followed by 4-n spaces where 0 < n < 4. This
#'     sequence is \emph{not} followed by \code{.} or \code{_}.
#'   }
#'   Lines that do not satisfy these requirements (e.g. do not start with #s,
#'   do not contain the right number of spaces after the #, indent before any #
#'   ect.) are not considered by \code{sum_str}.
#'
#' @examples
#' # the following separators are examples of valid
#' # separators and associated comments
#'
#' #   __________________________________________________
#' #   this is a level 1 comment
#' ##  . . . . . . . . . . . . . . . . . . . . . . . . .
#' ##  note that the comment or the separator character (_, .)
#' ##  always starts at indention 4.
#'
#' \dontrun{
#' # Open a new .R file in RStudio, insert some code breaks
#' # using the Add-in of this package, save the file and run:
#' sum_str() # get a summary of the source editor.
#' }
#' @importFrom rstudioapi getSourceEditorContext
#' @export
#'
#   ____________________________________________________________________________
#   user-function
sum_str <- function(dir_in = NULL,
                    dir_out = "",
                    file_in = getSourceEditorContext()$path,
                    file_in_extension = ".R",
                    file_out = NULL,
                    file_out_extension = "",
                    width = NULL,
                    line_nr = TRUE,
                    granularity = 3,
                    lowest_sep = TRUE,
                    title = TRUE,
                    header = TRUE,
                    ...) {

##  ............................................................................
##  prepare input to call helper repeated times.
  # in the case there are multiple files
  if (is.null(file_in)) {
    all_files <- as.list(list.files(path = dir_in,
                            pattern = paste0(file_in_extension, "$"),
                            full.names = FALSE,
                            ...)
    )

  # in the case there is just one file
  } else {
    all_files <- as.list(file_in)
  }

##  ............................................................................
##  call helper
  lapply(all_files, function(g) {
    # pass all arguments as is except the file_in
    sum_str_helper(dir_in = dir_in,
                   dir_out = dir_out,
                   file_in = g,
                   file_out = file_out,
                   file_out_extension = file_out_extension,
                   width = width,
                   line_nr = line_nr,
                   granularity = granularity,
                   lowest_sep = lowest_sep,
                   title = title,
                   header = header)
  })

  # if output is not printed in the console, print a short summary.
  if (dir_out != "") {
    cat("The following files were summarized",
            as.character(all_files), sep = "\n")
  }
}

#   ____________________________________________________________________________
#   helper function

sum_str_helper <- function(dir_in,
                           dir_out,
                           file_in,
                           file_out,
                           file_out_extension,
                           width,
                           line_nr,
                           granularity,
                           lowest_sep,
                           title,
                           header) {
##  ............................................................................
##  argument interaction

### .. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
### get the file_out together
if (is.null(file_out)) {
  file_out <- paste0("code_summary-",
                     gsub("^(.*)\\..*$", "\\1", file_in, perl = TRUE),
                     file_out_extension)
}



### .. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
### paths
  # path_in
  ## note that file_in is never null when called from sum_str()

  # if dir is not null, the path is composed of dir and file
  if (!is.null(dir_in)) {
    path_in <- paste(dir_in, file_in, sep = "/")
  # otherwise it is simply the file_in
  } else {
    path_in <- file_in
  }

  # path_out
  ## path_out is "" if dir_out is ""
  if (is.null(dir_out) || dir_out == "") {
    path_out <- ""
  # otherwise it is composed of dir_out and file_out, if file_out
  # has a not empty value
  } else {
    path_out <- paste(dir_out, file_out, sep = "/")
  }



##  ............................................................................
## function definitions
  # find maximal or minimal level of granularity used.
  find_gran <- function(direction = "up") {
    if (direction == "up") {
      l <- 1 # initialize
    } else if (direction == "down") {
      l <- 3
    }

    helper_find_gran <- function(direction) {
      if (direction == "up") {
        m <- 1
      } else if (direction == "down") {
        m <- -1
      }
      pattern <- paste0("^", paste0(rep("#", l), sep = "", collapse = ""), "\\s+")
      if (any(grepl(pattern, lines, perl = TRUE))) {
        l

      } else {
        l <<- l + m * 1
        helper_find_gran(direction = direction)
      }
    }

    helper_find_gran(direction)
  }

##  ............................................................................
##  get pattern

  lines <- readLines(con = path_in)
  sub_pattern <- "^#   |##  |### "
  pos <- grep(sub_pattern, lines, perl = FALSE) # extract candiates
  pattern <-lines[pos]

##  ............................................................................
##  modify pattern according to arguments

### .. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
### getting the granularity right

  # remove the l lowest pattern separator depending on granularity if
  # lowest_sep is TRUE
  if (lowest_sep == FALSE) {
   sub_pattern <- paste0("^#{", min(granularity, find_gran("down")), ",", 4,
                          "}\\s+[_|\\.].*$")
   remove <- grep(sub_pattern, lines[pos], perl = TRUE)
   pattern <- pattern[-remove]
   pos <- pos[-remove]
  }

  # removing the l lowest separator comments and breaks depending on granularity
  get_gran_pattern <- function(level = 3) {
    paste("^", "#", "{", 1, ",", level, "}",
          "\\s{", 1, ",", level, "}", sep = "", collapse = "")
  }

  update_pos_pattern <- function(level) {
    keep <- grep(get_gran_pattern(level = level), lines[pos], perl = TRUE)
    pattern <<- pattern[keep]
    pos <<- pos[keep]

  }

  update_pos_pattern(granularity)

##  ............................................................................
##  width adjust line_nr, title, output path, header
  # only continue if there is a valid pattern
  if (identical(pattern, character(0))) {
    return(message("No line matching the required pattern"))
  }

  # adjust length of pattern.
  if (is.null(width)) {
  # first calculate width. It is the length of the maximal comment string
  ## get the comment strings
    pattern_comments <- grep("^(#   |##  |### )[^._)].*$", pattern, value = TRUE)
    width <- max(nchar(pattern_comments))
  }

  pattern <- substring(pattern, 1, width)


  if (line_nr == TRUE) {
    pattern <- paste(pos, pattern, sep = "\t")
  }

  if (header == TRUE) {
    pattern <- append(c("line  level section"), pattern)
  }
  if (title == TRUE) {
    pattern <- append(paste0("Summarized structure of ", file_in, "\n"), pattern)
  }



##  ............................................................................
##  output the pattern
  cat(pattern, file = path_out, sep = "\n")
}

 # relace ^\s+(#+) with \1 in Rstudio to move all breaks to the left.
 # extensions
 # - multiple files in a directrory
 # - output to file


