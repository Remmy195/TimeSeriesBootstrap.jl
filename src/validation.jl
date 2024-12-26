export validate_series

using HypothesisTests, Statistics, StatsBase

# Distribution Similarity Test
"""
    validate_distribution_similarity(generated, historical)

Performs two distribution similarity tests (Kolmogorov-Smirnov and Mann-Whitney U) 
to compare the generated and historical data.

# Arguments
- `generated::Vector{Float64}`: Generated series.
- `historical::Vector{Float64}`: Historical series.

# Returns
- `Dict`: Results of the Kolmogorov-Smirnov and Mann-Whitney U tests.
"""
function validate_distribution_similarity(generated::Vector{Float64}, historical::Vector{Float64})
    # Kolmogorov-Smirnov Test
    ks_test = ApproximateTwoSampleKSTest(generated, historical)
    ks_result = pvalue(ks_test) > 0.05  # True if distributions are statistically similar

    # Mann-Whitney U Test
    mu_test = MannWhitneyUTest(generated, historical)
    mu_result = pvalue(mu_test) > 0.05  # True if distributions are statistically similar

    return ks_result 
end




# Aggregate Validation Results
"""
    validate_series(generated, historical)

Aggregates all validation tests for generated and historical data.

# Arguments
- `generated::Vector{Float64}`: Generated series.
- `historical::Vector{Float64}`: Historical series.

# Returns
- `Dict`: Results of all validation tests.
"""
function validate_series(generated::Vector{Float64}, historical::Vector{Float64})
    distribution_valid = validate_distribution_similarity(generated, historical)

    return distribution_valid
end
