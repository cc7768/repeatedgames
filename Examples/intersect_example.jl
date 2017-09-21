include("../utils/point.jl")
include("../utils/utils.jl")
include("../utils/algorithms.jl")
include("TwoPlayerGame.jl")
include("AbreuSannikov.jl")

using PlotlyJS

# Examples of intersection function
test1 = [Point(0.0, 0.0), Point(1.0, 0.1), Point(1.0, 1.0),
         Point(0.0, 1.0), Point(0.0, 0.0)]
test2 = [Point(0.0, 1.0), Point(0.5, 1.5), Point(2.0, 2.0),
         Point(1.5, 0.5), Point(1.0, 0.0), Point(0.0, 1.0)]

out1 = intersect_QW(test1, 0.4, 0.4)
out2 = intersect_QW(test2, 0.4, 0.4)

p = [Point(randn(), randn()) for i=1:250]
ep = _monotonechain(p)

function plottest(test, w1, w2)

    # Get intersection
    out = intersect_QW(test, w1, w2)

    # Create traces
    push!(test, test[1])
    t1 = scatter(;x=[el.x for el in test], y=[el.y for el in test], mode="line")
    t2a = scatter(;x=[w1, w1], y=[w2, 3.0], mode="line")
    t2b = scatter(;x=[w1, 3.0], y=[w2, w2], mode="line")
    t3 = scatter(;x=[el.x for el in out], y=[el.y for el in out], mode="markers")

    p = Plot([t1, t2a, t2b, t3])

    return p
end

