# bootplus 

> **Modern Visualization, Interpretation & Bayesian Bootstrap Extensions for R's `boot` Package**


---

## Why bootplus?

The `boot` package is R's gold-standard for bootstrap resampling — but it was designed in a time before `ggplot2`, tidy data, and widespread Bayesian workflows. **bootplus** is a lightweight extension layer that adds three things `boot` is missing:

| Capability | Functions |
|---|---|
| **Visualization** | `boot_viz()`, `boot_density()`, `boot_ci_plot()`, `boot_dist_plot()` |
| **Interpretation** | `boot_interpret()`, `boot_compare_ci()`, `boot_report()` |
| **Bayesian Bootstrap** | `boot_bayes()`, `boot_bayes_plot()` |

**bootplus does not replace `boot`** — it works directly with `boot` objects and adds what's missing.

---

## Installation

```r
# Install from GitHub (devtools required)
devtools::install_github("YOUR_USERNAME/bootplus")
```

---

## Quick Start

### 1. Classical Bootstrap → Visualize & Interpret

```r
library(boot)
library(bootplus)

# Bootstrap the mean of mpg
set.seed(42)
b <- boot(mtcars$mpg, function(d, i) mean(d[i]), R = 2000)

# Beautiful distribution plot with CI shading
boot_viz(b)

# Human-readable interpretation
boot_interpret(b)
#> Bootstrap Analysis (R = 2000)
#> -------------------------------------------
#> Original statistic : 20.0906
#> Bootstrap mean     : 20.0754
#> Bias               : -0.0152  (negligible)
#> Std. Error         : 1.0632
#> 95% Percentile CI  : [18.0422, 22.1406]

# Compare CI methods side-by-side
boot_ci_plot(b)
boot_compare_ci(b)
#>       method   lower   upper   width
#> 1     Normal 17.9920 22.1893  4.1973
#> 2      Basic 18.0094 22.1391  4.1297
#> 3 Percentile 18.0422 22.1719  4.1297
#> 4        BCa 18.1847 22.2969  4.1122

# Full report with diagnostics
boot_report(b)
```

### 2. Bayesian Bootstrap

```r
x <- c(2, 4, 5, 8, 10)
weighted_mean <- function(data, weights) sum(data * weights)

bb <- boot_bayes(x, weighted_mean, R = 4000, seed = 42)
print(bb)
#> Bayesian Bootstrap
#> ------------------
#> Draws (R)          : 4000
#> Posterior mean     : 5.7993
#> Posterior median   : 5.7268
#> Posterior SD       : 1.4112
#> 95% Credible Int.  : [ 3.1752 , 8.6273 ]

# Posterior density plot
boot_bayes_plot(bb)
```

---

## Function Reference

### Visualization

| Function | Description |
|---|---|
| `boot_viz()` | Histogram + density + CI shading + bias annotation |
| `boot_density()` | Streamlined filled density plot |
| `boot_ci_plot()` | Horizontal interval comparison (Normal, Basic, Percentile, BCa) |
| `boot_dist_plot()` | Ordered tile-strip of all replicates |

### Interpretation

| Function | Description |
|---|---|
| `boot_interpret()` | Structured summary with bias assessment & narrative |
| `boot_compare_ci()` | Tidy data frame of CI methods with widths |
| `boot_report()` | Full report: interpretation + CI table + skewness/kurtosis |

### Bayesian Bootstrap

| Function | Description |
|---|---|
| `boot_bayes()` | Rubin's (1981) Dirichlet-weighted Bayesian bootstrap |
| `boot_bayes_plot()` | Posterior density with credible interval shading |

---

## Design Philosophy

```
┌─────────────────────────────────────────────────┐
│                  User Code                      │
│                                                 │
│   boot()  ──►  boot_viz()                       │
│            ──►  boot_interpret()                │
│            ──►  boot_report()                   │
│                                                 │
│   boot_bayes()  ──►  boot_bayes_plot()          │
└─────────────────────────────────────────────────┘
        │                     │
        ▼                     ▼
   ┌─────────┐        ┌────────────┐
   │  boot   │        │  ggplot2   │
   │ package │        │  package   │
   └─────────┘        └────────────┘
```

- **Non-invasive**: Works with existing `boot` objects — no custom classes needed for classical bootstrap.
- **Composable**: Every visualization function returns a `ggplot` object you can further customize.
- **Teach-friendly**: `boot_interpret()` explains results in plain language.

---

## Dependencies

- **R** ≥ 3.5.0
- **boot** (ships with R)
- **ggplot2** ≥ 3.4.0

---

## References

- Davison, A.C. & Hinkley, D.V. (1997). *Bootstrap Methods and Their Application*. Cambridge University Press.
- Efron, B. & Tibshirani, R.J. (1993). *An Introduction to the Bootstrap*. Chapman & Hall/CRC.
- Rubin, D.B. (1981). The Bayesian Bootstrap. *Annals of Statistics*, 9(1), 130–134.

---
