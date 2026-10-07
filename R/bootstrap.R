# Make every analysis script portable: it can be sourced or run from any folder.
script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file) || !nzchar(script_file)) {
  file_argument <- commandArgs(trailingOnly = FALSE)
  file_argument <- sub("^--file=", "", file_argument[grepl("^--file=", file_argument)])
  script_file <- if (length(file_argument) > 0) file_argument[1] else NULL
}
if (is.null(script_file) || !nzchar(script_file)) {
  stop("Unable to determine the script location. Run with Rscript or source a script by path.")
}

project_root <- normalizePath(file.path(dirname(script_file), ".."))
setwd(project_root)
source(file.path(project_root, "R", "config.R"))
source(file.path(project_root, "R", "helpers.R"))
