#' @title Bayesian Bootstrap
#'
#' @description
#' Perform Rubin's (1981) Bayesian bootstrap.
#' Instead of resampling observations with replacement, each replicate draws a
#' set of Dirichlet(1, …, 1) weights and computes the statistic as a weighted
#' function of the original data.
#'
#' @param data A numeric vector (or matrix / data frame for multivariate
#'   statistics).
#' @param statistic A function of the form \code{function(data, weights)} that
#'   returns a scalar.
#' @param R Integer. Number of posterior draws. Default \code{4000}.
#' @param seed Optional integer seed for reproducibility.
#'
#' @return A list of class \code{boot_bayes} with components:
#'   \describe{
#'     \item{posterior_samples}{Numeric vector of length \code{R}.}
#'     \item{posterior_mean}{Mean of the posterior samples.}
#'     \item{posterior_median}{Median of the posterior samples.}
#'     \item{posterior_sd}{Standard deviation of the posterior samples.}
#'     \item{credible_interval}{Named numeric vector with 2.5\% and 97.5\%
#'       quantiles (equal-tailed 95\% interval).}
#'     \item{R}{Number of draws.}
#'     \item{data}{Original data passed in.}
#'     \item{statistic}{The user-supplied function.}
#'   }
#'
#' @details
#' The weighting scheme follows Rubin (1981): generate
#' \eqn{g_i \sim \mathrm{Gamma}(1,1)} for \eqn{i = 1, \ldots, n} and set
#' \eqn{w_i = g_i / \sum g_j}.
#' This is equivalent to drawing \eqn{(w_1, \ldots, w_n) \sim
#' \mathrm{Dirichlet}(1, \ldots, 1)}.
#'
#' @references
#' Rubin, D. B. (1981). The Bayesian bootstrap. \emph{Annals of Statistics},
#' 9(1), 130–134.
#'
#' @examples
#' x <- c(2, 4, 5, 8, 10)
#' weighted_mean <- function(data, weights) sum(data * weights)
#' set.seed(42)
#' bb <- boot_bayes(x, weighted_mean, R = 2000)
#' bb$posterior_mean
#' bb$credible_interval
#'
#' @export
boot_bayes <- function(data, statistic, R = 4000, seed = NULL) {

 # ---- validation -----------------------------------------------------------
  if (!is.function(statistic)) {
    stop("`statistic` must be a function(data, weights).", call. = FALSE)
  }
  if (!is.numeric(R) || length(R) != 1 || R < 1) {
    stop("`R` must be a positive integer.", call. = FALSE)
  }
  R <- as.integer(R)

  if (!is.null(seed)) set.seed(seed)

  n       <- if (is.vector(data)) length(data) else nrow(data)
  results <- numeric(R)

  for (i in seq_len(R)) {
    w <- stats::rgamma(n, shape = 1, rate = 1)
    w <- w / sum(w)
    results[i] <- statistic(data, w)
  }

  out <- list(
    posterior_samples  = results,
    posterior_mean     = mean(results),
    posterior_median   = stats::median(results),
    posterior_sd       = stats::sd(results),
    credible_interval  = stats::quantile(results, probs = c(0.025, 0.975)),
    R                  = R,
    data               = data,
    statistic          = statistic
  )
  class(out) <- "boot_bayes"
  out
}


#' @title Print Method for boot_bayes Objects
#'
#' @param x An object of class \code{boot_bayes}.
#' @param digits Number of significant digits. Default \code{4}.
#' @param ... Further arguments (ignored).
#'
#' @return Invisibly returns \code{x}.
#' @export
print.boot_bayes <- function(x, digits = 4, ...) {
  cat("Bayesian Bootstrap\n")
  cat("------------------\n")
  cat("Draws (R)          :", x$R, "\n")
  cat("Posterior mean     :", round(x$posterior_mean, digits), "\n")
  cat("Posterior median   :", round(x$posterior_median, digits), "\n")
  cat("Posterior SD       :", round(x$posterior_sd, digits), "\n")
  cat("95% Credible Int.  : [",
      round(x$credible_interval[1], digits), ",",
      round(x$credible_interval[2], digits), "]\n")
  invisible(x)
}


#' @title Bayesian Bootstrap Posterior Visualization
#'
#' @description
#' Plot the posterior distribution from a Bayesian bootstrap analysis with
#' credible interval shading and posterior mean annotation.
#'
#' @param bb An object of class \code{boot_bayes} returned by
#'   \code{\link{boot_bayes}}.
#' @param ci_level Numeric. Credible interval level. Default \code{0.95}.
#' @param bins Integer. Histogram bins. Default \code{40}.
#' @param title Character or \code{NULL}.
#'
#' @return A \code{ggplot} object.
#'
#' @examples
#' \dontrun{
#' x <- c(2, 4, 5, 8, 10)
#' bb <- boot_bayes(x, function(d, w) sum(d * w), R = 3000)
#' boot_bayes_plot(bb)
#' }
#'
#' @export
boot_bayes_plot <- function(bb,
                            ci_level = 0.95,
                            bins     = 40,
                            title    = NULL) {

  if (!inherits(bb, "boot_bayes")) {
    stop("`bb` must be an object of class 'boot_bayes'.", call. = FALSE)
  }

  alpha <- (1 - ci_level) / 2
  ci    <- stats::quantile(bb$posterior_samples, probs = c(alpha, 1 - alpha))

  df <- data.frame(value = bb$posterior_samples)

  col_fill    <- "#00B894"
  col_density <- "#00CEC9"
  col_ci      <- "#FDCB6E"
  col_mean    <- "#D63031"

  plot_title <- if (is.null(title)) "Bayesian Bootstrap Posterior" else title
  sub_text   <- paste0(
    "R = ", bb$R,
    "  |  Post. Mean = ", round(bb$posterior_mean, 4),
    "  |  ", round(ci_level * 100), "% CrI: [",
    round(ci[1], 4), ", ", round(ci[2], 4), "]"
  )

  ggplot2::ggplot(df, ggplot2::aes(x = .data$value)) +
    ggplot2::annotate(
      "rect",
      xmin = ci[1], xmax = ci[2],
      ymin = -Inf,  ymax = Inf,
      fill = col_ci, alpha = 0.2
    ) +
    ggplot2::geom_histogram(
      ggplot2::aes(y = ggplot2::after_stat(density)),
      bins   = bins,
      fill   = col_fill,
      colour = "white",
      alpha  = 0.65
    ) +
    ggplot2::geom_density(
      linewidth = 1.1,
      colour    = col_density
    ) +
    ggplot2::geom_vline(
      xintercept = bb$posterior_mean,
      colour     = col_mean,
      linewidth  = 1,
      linetype   = "dashed"
    ) +
    ggplot2::labs(
      title    = plot_title,
      subtitle = sub_text,
      x        = "Posterior Value",
      y        = "Density"
    ) +
    ggplot2::theme_minimal(base_size = 13) +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(face = "bold", size = 16),
      plot.subtitle = ggplot2::element_text(colour = "grey40", size = 10),
      panel.grid.minor = ggplot2::element_blank()
    )
}
