# ==============================================================================
# ANOMALY DETECTION FOR IDENTITY THREAT DYNAMICS
# ==============================================================================
# Purpose: Detect anomalous behavior patterns using statistical and ML methods
# Methods: Z-score, Isolation Forest, and ensemble approaches
# ==============================================================================

library(tidyverse)
library(isotree)  # Isolation forest: install.packages("isotree")
library(slider)

# ==============================================================================
# Z-SCORE ANOMALY DETECTION (TRADITIONAL METHOD)
# ==============================================================================

#' Detect Anomalies Using Rolling Z-Score
#' 
#' Traditional statistical approach: flags observations >3 SD from rolling mean
#' 
#' @param data Data frame with time series
#' @param value_col Column to analyze for anomalies (unquoted)
#' @param window Rolling window size in days (default: 30)
#' @param threshold Z-score threshold for anomaly (default: 3)
#' @param group_col Optional grouping column (unquoted)
#' @return Data frame with anomaly flags and z-scores
detect_zscore_anomalies <- function(data,
                                   value_col,
                                   window = 30,
                                   threshold = 3,
                                   group_col = NULL) {
  
  value_col_name <- deparse(substitute(value_col))
  
  if (!is.null(substitute(group_col))) {
    # Group-wise calculation
    result <- data %>%
      arrange(date, {{group_col}}) %>%
      group_by({{group_col}}) %>%
      mutate(
        rolling_mean = slider::slide_dbl(
          {{value_col}}, 
          mean, 
          .before = window, 
          .complete = FALSE,
          na.rm = TRUE
        ),
        rolling_sd = slider::slide_dbl(
          {{value_col}}, 
          sd,
          .before = window, 
          .complete = FALSE,
          na.rm = TRUE
        ),
        z_score = ({{value_col}} - rolling_mean) / rolling_sd,
        is_anomaly_zscore = abs(z_score) > threshold & !is.na(z_score)
      ) %>%
      ungroup()
  } else {
    # Overall calculation
    result <- data %>%
      arrange(date) %>%
      mutate(
        rolling_mean = slider::slide_dbl(
          {{value_col}}, 
          mean, 
          .before = window, 
          .complete = FALSE,
          na.rm = TRUE
        ),
        rolling_sd = slider::slide_dbl(
          {{value_col}}, 
          sd,
          .before = window, 
          .complete = FALSE,
          na.rm = TRUE
        ),
        z_score = ({{value_col}} - rolling_mean) / rolling_sd,
        is_anomaly_zscore = abs(z_score) > threshold & !is.na(z_score)
      )
  }
  
  n_anomalies <- sum(result$is_anomaly_zscore, na.rm = TRUE)
  pct_anomalies <- 100 * n_anomalies / nrow(result)
  
  cat("Z-Score Anomaly Detection Results:\n")
  cat("Variable:", value_col_name, "\n")
  cat("Window:", window, "days\n")
  cat("Threshold:", threshold, "SD\n")
  cat("Anomalies detected:", n_anomalies, "(", round(pct_anomalies, 2), "%)\n\n")
  
  return(result)
}


# ==============================================================================
# ISOLATION FOREST ANOMALY DETECTION (ML METHOD)
# ==============================================================================

