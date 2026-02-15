# ==============================================================================
# BAYESIAN BELIEF UPDATING MODEL FOR IDENTITY THREAT
# ==============================================================================
# Purpose: Model how credibility beliefs update in response to evidence
#          under conditions of identity threat using Bayesian framework
# ==============================================================================

library(tidyverse)

# ==============================================================================
# BAYESIAN BELIEF UPDATING FRAMEWORK
# ==============================================================================

#' Bayesian Belief Update
#' 
#' Models how prior beliefs about credibility update given evidence,
#' weighted by identity threat and institutional signals
#' 
#' Core equation: Posterior ∝ Prior × Likelihood(Evidence | Threat, Institution)
#' 
#' @param prior_mean Prior belief about credibility (0-100)
#' @param prior_sd Uncertainty in prior belief (default: 15)
#' @param evidence_strength Quality of evidence (0-100)
#' @param identity_threat_level Identity threat index (0-100)
#' @param institutional_signal Institutional response strength (0-100)
#' @param evidence_weight Base weight for evidence (default: 0.15)
#' @param institution_weight Base weight for institution (default: 0.50)
#' @param threat_modulation How threat modulates evidence weight (default: -0.01)
#' @return List with posterior distribution parameters
bayesian_update <- function(prior_mean,
                           prior_sd = 15,
                           evidence_strength,
                           identity_threat_level,
                           institutional_signal,
                           evidence_weight = 0.15,
                           institution_weight = 0.50,
                           threat_modulation = -0.01) {
  
  # Threat modulates evidence weighting
  # Higher threat → lower evidence weight (evidence-credibility decoupling)
  adjusted_evidence_weight <- evidence_weight + 
                             (threat_modulation * identity_threat_level)
  adjusted_evidence_weight <- max(0.01, adjusted_evidence_weight)  # Floor at 0.01
  
  # Threat amplifies institutional signal importance
  adjusted_institution_weight <- institution_weight + 
                                 (0.005 * identity_threat_level)
  adjusted_institution_weight <- min(0.80, adjusted_institution_weight)  # Ceiling at 0.80
  
  # Likelihood: How much should belief shift based on evidence + institution?
  evidence_pull <- adjusted_evidence_weight * evidence_strength
  institution_pull <- adjusted_institution_weight * institutional_signal
  
  # Total pull toward new information
  total_pull <- evidence_pull + institution_pull
  total_weight <- adjusted_evidence_weight + adjusted_institution_weight
  
  # Posterior mean: weighted combination of prior and likelihood
  # Higher total_weight = more updating from data
  # Lower total_weight = more staying with prior
  precision_prior <- 1 / (prior_sd^2)
  precision_likelihood <- total_weight / 100  # Normalize
  
  posterior_precision <- precision_prior + precision_likelihood
  posterior_sd <- sqrt(1 / posterior_precision)
  
  posterior_mean <- (precision_prior * prior_mean + 
                    precision_likelihood * total_pull) / posterior_precision
  
  # Bound to [0, 100]
  posterior_mean <- pmax(0, pmin(100, posterior_mean))
  
  # Belief shift
  belief_shift <- posterior_mean - prior_mean
  
  # Return results
  list(
    posterior_mean = posterior_mean,
    posterior_sd = posterior_sd,
    belief_shift = belief_shift,
    adjusted_evidence_weight = adjusted_evidence_weight,
    adjusted_institution_weight = adjusted_institution_weight,
    evidence_pull = evidence_pull,
    institution_pull = institution_pull,
    evidence_dominance = evidence_pull > institution_pull
  )
}


