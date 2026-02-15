# ==============================================================================
# DATA GENERATION FOR IDENTITY THREAT DYNAMICS SIMULATION
# ==============================================================================
# Purpose: Generate simulated time-series data modeling identity threat,
#          emotional rhetoric, institutional response, and credibility perception
# Based on: identity_dashboard_CHIEF_DS_ENHANCED.Rmd
# ==============================================================================

library(tidyverse)
library(lubridate)
library(slider)

# Set reproducible seed
set.seed(42)

# ==============================================================================
# CONFIGURATION PARAMETERS
# ==============================================================================

# Time parameters
n_days <- 730
start_date <- as.Date("2024-03-01")
groups <- c("Group_A", "Group_B")
dates <- seq.Date(start_date, by = "day", length.out = n_days)

# Shock event parameters
n_shock_events <- 12
shock_intensity <- 20
shock_decay_rate <- 7  # days for exponential decay

# AR(1) parameters for institutional response
ar1_phi <- 0.8
ar1_baseline <- 55
ar1_noise_sd <- 12

# ==============================================================================
# CORE GENERATION FUNCTIONS
# ==============================================================================

#' Generate Cyclical Pattern with Noise
#' 
#' Creates sinusoidal pattern representing periodic phenomena (e.g., media cycles)
#' 
#' @param n Number of observations
#' @param period Cycle period in days (default: 90)
#' @param amplitude Amplitude of sine wave (default: 20)
#' @param baseline Baseline value (default: 50)
#' @param noise_sd Standard deviation of Gaussian noise (default: 10)
#' @return Numeric vector of length n bounded [0, 100]
generate_cyclical <- function(n, period = 90, amplitude = 20, baseline = 50, noise_sd = 10) {
  cycle <- baseline + amplitude * sin(2 * pi * seq(1, n) / period)
  noise <- rnorm(n, mean = 0, sd = noise_sd)
  # Bound to [0, 100]
  pmax(0, pmin(100, cycle + noise))
}


#' Generate Shock Events with Exponential Decay
#' 
#' Simulates discrete shock events (e.g., cultural flashpoints) with exponential decay
#' 
#' @param n Number of days
#' @param n_events Number of shock events to generate
#' @param intensity Base intensity of shock events
#' @param decay_rate Decay rate for exponential function (days)
#' @return List with 'markers' (binary event indicators) and 'effect' (decaying impact)
generate_events <- function(n, n_events = 12, intensity = 20, decay_rate = 7) {
  # Binary event markers
  events <- rep(0, n)
  # Place events randomly, avoiding first/last 50 days
  event_days <- sample(50:(n-50), n_events)
  events[event_days] <- 1
  
  # Calculate decaying effect of each event
  event_effect <- rep(0, n)
  for (day in event_days) {
    decay_window <- 1:14  # 2-week impact window
    if (day + 14 <= n) {
      # Exponential decay: intensity * exp(-days / decay_rate)
      event_effect[day + decay_window] <- intensity * exp(-decay_window / decay_rate)
    }
  }
  
  list(markers = events, effect = event_effect)
}


#' Generate AR(1) Time Series
#' 
#' Creates autoregressive process of order 1 for persistent time series
#' (e.g., institutional response that depends on previous state)
#' 
#' @param n Number of observations
#' @param phi Autoregressive coefficient (persistence, default: 0.8)
#' @param baseline Mean-reversion baseline (default: 50)
#' @param noise_sd Standard deviation of innovation noise (default: 15)
#' @return Numeric vector of length n bounded [0, 100]
generate_ar1 <- function(n, phi = 0.8, baseline = 50, noise_sd = 15) {
  x <- numeric(n)
  x[1] <- baseline
  
  for (i in 2:n) {
    # AR(1): x_t = baseline * (1 - phi) + phi * x_{t-1} + noise
    x[i] <- baseline * (1 - phi) + phi * x[i-1] + rnorm(1, 0, noise_sd)
  }
  
  # Bound to [0, 100]
  pmax(0, pmin(100, x))
}


# ==============================================================================
# GENERATE BASE PATTERNS
# ==============================================================================

