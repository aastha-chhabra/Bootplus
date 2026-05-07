#' @title Interpret Bootstrap Results in Plain Language
#'
#' @description
#' Produce a structured, human-readable interpretation of a \code{boot} object.
#' The output includes the original statistic, bootstrap mean, bias, standard
#' error, coefficient of variation, and a narrative conclusion suitable for
#' reports and teaching contexts.
#'
#' @param boot_obj An object of class \code{boot}.
#' @param index Integer. Which element of the statistic vector to interpret.
#'   Default \code{1}.
#' @param ci_level Numeric. Confidence level for the percentile interval.
#'   Default \code{0.95}.
#' @param digits Integer. Number of decimal places for rounding. Default
#'   \code{4}.
#' @param verbose Logical. If \code{TRUE} (default), print the interpretation
#'   to the console.
#'
#' @return Invisibly returns a list with components:
#'   \describe{
#'     \item{original_statistic}{The statistic computed on the original data.}
#'     \item{bootstrap_mean}{Mean of the bootstrap replicates.}
#'     \item{bootstrap_median}{Median of the bootstrap replicates.}
#'     \item{bootstrap_bias}{Bootstrap mean minus original statistic.}
#'     \item{bias_ratio}{Absolute bias divided by bootstrap SE.}
#'     \item{bootstrap_se}{Standard deviation of the bootstrap replicates.}
#'     \item{cv_percent}{Coefficient of variation as a percentage.}
#'     \item{ci_lower}{Lower bound of the percentile CI.}
#'     \item{ci_upper}{Upper bound of the percentile CI.}
#'     \item{R}{Number of bootstrap replicates.}
#'     \item{conclusion}{Narrative text summary.}
#'   }
#'
#' @details
#' ## Interpretation Guide
#'
#' | Output | Meaning |
#' |---|---|
#' | Original statistic | Statistic from the original sample |
#' | Bootstrap mean | Average across bootstrap replicates |
#' | Bias | Difference between bootstrap mean and original statistic |
#' | Bias ratio | If > 0.25 the bias may be non-negligible |
#' | SE | Estimated sampling uncertainty |
#' | CV | Relative precision as a percentage |
#' | CI | Range of plausible values at the chosen confidence level |
#'
#' @examples
#' \dontrun{
#' library(boot)
#' set.seed(1)
#' b <- boot(mtcars$mpg, function(d, i) mean(d[i]), R = 2000)
#' boot_interpret(b)
#' }
#'
#' @export
boot_interpret <- function(boot_obj,
                           index    = 1,
                           ci_level = 0.95,
                           digits   = 4,
                           verbose  = TRUE) {

  # ---- validation -----------------------------------------------------------
 if (!inherits(boot_obj, "boot")) {
    stop("`boot_obj` must be an object of class 'boot'.", call. = FALSE)
  }

  theta   <- boot_obj$t[, index]
  theta0  <- boot_obj$t0[index]
  b_mean  <- mean(theta)
  b_med   <- stats::median(theta)
  bias    <- b_mean - theta0
  se      <- stats::sd(theta)
  cv      <- (se / abs(b_mean)) * 100
  bias_r  <- abs(bias) / se

  alpha   <- (1 - ci_level) / 2
  ci      <- stats::quantile(theta, probs = c(alpha, 1 - alpha))

  # ---- bias assessment ------------------------------------------------------
  bias_assessment <- if (bias_r < 0.02) {
    "negligible"
  } else if (bias_r < 0.1) {
    "small"
  } else if (bias_r < 0.25) {
    "moderate"
  } else {
    "substantial — consider bias-corrected intervals (BCa)"
  }

  # ---- narrative ------------------------------------------------------------
  conclusion <- paste0(
    "Bootstrap Analysis (R = ", boot_obj$R, ")\n",
    "-------------------------------------------\n",
    "Original statistic : ", round(theta0, digits), "\n",
    "Bootstrap mean     : ", round(b_mean, digits), "\n",
    "Bootstrap median   : ", round(b_med, digits), "\n",
    "Bias               : ", round(bias, digits),
    "  (", bias_assessment, ")\n",
    "Std. Error         : ", round(se, digits), "\n",
    "CV                 : ", round(cv, 2), "%\n",
    round(ci_level * 100), "% Percentile CI : [",
    round(ci[1], digits), ", ", round(ci[2], digits), "]\n\n",
    "Interpretation:\n",
    "  The original sample statistic is ", round(theta0, digits),
    ". Across ", boot_obj$R, " bootstrap replicates the mean estimate is ",
    round(b_mean, digits), ", giving a bias of ", round(bias, digits),
    " (ratio |bias|/SE = ", round(bias_r, 3), ", deemed ", bias_assessment, "). ",
    "The bootstrap standard error of ", round(se, digits),
    " quantifies sampling uncertainty. ",
    "A ", round(ci_level * 100), "% percentile confidence interval is [",
    round(ci[1], digits), ", ", round(ci[2], digits), "]."
  )

  if (verbose) cat(conclusion, "\n")

  invisible(list(
    original_statistic = theta0,
    bootstrap_mean     = b_mean,
    bootstrap_median   = b_med,
    bootstrap_bias     = bias,
    bias_ratio         = bias_r,
    bootstrap_se       = se,
    cv_percent         = cv,
    ci_lower           = unname(ci[1]),
    ci_upper           = unname(ci[2]),
    R                  = boot_obj$R,
    conclusion         = conclusion
  ))
}