#' Simulate Belief Evolution Over Time
#' 
#' Models how beliefs evolve as person encounters multiple pieces of evidence
#' under varying identity threat conditions
#' 
#' @param n_observations Number of evidence encounters
#' @param initial_belief Starting credibility belief (default: 50)
#' @param initial_uncertainty Starting uncertainty (default: 20)
#' @param evidence_quality Mean evidence quality (default: 60)
#' @param evidence_variability SD of evidence quality (default: 15)
#' @param threat_trajectory Function of time returning threat level
#' @param institutional_trajectory Function of time returning institutional signal
#' @return Tibble with belief evolution trajectory
simulate_belief_evolution <- function(n_observations,
                                     initial_belief = 50,
                                     initial_uncertainty = 20,
                                     evidence_quality = 60,
                                     evidence_variability = 15,
                                     threat_trajectory = function(t) 50,
                                     institutional_trajectory = function(t) 50) {
  
  # Initialize
  results <- tibble(
    time = 1:n_observations,
    prior_mean = numeric(n_observations),
    posterior_mean = numeric(n_observations),
    posterior_sd = numeric(n_observations),
    evidence_strength = numeric(n_observations),
    identity_threat = numeric(n_observations),
    institutional_signal = numeric(n_observations),
    belief_shift = numeric(n_observations),
    evidence_weight_used = numeric(n_observations),
    institution_weight_used = numeric(n_observations)
  )
  
  current_belief <- initial_belief
  current_uncertainty <- initial_uncertainty
  
  # Simulate sequential belief updates
  for (t in 1:n_observations) {
    
    # Generate evidence and context
    evidence <- rnorm(1, evidence_quality, evidence_variability)
    evidence <- pmax(0, pmin(100, evidence))
    
    threat <- threat_trajectory(t)
    institution <- institutional_trajectory(t)
    
    # Record prior
    results$prior_mean[t] <- current_belief
    results$evidence_strength[t] <- evidence
    results$identity_threat[t] <- threat
    results$institutional_signal[t] <- institution
    
    # Bayesian update
    update <- bayesian_update(
      prior_mean = current_belief,
      prior_sd = current_uncertainty,
      evidence_strength = evidence,
      identity_threat_level = threat,
      institutional_signal = institution
    )
    
    # Record posterior
    results$posterior_mean[t] <- update$posterior_mean
    results$posterior_sd[t] <- update$posterior_sd
    results$belief_shift[t] <- update$belief_shift
    results$evidence_weight_used[t] <- update$adjusted_evidence_weight
    results$institution_weight_used[t] <- update$adjusted_institution_weight
    
    # Update for next iteration
    current_belief <- update$posterior_mean
    current_uncertainty <- update$posterior_sd
  }
  
  return(results)
}


# ==============================================================================
# IDENTITY THREAT SCENARIOS
# ==============================================================================

#' Constant Low Threat Scenario
#' 
#' Baseline: minimal identity threat, rational belief updating
constant_low_threat <- function(t) 20

#' Constant High Threat Scenario
#' 
#' Sustained identity threat, evidence-credibility decoupling
constant_high_threat <- function(t) 80

#' Shock Event Scenario
#' 
#' Sudden threat spike (e.g., Bad Bunny moment) with exponential decay
shock_event_threat <- function(t, shock_time = 10, intensity = 80, decay_rate = 5) {
  if (t < shock_time) {
    return(20)  # Baseline before shock
  } else {
    # Exponential decay after shock
    days_since_shock <- t - shock_time
    threat <- 20 + intensity * exp(-days_since_shock / decay_rate)
    return(threat)
  }
}

#' Escalating Threat Scenario
#' 
#' Gradual increase in threat (e.g., polarization over time)
escalating_threat <- function(t, max_threat = 90, rate = 0.5) {
  threat <- 20 + (max_threat - 20) * (1 - exp(-rate * t / 10))
  return(threat)
}


# ==============================================================================
# INSTITUTIONAL SIGNAL PATTERNS
# ==============================================================================

#' Responsive Institution
#' 
#' Institution responds proportionally to threat
responsive_institution <- function(t, threat_fn) {
  threat <- threat_fn(t)
  signal <- 30 + 0.6 * threat  # Amplifies threat
  return(pmin(100, signal))
}

#' Delayed Institution
#' 
#' Institution responds with lag (e.g., 14-day delay)
delayed_institution <- function(t, threat_fn, delay = 14) {
  if (t <= delay) {
    return(40)  # Baseline
  } else {
    threat <- threat_fn(t - delay)
    signal <- 30 + 0.6 * threat
    return(pmin(100, signal))
  }
}

#' Absent Institution
#' 
#' Institution provides no signal (allows evidence to dominate)
absent_institution <- function(t) 30


# ==============================================================================
# COMPARATIVE SCENARIOS
# ==============================================================================

#' Compare Belief Evolution Across Scenarios
#' 
#' @param n_obs Number of observations
#' @param scenarios Named list of threat trajectory functions
#' @return Tibble with all scenarios combined
compare_scenarios <- function(n_obs = 50, scenarios = NULL) {
  
  if (is.null(scenarios)) {
    # Default comparison scenarios
    scenarios <- list(
      "Low Threat" = constant_low_threat,
      "High Threat" = constant_high_threat,
      "Shock Event" = function(t) shock_event_threat(t, shock_time = 10),
      "Escalating" = escalating_threat
    )
  }
  
  results <- map_dfr(names(scenarios), function(scenario_name) {
    threat_fn <- scenarios[[scenario_name]]
    
    sim <- simulate_belief_evolution(
      n_observations = n_obs,
      threat_trajectory = threat_fn,
      institutional_trajectory = function(t) responsive_institution(t, threat_fn)
    )
    
    sim %>% mutate(scenario = scenario_name)
  })
  
  return(results)
}


