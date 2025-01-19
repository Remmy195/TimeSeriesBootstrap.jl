# TimeSeriesBootstrap.jl
## This project is still in dev and not quite stable
This project implements a **block bootstrap sampling framework** and validation methods for evaluating time series data.

---

## Key Features
- **Block Bootstrap Sampling:**
  - Resamples time series while preserving temporal dependencies.
- **Statistical Validations:**
  - Distribution similarity using Kolmogorov-Smirnov test.
  - Mean and variance validation with 95% confidence intervals.
- **Monte Carlo Simulations:**
  - Evaluate sampling performance over time series with varying **forecast horizons**.
  - Metrics include bias, variance, and confidence interval coverage.
- **Asymptotic Consistency Tests:**
  - Ensures block lengths scale appropriately with increasing forecast horizons.
