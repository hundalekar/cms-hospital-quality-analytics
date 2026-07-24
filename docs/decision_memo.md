# Hospital Quality and Readmissions: Where Ownership Structure Matters

**Decision Memo | Data-Driven Priorities for Quality Improvement**

Prepared by: Abhishek Mohan Hundalekar
Date: November 2025
Data: CMS public datasets, 445,458 measure-level records from 5,432 US hospitals (2021-2025)

---

## Business Question

Which hospital characteristics and quality measures are statistically associated with higher readmission rates and lower star ratings, and where should quality improvement resources be prioritized?

---

## Top 3 Findings

**1. VA hospitals achieve 5-star ratings at 44.6% - roughly 8.5x the rate of Proprietary hospitals.**
The Veterans Health Administration outperforms every other ownership category on overall star rating. The 95% confidence interval for VA 5-star share is [35%, 54%] - even at the lower bound, VA leads by a wide margin. Proprietary hospitals achieve 5-star at only 5.2%.

**2. Ownership category was associated with approximately 5% of the observed variation in Excess Readmission Ratio (ANOVA F=20.4, η²=0.049).**
One-way ANOVA across 8 ownership types was highly significant. 10 of 28 pairwise ownership comparisons were statistically significant. Government-Federal (avg ERR 1.014) and Proprietary (1.013) sit at the worst end; Physician-owned (0.922) at the best - but with 3x the variance of other groups.

**3. Star ratings correlate with excess readmissions (Spearman r = -0.45) and patient experience (r = 0.51).**
CMS star methodology is internally consistent - hospitals with lower readmissions and better patient experience earn higher ratings. This validates using star rating as a summary quality signal.

---

## Recommendations

**Recommendation 1: Investigate operational practices at VA hospitals to identify potentially transferable quality improvement strategies.**
The VA outperformance is large, statistically significant, and consistent across measures. Priority areas for qualitative study: staffing ratios, care transition protocols, standardized discharge planning, and integrated EMR use. Any transferability of practices should be validated through pilot testing before broader adoption.

**Recommendation 2: Prioritize Proprietary hospitals for targeted quality improvement engagement.**
Proprietary hospitals show the lowest 5-star share (5.2%) and near-worst ERR (1.013). This segment represents the largest observable performance gap and is a logical starting point for improvement resources. Root-cause analysis should distinguish structural factors (case-mix, funding, patient population) from operational factors before intervention design.

---

## Limitations and Caveats

- **All findings are observed associations, not causal claims.** Ownership does not cause quality outcomes directly - it correlates with case-mix, patient population, funding structure, and regulatory environment.
- **Physician-owned hospitals show the lowest ERR but 3x the variance of other groups.** This pattern strongly suggests selection bias - these hospitals may systematically admit lower-acuity patients rather than deliver superior care. Do not interpret the 0.922 ERR as evidence of best practices without adjustment.
- **41% of hospitals have no CMS star rating.** Selection into the rated sample is not random. Findings apply to rated hospitals, which skew toward larger, urban acute-care facilities.
- **Statistical significance does not imply operational significance.** An ERR difference of 0.02 is measurable at scale but modest at the individual hospital level.
- **This analysis does not estimate intervention effects.** Any impact projections would require additional modeling with intervention-effect assumptions not supported by this dataset.

---

## Methodology and Data

- **Data:** 4 CMS public datasets comprising 445,458 measure-level records from 5,432 US hospitals (2021-2025)
- **Tools:** PostgreSQL 18, Python (pandas, scipy, statsmodels), Power BI
- **Tests applied:** Spearman correlation, chi-square with Cramer's V, Welch's t-test with Cohen's d, one-way ANOVA with eta-squared, 95% Wilson confidence intervals for proportions
- **Rigor standard:** Effect sizes reported alongside p-values; parametric and non-parametric tests both applied where distributional assumptions were in question; minimum sample thresholds (n ≥ 20) applied for group-level proportion estimates

*Dashboard, code, and full analysis: https://github.com/hundalekar/cms-hospital-quality-analytics*
