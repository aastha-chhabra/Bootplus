\name{boot_bayes}
\alias{boot_bayes}
\alias{boot_bayes_plot}
\alias{print.boot_bayes}
\title{Bayesian Bootstrap}
\description{
\code{boot_bayes()} performs Rubin's (1981) Bayesian bootstrap using
Dirichlet(1, ..., 1) weights. Instead of resampling observations, each
replicate draws random probability weights and computes a weighted statistic.

\code{boot_bayes_plot()} visualizes the resulting posterior distribution with
credible interval shading.

\code{print.boot_bayes()} provides a concise console summary.
}
\usage{
boot_bayes(data, statistic, R = 4000, seed = NULL)

boot_bayes_plot(bb, ci_level = 0.95, bins = 40, title = NULL)

\method{print}{boot_bayes}(x, digits = 4, \dots)
}
\arguments{
  \item{data}{A numeric vector or matrix.}
  \item{statistic}{A function of the form \code{function(data, weights)}
    returning a scalar.}
  \item{R}{Number of posterior draws (default 4000).}
  \item{seed}{Optional integer seed.}
  \item{bb}{An object of class \code{boot_bayes}.}
  \item{ci_level}{Credible interval level (default 0.95).}
  \item{bins}{Histogram bins (default 40).}
  \item{title}{Optional plot title.}
  \item{x}{An object of class \code{boot_bayes}.}
  \item{digits}{Significant digits (default 4).}
  \item{\dots}{Further arguments (ignored).}
}
\value{
\code{boot_bayes()} returns a list of class \code{boot_bayes} with
posterior samples, mean, median, SD, and a 95\% credible interval.

\code{boot_bayes_plot()} returns a \code{ggplot} object.
}
\references{
Rubin, D. B. (1981). The Bayesian bootstrap. \emph{Annals of Statistics},
9(1), 130-134.
}
\examples{
x <- c(2, 4, 5, 8, 10)
wmean <- function(data, weights) sum(data * weights)
bb <- boot_bayes(x, wmean, R = 2000, seed = 42)
print(bb)

\dontrun{
boot_bayes_plot(bb)
}
}
