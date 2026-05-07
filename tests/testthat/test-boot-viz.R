test_that("boot_viz returns a ggplot object", {
  library(boot)
  set.seed(1)
  b <- boot(mtcars$mpg, function(d, i) mean(d[i]), R = 500)
  p <- boot_viz(b)
  expect_s3_class(p, "ggplot")
})

test_that("boot_viz rejects non-boot objects", {
  expect_error(boot_viz(list()), "class 'boot'")
})

test_that("boot_density returns a ggplot object", {
  library(boot)
  set.seed(2)
  b <- boot(mtcars$mpg, function(d, i) mean(d[i]), R = 500)
  p <- boot_density(b)
  expect_s3_class(p, "ggplot")
})

test_that("boot_ci_plot returns a ggplot object", {
  library(boot)
  set.seed(3)
  b <- boot(mtcars$mpg, function(d, i) mean(d[i]), R = 1000)
  p <- boot_ci_plot(b)
  expect_s3_class(p, "ggplot")
})

test_that("boot_dist_plot returns a ggplot object", {
  library(boot)
  set.seed(4)
  b <- boot(mtcars$mpg, function(d, i) mean(d[i]), R = 500)
  p <- boot_dist_plot(b)
  expect_s3_class(p, "ggplot")
})

test_that("boot_compare_ci returns a data.frame with expected columns", {
  library(boot)
  set.seed(5)
  b <- boot(mtcars$mpg, function(d, i) mean(d[i]), R = 1000)
  ci_df <- boot_compare_ci(b)
  expect_s3_class(ci_df, "data.frame")
  expect_true(all(c("method", "lower", "upper", "width") %in% names(ci_df)))
  expect_true(nrow(ci_df) >= 1)
})