#' Detect Anomalies Using Isolation Forest
#' 
#' Machine learning approach: detects anomalies based on multivariate patterns
#' Superior to z-score for capturing complex interactions between variables
#' 
#' @param data Data frame with features
#' @param feature_cols Character vector of column names to use as features
#' @param contamination Expected proportion of outliers (default: 0.05)
#' @param ntrees Number of trees (default: 100)
#' @param sample_size Sample size per tree (default: 256)
#' @param threshold Anomaly score threshold (default: 0.6)
#' @return Data frame with anomaly scores and flags
detect_isolation_forest_anomalies <- function(data,
                                              feature_cols,
                                              contamination = 0.05,
                                              ntrees = 100,
                                              sample_size = 256,
                                              threshold = 0.6) {
  
  cat("Isolation Forest Anomaly Detection\n")
  cat("Features:", paste(feature_cols, collapse = ", "), "\n")
  
  # Extract features and remove NA rows
  features <- data %>%
    select(all_of(feature_cols)) %>%
    na.omit()
  
  complete_idx <- complete.cases(data[, feature_cols])
  
  cat("Complete observations:", sum(complete_idx), "/", nrow(data), "\n")
  
  # Train isolation forest
  cat("Training isolation forest...\n")
  iso_model <- isolation.forest(
    features,
    ntrees = ntrees,
    sample_size = sample_size,
    seed = 42
  )
  
  # Get anomaly scores (higher = more anomalous)
  anomaly_scores <- predict(iso_model, features)
  
  # Add results to data
  result <- data
  result$iso_anomaly_score <- NA
  result$iso_anomaly_score[complete_idx] <- anomaly_scores
  result$is_anomaly_iso <- result$iso_anomaly_score > threshold
  
  # Summary statistics
  n_anomalies <- sum(result$is_anomaly_iso, na.rm = TRUE)
  pct_anomalies <- 100 * n_anomalies / sum(complete_idx)
  
  mean_score <- mean(anomaly_scores, na.rm = TRUE)
  median_score <- median(anomaly_scores, na.rm = TRUE)
  
  cat("\nResults:\n")
  cat("Mean anomaly score:", round(mean_score, 3), "\n")
  cat("Median anomaly score:", round(median_score, 3), "\n")
  cat("Threshold:", threshold, "\n")
  cat("Anomalies detected:", n_anomalies, "(", round(pct_anomalies, 2), "%)\n\n")
  
  list(
    data = result,
    model = iso_model,
    n_anomalies = n_anomalies,
    pct_anomalies = pct_anomalies
  )
}


#' Detect Anomalies in Identity Threat Data (All Features)
#' 
#' Convenience wrapper for isolation forest on identity threat variables
#' 
#' @param data Identity threat data frame
#' @param threshold Anomaly score threshold (default: 0.6)
#' @return List with results
detect_identity_threat_anomalies <- function(data, threshold = 0.6) {
  
  # Standard feature set for identity threat analysis
  features <- c(
    "identity_threat_index",
    "emotional_rhetoric_score",
    "media_intensity_index",
    "rationalization_score",
    "perceived_credibility_score"
  )
  
  cat("=== Identity Threat Anomaly Detection ===\n\n")
  
  result <- detect_isolation_forest_anomalies(
    data = data,
    feature_cols = features,
    threshold = threshold
  )
  
  return(result)
}


# ==============================================================================
# ENSEMBLE ANOMALY DETECTION
# ==============================================================================

#' Combine Z-Score and Isolation Forest Methods
#' 
#' Flags observations as anomalous if detected by either method
#' 
#' @param data Data frame
#' @param value_col Column for z-score analysis (unquoted)
#' @param feature_cols Features for isolation forest (character vector)
#' @param zscore_threshold Z-score threshold (default: 3)
#' @param iso_threshold Isolation forest threshold (default: 0.6)
#' @param group_col Optional grouping for z-score (unquoted)
#' @return Data frame with combined anomaly detection
detect_ensemble_anomalies <- function(data,
                                     value_col,
                                     feature_cols,
                                     zscore_threshold = 3,
                                     iso_threshold = 0.6,
                                     group_col = NULL) {
  
  cat("=== Ensemble Anomaly Detection ===\n\n")
  
  # Z-score detection
  cat("Step 1: Z-Score Detection\n")
  if (!is.null(substitute(group_col))) {
    data_zscore <- detect_zscore_anomalies(
      data, 
      {{value_col}}, 
      threshold = zscore_threshold,
      group_col = {{group_col}}
    )
  } else {
    data_zscore <- detect_zscore_anomalies(
      data, 
      {{value_col}}, 
      threshold = zscore_threshold
    )
  }
  
  # Isolation forest detection
  cat("Step 2: Isolation Forest Detection\n")
  iso_result <- detect_isolation_forest_anomalies(
    data_zscore,
    feature_cols = feature_cols,
    threshold = iso_threshold
  )
  
  # Combine results
  data_final <- iso_result$data %>%
    mutate(
      is_anomaly_ensemble = is_anomaly_zscore | is_anomaly_iso,
      anomaly_method = case_when(
        is_anomaly_zscore & is_anomaly_iso ~ "Both",
        is_anomaly_zscore ~ "Z-Score Only",
        is_anomaly_iso ~ "Isolation Forest Only",
        TRUE ~ "None"
      )
    )
  
  # Summary
  cat("\n=== Ensemble Summary ===\n")
  cat("Z-Score anomalies:", sum(data_final$is_anomaly_zscore, na.rm = TRUE), "\n")
  cat("Isolation Forest anomalies:", sum(data_final$is_anomaly_iso, na.rm = TRUE), "\n")
  cat("Both methods:", sum(data_final$anomaly_method == "Both", na.rm = TRUE), "\n")
  cat("Either method:", sum(data_final$is_anomaly_ensemble, na.rm = TRUE), "\n\n")
  
  list(
    data = data_final,
    iso_model = iso_result$model
  )
}


