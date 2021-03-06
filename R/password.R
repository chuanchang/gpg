#' Password Entry
#'
#' Function to prompt the user for a password to read a protected private key.
#'
#' If available, this function calls the GnuPG `pinentry` program. However this
#' only works in a terminal. Therefore the IDE can provide a custom password entry
#' widget by setting the \code{askpass} option. If no such option is specified
#' we default to \code{\link{readline}}.
#'
#' @export
#' @param prompt the string printed when prompting the user for input.
pinentry <- function(prompt = "Enter your GPG passphrase:"){
  if(is_unix() && has_pinentry()){
    tryCatch({
      return(pinentry_exec(prompt))
    }, error = identity)
  }
  if(is.function(FUN <- getOption("askpass"))){
    return(FUN(prompt))
  }
  if(interactive()){
    return(readline(prompt))
  }
  if(is_windows()){
    stop("Passphrase required but no suitable pinentry program found. Try installing GPG4Win.")
  } else {
    stop("Passphrase required but no suitable pinentry program found. Need to configure gpg-agent.")
  }
}

is_cmd_build <- function(){
  grepl("^Rbuild", basename(getwd()))
}

is_unix <- function(){
  identical(.Platform$OS.type, "unix")
}

is_tty <- function(){
  return(system2("tty", "<&2") == 0)
}

has_pinentry <- function(){
  return(system2("pinentry", "--version", stdout = FALSE, stderr = FALSE) == 0)
}

# in POSIX, "/dev/tty" means current CTTY
pinentry_exec <- function(str){
  input <- c(paste("SETPROMPT", str), "GETPIN")
  res <- system2("pinentry", paste("-T", '/dev/tty'), input = input, stdout = TRUE)
  errors <- res[grepl("^ERR ", res)]
  if(length(errors))
    stop(sub("^ERR", "Pinentry error", errors[1]), call. = FALSE)
  pwline <- res[grepl("^D ", res)]
  if(!length(pwline))
    return(NULL) #no password entered
  sub("D ", "", pwline, fixed = TRUE)
}
