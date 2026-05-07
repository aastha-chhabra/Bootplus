#' @title Auto-Generate Bootstrap Summary Report
#'
#' @description
#' Produce a comprehensive console report that combines interpretation,
#' CI comparison, and diagnostic checks for a \code{boot} object. This is a
#' one-stop function that calls \code{\link{boot_interpret}} and
#' \code{\link{boot_compare_ci}} internally.
#'
#' @param boot_obj An object of class \code{boot}.
#' @param index Integer. Statistic index. Default \code{1}.
#' @param ci_level Numeric. Confidence level. Default \code{0.95}.
#' @param ci_methods Character vector of CI methods. Default
#'   \code{c("norm", "basic", "perc", "bca")}.
#' @param digits Integer. Rounding digits. Default \code{4}.
#'
#' @return Invisibly returns a list with components \code{interpretation}
#'   (from \code{boot_interpret}) and \code{ci_comparison} (from
#'   \code{boot_compare_ci}).
#'
#' @examples
#' \dontrun{
#' library(boot)
#' b <- boot(mtcars$mpg, function(d, i) mean(d[i]), R = 2000)
#' boot_report(b)
#' }
#'
#' @export
boot_report <- function(boot_obj,
                        index      = 1,
                        ci_level   = 0.95,
                        ci_methods = c("norm", "basic", "perc", "bca"),
                        digits     = 4) {

  if (!inherits(boot_obj, "boot")) {
    stop("`boot_obj` must be an object of class 'boot'.", call. = FALSE)
  }

  cat("==============================================\n")
  cat("         bootplus  —  Summary Report\n")
  cat("==============================================\n\n")

  # ---- Interpretation -------------------------------------------------------
  interp <- boot_interpret(
    boot_obj, index = index, ci_level = ci_level,
    digits = digits, verbose = TRUE
  )

  # ---- CI Comparison --------------------------------------------------------
  cat("\n\n--- Confidence Interval Comparison ---\n\n")
  ci_df <- tryCatch(
    boot_compare_ci(
      boot_obj, index = index, ci_level = ci_level, methods = ci_methods
    ),
    error = function(e) {
      cat("  Could not compute all CI methods: ", conditionMessage(e), "\n")
      NULL
    }
  )

  if (!is.null(ci_df)) {
    # Pretty-print table
    col_w <- max(nchar(ci_df$method)) + 2
    cat(
      formatC("Method", width = col_w, flag = "-"),
      formatC("Lower", width = 12, flag = "-"),
      formatC("Upper", width = 12, flag = "-"),
      formatC("Width", width = 12, flag = "-"),
      "\n"
    )
    cat(strrep("-", col_w + 36), "\n")
    for (r in seq_len(nrow(ci_df))) {
      cat(
        formatC(ci_df$method[r], width = col_w, flag = "-"),
        formatC(ci_df$lower[r],  width = 12, format = "f", digits = digits),
        formatC(ci_df$upper[r],  width = 12, format = "f", digits = digits),
        formatC(ci_df$width[r],  width = 12, format = "f", digits = digits),
        "\n"
      )
    }
  }

  # ---- Diagnostics ----------------------------------------------------------
  theta <- boot_obj$t[, index]
  cat("\n--- Diagnostics ---\n")
  cat("  Skewness (approx) :",
      round(.skewness(theta), digits), "\n")
  cat("  Kurtosis (excess) :",
      round(.kurtosis(theta) - 3, digits), "\n")
  n_na <- sum(is.na(theta))
  if (n_na > 0) {
    cat("  WARNING:", n_na, "NA replicates detected.\n")
  } else {
    cat("  No NA replicates.\n")
  }

  cat("\n==============================================\n")

  invisible(list(
    interpretation = interp,
    ci_comparison  = ci_df
  ))
}


# ---- internal helpers -------------------------------------------------------

#' @keywords internal
.skewness <- function(x) {
  x <- x[!is.na(x)]
  n <- length(x)
  m <- mean(x)
  s <- stats::sd(x)
  (sum((x - m)^3) / n) / (s^3)
}

#' @keywords internal
.kurtosis <- function(x) {
  x <- x[!is.na(x)]
  n <- length(x)
  m <- mean(x)
  s <- stats::sd(x)
  (sum((x - m)^4) / n) / (s^4)
}
