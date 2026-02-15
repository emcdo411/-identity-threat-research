# Identity Threat Dynamics: A Bayesian Framework for Modeling Belief Shifts

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-4.0%2B-blue)](https://www.r-project.org/)
[![Status: Research](https://img.shields.io/badge/Status-Research-yellow)](https://github.com)

## 🎯 Research Motivation

How do identity threats influence the evolution of discourse, credibility perception, and institutional trust? This repository implements a quantitative framework for understanding the dynamics of belief formation and narrative escalation in polarized environments.

Traditional approaches to analyzing social discourse focus on content analysis or sentiment scoring. This research takes a systems approach: modeling **identity threat** as a forcing function that influences emotional rhetoric, rationalization behavior, and credibility assessment—independent of evidence quality.

The framework is designed for:

- **Crisis response teams** assessing escalation risk
- **Policy researchers** studying institutional legitimacy dynamics
- **AI safety researchers** modeling belief propagation in contested information environments
- **Leadership decision-makers** evaluating communication strategies during high-stakes events

## 🔬 Modeling Approach

### Core Framework

This repository implements three integrated modeling layers:

#### 1. **Time-Series Dynamics**
Longitudinal simulation of group-level behavior over 24 months, capturing:
- Media intensity cycles
- Identity threat fluctuations
- Emotional rhetoric trajectories
- Institutional response patterns
- Credibility perception shifts

#### 2. **Forecasting Models**
Predictive models using Prophet/ARIMA to forecast:
- Future rhetoric escalation patterns
- Credibility trajectory shifts
- Threat index evolution

#### 3. **Bayesian Belief Updating**
Formal model of how perceived credibility updates over time:
- Prior beliefs in narrative strength
- Evidence quality as likelihood function
- Institutional signals as credibility multipliers
- Posterior belief distributions

#### 4. **Anomaly Detection**
Statistical identification of:
- Unusual rhetoric surges
- Abnormal credibility jumps
- Extreme institutional response lags

### Key Research Questions

1. **Evidence-Credibility Decoupling**: Under what conditions does perceived credibility diverge from evidence strength?

2. **Institutional Response Effects**: How do institutional response patterns influence narrative stability across identity groups?

3. **Escalation Symmetry**: Do opposing groups exhibit convergent or divergent patterns in rhetoric escalation?

4. **Belief Persistence**: How do prior beliefs influence credibility updates in the presence of new evidence?

## 📊 Dashboard Overview

The interactive R Markdown dashboard (`identity_dashboard.Rmd`) provides seven analytical panels:

### Panel 1: System Overview
- Multi-dimensional time series of threat, rhetoric, and media cycles
- Cross-correlation analysis
- System-level trend identification

### Panel 2: Identity Threat Dynamics
- Group-level threat trajectories with rolling averages
- Comparative analysis between Group A and Group B
- Threat divergence/convergence patterns

### Panel 3: Institutional Response Effects
- Lagged correlation between institutional speed and narrative stability
- Response effectiveness analysis
- Time-delay impact visualization

### Panel 4: Credibility Signaling
- Evidence strength vs. perceived credibility
- Institutional support multiplier effects
- Credibility-evidence decoupling detection

### Panel 5: Forecasting Panel
- 90-day forward projections for key metrics
- Uncertainty intervals
- Scenario analysis

### Panel 6: Anomaly Detection Panel
- Statistical outlier identification
- Surge/spike event flagging
- Anomaly context visualization

### Panel 7: Bayesian Belief Panel
- Prior vs. posterior distributions
- Belief trajectory evolution
- Credibility weight influence curves

## 📁 Repository Structure

```
identity-threat-research/
│
├── README.md                          # This file
├── methodology.md                     # Detailed methods and assumptions
├── identity_dashboard_CHIEF_DS_ENHANCED.Rmd            # Main interactive dashboard
│
├── R/
│   ├── data_generation.R              # Simulation logic and data generation
│   ├── forecasting_models.R           # Prophet/ARIMA forecasting functions
│   ├── anomaly_detection.R            # Outlier detection algorithms
│   └── bayesian_model.R               # Bayesian belief updating model
│
├── data/
│   └── simulated_data_description.md  # Data dictionary and simulation notes
│
└── renv.lock                          # (Optional) Dependency snapshot
```

## 🚀 Reproducibility Instructions

### Prerequisites

- **R version 4.0 or higher**
- **RStudio** (recommended for knitting dashboard)

### Required R Packages

```r
install.packages(c(
  "tidyverse",      # Data manipulation and visualization
  "plotly",         # Interactive plots
  "flexdashboard",  # Dashboard framework
  "prophet",        # Forecasting (or use 'forecast' package)
  "isotree",        # Anomaly detection
  "DT",             # Interactive tables
  "lubridate",      # Date handling
  "slider",         # Rolling window functions
  "rstanarm"        # Bayesian modeling (or 'brms')
))
```

### Running the Analysis

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/identity-threat-research.git
   cd identity-threat-research
   ```

2. **Generate simulated data**:
   ```r
   source("R/data_generation.R")
   ```

3. **Knit the dashboard**:
   ```r
   rmarkdown::render("identity_dashboard.Rmd")
   ```

4. **View the output**:
   Open `identity_dashboard.html` in your web browser

### Reproducibility Note

All analyses use a fixed random seed (`set.seed(42)`) to ensure reproducible results. The simulation parameters are documented in `R/data_generation.R` and explained in `methodology.md`.

## 🧠 Why This Matters

### For Leadership Decision-Making

Understanding how identity threat influences credibility perception enables leaders to:
- Anticipate escalation dynamics before crisis points
- Design institutional responses that stabilize rather than amplify threats
- Distinguish evidence-driven credibility from identity-driven credibility

### For Crisis Response

The forecasting and anomaly detection layers provide:
- Early warning signals of rhetoric escalation
- Identification of critical institutional response windows
- Risk assessment for narrative instability

### For AI Modeling of Social Systems

This framework demonstrates:
- How to model belief propagation in contested environments
- Bayesian approaches to credibility updating under uncertainty
- Integration of institutional signals into belief formation models

Modern AI systems increasingly need to model human belief dynamics—not just to predict behavior, but to understand the causal mechanisms driving polarization, radicalization, and institutional legitimacy crises.

## 📚 Methodology

For detailed explanation of:
- Simulation design and assumptions
- Bayesian model specification
- Forecasting approach
- Anomaly detection algorithms
- Limitations and caveats

See [`methodology.md`](methodology.md).

## 📖 Citation

If you use this framework in your research, please cite:

```bibtex
@software{identity_threat_research_2026,
  title = {Identity Threat Dynamics: A Bayesian Framework for Modeling Belief Shifts},
  author = {[Your Name]},
  year = {2026},
  url = {https://github.com/yourusername/identity-threat-research}
}
```

## 📄 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

This is a research project, but contributions are welcome. See CONTRIBUTING.md for guidelines.

## ✉️ Contact

For questions about the methodology or applications:
- **Email**: erwin.mcdonald@outlook.com
- **LinkedIn**: [https://www.linkedin.com/in/mauricemcdonald]
- **Research Portfolio**: [https://github.com/emcdo411]

---

**Note**: This analysis uses simulated data to demonstrate the modeling framework. Real-world applications would require domain-specific calibration and validation against observational data.
