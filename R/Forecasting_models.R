# ==============================================================================
# FORECASTING MODELS FOR IDENTITY THREAT DYNAMICS
# ==============================================================================
# Purpose: Time-series forecasting using Prophet and ARIMA to predict
#          future identity threat, emotional rhetoric, and credibility patterns
# ==============================================================================

library(tidyverse)
library(forecast)
library(prophet)  # Install via: install.packages("prophet")
library(lubridate)

# ==============================================================================
# PROPHET FORECASTING
# ==============================================================================

#' Forecast with Prophet
#' 
#' Uses Facebook Prophet for time-series forecasting with automatic
#' seasonality detection and uncertainty quantification
#' 
#' @param data Data frame with time series
#' @param date_col Name of date column (unquoted)
#' @param value_col Name of value column to forecast (unquoted)
#' @param group_filter Optional group to filter (e.g., "Group_A")
#' @param forecast_days Number of days to forecast ahead (default: 90)
#' @param changepoint_prior_scale Flexibility of trend (default: 0.05)
#' @return List with model, forecast, and plots
forecast_prophet <- function(data, 
                             date_col, 
                             value_col,
                             group_filter = NULL,
                             forecast_days = 90,
                             changepoint_prior_scale = 0.05) {
  
  # Filter by group if specified
  if (!is.null(group_filter)) {
    data <- data %>% filter(group == group_filter)
  }
  
  # Prepare data for Prophet (requires 'ds' and 'y' columns)
  prophet_data <- data %>%
    select(ds = {{date_col}}, y = {{value_col}}) %>%
    na.omit()
  
  cat("Fitting Prophet model...\n")
  cat("Observations:", nrow(prophet_data), "\n")
  cat("Date range:", min(prophet_data$ds), "to", max(prophet_data$ds), "\n")
  
  # Fit Prophet model
  m <- prophet(
    prophet_data,
    weekly.seasonality = FALSE,   # Daily data, weekly patterns less relevant
    yearly.seasonality = TRUE,     # Annual patterns may exist
    changepoint.prior.scale = changepoint_prior_scale,
    interval.width = 0.95          # 95% confidence intervals
  )
  
  # Create future dataframe
  future <- make_future_dataframe(m, periods = forecast_days)
  
  # Generate forecast
  forecast <- predict(m, future)
  
  cat("Forecast generated for", forecast_days, "days ahead\n")
  
  # Create plots
  plot_forecast <- plot(m, forecast) +
    labs(
      title = paste("Prophet Forecast:", deparse(substitute(value_col))),
      x = "Date",
      y = "Value"
    ) +
    theme_minimal()
  
  plot_components <- prophet_plot_components(m, forecast)
  
  # Return results
  list(
    model = m,
    forecast = forecast,
    plot_forecast = plot_forecast,
    plot_components = plot_components,
    future_predictions = forecast %>%
      filter(ds > max(prophet_data$ds)) %>%
      select(ds, yhat, yhat_lower, yhat_upper)
  )
}


#' Forecast Multiple Variables with Prophet
#' 
#' Convenience function to forecast multiple metrics
#' 
#' @param data Data frame with identity threat data
#' @param group_filter Group to analyze (default: "Group_A")
#' @param forecast_days Days to forecast (default: 90)
#' @return Named list of forecast results for each variable
forecast_all_prophet <- function(data, 
                                group_filter = "Group_A",
                                forecast_days = 90) {
  
  variables <- c("identity_threat_index", 
                "emotional_rhetoric_score",
                "perceived_credibility_score",
                "narrative_stability_index")
  
  results <- list()
  
  for (var in variables) {
    cat("\n=== Forecasting", var, "===\n")
    results[[var]] <- forecast_prophet(
      data = data,
      date_col = date,
      value_col = !!sym(var),
      group_filter = group_filter,
      forecast_days = forecast_days
    )
  }
  
  return(results)
}


# ==============================================================================
# ARIMA FORECASTING
# ==============================================================================

#' Auto ARIMA Forecast
#' 
#' Automatically selects best ARIMA model using AIC/BIC criteria
#' Provides more traditional time-series approach compared to Prophet
#' 
#' @param data Data frame with time series
#' @param value_col Name of value column to forecast (unquoted)
#' @param group_filter Optional group to filter
#' @param forecast_days Number of days to forecast (default: 90)
#' @param seasonal Include seasonal components (default: TRUE)
#' @param frequency Seasonal frequency (default: 7 for weekly patterns)
#' @return List with model, forecast, and plot
forecast_arima <- function(data,
                          value_col,
                          group_filter = NULL,
                          forecast_days = 90,
                          seasonal = TRUE,
                          frequency = 7) {
  
  # Filter by group if specified
  if (!is.null(group_filter)) {
    data <- data %>% filter(group == group_filter)
  }
  
  # Extract time series
  ts_data <- data %>%
    select({{value_col}}) %>%
    pull() %>%
    na.omit()
  
  # Convert to ts object
  if (seasonal && frequency > 1) {
    ts_obj <- ts(ts_data, frequency = frequency)
  } else {
    ts_obj <- ts(ts_data)
  }
  
  cat("Fitting Auto ARIMA model...\n")
  cat("Observations:", length(ts_obj), "\n")
  
  # Fit auto ARIMA
  arima_model <- auto.arima(
    ts_obj,
    seasonal = seasonal,
    stepwise = FALSE,      # More exhaustive search
    approximation = FALSE,  # More accurate likelihood
    trace = FALSE
  )
  
  cat("Selected model:", arima_model$method, "\n")
  cat("AIC:", arima_model$aic, "\n")
  
  # Generate forecast
  arima_forecast <- forecast(arima_model, h = forecast_days)
  
  # Create plot
  plot_obj <- autoplot(arima_forecast) +
    labs(
      title = paste("ARIMA Forecast:", deparse(substitute(value_col))),
      x = "Time",
      y = "Value"
    ) +
    theme_minimal()
  
  # Extract forecast values
  forecast_df <- tibble(
    point_forecast = as.numeric(arima_forecast$mean),
    lower_80 = as.numeric(arima_forecast$lower[, 1]),
    upper_80 = as.numeric(arima_forecast$upper[, 1]),
    lower_95 = as.numeric(arima_forecast$lower[, 2]),
    upper_95 = as.numeric(arima_forecast$upper[, 2])
  )
  
  cat("Forecast generated for", forecast_days, "periods ahead\n\n")
  
  # Return results
  list(
    model = arima_model,
    forecast = arima_forecast,
    forecast_values = forecast_df,
    plot = plot_obj,
    model_summary = summary(arima_model)
  )
}


