# oncoscanR
author: Yann Christinat

date: April 26, 2023

version: 1.7.0 (bioconductor-devel)

## Description
OncoscanR is an R package to handle Copy Number Variation analyses originating 
from the Applied Biosystems™️ OncoScan™️ CNV Assay. It allows computation of 
different homologous recombination deficiency (HRD) scores[Telli 2016], including the nLST 
score used by the Geneva HRD test[Christinat 2023], and the tandem 
duplication plus score (TDplus) to identify CDK12-mutated tumors [Popova 2016]. 

The package also allows for identification of arm-level alterations (e.g. gain 
of chromosome arm 1p).

**IMPORTANT**: The package expects as input the text exported file from ChAS 
(Chromosome Analysis Suite; the Applied Biosystems™️ software to identify CNV 
segments from the OncoScan™️ CNV Assay). The package assumes that all segments 
given in the file are correct and true. The ChAS text file has to contain the 
columns `Type`, `CN State` and `Full Location` (to setup in ChAS). Any text file 
that complies with this structure should work equally well.

Starting with version 1.2.0 (github), ASCAT output files can also be used as input.

Note that the Oncoscan does not cover the p arms of chromosome 13, 14, 15 and 22. 
The coverage on the p arm of chromosome 21 is only partial and is not included 
in this package.


**Disclaimer**: The use of OncoScan™️ platform in this research
does not imply an endorsement or recommendation of Thermo
Fisher Scientific Inc. and its subsidiaries for the utilization of
any specific algorithm or methodology with the OncoScan™️
platform for HRD analysis. Thermo Fisher Scientific Inc. and
its subsidiaries make no claims regarding the suitability,
performance or efficacy of any algorithms or methodologies
used in conjunction with the OncoScan™️ platform for HRD
analysis. Furthermore, Thermo Fisher Scientific Inc. and its
subsidiaries take no responsibility, and anyone using any
specific algorithms or methodologies in conjunction with the
OncoScan™️ platform for HRD analysis is solely responsible
for researching, identifying, and obtaining any necessary third-party
rights and ensuring that such use is in compliance with
applicable laws and regulations.

### Computation of arm-level alteration
An arm is declared globally altered if more than 90% of its bases are altered with a similar CNV type (amplifications
[5 copies or more], gains [1-2 extra copies], losses or copy-neutral losses of heterozygozity [LOH])[Christinat 2021]. For
instance, "gain of 3p" indicates that there is more than 90% of arm with 3 copies but less than 90% with 5 (otherwise
it would be an amplification). Prior to computation, segments of same copy number and at a distance <300Kbp (Oncoscan
resolution genome-wide) are merged. The remaining segments are filtered to a minimum size of 300Kbp.


### HRD scores
#### Score nLST
HRD score developed at HUG and based on the LST score by Popova et al. but normalized by an estimation of the number of
whole-genome doubling events.Of note, copy-neutral LOH segments are removed before computation.

`nLST = LST - 7*W/2` where `W` is the number of whole-genome doubling events.

The score is positive if there are at least 15 nLST.

The nLST score has been validated on 469 high grade ovarian cancer samples from
the PAOLA-1 clinical trial and is used in routine at the Geneva University Hospitals 
for prediction of PARP inhibitors response.

*How to cite*

Yann Christinat et al., Normalized LST Is an Efficient Biomarker for Homologous Recombination Deficiency and Olaparib Response in Ovarian Carcinoma. *JCO Precis Oncol* 7, e2200555(2023).
DOI:10.1200/PO.22.00555


#### Score LST
Procedure based on the paper from Popova et al, Can. Res. 2012 (PMID: 22933060). First segments
smaller than 3Mb are removed, then segments are smoothed with respect to copy number at a distance of 3Mb.
The number of LSTs is the number of breakpoints (breakpoints closer than 3Mb are merged) that have a segment
larger or equal to 10Mb on each side. This score was linked to BRCA1/2-deficient tumors.

#### Score LOH
Procedure based on the paper from Abkevich et al., Br J Cancer 2012 (PMID: 23047548). 
Number of LOH segments larger than 15Mb but excluding segments on chromosomes with a global LOH alteration. 
This score was linked to BRCA1/2-deficient tumors.

