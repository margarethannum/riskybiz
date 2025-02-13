#' Results from a simulated trial of Placebo vs Drug
#'
#' A dataset containing the baseline characteristics of 200 patients
#' randomized to Placebo or Drug.  Dataset also contains the trial outcome:
#' tumor response to the treatment.
#'
#' @format A data frame with 200 rows--one row per patient
#' \describe{
#'     \item{trt}{Treatment Randomization}
#'     \item{age}{Age, yrs}
#'     \item{marker}{Marker Level, ng/mL}
#'     \item{stage}{T Stage}
#'     \item{grade}{Grade}
#'     \item{response}{Tumor Response}
#'     \item{death}{Patient Died}
#'     \item{ttdeath}{Months to Death/Censor}
#'     \item{death_cr}{Death status (Competing Risks)}
#' }
"trial"
