test_that("boot_interpret returns expected list structure", {
  library(boot)
  set.seed(10)
  b <- boot(mtcars$mpg, function(d, i) mean(d[i]), R = 500)
  res <- boot_interpret(b, verbose = FALSE)

  expect_type(res, "list")
  expect_named(res, c(
    "original_statistic", "bootstrap_mean", "bootstrap_median",
    "bootstrap_bias", "bias_ratio", "bootstrap_se", "cv_percent",
    "ci_lower", "ci_upper", "R", "conclusion"
  ), ignore.order = TRUE)

  expect_equal(res$original_statistic, mean(mtcars$mpg))
  expect_equal(res$R, 500)
  expect_true(is.numeric(res$bootstrap_se))
  expect_true(res$bootstrap_se > 0)
})

test_that("boot_interpret rejects non-boot objects", {
  expect_error(boot_interpret("not_boot"), "class 'boot'")
})

test_that("boot_interpret bias is close to zero for large R", {
  library(boot)
  set.seed(11)
  b <- boot(rnorm(200), function(d, i) mean(d[i]), R = 5000)
  res <- boot_interpret(b, verbose = FALSE)
  expect_true(abs(res$bootstrap_bias) < 0.1)
})
