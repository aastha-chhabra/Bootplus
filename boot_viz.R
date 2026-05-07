#' @title Modern Visualization for Bootstrap Objects
#'
#' @description
#' Produce a publication-quality ggplot2 visualization of a \code{boot} object.
#' The plot overlays a histogram with a kernel density estimate and marks the
#' original statistic, bootstrap mean, and (optionally) confidence interval
#' bounds.
#'
#' @param boot_obj An object of class \code{boot} returned by \code{\link[boot]{boot}}.
#' @param index Integer. Which element of \code{boot_obj$t0} to plot when the
#'   statistic is vector-valued. Default is \code{1}.
#' @param ci_level Numeric between 0 and 1. Confidence level for interval
#'   shading. Default is \code{0.95}.
#' @param show_ci Logical. Whether to draw vertical lines at the CI bounds.
#'   Default is \code{TRUE}.
#' @param show_bias Logical. Whether to annotate the bias (bootstrap mean minus
#'   original statistic). Default is \code{TRUE}.
#' @param bins Integer. Number of histogram bins. Default is \code{40}.
#' @param title Character. Plot title. If \code{NULL} a sensible default is
#'   used.
#'
#' @return A \code{ggplot} object.
#'
#' @examples
#' \dontrun{
#' library(boot)
#' set.seed(42)
#' mean_fn <- function(d, i) mean(d[i])
#' b <- boot(mtcars$mpg, mean_fn, R = 2000)
#' boot_viz(b)
#' }
#'
#' @export
boot_viz <- function(boot_obj,
                     index    = 1,
                     ci_level = 0.95,
                     show_ci  = TRUE,
                     show_bias = TRUE,
                     bins     = 40,
                     title    = NULL) {


  # ---- validation -----------------------------------------------------------
  if (!inherits(boot_obj, "boot")) {
    stop("`boot_obj` must be an object of class 'boot'.", call. = FALSE)
  }

  theta   <- boot_obj$t[, index]
  theta0  <- boot_obj$t0[index]
  b_mean  <- mean(theta)
  bias    <- b_mean - theta0
  se      <- stats::sd(theta)

  # ---- CI bounds ------------------------------------------------------------
  alpha <- (1 - ci_level) / 2
  ci    <- stats::quantile(theta, probs = c(alpha, 1 - alpha))

  # ---- build data frame -----------------------------------------------------
  df <- data.frame(statistic = theta)

  # ---- colour palette -------------------------------------------------------
  col_hist     <- "#6C5CE7"
  col_density  <- "#00CEC9"
  col_original <- "#E17055"
  col_mean     <- "#0984E3"

  col_ci       <- "#FDCB6E"

  # ---- plot -----------------------------------------------------------------
  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$statistic)) +
    ggplot2::geom_histogram(
      ggplot2::aes(y = ggplot2::after_stat(density)),
      bins     = bins,
      fill     = col_hist,
      colour   = "white",
      alpha    = 0.65
    ) +
    ggplot2::geom_density(
      linewidth = 1.1,
      colour    = col_density
    ) +
    # original statistic
    ggplot2::geom_vline(
      xintercept = theta0,
      linewidth  = 1,
      linetype   = "dashed",
      colour     = col_original
    ) +
    # bootstrap mean
    ggplot2::geom_vline(
      xintercept = b_mean,
      linewidth  = 1,
      linetype   = "dotted",
      colour     = col_mean
    )

  # ---- CI shading -----------------------------------------------------------
  if (show_ci) {
    p <- p +
      ggplot2::annotate(
        "rect",
        xmin  = ci[1], xmax = ci[2],
        ymin  = -Inf,  ymax = Inf,
        fill  = col_ci, alpha = 0.18
      ) +
      ggplot2::geom_vline(
        xintercept = ci[1], colour = col_ci,
        linewidth = 0.8, linetype = "solid"
      ) +
      ggplot2::geom_vline(
        xintercept = ci[2], colour = col_ci,
        linewidth = 0.8, linetype = "solid"
      )
  }

  # ---- bias annotation ------------------------------------------------------
  if (show_bias) {
    y_max <- max(stats::density(theta)$y)
    p <- p +
      ggplot2::annotate(
        "text",
        x     = b_mean,
        y     = y_max * 0.95,
        label = paste0("bias = ", round(bias, 4)),
        colour = col_mean,
        hjust  = -0.1,
        size   = 3.8,
        fontface = "italic"
      )
  }

  # ---- labels / theme -------------------------------------------------------
  plot_title <- if (is.null(title)) "Bootstrap Sampling Distribution" else title
  subtitle   <- paste0(
    "R = ", boot_obj$R,
    "   |   SE = ", round(se, 4),
    "   |   ", round(ci_level * 100), "% CI: [",
    round(ci[1], 4), ", ", round(ci[2], 4), "]"
  )

  p <- p +
    ggplot2::labs(
      title    = plot_title,
      subtitle = subtitle,
      x        = "Bootstrap Statistic",
      y        = "Density"
    ) +
    ggplot2::theme_minimal(base_size = 13) +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(face = "bold", size = 16),
      plot.subtitle = ggplot2::element_text(colour = "grey40", size = 10),
      panel.grid.minor = ggplot2::element_blank()
    )

  p
}