# ==============================================================================
# VISUALIZATION FUNCTIONS
# ==============================================================================

#' Plot Anomalies Over Time
#' 
#' @param data Data frame with anomaly detection results
#' @param value_col Column to plot (unquoted)
#' @param group_col Optional grouping (unquoted)
#' @param anomaly_col Anomaly indicator column (default: "is_anomaly_ensemble")
#' @return ggplot object
plot_anomalies <- function(data, 
                          value_col, 
                          group_col = NULL,
                          anomaly_col = "is_anomaly_ensemble") {
  
  value_col_name <- deparse(substitute(value_col))
  
  # Base plot
  p <- ggplot(data, aes(x = date, y = {{value_col}}))
  
  # Add group coloring if specified
  if (!is.null(substitute(group_col))) {
    p <- p + geom_line(aes(color = {{group_col}}), size = 1)
  } else {
    p <- p + geom_line(color = "#3498db", size = 1)
  }
  
  # Highlight anomalies
  anomaly_data <- data %>% filter(.data[[anomaly_col]] == TRUE)
  
  if (nrow(anomaly_data) > 0) {
    p <- p + geom_point(
      data = anomaly_data,
      aes(x = date, y = {{value_col}}),
      color = "red",
      size = 3,
      shape = 1,
      stroke = 2
    )
  }
  
  # Styling
  p <- p +
    labs(
      title = paste("Anomaly Detection:", value_col_name),
      x = "Date",
      y = value_col_name,
      subtitle = paste("Red circles indicate anomalies (n =", nrow(anomaly_data), ")")
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      legend.position = "bottom"
    )
  
  return(p)
}


#' Plot Anomaly Score Distribution
#' 
#' @param data Data frame with anomaly scores
#' @param threshold Anomaly threshold line (default: 0.6)
#' @return ggplot object
plot_anomaly_distribution <- function(data, threshold = 0.6) {
  
  plot_data <- data %>%
    filter(!is.na(iso_anomaly_score))
  
  ggplot(plot_data, aes(x = iso_anomaly_score)) +
    geom_histogram(bins = 50, fill = "#3498db", alpha = 0.7) +
    geom_vline(xintercept = threshold, color = "red", linetype = "dashed", size = 1) +
    annotate("text", x = threshold, y = Inf, label = paste("Threshold =", threshold),
             vjust = 2, hjust = -0.1, color = "red") +
    labs(
      title = "Isolation Forest Anomaly Score Distribution",
      x = "Anomaly Score (higher = more anomalous)",
      y = "Count"
    ) +
    theme_minimal()
}


# ==============================================================================
# EXAMPLE USAGE
# ==============================================================================

if (interactive()) {
  cat("Anomaly Detection Functions Loaded\n")
  cat("Available functions:\n")
  cat("- detect_zscore_anomalies(): Traditional z-score method\n")
  cat("- detect_isolation_forest_anomalies(): ML-based multivariate detection\n")
  cat("- detect_identity_threat_anomalies(): Convenience wrapper for identity data\n")
  cat("- detect_ensemble_anomalies(): Combine both methods\n")
  cat("- plot_anomalies(): Visualize detected anomalies\n")
  cat("- plot_anomaly_distribution(): Show anomaly score distribution\n")
  cat("\nExample:\n")
  cat("result <- detect_identity_threat_anomalies(data, threshold = 0.6)\n")
  cat("plot_anomalies(result$data, emotional_rhetoric_score, group)\n")
}