#' Forecast Multiple Variables with ARIMA
#' 
#' @param data Data frame with identity threat data
#' @param group_filter Group to analyze (default: "Group_A")
#' @param forecast_days Days to forecast (default: 90)
#' @return Named list of forecast results for each variable
forecast_all_arima <- function(data,
                              group_filter = "Group_A",
                              forecast_days = 90) {
  
  variables <- c("identity_threat_index", 
                "emotional_rhetoric_score",
                "perceived_credibility_score",
                "narrative_stability_index")
  
  results <- list()
  
  for (var in variables) {
    cat("\n=== ARIMA Forecasting", var, "===\n")
    results[[var]] <- forecast_arima(
      data = data,
      value_col = !!sym(var),
      group_filter = group_filter,
      forecast_days = forecast_days
    )
  }
  
  return(results)
}


# ==============================================================================
# FORECAST EVALUATION
# ==============================================================================

#' Evaluate Forecast Accuracy
#' 
#' Backtesting using train/test split
#' 
#' @param data Data frame with time series
#' @param value_col Column to forecast
#' @param group_filter Optional group filter
#' @param train_pct Percentage of data for training (default: 0.8)
#' @param method Forecasting method: "prophet" or "arima" (default: "prophet")
#' @return List with metrics and comparison plot
evaluate_forecast <- function(data,
                             value_col,
                             group_filter = NULL,
                             train_pct = 0.8,
                             method = "prophet") {
  
  # Filter by group if specified
  if (!is.null(group_filter)) {
    data <- data %>% filter(group == group_filter)
  }
  
  # Split into train/test
  n <- nrow(data)
  train_size <- floor(n * train_pct)
  
  train_data <- data %>% slice(1:train_size)
  test_data <- data %>% slice((train_size + 1):n)
  
  test_days <- nrow(test_data)
  
  cat("Train size:", train_size, "| Test size:", test_days, "\n")
  
  # Forecast based on method
  if (method == "prophet") {
    result <- forecast_prophet(
      train_data,
      date_col = date,
      value_col = {{value_col}},
      forecast_days = test_days,
      changepoint_prior_scale = 0.05
    )
    predictions <- result$future_predictions$yhat
  } else if (method == "arima") {
    result <- forecast_arima(
      train_data,
      value_col = {{value_col}},
      forecast_days = test_days
    )
    predictions <- result$forecast_values$point_forecast
  }
  
  # Calculate accuracy metrics
  actuals <- test_data %>% pull({{value_col}})
  
  mae <- mean(abs(predictions - actuals), na.rm = TRUE)
  rmse <- sqrt(mean((predictions - actuals)^2, na.rm = TRUE))
  mape <- mean(abs((actuals - predictions) / actuals), na.rm = TRUE) * 100
  
  cat("\nAccuracy Metrics:\n")
  cat("MAE:", round(mae, 2), "\n")
  cat("RMSE:", round(rmse, 2), "\n")
  cat("MAPE:", round(mape, 2), "%\n")
  
  # Create comparison plot
  comparison_df <- tibble(
    date = test_data$date,
    actual = actuals,
    predicted = predictions
  )
  
  plot <- ggplot(comparison_df, aes(x = date)) +
    geom_line(aes(y = actual, color = "Actual"), size = 1) +
    geom_line(aes(y = predicted, color = "Predicted"), size = 1, linetype = "dashed") +
    scale_color_manual(values = c("Actual" = "#2c3e50", "Predicted" = "#e74c3c")) +
    labs(
      title = paste(method, "Forecast Evaluation:", deparse(substitute(value_col))),
      x = "Date",
      y = "Value",
      color = NULL
    ) +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  list(
    mae = mae,
    rmse = rmse,
    mape = mape,
    comparison_plot = plot,
    comparison_data = comparison_df
  )
}


# ==============================================================================
# EXAMPLE USAGE
# ==============================================================================

if (interactive()) {
  cat("Forecasting Models Loaded\n")
  cat("Available functions:\n")
  cat("- forecast_prophet(): Prophet forecasting with uncertainty\n")
  cat("- forecast_arima(): Auto ARIMA forecasting\n")
  cat("- forecast_all_prophet(): Forecast multiple variables with Prophet\n")
  cat("- forecast_all_arima(): Forecast multiple variables with ARIMA\n")
  cat("- evaluate_forecast(): Backtest forecast accuracy\n")
  cat("\nExample:\n")
  cat("results <- forecast_prophet(data, date, identity_threat_index, 'Group_A', 90)\n")
}
