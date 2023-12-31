% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/input.R
\name{merge_segments}
\alias{merge_segments}
\title{Merge segments with respect to the kit resolution and the copy number.}
\usage{
merge_segments(segments, kit.resolution = 300)
}
\arguments{
\item{segments}{A \code{GRanges} object containing the segments, their copy
number and copy number types.}

\item{kit.resolution}{Number >0 indicating the minimum segment size
detectable by the technique (in kilobases).
Defaults to the Oncoscan assay resolution outside of cancer genes: 300Kb.}
}
\value{
A \code{GRanges} object containing the cleaned segments, their copy
number and copy number types.
}
\description{
Merge segments with respect to the kit resolution and the copy number.
}
\details{
If two segments are at a distance smaller than the resolution, then
the segments are merged if the
share the same \code{cn} value. Note that the function does not look at the
copy number type or subtype but
only at the actual copy number to decide whether segments can be merged.
}
\examples{
segs.merged <- merge_segments(segs.chas_example)
segs.merged_50k <- merge_segments(segs.chas_example, 50)
}
