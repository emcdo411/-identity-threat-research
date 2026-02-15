# Methodology

## Overview

This document provides detailed explanation of the modeling approach, simulation design, statistical methods, and limitations of the Identity Threat Dynamics research framework.

## 1. Simulation Design

### 1.1 Rationale for Simulated Data

This research uses **simulated longitudinal data** rather than observational data for several reasons:

1. **Construct Validity**: The framework models theoretical constructs (identity threat, institutional response speed) that are difficult to measure directly in real-world data without significant operationalization challenges.

2. **Controlled Experiments**: Simulation allows precise manipulation of causal relationships to test theoretical predictions without confounding factors.

3. **Reproducibility**: Simulated data ensures exact reproducibility across research environments and time periods.

4. **Privacy and Ethics**: Modeling sensitive group dynamics without risk of identifying or harming real individuals or communities.

5. **Framework Demonstration**: The goal is to demonstrate a **methodological framework** that can be calibrated to real-world data in domain-specific applications.

### 1.2 Data Generation Process

#### Time Period
- **Duration**: 24 months (730 days)
- **Granularity**: Daily observations
- **Total observations**: ~1,460 (730 days × 2 groups)

#### Core Variables

**Date** (`date`)
- Sequential daily timestamps
- Enables time-series analysis and temporal pattern detection

**Group** (`group`)
- Binary categorical: Group_A, Group_B
- Represents opposing identity-based coalitions
- Deliberately neutral labels to avoid political bias

**Media Intensity Index** (`media_intensity_index`)
- Range: 0-100
- Cyclical pattern with 90-day periodicity
- Random noise (SD = 10)
- Represents aggregate media attention and coverage volume

**Identity Threat Index** (`identity_threat_index`)
- Range: 0-100
- Correlated with media intensity (r ≈ 0.6)
- Group-specific baselines (Group_A: 45, Group_B: 50)
- Occasional shock events (+20 point spikes)
- Represents perceived existential threat to group identity

**Emotional Rhetoric Score** (`emotional_rhetoric_score`)
- Range: 0-100
- Driven by: identity threat (β ≈ 0.4) + media intensity (β ≈ 0.2)
- Group convergence over time (escalation symmetry)
- Represents affective language intensity in discourse

**Rationalization Score** (`rationalization_score`)
- Range: 0-100
- Lagged response to emotional rhetoric (7-day lag)
- Dampening factor (0.7) to prevent runaway escalation
- Represents post-hoc justification of emotional responses

**Institutional Response Speed** (`institutional_response_speed`)
- Range: 0-100
- Delayed institutional reactions (14-day lag relative to threat)
- Autocorrelated (AR(1) process, φ = 0.8)
- Represents speed and decisiveness of institutional interventions

**Perceived Credibility Score** (`perceived_credibility_score`)
- Range: 0-100
- **Critically**: Only weakly correlated with evidence strength (r ≈ 0.3)
- Strongly influenced by institutional response (β ≈ 0.5)
- Group-specific biases
- Represents subjective assessment of narrative trustworthiness

**Narrative Stability Index** (`narrative_stability_index`)
- Range: 0-100
- Inverse function of emotional rhetoric volatility
- Positively influenced by institutional response speed
- Represents coherence and consistency of group narrative

**Evidence Strength** (`evidence_strength`)
- Range: 0-100
- Independent random variable (uniform distribution)
- **Key feature**: Decoupled from perceived credibility
- Represents objective quality of factual support

**Event Marker** (`event_marker`)
- Binary: 0 or 1
- Flags major shock events (n ≈ 12 over 24 months)
- Used for anomaly detection and event study analysis

### 1.3 Causal Assumptions

The simulation embeds the following causal structure:

```
Media Intensity → Identity Threat → Emotional Rhetoric → Rationalization
                                           ↓
                              Institutional Response (lagged)
                                           ↓
                    Perceived Credibility (weakly linked to Evidence)
                                           ↓
                              Narrative Stability
```

**Key theoretical claims**:

1. **Threat-Rhetoric Link**: Identity threat is the primary driver of emotional rhetoric, not evidence quality.

