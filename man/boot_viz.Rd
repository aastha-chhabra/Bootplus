\name{boot_viz}
\alias{boot_viz}
\alias{boot_density}
\alias{boot_ci_plot}
\alias{boot_dist_plot}
\alias{boot_compare_ci}
\title{Modern Visualization Functions for Bootstrap Objects}
\description{
Publication-quality ggplot2-based visualizations for objects returned by
\code{\link[boot]{boot}}.

\code{boot_viz()} produces a histogram + density overlay with CI shading and
bias annotation.

\code{boot_density()} produces a filled density plot.

\code{boot_ci_plot()} displays multiple CI methods as horizontal intervals.

\code{boot_dist_plot()} renders an ordered tile strip of replicates.

\code{boot_compare_ci()} returns a tidy data frame comparing CI methods.
}
\usage{
boot_viz(boot_obj, index = 1, ci_level = 0.95,
         show_ci = TRUE, show_bias = TRUE, bins = 40, title = NULL)

boot_density(boot_obj, index = 1)

boot_ci_plot(boot_obj, index = 1, ci_level = 0.95,
             methods = c("norm", "basic", "perc", "bca"))

boot_dist_plot(boot_obj, index = 1)

boot_compare_ci(boot_obj, index = 1, ci_level = 0.95,
                methods = c("norm", "basic", "perc", "bca"))
}
\arguments{
  \item{boot_obj}{An object of class \code{boot}.}
  \item{index}{Integer index of the statistic to visualize (default 1).}
  \item{ci_level}{Confidence level (default 0.95).}
  \item{show_ci}{Logical; draw CI shading (default TRUE).}
  \item{show_bias}{Logical; annotate bias (default TRUE).}
  \item{bins}{Number of histogram bins (default 40).}
  \item{title}{Optional plot title.}
  \item{methods}{Character vector of CI methods.}
}
\value{
\code{boot_viz}, \code{boot_density}, \code{boot_ci_plot}, and
\code{boot_dist_plot} return a \code{ggplot} object.

\code{boot_compare_ci} returns a \code{data.frame}.
}
\examples{
\dontrun{
library(boot)
b <- boot(mtcars$mpg, function(d, i) mean(d[i]), R = 2000)
boot_viz(b)
boot_ci_plot(b)
boot_compare_ci(b)
}
}
