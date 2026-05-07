\name{boot_interpret}
\alias{boot_interpret}
\alias{boot_report}
\title{Interpret and Report Bootstrap Results}
\description{
\code{boot_interpret()} produces a structured, human-readable interpretation
of a \code{boot} object including bias assessment, standard error,
coefficient of variation, and a narrative conclusion.

\code{boot_report()} combines interpretation with CI comparison and
distribution diagnostics (skewness, kurtosis) in a single console report.
}
\usage{
boot_interpret(boot_obj, index = 1, ci_level = 0.95,
               digits = 4, verbose = TRUE)

boot_report(boot_obj, index = 1, ci_level = 0.95,
            ci_methods = c("norm", "basic", "perc", "bca"),
            digits = 4)
}
\arguments{
  \item{boot_obj}{An object of class \code{boot}.}
  \item{index}{Integer index of the statistic (default 1).}
  \item{ci_level}{Confidence level (default 0.95).}
  \item{digits}{Number of decimal places (default 4).}
  \item{verbose}{Logical; print to console (default TRUE).}
  \item{ci_methods}{Character vector of CI methods for the report.}
}
\value{
Both functions invisibly return a list.

\code{boot_interpret()} returns original statistic, bootstrap mean/median,
bias, bias ratio, SE, CV, CI bounds, R, and a narrative conclusion.

\code{boot_report()} returns the interpretation list and a CI comparison
data frame.
}
\examples{
\dontrun{
library(boot)
b <- boot(mtcars$mpg, function(d, i) mean(d[i]), R = 2000)
boot_interpret(b)
boot_report(b)
}
}
