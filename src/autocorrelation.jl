"""
    compute_acf(residuals, max_lag)

Compute the autocorrelation function (ACF) for a series of residuals up to `max_lag`.
"""
function compute_acf(residuals::Vector{Float64}, max_lag::Int)
    n = length(residuals)
    mean_r = mean(residuals)
    denominator = sum((residuals .- mean_r).^2)

    acf = [sum((residuals[1:n - lag] .- mean_r) .* (residuals[lag + 1:n] .- mean_r)) / denominator for lag in 0:max_lag]
    return acf
end

"""
    compute_threshold(acf, forecast_horizon)

Determine the threshold for block length computation.
"""
function compute_threshold(acf::Vector{Float64}, forecast_horizon::Int)
    max_acf = maximum(abs.(acf[2:end]))  # Ignore lag-0
    avg_acf = mean(abs.(acf[2:end]))
    threshold = max(max_acf, avg_acf) / (log(forecast_horizon + 1))
    return threshold
end
