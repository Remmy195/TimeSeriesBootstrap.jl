# TimeSeriesBootstrap.jl

This project implements a **block bootstrap framework** and statistical validation methods for evaluating time series data.
---

## Key Features
- **Block Bootstrap Implementation:**
  - Resamples residuals while preserving temporal dependencies.
- **Statistical Validations:**
  - Distribution similarity using Kolmogorov-Smirnov test.
  - Mean and variance validation with 95% confidence intervals.
- **Monte Carlo Simulations:**
  - Evaluate bootstrap performance over datasets with varying **forecast horizons**.
  - Metrics include bias, variance, and confidence interval coverage.
- **Asymptotic Consistency Tests:**
  - Ensures block lengths scale appropriately with increasing forecast horizons.