2. **Credibility-Evidence Decoupling**: Perceived credibility can rise independent of evidence strength when institutional signals are strong.

3. **Escalation Symmetry**: Opposing groups converge in rhetoric escalation patterns over time, despite asymmetric threat baselines.

4. **Institutional Lag Effects**: Institutional responses influence outcomes, but with substantial time delays.

## 2. Forecasting Methods

### 2.1 Prophet Model

For time-series forecasting, we use Facebook's Prophet algorithm:

- **Decomposition**: Trend + Seasonal + Holiday + Error
- **Trend modeling**: Piecewise linear with automatic changepoint detection
- **Seasonality**: Fourier series for cyclical patterns
- **Forecast horizon**: 90 days forward
- **Uncertainty intervals**: 80% credible intervals

**Variables forecasted**:
- Emotional rhetoric score
- Identity threat index
- Perceived credibility score

**Rationale**: Prophet is robust to missing data, handles trend shifts well, and provides intuitive uncertainty quantification.

### 2.2 Alternative: ARIMA

For users without Prophet, ARIMA models are provided:

- **Model selection**: Auto-ARIMA with AIC optimization
- **Differencing**: Automatic stationarity transformation
- **Forecast horizon**: 90 days
- **Uncertainty**: Standard forecast confidence intervals

## 3. Anomaly Detection

### 3.1 Isolation Forest Approach

We use the **isotree** package for multivariate anomaly detection:

**Algorithm**:
1. Build ensemble of isolation trees
2. Calculate anomaly score based on path length
3. Flag observations with score > threshold (95th percentile)

**Features used**:
- Emotional rhetoric score
- Identity threat index
- Institutional response speed
- Perceived credibility score

**Rationale**: Isolation Forest is effective for high-dimensional anomaly detection without requiring distributional assumptions.

### 3.2 Univariate Spike Detection

For single-variable anomalies, we use **z-score thresholding**:

- Compute rolling mean and SD (30-day window)
- Flag values > 3 SD from rolling mean
- Effective for detecting rhetoric surges or credibility jumps

### 3.3 STL Decomposition

Seasonal-Trend decomposition using Loess (STL):

- Separate trend, seasonal, and remainder components
- Flag large remainder values as anomalies
- Useful for detecting deviations from expected seasonal patterns

## 4. Bayesian Belief Updating Model

### 4.1 Conceptual Framework

The Bayesian model formalizes how **perceived credibility** updates over time given:

1. **Prior belief** (P(H)): Initial credibility assessment
2. **Evidence likelihood** (P(E|H)): How evidence affects belief given hypothesis
3. **Institutional weight** (w): Multiplier for institutional signal strength
4. **Posterior belief** (P(H|E)): Updated credibility after observing evidence

### 4.2 Model Specification

**Simplified Bayesian Update**:

```
Posterior ∝ Prior × Likelihood × Institutional_Weight

Where:
- Prior ~ Beta(α, β)  [initial belief distribution]
- Likelihood ~ f(Evidence_Strength)
- Institutional_Weight ~ f(Response_Speed)
```

**Implementation**:

We use a **simplified Bayesian updating simulation** rather than full MCMC:

1. Initialize prior distribution for each group (Beta(5, 5) = neutral)
2. For each time period:
   - Compute likelihood based on evidence strength
   - Apply institutional weight multiplier
   - Update posterior using Bayes' rule
   - Posterior becomes prior for next period

**Visualization**:
- Prior vs. posterior distributions over time
- Belief trajectory curves showing convergence/divergence
- Credibility weight influence on belief shifts

### 4.3 Alternative: Full Bayesian Implementation

For advanced users, the framework supports **rstanarm** or **brms** for full Bayesian regression:

```r
# Hierarchical model
credibility ~ evidence_strength + institutional_response + (1|group) + (1|date)
```

This allows:
- Proper uncertainty quantification
- Hierarchical effects by group
- Time-varying coefficients

### 4.4 Key Assumptions

