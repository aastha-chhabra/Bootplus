#' bootplus: Modern Extensions for the boot Package
#'
#' @description
#' \pkg{bootplus} is an extension layer for the \pkg{boot} package that adds
#' three modern capabilities:
#'
#' \enumerate{
#'   \item \strong{Visualization} — Publication-quality ggplot2 plots of
#'     bootstrap distributions, confidence intervals, and CI method
#'     comparisons via \code{\link{boot_viz}}, \code{\link{boot_density}},
#'     \code{\link{boot_ci_plot}}, and \code{\link{boot_dist_plot}}.
#'   \item \strong{Interpretation} — Human-readable summaries of bias,
#'     standard error, and confidence intervals via
#'     \code{\link{boot_interpret}} and \code{\link{boot_report}}.
#'   \item \strong{Bayesian Bootstrap} — Rubin's (1981) Dirichlet-weighted
#'     bootstrap with posterior summaries and credible interval plots via
#'     \code{\link{boot_bayes}} and \code{\link{boot_bayes_plot}}.
#' }
#'
#' @docType package
#' @name bootplus-package
#' @aliases bootplus
#'
#' @import ggplot2
#' @importFrom boot boot boot.ci
#' @importFrom stats density median quantile rgamma sd
#' @importFrom grDevices colorRampPalette
"_PACKAGE"
