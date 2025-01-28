using Test, TimeSeriesBootstrap, Distributions

# Function to generate AR(1) process
function generate_ar1(n::Int, phi::Float64)
    data = zeros(Float64, n)
    for i in 2:n
        data[i] = phi * data[i-1] + randn()
    end
    return data
end

# Define datasets with varying characteristics
datasets = Dict(
    "Normal" => () -> randn(100),
    "Exponential" => () -> rand(Exponential(1), 100),
    "Heavy-Tailed" => () -> rand(TDist(3), 100),
    "Autocorrelated" => () -> generate_ar1(100, 0.3),
    "Seasonal" => () -> (sin.(1:192 .* (2pi / 12))) .+ randn(100)
)

# Monte Carlo test parameters
num_iterations = 20_000  # Number of Monte Carlo iterations
forecast_horizon = 20
num_scenarios = 10


# Function to evaluate the statistical properties of generated scenarios
function evaluate_scenarios(generated::Vector{Vector{Float64}}, historical::Vector{Float64})
    
    # Compute statistics for scenarios and historical data
    generated_mean = mean(generated)
    generated_variance = var(generated)
    generated_acf = compute_acf(generated, 10)
    historical_mean = mean(historical)
    historical_variance = var(historical)
    historical_acf = compute_acf(historical, 10)  # Replace with your ACF computation function

    # Print results
    println("Historical Mean: ", historical_mean)
    println("Average Scenario Mean: ", generated_mean)
    println("Historical Variance: ", historical_variance)
    println("Average Scenario Variance: ", generated_variance)
    println("Historical ACF: ", historical_acf)
    println("Average Scenario ACF: ", generated_acf)

    return (generated_mean, generated_variance, generated_acf)
end

# Function to compute coverage probability for confidence intervals
# function coverage_probability_analysis(historical_mean::Float64, scenario_means::Float64, alpha::Float64 = 0.05)
#     sorted_means = sort(scenario_means)
#     lower_index = round(Int, length(sorted_means) * (alpha / 2))
#     upper_index = round(Int, length(sorted_means) * (1 - alpha / 2))
    
#     lower_ci = sorted_means[lower_index]
#     upper_ci = sorted_means[upper_index]
    
#     # Check if the historical mean falls within the confidence interval
#     coverage = (historical_mean >= lower_ci) && (historical_mean <= upper_ci)
#     return coverage, lower_ci, upper_ci
# end

# # Function to compute bias and variance
# function compute_bias_variance(historical_mean::Float64, scenario_means::Float64)
#     bias = scenario_means - historical_mean
#     variance = var(scenario_means)
#     return bias, variance
# end

# Unified Test Set
@testset "Block Bootstrap and Monte Carlo Tests" begin
    # Part 1: Monte Carlo Tests for Various Datasets
    results = Dict()
    for (label, generate_data) in datasets
        println("Testing dataset: $label")
        pass_count = 0

        for _ in 1:num_iterations
            # Generate data and perform block bootstrap
            residuals = generate_data()
            bootstrapped = block_bootstrap(residuals, forecast_horizon, num_scenarios)

            # Evaluate each scenario and validate statistical properties
            for idx in 1:num_scenarios
                generated = bootstrapped[:, idx]

                # Statistical property evaluation
                scenario_mean = mean(generated)
                # coverage, lower_ci, upper_ci = coverage_probability_analysis(mean(residuals), scenario_mean)
                # bias, variance = compute_bias_variance(mean(residuals), scenario_mean)
                
                # Pass criteria
                valid = validate_series(generated, residuals)

                # All validations must pass
                if valid
                    pass_count += 1
                end
            end
        end

        # Calculate pass rate
        total_tests = num_iterations * num_scenarios
        pass_rate = pass_count / total_tests * 100
        println("Pass rate for $label: $pass_rate%")
        results[label] = pass_rate
        @test pass_rate >= 95  # Ensure pass rate meets threshold
    end

    # Part 2: Basic Block Bootstrap Tests
    residuals = randn(100)

    # Test autocorrelation function
    acf = compute_acf(residuals, 10)
    @test length(acf) == 11  # Includes lag 0

    # Test bootstrap output
    bootstrapped = block_bootstrap(residuals, forecast_horizon, num_scenarios)
    @test size(bootstrapped) == (forecast_horizon, num_scenarios)

    # Validate each scenario in a Monte Carlo loop
    pass_count = 0
    for _ in 1:num_iterations
        for idx in 1:num_scenarios
            generated = bootstrapped[:, idx]
            valid = validate_series(generated, residuals)
            if valid
                pass_count += 1
            end
        end
    end
    total_tests = num_iterations * num_scenarios
    pass_rate = pass_count / total_tests * 100
    println("Pass rate for Basic Block Bootstrap: $pass_rate%")
    @test pass_rate >= 95

    # Part 3: Asymptotic Consistency of Block Lengths
    residuals = randn(1000)
    forecast_horizons = [5, 10, 20, 50, 100, 500]  # Test increasing forecast horizons
    block_lengths = Float64[]

    for F in forecast_horizons
        # Run block bootstrap and capture the block length calculation
        acf = compute_acf(residuals, min(length(residuals) - 1, Int(floor(10 * log10(length(residuals))))))
        weighted_acf = [acf[k] * exp(-k / F) for k in 1:length(acf) - 1]
        threshold = compute_threshold(acf, F, 0.5)
        idx = findfirst(x -> abs(x) < threshold, weighted_acf)
        block_length = idx !== nothing ? idx : min(length(weighted_acf), F)

        push!(block_lengths, block_length)
        println("Forecast Horizon: $F, Block Length: $block_length, Threshold: $threshold, Index Found: $idx")  # Debugging
    end

    # Ensure block lengths increase or stabilize as forecast horizon increases
    @test all(diff(block_lengths) .>= 0)
end
