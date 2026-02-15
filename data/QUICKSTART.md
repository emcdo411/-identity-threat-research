# Identity Threat Research Repository - Quick Start Guide

## 🎉 Repository Generated Successfully

Your complete research repository is ready! This guide will help you get started.

## 📦 What's Included

```
identity-threat-research/
│
├── README.md                          ✓ Professional research overview
├── methodology.md                     ✓ Detailed methods documentation
├── identity_dashboard.Rmd             ✓ Interactive flexdashboard (7 panels)
│
├── R/                                 ✓ Modular analysis scripts
│   ├── data_generation.R              ✓ Simulation engine
│   ├── forecasting_models.R           ✓ Prophet/ARIMA forecasting
│   ├── anomaly_detection.R            ✓ Isolation Forest + z-score
│   └── bayesian_model.R               ✓ Belief updating framework
│
└── data/
    └── simulated_data_description.md  ✓ Data dictionary

Total Files: 8 core files + documentation
Lines of Code: ~2,500+ lines
```

## 🚀 Quick Start (5 Minutes)

### Step 1: Set Up R Environment

```r
# Install required packages
install.packages(c(
  "tidyverse",      # Data manipulation
  "plotly",         # Interactive plots
  "flexdashboard",  # Dashboard framework
  "prophet",        # Forecasting
  "isotree",        # Anomaly detection
  "DT",             # Interactive tables
  "lubridate",      # Date handling
  "slider",         # Rolling windows
  "broom"           # Model tidying
))
```

### Step 2: Generate Data

```r
# Run data generation script
source("R/data_generation.R")

# This creates:
# - data/identity_threat_data.rds
# - data/identity_threat_data.csv
# - Console output showing data summary
```

### Step 3: View the Dashboard

```r
# Open RStudio and knit the dashboard
rmarkdown::render("identity_dashboard.Rmd")

# Or use RStudio "Knit" button
# Output: identity_dashboard.html
```

## 📊 Dashboard Panels

Your dashboard includes 7 analytical panels:

1. **System Overview** - Multi-dimensional time series and cross-correlations
2. **Identity Threat Dynamics** - Group comparisons and convergence analysis
3. **Institutional Response** - Lagged effects and regression models
4. **Credibility Signaling** - Evidence-credibility decoupling visualization
5. **Forecasting** - 90-day projections with uncertainty intervals
6. **Anomaly Detection** - Statistical outliers and spike events
7. **Bayesian Belief** - Prior/posterior distributions and belief trajectories

## 🔬 Research Applications

### For Data Science Portfolios

This demonstrates:
- ✓ Time-series analysis
- ✓ Bayesian modeling
- ✓ Forecasting (Prophet)
- ✓ Anomaly detection (ML)
- ✓ Interactive dashboards
- ✓ Reproducible research
- ✓ Professional documentation

### For Academic Research

Use this framework to:
- Model belief propagation
- Study credibility dynamics
- Analyze institutional effects
- Prototype narrative analysis

### For Industry Applications

Adapt this for:
- Crisis response monitoring
- Brand reputation tracking
- Disinformation detection
- Stakeholder sentiment analysis

## 🎨 Customization Guide

### Change Color Theme

Edit in `identity_dashboard.Rmd`:

```r
# Current: Indigo/violet theme
colors_main <- c("#6366f1", "#8b5cf6", "#a78bfa", "#c4b5fd")

# Your custom colors:
colors_main <- c("color1", "color2", "color3", "color4")
```

### Modify Simulation Parameters

Edit in `R/data_generation.R`:

```r
# Current: 24 months, 2 groups
n_days <- 730
groups <- c("Group_A", "Group_B")

# Your parameters:
n_days <- 365  # 12 months
groups <- c("Group_1", "Group_2", "Group_3")  # Add groups
```

### Add New Variables

In `R/data_generation.R`, add to the data generation pipeline:

```r
data <- data %>%
  mutate(
    your_new_variable = # your calculation here
  )
```

## 📈 Next Steps

### 1. GitHub Setup

```bash
cd identity-threat-research
git init
git add .
git commit -m "Initial commit: Identity threat research framework"
git remote add origin https://github.com/yourusername/identity-threat-research.git
git push -u origin main
```

### 2. Update Contact Information

Edit these files:
- `README.md` - Add your name, email, LinkedIn
- `methodology.md` - Update author information
- `data/simulated_data_description.md` - Add your contact details

### 3. Create GitHub Repository Description

Use this text:

```
Bayesian framework for modeling identity threat dynamics, belief formation, 
and credibility perception. Includes interactive dashboard, forecasting models, 
and anomaly detection. Built with R + flexdashboard.

Topics: bayesian-statistics, time-series, forecasting, anomaly-detection, 
social-systems, data-science, r-stats, reproducible-research
```

### 4. LinkedIn Post (Optional)

See the `linkedin-bitcoin-post.txt` files for templates on how to announce this project.

## 🐛 Troubleshooting

### "Package not found" error

```r
# Check your R version
R.version

# Must be R 4.0+
# Update if needed from: https://cran.r-project.org/
```

### "Prophet installation failed"

```r
# Prophet requires additional dependencies
# On Mac:
install.packages("prophet", type = "source")

# On Windows: Install Rtools first
# https://cran.r-project.org/bin/windows/Rtools/
```

### "Dashboard won't knit"

```r
# Check all packages are installed
required_packages <- c("tidyverse", "plotly", "flexdashboard", 
                       "prophet", "isotree", "DT", "lubridate", 
                       "slider", "broom")

missing <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if(length(missing)) {
  install.packages(missing)
}
```

### "Data generation is slow"

```r
# Reduce time period for testing:
n_days <- 180  # 6 months instead of 24

# Or reduce forecast horizon:
horizon = 30  # Instead of 90 days
```

## 📚 Learning Resources

### Bayesian Statistics
- "Statistical Rethinking" by Richard McElreath
- Bayesian Data Analysis by Gelman et al.

### Time Series Forecasting
- Prophet documentation: facebook.github.io/prophet
- "Forecasting: Principles and Practice" by Hyndman

### R Dashboard Development
- flexdashboard documentation: rmarkdown.rstudio.com/flexdashboard
- Plotly for R: plotly.com/r

## ✨ Tips for Portfolio Presentation

1. **Lead with the dashboard** - Visual impact matters
2. **Emphasize methodology** - Show your thinking process
3. **Highlight versatility** - Applicable across domains
4. **Document assumptions** - Shows intellectual honesty
5. **Make it interactive** - Let viewers explore the data

## 🤝 Contributing

This is your research project, but if you want to make it open source:

1. Add a LICENSE file (MIT recommended)
2. Create CONTRIBUTING.md with guidelines
3. Add CHANGELOG.md for version tracking
4. Use GitHub Issues for feature requests
5. Tag releases (v1.0, v1.1, etc.)

## 📞 Support

For questions about this repository setup:
- Open a GitHub Issue
- Email: your.email@example.com
- LinkedIn: your-linkedin-profile

---

**Built with**: R 4.x, flexdashboard, plotly, prophet, tidyverse

**Status**: Research Framework / Portfolio Project

**License**: [Add your chosen license]

**Last Updated**: February 14, 2026
