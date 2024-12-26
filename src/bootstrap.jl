using Distributions
"""
    block_bootstrap(residuals, forecast_horizon, num_scenarios)

Perform block bootstrap on the given residuals for a specified forecast horizon
and number of scenarios.
"""
function block_bootstrap(residuals::Vector{Float64}, forecast_horizon::Int, num_scenarios::Int)
    n = length(residuals)
    max_lag = min(n - 1, Int(floor(10 * log10(n))))

    # Compute ACF and weighted ACF
    acf = compute_acf(residuals, max_lag)
    weighted_acf = [acf[k] * exp(-k / forecast_horizon) for k in 1:max_lag]

    # Compute threshold and block length
    threshold = compute_threshold(acf, forecast_horizon)
    idx = findfirst(x -> abs(x) < threshold, weighted_acf)
    block_length = idx !== nothing ? idx : min(max_lag, forecast_horizon)


    # Initialize output matrix
    bootstrapped_residuals = Matrix{Float64}(undef, forecast_horizon, num_scenarios)

    # Perform block bootstrap sampling
    for s in 1:num_scenarios
        boot_residual = Float64[]
        i = 1
        while i <= forecast_horizon
            # Sample block length
            sampled_length = min(rand(Geometric(1 / block_length)), forecast_horizon - i + 1)

            # Sample starting index
            start_index = rand(1:n - sampled_length + 1)

            # Append block
            append!(boot_residual, residuals[start_index:start_index + sampled_length - 1])

            # Update position
            i += sampled_length
        end

        # Truncate to forecast horizon and add to matrix
        bootstrapped_residuals[:, s] = boot_residual[1:forecast_horizon]
    end

    return bootstrapped_residuals
end