#### Score gLOH
The percentage genomic LOH score is computed as described in the FoundationFocus CDx BRCA
LOH assay; i.e. the percentage of bases covered by the Oncoscan that display a loss of heterozygosity
independently of the number of copies, excluding chromosomal arms that have a global LOH
(>=90% arm length). To compute with the armlevel_alt function on LOH segments only). This
score was linked to BRCA1/2-deficient tumors.

### Score TDplus
Procedure based on the paper from Popova et al., Cancer Res 2016 (PMID: 26787835). The TDplus
score is defined as the number of regions larger than 1Mb but smaller or equal to 10Mb with a gain of one
or two copies. This score was linked to CDK12-deficient tumors. 
They also identified as second category of tandem duplication whose size is smaller or equal than 1Mb and around 
300Kb but could not link it to a phenotype. Note that due to its resolution the Oncoscan assay will most likely miss 
this second category. Nonetheless it is reported by the function but not by the standard workflow.

## Installation
The package requires the prior installation of the packages `GenomicRanges` (bioconductor), `magrittr`, `jsonlite` and
`readr`.

```{r}
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("GenomicRanges")

install.packages(c("magrittr", "jsonlite", "readr"))
```

There are three options to install the oncoscanR package: 

1. Install via bioconductor (nightly build):
```{r}
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

# The following initializes usage of Bioc devel
BiocManager::install(version='devel')

BiocManager::install("oncoscanR")
```
2. Install from tarball. Download the `oncoscanR_1.2.0.tar.gz` file (stable version). Then in R, set the working directory to where the
compressed package is and run:
```{r}
install.packages('oncoscanR_1.2.0.tar.gz', repos=NULL, type='source')
```
3. Install from GitHub. In R, install the devtools package (`install.packages('devtools')`), then run:
```{r}
library(devtools)
install_github('yannchristinat/oncoscanR')
```


## Testing the installation
Open R and type the following commands:
```{r}
library(oncoscanR)
segs.filename <- system.file("extdata", "chas_example.txt", package = "oncoscanR")
workflow_oncoscan.chas(segs.filename)
```

If everything is setup fine, it should return a list with no arm-level alterations and a negative HRD score (nLST=1).


## Usage
The main workflow can be launched either in R via the `workflow_oncoscan.chas(chas.fn)` function or via the
script `bin/run_oncoscan_workflow.R`:

Usage: `Rscript path_to_oncoscanR_package/scripts/run_oncoscan-workflow.R CHAS_FILE`
- `CHAS_FILE`: Path to the text export file from ChAS or a compatible text file.

The script will output a JSON string into the terminal with all the computed information. :

```{json}
{
  "armlevel": {
    "AMP": [],
    "LOSS": ["17p", "2q", "4p"],
    "LOH": ["14q", "5q", "8p", "8q"],
    "GAIN": [19p", "19q", "1q", "20p", "20q", "3q", "5p", "6p", "9p", "9q", "Xp", "Xq"]
  },
  "scores": {
    "HRD": "Negative, nLST=12",
    "TDplus": 22,
    "avgCN": "2.43"
  }
  "file": "path/to/original_ChAS_file.txt"
}
```

Please read the vignette for more details and the manual for a description of all available R functions.

## References
- Abkevich et al., Patterns of genomic loss of heterozygosity predict homologous recombination repair defects in epithelial ovarian cancer, Br J Cancer, 107(10), 2012.
- Carter et al., Absolute quantification of somatic DNA alterations in human cancer, Nat Biotech, volume 30(5), 2012.
- Christinat et al., Automated Detection of Arm-Level Alterations for Individual Cancer Patients in the Clinical Setting, J Mol Diagn, 23(17):1722-1731, 2021.
- Christinat et al., Normalized LST Is an Efficient Biomarker for Homologous Recombination Deficiency and Olaparib Response in Ovarian Carcinoma, JCO Precision Oncology, volume 7, 2023.
- Popova et al., Ploidy and large-scale genomic instability consistently identify basal-like breast carcinomas with BRCA1/2 inactivation, Cancer Res volume 72(21), 2012.
- Popova et al., Ovarian Cancers Harboring Inactivating Mutations in CDK12 Display a Distinct Genomic Instability Pattern Characterized by Large Tandem Duplications, Cancer Res volume 76(7), 2016.
- Telli et al., Homologous Recombination Deficiency (HRD) Score Predicts Response to Platinum-Containing Neoadjuvant Chemotherapy in Patients with Triple-Negative Breast Cancer, Clin Cancer Res volume 22(15), 2016.

