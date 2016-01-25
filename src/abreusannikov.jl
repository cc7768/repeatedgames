include("twoplayergames.jl")

function threatpoint(x::Array{Float64, 2}})

    threat_point = minimum(x, 2)[:]

    return threat_point
end

function Q_operator(tpg::TwoPlayerGame, a1::Int, a2::Int, W::Matrix{Float64}, u::Vector{Float64})

    δ = tpg.δ
    # Flow from action profile and gain from deviation
    _g = g(tpg, a1, a2)
    _h = h(tpg, a1, a2)

    # Find the lines to intersect set with
    w1 = ((1-δ)/δ)*_h[1] + u[1]
    w2 = ((1-δ)/δ)*_h[2] + u[2]

    Q_aWu = intersect_AS(W, w1, w2)

    return Q_aWu
end

function C_operator(tpg::TwoPlayerGame, a1::Int, a2::Int, W::Matrix{Float64}, u::Vector{Float64})

    δ = tpg.δ

    # Flow from action profile and gain from deviation
    _g = g(tpg, a1, a2)
    _h = h(tpg, a1, a2)

    if all(δ*(_g - u) .>= (1-δ)*_h)
        # Only one relevant point if the above holds
        out_ep = [ga]
        out_nep = 1
    else
        # Allocate space for points and give it a size hint
        out_ep = []
        out_nep = 0
        sizehint!(out_ep, 3)

        # Compute elements in Q(a, W, u)
        Q_aWu = Q_operator(tpg, a1, a2, W, u)

        # Check each extreme point of Q(a, W, u) for binding IC
        for ep in Q_aWu
            # Checking binding IC for both agents
            bIC_1 = isapprox((1-δ)*_h[1] - δ*(g[1] - u[1]), 0.0) ? true : false
            bIC_2 = isapprox((1-δ)*_h[2] - δ*(g[2] - u[2]), 0.0) ? true : false

            # Keep points for which either IC is binding
            if bIC_1 || bIC_2
                push!(out_ep, ep)
                out_nep += 1
            end
        end
    end

    return out_ep, out_nep
end

function R_operator(tpg::TwoPlayerGame, W::Matrix{Float64}, u::Vector{Float64})
    # Create space for the extreme points of R(W, u) -- Abreu Sannikov
    # prove that it will be less than 3|A| so we can give a size hint.
    R_Wu = []
    sizehint!(R_Wu, 3*na1*na2)

    for a1=1:na1
        for a2=1:na2
            # Compute the flow payoff
            flow_today = (1-δ)*g(tpg, a1, a2)

            # Get set of possible continuation values
            C_aWu, nC_aWu = C_operator(tpg, a1, a2, W, u)
            for cind=1:nC_aWu
                val_today = flow_today + δ*C_aWu[cind]
                push!(R_Wu, val_today)
            end
        end
    end

    # Take convex hull
    R_Wu = convexhull(R_Wu)

    return R_Wu
end