1. **Independence**: Evidence observations are conditionally independent given hypothesis
2. **Stationarity**: Prior distributions are stable within short time windows
3. **Rationality**: Agents update beliefs according to Bayes' rule (descriptive, not normative)
4. **Credibility-Evidence Link**: Likelihood function correctly maps evidence to belief

**Limitations**:
- Real belief updating may violate Bayesian rationality
- Institutional weight is modeled linearly (may be non-linear)
- Model doesn't capture motivated reasoning or confirmation bias explicitly

## 5. Statistical Methods

### 5.1 Cross-Correlation Analysis

To detect lagged relationships:

```r
ccf(threat_index, rhetoric_score, lag.max = 30)
```

Tests temporal precedence (does threat predict rhetoric, or vice versa?).

### 5.2 Rolling Window Statistics

For trend detection and smoothing:

- **Window size**: 7-day, 30-day
- **Metrics**: Mean, SD, min, max
- **Purpose**: Reduce noise, identify sustained patterns

### 5.3 Group Comparison Tests

To test convergence/divergence hypotheses:

- **Early period** (months 1-6) vs. **late period** (months 19-24)
- Welch's t-test for mean differences
- Levene's test for variance homogeneity

### 5.4 Regression Models

Institutional response effects:

```r
lm(narrative_stability ~ institutional_response_speed + lag(institutional_response_speed, 7))
```

Tests contemporaneous and lagged effects.

## 6. Limitations and Caveats

### 6.1 Simulation Limitations

1. **Simplified Dynamics**: Real-world social systems have far more complexity (network effects, individual heterogeneity, external shocks).

2. **Linear Relationships**: Most relationships are modeled linearly; real dynamics may be non-linear or threshold-based.

3. **Binary Groups**: Reduces multi-dimensional ideological space to two groups.

4. **No Network Structure**: Ignores social influence networks and information diffusion patterns.

5. **Aggregate-Level Only**: No individual-level heterogeneity or agent-based dynamics.

### 6.2 Measurement Challenges

In real-world applications:

- **Identity Threat**: Difficult to measure objectively; often conflated with self-reports
- **Emotional Rhetoric**: Requires sophisticated NLP; sentiment analysis is noisy
- **Institutional Response Speed**: What counts as a "response"? Multiple overlapping institutions?
- **Evidence Strength**: Who adjudicates "objective" evidence quality?

### 6.3 External Validity

This framework is a **proof of concept**. Applying it to real cases requires:

1. Domain-specific operationalization of constructs
2. Validation against ground truth data where available
3. Calibration of parameters based on empirical estimates
4. Sensitivity analysis for model assumptions

### 6.4 Causal Inference

Simulation allows testing causal hypotheses, but:

- Real-world causal identification requires natural experiments, instrumental variables, or randomized designs
- Confounding is pervasive in observational data
- This framework demonstrates potential causal mechanisms, not proven causal effects

## 7. Future Extensions

### 7.1 Methodological

- **Agent-based modeling**: Individual-level heterogeneity
- **Network analysis**: Social influence and information diffusion
- **Non-linear dynamics**: Threshold effects and tipping points
- **Reinforcement learning**: Adaptive institutional response strategies

### 7.2 Domain-Specific Applications

- **Public health crises**: Vaccine hesitancy and institutional trust
- **Political polarization**: Election integrity narratives
- **Corporate crises**: Brand reputation and stakeholder trust
- **International relations**: State legitimacy and propaganda

### 7.3 Integration with Real Data

- Calibration with social media text data (Twitter, Reddit)
- Survey data for validation (Pew, Gallup)
- Event databases for institutional response timing
- Media content analysis for intensity metrics

## 8. Conclusion

This methodology balances theoretical rigor with practical applicability. The simulation design is deliberately simplified to highlight core dynamics while remaining extensible for real-world calibration.

The Bayesian belief model provides a formal framework for understanding how credibility perception diverges from evidence quality—a critical dynamic in contemporary information ecosystems.

The forecasting and anomaly detection layers add predictive and diagnostic capabilities, making this framework useful for both research and applied decision-making contexts.

---

**For questions about methodology or replication**: See contact information in README.md
