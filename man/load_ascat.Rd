% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/input.R
\name{load_ascat}
\alias{load_ascat}
\title{Load am ASCAT text export file.}
\usage{
load_ascat(filename, kit.coverage)
}
\arguments{
\item{filename}{Path to the ASCAT file.}

\item{kit.coverage}{A \code{GRanges} object containing the regions covered on
each chromosome arm by the kit.}
}
\value{
A \code{GRanges} object containing the segments, their copy number
(field \code{cn}), their copy
number types (field \code{cntype}). \code{cntype} contains either 'Gain',
'Loss' or 'LOH'.
If the file contains twice the same segment or does not respect the format
specifications, then an error is raised. 
NB. If the chromosome name is in the format '1' and not 'chr1' and will
be transformed if needed.
}
\description{
Load am ASCAT text export file.
}
\details{
The ASCAT file is expected to have the following column names:
'chr' (chromosome number), 'startpos' (first position of CNV segment),
'endpos' (last position of CNV segment), 'nMajor' (Number of copies of the 
major allele) and 'nMinor' (Number of copies of the minor allele).

The segments are attributed to each chromosome arm and split if necessary.
}
\examples{
segs.filename <- system.file('extdata', 'ascat_example.txt',
  package = 'oncoscanR')
segs.ascat_example <- load_ascat(segs.filename, oncoscan_na33.cov)
}
