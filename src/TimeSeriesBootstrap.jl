module TimeSeriesBootstrap
using Random, Statistics
export compute_acf, compute_threshold, block_bootstrap

include("autocorrelation.jl")
include("bootstrap.jl")
include("validation.jl")

end