#' @title Bootstrap Density Plot
#'
#' @description
#' A streamlined density-only view of the bootstrap distribution.
#'
#' @inheritParams boot_viz
#'
#' @return A \code{ggplot} object.
#' @export
boot_density <- function(boot_obj, index = 1) {

  if (!inherits(boot_obj, "boot")) {
    stop("`boot_obj` must be an object of class 'boot'.", call. = FALSE)
  }

  theta  <- boot_obj$t[, index]
  theta0 <- boot_obj$t0[index]
  df     <- data.frame(statistic = theta)

  ggplot2::ggplot(df, ggplot2::aes(x = .data$statistic)) +
    ggplot2::geom_density(
      fill      = "#A29BFE",
      colour    = "#6C5CE7",
      alpha     = 0.55,
      linewidth = 1
    ) +
    ggplot2::geom_vline(
      xintercept = theta0,
      colour     = "#E17055",
      linewidth  = 0.9,
      linetype   = "dashed"
    ) +
    ggplot2::labs(
      title = "Bootstrap Density Estimate",
      x     = "Bootstrap Statistic",
      y     = "Density"
    ) +
    ggplot2::theme_minimal(base_size = 13) +
    ggplot2::theme(
      plot.title       = ggplot2::element_text(face = "bold", size = 15),
      panel.grid.minor = ggplot2::element_blank()
    )
}


#' @title Confidence Interval Plot
#'
#' @description
#' A horizontal interval plot that displays the point estimate together with
#' multiple bootstrap CI methods side-by-side for easy comparison.
#'
#' @param boot_obj An object of class \code{boot}.
#' @param index Integer. Index of the statistic. Default \code{1}.
#' @param ci_level Numeric. Confidence level. Default \code{0.95}.
#' @param methods Character vector of CI methods to include. Any subset of
#'   \code{c("norm", "basic", "perc", "bca")}. Default: all four.
#'
#' @return A \code{ggplot} object.
#' @export
boot_ci_plot <- function(boot_obj,
                         index    = 1,
                         ci_level = 0.95,
                         methods  = c("norm", "basic", "perc", "bca")) {

  if (!inherits(boot_obj, "boot")) {
    stop("`boot_obj` must be an object of class 'boot'.", call. = FALSE)
  }

  ci_obj <- tryCatch(
    boot::boot.ci(boot_obj, conf = ci_level, type = methods, index = index),
    error = function(e) {
      stop("boot.ci() failed: ", conditionMessage(e), call. = FALSE)
    }
  )

  # ---- extract intervals ----------------------------------------------------
  method_labels <- c(
    norm  = "Normal",
    basic = "Basic",
    perc  = "Percentile",
    bca   = "BCa"
  )

  rows <- list()
  for (m in methods) {
    ci_mat <- ci_obj[[m]]
    if (is.null(ci_mat)) next
    # boot.ci returns matrices; last two columns are lower/upper
    nc <- ncol(ci_mat)
    rows[[length(rows) + 1]] <- data.frame(
      method = method_labels[m],
      lower  = ci_mat[1, nc - 1],
      upper  = ci_mat[1, nc],
      stringsAsFactors = FALSE
    )
  }

  ci_df <- do.call(rbind, rows)
  ci_df$method <- factor(ci_df$method, levels = rev(ci_df$method))

  theta0 <- boot_obj$t0[index]

  # ---- colours --------------------------------------------------------------
  cols <- c("#6C5CE7", "#00CEC9", "#E17055", "#0984E3")

  ggplot2::ggplot(ci_df, ggplot2::aes(
    y = .data$method, xmin = .data$lower, xmax = .data$upper,
    colour = .data$method)) +
    ggplot2::geom_linerange(linewidth = 2.2) +
    ggplot2::geom_point(
      ggplot2::aes(x = (.data$lower + .data$upper) / 2),
      size = 3
    ) +
    ggplot2::geom_vline(
      xintercept = theta0, linetype = "dashed",
      colour = "#2D3436", linewidth = 0.7
    ) +
    ggplot2::scale_colour_manual(values = cols, guide = "none") +
    ggplot2::labs(
      title    = paste0(round(ci_level * 100), "% Bootstrap Confidence Intervals"),
      subtitle = paste0("Original statistic = ", round(theta0, 4)),
      x        = "Value",
      y        = NULL
    ) +
    ggplot2::theme_minimal(base_size = 13) +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(face = "bold", size = 15),
      plot.subtitle = ggplot2::element_text(colour = "grey40"),
      panel.grid.minor = ggplot2::element_blank()
    )
}


