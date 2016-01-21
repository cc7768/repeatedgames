include("twoplayergames.jl")

function threatpoint(x::Array{Float64, 2}})

    nothing
end

function Q_operator(tpg::TwoPlayerGame, a, W, u)

    # Action profile
    a1, a2 = a

    nothing
end

function C_operator(tpg::TwoPlayerGame, a, W, u)

    δ = tpg.δ

    # Action profile
    a1, a2 = a

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
        Q_aWu = Q_operator(tpg, a, W, u)

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
