# workflow_oncoscan.R Functions to run the complete workflow from input files
# to scores and arm-level alterations.  Author: Yann Christinat Date:
# 23.06.2020

#' Run the standard workflow for Oncoscan ChAS files.
#'
#' @details Identifies the globally altered arms (\>=90\% of arm altered),
#' computes the HRD and TD+ scores. The amplification is defined as a CN subtype
#'  \code{cntype.weakamp} or \code{cntype.strongamp}. An arm is gained if of CN
#'  type \code{cntype.gain} unless the arm is amplified.
#'
#' @param chas.fn Path to the text-export ChAS file
#'
#' @return A list of lists with the following elements:
#' \code{armlevel = list(AMP= list of arms, GAIN= list of arms, LOSS= list of
#' arms, LOH= list of arms),
#' scores = list(LST= number, LOH= number, TDplus= number, TD= number),
#' file = path of the ChAS file as given by the parameter)}
#'
#' @export
#'
#' @importFrom magrittr %>%
#'
#' @examples
#' segs.filename <- system.file('extdata', 'chas_example.txt',
#' package = 'oncoscanR')
#' workflow_oncoscan.chas(segs.filename)
workflow_oncoscan.chas <- function(chas.fn) {
    # Load the ChAS file and assign subtypes.
    segments <- load_chas(chas.fn, oncoscanR::oncoscan_na33.cov)

    # Clean the segments: resctricted to Oncoscan coverage, LOH not overlapping
    # with copy loss segments, smooth&merge segments within 300kb and prune
    # segments smaller than 300kb.
    segs.clean <- trim_to_coverage(segments, oncoscanR::oncoscan_na33.cov) %>%
        adjust_loh() %>%
        merge_segments() %>%
        prune_by_size()

    # Split segments by type: Loss, LOH, gain or amplification and get the
    # arm-level alterations.  Note that the segments with copy gains include
    # all amplified segments.
    armlevel.loss <- get_loss_segments(segs.clean) %>%
        armlevel_alt(kit.coverage = oncoscanR::oncoscan_na33.cov)
    armlevel.loh <- get_loh_segments(segs.clean) %>%
        armlevel_alt(kit.coverage = oncoscanR::oncoscan_na33.cov)
    armlevel.gain <- get_gain_segments(segs.clean) %>%
        armlevel_alt(kit.coverage = oncoscanR::oncoscan_na33.cov)
    armlevel.amp <- get_amp_segments(segs.clean) %>%
        armlevel_alt(kit.coverage = oncoscanR::oncoscan_na33.cov)

    # Remove amplified segments from armlevel.gain
    armlevel.gain <-
        armlevel.gain[!(names(armlevel.gain) %in% names(armlevel.amp))]

    # Get the number of nLST and TDplus
    wgd <- score_estwgd(segs.clean, oncoscanR::oncoscan_na33.cov)
    hrd <- score_nlst(segs.clean, wgd["WGD"], oncoscanR::oncoscan_na33.cov)

    n.td <- score_td(segs.clean)

    mbalt <- score_mbalt(segs.clean, oncoscanR::oncoscan_na33.cov, loh.rm=TRUE)

    hrd.label <- hrd["HRD"]
    if (mbalt['sample'] / mbalt['kit'] < 0.01)
        hrd.label <- paste(hrd["HRD"], "(no tumor?)")

    # Get the alterations into a single list and print it in a JSON format.
    armlevel_alt.list <-
        list(
            AMP = sort(names(armlevel.amp)),
            LOSS = sort(names(armlevel.loss)),
            LOH = sort(names(armlevel.loh)),
            GAIN = sort(names(armlevel.gain))
        )
    scores.list <-
        list(
            HRD = paste0(hrd.label, ", nLST=", hrd["nLST"]),
            TDplus = n.td$TDplus,
            avgCN = substr(as.character(wgd["avgCN"]), 1, 4)
        )

    return(list(
        armlevel = armlevel_alt.list,
        scores = scores.list,
        file = basename(chas.fn)
    ))
}