#' Generate Complete Identity Threat Dataset
#' 
#' Creates full simulated dataset with all key variables
#' 
#' @return Tibble with identity threat dynamics data
generate_identity_threat_data <- function() {
  
  # Generate base patterns
  media_intensity <- generate_cyclical(
    n_days, 
    period = 90, 
    amplitude = 25, 
    baseline = 50, 
    noise_sd = 12
  )
  
  events_list <- generate_events(
    n_days, 
    n_events = n_shock_events, 
    intensity = shock_intensity,
    decay_rate = shock_decay_rate
  )
  
  event_markers <- events_list$markers
  event_effect <- events_list$effect
  
  institutional_base <- generate_ar1(
    n_days, 
    phi = ar1_phi, 
    baseline = ar1_baseline, 
    noise_sd = ar1_noise_sd
  )
  
  # ===========================================================================
  # CREATE MAIN DATASET
  # ===========================================================================
  
  data <- expand_grid(date = dates, group = groups) %>%
    arrange(date, group) %>%
    mutate(
      # Media intensity (same for both groups)
      media_intensity_index = rep(media_intensity, each = 2),
      
      # Event markers (same for both groups)
      event_marker = rep(event_markers, each = 2),
      
      # Identity Threat Index
      # Function: baseline + 0.3-0.35 * media + event_effect + noise
      # Group B has slightly higher baseline and media sensitivity
      identity_threat_index = case_when(
        group == "Group_A" ~ 40 + 0.30 * media_intensity_index + 
                             rep(event_effect, each = 2) + rnorm(n(), 0, 8),
        group == "Group_B" ~ 48 + 0.35 * media_intensity_index + 
                             rep(event_effect, each = 2) + rnorm(n(), 0, 8)
      ),
      
      # Time index for convergence factor
      time_index = as.numeric(date - min(date)) / max(as.numeric(date - min(date))),
      convergence_factor = 1 - 0.4 * time_index,
      
      # Emotional Rhetoric Score
      # Function: baseline + 0.4-0.45 * threat + 0.2-0.25 * media + noise
      emotional_rhetoric_score = case_when(
        group == "Group_A" ~ 30 + 0.45 * identity_threat_index + 
                             0.25 * media_intensity_index + 
                             convergence_factor * rnorm(n(), 0, 10),
        group == "Group_B" ~ 35 + 0.40 * identity_threat_index + 
                             0.20 * media_intensity_index + 
                             convergence_factor * rnorm(n(), 0, 10)
      )
    ) %>%
    mutate(
      institutional_base_rep = rep(institutional_base, each = 2)
    ) %>%
    
    # ===========================================================================
    # LAGGED VARIABLES AND DERIVED METRICS
    # ===========================================================================
    
    group_by(group) %>%
    mutate(
      # 7-day lag: Emotional rhetoric → Rationalization
      emotional_rhetoric_lagged = lag(emotional_rhetoric_score, 7),
      rationalization_score = 0.7 * emotional_rhetoric_lagged + rnorm(n(), 0, 8),
      
      # 14-day lag: Identity threat → Institutional response
      threat_lagged = lag(identity_threat_index, 14),
      institutional_response_speed = institutional_base_rep + 
                                     0.2 * threat_lagged + 
                                     rnorm(n(), 0, 8),
      
      # Evidence strength (uniform random - orthogonal to threat)
      evidence_strength = runif(n(), 20, 80),
      
      # Perceived Credibility (THE KEY EQUATION)
      # Function: 35 + 0.15 * evidence + 0.50 * institutional_response + group_bias
      # NOTE: Institutional response weighted 3.3x more than evidence (0.50 vs 0.15)
      perceived_credibility_score = 35 + 
                                   0.15 * evidence_strength + 
                                   0.50 * institutional_response_speed +
                                   case_when(
                                     group == "Group_A" ~ 5,
                                     group == "Group_B" ~ -3
                                   ) + 
                                   rnorm(n(), 0, 10),
      
      # Rhetoric volatility (rolling SD)
      rhetoric_volatility = slider::slide_dbl(
        emotional_rhetoric_score, 
        ~sd(.x, na.rm = TRUE), 
        .before = 6, 
        .after = 0, 
        .complete = FALSE
      ),
      
      # Narrative Stability Index
      # Function: 70 - 0.3 * volatility + 0.3 * institutional_response
      narrative_stability_index = 70 - 
                                 0.3 * rhetoric_volatility + 
                                 0.3 * institutional_response_speed + 
                                 rnorm(n(), 0, 8)
    ) %>%
    ungroup() %>%
    
    # Bound all scores to [0, 100]
    mutate(across(
      c(identity_threat_index, emotional_rhetoric_score, rationalization_score,
        institutional_response_speed, perceived_credibility_score, 
        narrative_stability_index, media_intensity_index),
      ~pmax(0, pmin(100, .x))
    )) %>%
    
    # Clean up temporary variables
    select(-time_index, -convergence_factor, -emotional_rhetoric_lagged, 
           -threat_lagged, -rhetoric_volatility, -institutional_base_rep)
  
  return(data)
}


# ==============================================================================
# EXECUTE DATA GENERATION
# ==============================================================================

if (interactive()) {
  cat("Generating identity threat dynamics data...\n")
  data <- generate_identity_threat_data()
  cat("Data generated successfully.\n")
  cat("Total observations:", nrow(data), "\n")
  cat("Date range:", min(data$date), "to", max(data$date), "\n")
  cat("\nKey variables:\n")
  cat("- identity_threat_index\n")
  cat("- emotional_rhetoric_score\n")
  cat("- rationalization_score\n")
  cat("- institutional_response_speed\n")
  cat("- evidence_strength\n")
  cat("- perceived_credibility_score (0.15*evidence + 0.50*institutional)\n")
  cat("- narrative_stability_index\n")
}


# ==============================================================================
# EXPORT FUNCTION
# ==============================================================================

#' Save Generated Data
#' 
#' @param data Data frame to save
#' @param filepath Path to save CSV (default: "data/identity_threat_data.csv")
save_identity_data <- function(data, filepath = "data/identity_threat_data.csv") {
  dir.create(dirname(filepath), showWarnings = FALSE, recursive = TRUE)
  write_csv(data, filepath)
  cat("Data saved to:", filepath, "\n")
}
