% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hub.R
\name{create.signatures}
\alias{create.signatures}
\title{Computes HMAC signatures}
\usage{
create.signatures(track.bucket, bw.df)
}
\arguments{
\item{track.bucket}{Amazon S3 bucket name that stores the .bw files}

\item{bigwigs}{Bigwig file names which exactly match those in 'track.bucket'}
}
\description{
This function takes in a vector of bigwig file names and Amazon S3 credentials to generate hmac signatures to access .bw files.
}
\keyword{internal}
