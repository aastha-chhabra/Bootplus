test_that("boot_bayes returns correct structure", {
  x <- c(2, 4, 5, 8, 10)
  wmean <- function(data, weights) sum(data * weights)
  bb <- boot_bayes(x, wmean, R = 1000, seed = 42)

  expect_s3_class(bb, "boot_bayes")
  expect_equal(bb$R, 1000L)
  expect_length(bb$posterior_samples, 1000)
  expect_true(is.numeric(bb$posterior_mean))
  expect_true(is.numeric(bb$posterior_sd))
  expect_length(bb$credible_interval, 2)
  expect_true(bb$credible_interval[1] < bb$credible_interval[2])
})

test_that("boot_bayes posterior mean is close to sample mean", {
  set.seed(99)
  x <- rnorm(100, mean = 5, sd = 1)
  wmean <- function(data, weights) sum(data * weights)
  bb <- boot_bayes(x, wmean, R = 5000, seed = 99)
  expect_true(abs(bb$posterior_mean - mean(x)) < 0.5)
})

test_that("boot_bayes rejects non-function statistic", {
  expect_error(boot_bayes(1:10, "not_a_function"), "must be a function")
})

test_that("boot_bayes rejects invalid R", {
  wmean <- function(data, weights) sum(data * weights)
  expect_error(boot_bayes(1:5, wmean, R = -1), "positive integer")
})

test_that("boot_bayes_plot returns a ggplot object", {
  x <- c(2, 4, 5, 8, 10)
  wmean <- function(data, weights) sum(data * weights)
  bb <- boot_bayes(x, wmean, R = 500, seed = 7)
  p <- boot_bayes_plot(bb)
  expect_s3_class(p, "ggplot")
})

test_that("boot_bayes_plot rejects non-boot_bayes objects", {
  expect_error(boot_bayes_plot(list()), "class 'boot_bayes'")
})

test_that("print.boot_bayes works without error", {
  x <- c(2, 4, 5, 8, 10)
  wmean <- function(data, weights) sum(data * weights)
  bb <- boot_bayes(x, wmean, R = 200, seed = 1)
  expect_output(print(bb), "Bayesian Bootstrap")
})
