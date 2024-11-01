% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{cntypes}
\alias{cntypes}
\title{Accepted types of CN for the segments
  - 'Gain': 1-2 extra copies
  - 'Weak amplification': 3-7 extra copies
  - 'Strong amplification': 8 or more extra copies
  - 'Heterozygote loss': Loss of one copy out of two
  - 'Homozygote loss': Loss of all copies
  - 'LOH': copy-neutral loss of one parental allele}
\format{
A list of strings containing all CN types
}
\source{
cntypes <- list(LOH='LOH', Gain='Gain', Loss='Loss')
}
\usage{
cntypes
}
\description{
Accepted types of CN for the segments
  - 'Gain': 1-2 extra copies
  - 'Weak amplification': 3-7 extra copies
  - 'Strong amplification': 8 or more extra copies
  - 'Heterozygote loss': Loss of one copy out of two
  - 'Homozygote loss': Loss of all copies
  - 'LOH': copy-neutral loss of one parental allele
}
\keyword{datasets}
