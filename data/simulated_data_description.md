# Simulated Data Description

## Overview

This dataset contains simulated longitudinal observations tracking identity threat dynamics, discourse patterns, and belief formation across two groups over a 24-month period.

## Data Generation

- **Method**: Computational simulation with controlled causal relationships
- **Purpose**: Framework demonstration and methodological development
- **Random Seed**: 42 (for reproducibility)
- **Generation Script**: `R/data_generation.R`

## File Formats

- **RDS**: `data/identity_threat_data.rds` (R native format, preserves data types)
- **CSV**: `data/identity_threat_data.csv` (cross-platform compatibility)

## Schema

### Dimensions

- **Observations**: ~1,460 (730 days × 2 groups)
- **Variables**: 11 core variables + derived metrics
- **Time Period**: 24 months (daily granularity)
- **Groups**: 2 (Group_A, Group_B)

### Variables

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `date` | Date | 2024-03-01 to 2026-02-28 | Calendar date of observation |
| `group` | Factor | {Group_A, Group_B} | Identity group identifier |
| `media_intensity_index` | Numeric | 0-100 | Aggregate media attention and coverage volume |
| `identity_threat_index` | Numeric | 0-100 | Perceived existential threat to group identity |
| `emotional_rhetoric_score` | Numeric | 0-100 | Affective language intensity in discourse |
| `rationalization_score` | Numeric | 0-100 | Post-hoc justification of emotional responses |
| `institutional_response_speed` | Numeric | 0-100 | Speed and decisiveness of institutional interventions |
| `perceived_credibility_score` | Numeric | 0-100 | Subjective assessment of narrative trustworthiness |
| `narrative_stability_index` | Numeric | 0-100 | Coherence and consistency of group narrative |
| `evidence_strength` | Numeric | 0-100 | Objective quality of factual support (independent) |
| `event_marker` | Binary | {0, 1} | Indicator for major shock events |

## Key Features

### 1. Cyclical Patterns

- **Media Intensity**: 90-day cyclical pattern with random noise
- **Seasonal Effects**: Weekly patterns in institutional response

### 2. Lagged Relationships

- **Rationalization**: 7-day lag relative to emotional rhetoric
- **Institutional Response**: 14-day lag relative to threat index

### 3. Group Dynamics

- **Baseline Differences**: Groups have distinct threat baselines
- **Convergence**: Escalation patterns converge over time
- **Asymmetry**: Response patterns differ between groups

### 4. Evidence-Credibility Decoupling

- **Critical Feature**: Evidence strength is only weakly correlated (r ≈ 0.3) with perceived credibility
- **Institutional Multiplier**: Institutional response strongly influences credibility (β ≈ 0.5)

### 5. Shock Events

- **Frequency**: ~12 major events over 24 months
- **Impact**: Temporary spikes in threat index with exponential decay
- **Duration**: Effects persist for ~14 days

## Data Quality

### Completeness

- All core variables: 100% complete
- Lagged variables: First 7-14 observations NA by design
- Anomaly detection flags: Added via analysis scripts

### Known Artifacts

1. **Edge Effects**: Rolling window statistics undefined at time series boundaries
2. **Initialization Period**: First month may show startup artifacts
3. **Perfect Reproducibility**: Seeded random generation ensures identical data across runs

## Causal Structure (Simulated)

```
Media Intensity → Identity Threat → Emotional Rhetoric → Rationalization
                       ↓
          Institutional Response (lagged)
                       ↓
        Perceived Credibility (weakly linked to Evidence)
                       ↓
          Narrative Stability
```

## Limitations

As **simulated data**, this dataset:

1. ✓ Demonstrates methodological framework
2. ✓ Enables reproducible research
3. ✓ Provides controlled test environment
4. ✗ Does not represent real-world observations
5. ✗ Simplifies complex social dynamics
6. ✗ Requires domain-specific calibration for applications

## Usage Recommendations

### For Research

- Use to develop and test analytical methods
- Validate statistical models before real-world application
- Demonstrate proof-of-concept for frameworks

### For Teaching

- Illustrate causal inference challenges
- Demonstrate time-series analysis techniques
- Show Bayesian updating principles

### For Production

- **Do not use directly** for real-world decision-making
- Calibrate parameters using observational data
- Validate assumptions against domain expertise

## Citation

If using this dataset, cite:

```bibtex
@software{identity_threat_data_2026,
  title = {Identity Threat Dynamics: Simulated Dataset},
  author = {[Your Name]},
  year = {2026},
  url = {https://github.com/yourusername/identity-threat-research}
}
```

## Version History

- **v1.0** (2026-02-14): Initial release
  - 24 months of daily observations
  - 11 core variables
  - 2 groups
  - Fixed random seed (42)

## Contact

For questions about data generation or requests for modified simulation parameters:

- **Email**: erwin.mcdonald@outlook.com
- **GitHub**: github.com/emcdo411/identity-threat-research