#' Run the standard workflow for ASCAT files (from oncoscan data).
#'
#' @details Identifies the globally altered arms (\>=90\% of arm altered),
#' computes the HRD and TD+ scores. The amplification is defined as a CN>=5. 
#' An arm is gained if of CN type \code{cntype.gain} unless the arm is 
#' amplified.
#'
#' @param ascat.fn Path to the text-export ASCAT file
#'
#' @return A list of lists with the following elements:
#' \code{armlevel = list(AMP= list of arms, GAIN= list of arms, LOSS= list of
#' arms, LOH= list of arms),
#' scores = list(LST= number, LOH= number, TDplus= number, TD= number),
#' file = path of the ChAS file as given by the parameter)}
#'
#' @export
#'
#' @importFrom magrittr %>%
#'
#' @examples
#' segs.filename <- system.file('extdata', 'ascat_example.txt',
#' package = 'oncoscanR')
#' workflow_oncoscan.ascat(segs.filename)
workflow_oncoscan.ascat <- function(ascat.fn) {
    # Load the ChAS file and assign subtypes.
    segments <- load_ascat(ascat.fn, oncoscanR::oncoscan_na33.cov)
    
    # Clean the segments: resctricted to Oncoscan coverage, LOH not overlapping
    # with copy loss segments, smooth&merge segments within 300kb and prune
    # segments smaller than 300kb.
    segs.clean <- trim_to_coverage(segments, oncoscanR::oncoscan_na33.cov) %>%
        adjust_loh() %>%
        merge_segments() %>%
        prune_by_size()
    
    # Split segments by type: Loss, LOH, gain or amplification and get the
    # arm-level alterations.  Note that the segments with copy gains include
    # all amplified segments.
    armlevel.loss <- get_loss_segments(segs.clean) %>%
        armlevel_alt(kit.coverage = oncoscanR::oncoscan_na33.cov)
    armlevel.loh <- get_loh_segments(segs.clean) %>%
        armlevel_alt(kit.coverage = oncoscanR::oncoscan_na33.cov)
    armlevel.gain <- get_gain_segments(segs.clean) %>%
        armlevel_alt(kit.coverage = oncoscanR::oncoscan_na33.cov)
    armlevel.amp <- get_amp_segments(segs.clean) %>%
        armlevel_alt(kit.coverage = oncoscanR::oncoscan_na33.cov)
    
    # Remove amplified segments from armlevel.gain
    armlevel.gain <-
        armlevel.gain[!(names(armlevel.gain) %in% names(armlevel.amp))]
    
    # Get the number of nLST and TDplus
    wgd <- score_estwgd(segs.clean, oncoscanR::oncoscan_na33.cov)
    hrd <- score_nlst(segs.clean, wgd["WGD"], oncoscanR::oncoscan_na33.cov)
    
    n.td <- score_td(segs.clean)
    
    mbalt <- score_mbalt(segs.clean, oncoscanR::oncoscan_na33.cov, loh.rm=TRUE)
    
    hrd.label <- hrd["HRD"]
    if (mbalt['sample'] / mbalt['kit'] < 0.01)
        hrd.label <- paste(hrd["HRD"], "(no tumor?)")
    
    # Get the alterations into a single list and print it in a JSON format.
    armlevel_alt.list <-
        list(
            AMP = sort(names(armlevel.amp)),
            LOSS = sort(names(armlevel.loss)),
            LOH = sort(names(armlevel.loh)),
            GAIN = sort(names(armlevel.gain))
        )
    scores.list <-
        list(
            HRD = paste0(hrd.label, ", nLST=", hrd["nLST"]),
            TDplus = n.td$TDplus,
            avgCN = substr(as.character(wgd["avgCN"]), 1, 4)
        )
    
    return(list(
        armlevel = armlevel_alt.list,
        scores = scores.list,
        file = basename(ascat.fn)
    ))
}