#' @title Bootstrap Distribution Tile Plot
#'
#' @description
#' Visualise bootstrap replicates as a strip/tile plot ordered by magnitude.
#' Useful for spotting outlier replicates and overall spread at a glance.
#'
#' @inheritParams boot_viz
#'
#' @return A \code{ggplot} object.
#' @export
boot_dist_plot <- function(boot_obj, index = 1) {

  if (!inherits(boot_obj, "boot")) {
    stop("`boot_obj` must be an object of class 'boot'.", call. = FALSE)
  }

  theta  <- boot_obj$t[, index]
  df     <- data.frame(
    replicate = seq_along(theta),
    statistic = sort(theta)
  )

  ggplot2::ggplot(df, ggplot2::aes(
    x = .data$replicate, y = 1, fill = .data$statistic)) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_viridis_c(option = "C", name = "Statistic") +
    ggplot2::labs(
      title = "Bootstrap Replicates — Ordered Tile Strip",
      x     = "Replicate (sorted)",
      y     = NULL
    ) +
    ggplot2::theme_minimal(base_size = 13) +
    ggplot2::theme(
      axis.text.y      = ggplot2::element_blank(),
      axis.ticks.y     = ggplot2::element_blank(),
      panel.grid       = ggplot2::element_blank(),
      plot.title       = ggplot2::element_text(face = "bold", size = 15)
    )
}


#' @title Compare Bootstrap CI Methods
#'
#' @description
#' Compute and return a tidy data frame comparing multiple bootstrap CI methods.
#' This is the tabular companion to \code{\link{boot_ci_plot}}.
#'
#' @inheritParams boot_ci_plot
#'
#' @return A \code{data.frame} with columns \code{method}, \code{lower},
#'   \code{upper}, and \code{width}.
#' @export
boot_compare_ci <- function(boot_obj,
                            index    = 1,
                            ci_level = 0.95,
                            methods  = c("norm", "basic", "perc", "bca")) {

  if (!inherits(boot_obj, "boot")) {
    stop("`boot_obj` must be an object of class 'boot'.", call. = FALSE)
  }

  ci_obj <- boot::boot.ci(boot_obj, conf = ci_level, type = methods, index = index)

  method_labels <- c(
    norm  = "Normal",
    basic = "Basic",
    perc  = "Percentile",
    bca   = "BCa"
  )

  rows <- list()
  for (m in methods) {
    ci_mat <- ci_obj[[m]]
    if (is.null(ci_mat)) next
    nc <- ncol(ci_mat)
    lo <- ci_mat[1, nc - 1]
    hi <- ci_mat[1, nc]
    rows[[length(rows) + 1]] <- data.frame(
      method = method_labels[m],
      lower  = round(lo, 5),
      upper  = round(hi, 5),
      width  = round(hi - lo, 5),
      stringsAsFactors = FALSE
    )
  }

  do.call(rbind, rows)
}
