#' Encryption
#'
#' Encrypt or decrypt a message using the public key from the `receiver`.
#' Optionally the message can be signed using the private key of the sender.
#'
#' @export
#' @rdname gpg_encrypt
#' @family gpg
#' @useDynLib gpg R_gpgme_encrypt R_gpgme_signed_encrypt
#' @param data path or raw vector with data to encrypt / decrypt
#' @param receiver key id(s) or fingerprint(s) for recepient(s)
#' @param signer (optional) key id(s) or fingerprint(s) for the sender(s) to sign
#' the message
gpg_encrypt <- function(data, receiver, signer = NULL){
  data <- file_or_raw(data)
  stopifnot(is.character(receiver))
  if(length(signer)){
    stopifnot(is.character(signer))
    .Call(R_gpgme_signed_encrypt, data, receiver, signer)
  } else {
    .Call(R_gpgme_encrypt, data, receiver)
  }
}

#' @export
#' @rdname gpg_encrypt
#' @param verify automatically checks that all signatures (if any) can be verified and
#' raises an error otherwise
#' @useDynLib gpg R_gpgme_decrypt R_gpgme_signed_decrypt
gpg_decrypt <- function(data, verify = TRUE){
  data <- file_or_raw(data)
  if(isTRUE(verify)){
    .Call(R_gpgme_signed_decrypt, data)
  } else {
    .Call(R_gpgme_decrypt, data)
  }
}

file_or_raw <- function(file){
  if(is.raw(file))
    return(file)
  if(is.character(file)){
    stopifnot(file.exists(file))
    return(readBin(file, raw(), file.info(file)$size))
  }
  stop("Argument 'file' must be existing filepath or raw vector")
}