# ==============================================================================
# VISUALIZATION FUNCTIONS
# ==============================================================================

#' Plot Belief Evolution
#' 
#' @param data Tibble from simulate_belief_evolution
#' @return ggplot object
plot_belief_evolution <- function(data) {
  
  ggplot(data, aes(x = time)) +
    geom_line(aes(y = posterior_mean, color = "Belief"), size = 1) +
    geom_ribbon(
      aes(ymin = posterior_mean - posterior_sd, 
          ymax = posterior_mean + posterior_sd),
      alpha = 0.2, fill = "#3498db"
    ) +
    geom_line(aes(y = evidence_strength, color = "Evidence"), 
              linetype = "dashed", alpha = 0.6) +
    geom_line(aes(y = identity_threat, color = "Threat"), 
              linetype = "dotted", alpha = 0.6) +
    scale_color_manual(
      values = c("Belief" = "#3498db", "Evidence" = "#2ecc71", "Threat" = "#e74c3c")
    ) +
    labs(
      title = "Bayesian Belief Evolution Under Identity Threat",
      x = "Time",
      y = "Value (0-100)",
      color = NULL
    ) +
    theme_minimal() +
    theme(legend.position = "bottom")
}


#' Plot Evidence vs Institution Weights Over Time
#' 
#' @param data Tibble from simulate_belief_evolution
#' @return ggplot object
plot_weight_evolution <- function(data) {
  
  data_long <- data %>%
    select(time, evidence_weight_used, institution_weight_used) %>%
    pivot_longer(
      cols = c(evidence_weight_used, institution_weight_used),
      names_to = "weight_type",
      values_to = "weight"
    ) %>%
    mutate(
      weight_type = case_when(
        weight_type == "evidence_weight_used" ~ "Evidence Weight",
        weight_type == "institution_weight_used" ~ "Institution Weight"
      )
    )
  
  ggplot(data_long, aes(x = time, y = weight, color = weight_type)) +
    geom_line(size = 1) +
    scale_color_manual(values = c("Evidence Weight" = "#2ecc71", 
                                  "Institution Weight" = "#e74c3c")) +
    labs(
      title = "Evidence-Credibility Decoupling Over Time",
      subtitle = "How identity threat modulates evidence vs. institutional weighting",
      x = "Time",
      y = "Weight Coefficient",
      color = NULL
    ) +
    theme_minimal() +
    theme(legend.position = "bottom")
}


#' Plot Scenario Comparison
#' 
#' @param data Tibble from compare_scenarios
#' @return ggplot object
plot_scenario_comparison <- function(data) {
  
  ggplot(data, aes(x = time, y = posterior_mean, color = scenario)) +
    geom_line(size = 1) +
    labs(
      title = "Belief Evolution Across Identity Threat Scenarios",
      x = "Time",
      y = "Posterior Credibility Belief",
      color = "Scenario"
    ) +
    theme_minimal() +
    theme(legend.position = "bottom")
}


# ==============================================================================
# EXAMPLE USAGE
# ==============================================================================

if (interactive()) {
  cat("Bayesian Belief Updating Model Loaded\n")
  cat("Available functions:\n")
  cat("- bayesian_update(): Single belief update given evidence and threat\n")
  cat("- simulate_belief_evolution(): Model belief trajectory over time\n")
  cat("- compare_scenarios(): Compare multiple threat scenarios\n")
  cat("\nThreat trajectory functions:\n")
  cat("- constant_low_threat()\n")
  cat("- constant_high_threat()\n")
  cat("- shock_event_threat()\n")
  cat("- escalating_threat()\n")
  cat("\nVisualization functions:\n")
  cat("- plot_belief_evolution()\n")
  cat("- plot_weight_evolution()\n")
  cat("- plot_scenario_comparison()\n")
  cat("\nExample:\n")
  cat("sim <- simulate_belief_evolution(50, threat_trajectory = shock_event_threat)\n")
  cat("plot_belief_evolution(sim)\n")
}
