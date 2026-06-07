# Non-Parametric Regression Analysis: Heat Exposure & Fecundity in Diamondback Moths
 
> Does the duration of extreme heat exposure during the first larval instar stage influence fecundity in female *Plutella xylostella* (diamondback moths)?
 
---
 
## Overview
 
This project applies a suite of non-parametric and semi-parametric regression techniques to a biological dataset examining the relationship between early-life heat stress and reproductive output in female diamondback moths.
 
Rather than assuming a specific functional form, the analysis systematically compares four curve-fitting approaches — polynomial regression, kernel regression, smoothing splines, and LOESS — to identify the most appropriate model for this ecological data.
 
**Key question:** Does fecundity decline monotonically with exposure duration, or is the relationship non-linear?
 
---
 
## Dataset
 
| Variable | Description |
|---|---|
| `ID` | Individual moth identifier |
| `Exposure` | Duration of extreme heat exposure during first larval instar (hours, 0–5) |
| `Fecundity` | Reproductive output of adult female (egg count proxy) |
 
- **n = 150** observations
- Exposure levels: 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5 hours
- Source: `heat.txt` (tab-separated, included in repo)
---
 
## Analysis Pipeline
 
### 1. Exploratory Data Analysis
 
An initial scatterplot with a default LOESS smoother reveals a non-monotonic relationship — fecundity appears to dip around 1 hour of exposure, recover around 3 hours, then decline again at higher exposures. The wide spread of points suggests high within-group variability.
 
![Exploratory plot](Results/exploratory%20plot.png)
 
---
 
### 2. Polynomial Regression
 
A **3rd-degree orthogonal polynomial** was fitted using ordinary least squares as a parametric baseline:
 
```r
heat <- lm(Fecundity ~ poly(Exposure, 3, raw = FALSE), data = heat.df)
```
 
**Model diagnostics** (Shapiro-Wilk, Cook's distance, residual plots) confirmed:
- Residuals approximately normally distributed
- No single influential observation dominates the fit (all Cook's D < 0.1)
- Mild heteroscedasticity present but not severe
The 3rd-degree polynomial captures the broad non-linear trend while providing 95% confidence bands.
 
![3rd degree polynomial with 95% confidence bands](Results/third%20degree%20polynomial%20with%2095%20confidence%20bands.png)
 
**Residual diagnostics:**
 
![Residual diagnostic plots](Results/residual%20diagnostic%20plot.png)
 
---
 
### 3. Kernel Regression
 
Gaussian kernel regression was applied using `ksmooth()` with cross-validation bandwidth selection via `hcv()` from the `sm` package.
 
Three bandwidths compared:
 
| Bandwidth | Effect |
|---|---|
| 0.2 | Over-fits — follows local noise closely |
| 1.0 | Balanced smoothing (near CV-optimal) |
| 2.0 | Over-smooths — loses meaningful local structure |
 
```r
hm <- hcv(heat.df$Exposure, heat.df$Fecundity, display = "lines")  # Cross-validated bandwidth
fit <- ksmooth(heat.df$Exposure, heat.df$Fecundity, bandwidth = hm, kernel = "normal")
```
 
The `hcv()` function selects the bandwidth that minimises cross-validation error. The CV curve (inset in the plot below) shows a clear minimum around h ≈ 0.4, confirming that moderate smoothing is data-optimal.
 
![sm package CV bandwidth selection](Results/sm%20pakage%20kernel%20output.png)
 
![Kernel regression — bandwidth comparison](Results/kernel%20regression%20comparison.png)
 
---
 
### 4. Smoothing Splines
 
`smooth.spline()` with varying `spar` (smoothing parameter) was used to fit penalised splines. The `spar` parameter controls the bias–variance trade-off directly.
 
| spar | Effect |
|---|---|
| 0.1 | Highly wiggly — interpolates local fluctuations |
| 0.4 | Moderate smoothing — captures main trend |
| 1.0 | Near-linear — underfits the curvature |
 
![Smoothing splines — span comparison](Results/smoothing%20spline%20comparison.png)
 
---
 
### 5. B-Spline Regression
 
B-splines were fitted via `lm()` with the `bs()` basis function from the `splines` package, varying degrees of freedom:
 
```r
bsp1 <- lm(Fecundity ~ bs(Exposure, df = 3), data = heat.df)
bsp2 <- lm(Fecundity ~ bs(Exposure, df = 4), data = heat.df)
bsp3 <- lm(Fecundity ~ bs(Exposure, df = 5), data = heat.df)
```
 
Higher df produces more flexible fits; df = 3–4 gave the most interpretable curves without overfitting.
 
![B-spline regression — df comparison](Results/B-spline%20df%20comparison.png)
 
---
 
### 6. Model Comparison
 
All four methods are overlaid on a single plot for direct visual comparison:
 
![All fitted curves — comparison](Results/various%20types%20of%20fitted%20curves.png)
 
| Method | Strengths | Weaknesses |
|---|---|---|
| 3rd-degree polynomial | Interpretable; confidence intervals available | Rigid global form; poor at boundary behaviour |
| Kernel regression | Locally adaptive; bandwidth tuned by CV | Boundary effects; computationally simple |
| Smoothing spline | Penalised — controls overfitting explicitly | spar choice still subjective |
| LOESS | Robust to local outliers; flexible span | No closed-form model; less interpretable |
 
All methods agree on the **broad shape**: fecundity is highest at low exposure (0–0.5 hours), dips around 1 hour, partially recovers at ~3 hours, then declines toward 5 hours. This non-monotonic pattern suggests a complex physiological response to early heat stress.
 
---
 
## Key Finding
 
There is **evidence of a non-monotonic relationship** between heat exposure duration and fecundity. A simple linear model would be inadequate — the data require at least a cubic or flexible non-parametric fit to capture the observed pattern. However, given the high within-group variability (wide scatter at each exposure level), caution is warranted in over-interpreting fine-grained local features of any fitted curve.
 
---
 
## Repository Structure
 
```
moth-heat-nonparametric/
│
├── analysis.R                    # Full R analysis script
├── heat.txt                      # Dataset (tab-separated, n=150)
├── README.md
│
└── Results/
    ├── exploratory_plot.png                          # EDA scatterplot with LOESS smoother
    ├── third_degree_polynomial_with_95_confidence_bands.png
    ├── residual_diagnostic_plot.png                  # Residuals vs Fitted, Q-Q, Cook's D
    ├── kernel_regression_comparison.png              # Bandwidth 0.2 / 1.0 / 2.0
    ├── smoothing_spline_comparison.png               # spar 0.1 / 0.4 / 1.0
    ├── B-spline_df_comparison.png                    # df 3 / 4 / 5
    ├── sm_pakage_kernel_output.png                   # sm package CV bandwidth output
    └── various_types_of_fitted_curves.png            # All methods overlaid
```
 
---
 
## How to Reproduce
 
**Requirements:** R (≥ 4.0) with the following packages:
 
```r
install.packages(c("ggplot2", "sm", "splines", "splines2"))
```
 
**Run the analysis:**
 
```r
source("analysis.R")
```
 
Ensure `heat.txt` is in your working directory, or update the path in `read.table()`.
 
---
 
## Tech Stack
 
`R` · `ggplot2` · `sm` · `splines` · `splines2` · `ksmooth` · `smooth.spline` · `loess`
 
---
