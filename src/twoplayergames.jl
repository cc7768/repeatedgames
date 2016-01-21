immutable TwoPlayerGame
    # Number of actions
    na1::Int
    na2::Int

    # Discount factor
    δ::Float64

    # Payoffs
    g1::Array{Float64, 2}
    g2::Array{Float64, 2}

    # Best Response
    br1::Array{Float64, 1}
    br2::Array{Float64, 1}

    # Gains from deviations
    h1::Array{Float64, 2}
    h2::Array{Float64, 2}
end

# Output flow utility for action profile
@inline g(tpg::TwoPlayerGame, i::Int, j::Int) = [tpg.g1[i, j], tpg.g2[i, j]]
@inline g1(tpg::TwoPlayerGame, i::Int, j::Int) = tpg.g1[i, j]
@inline g2(tpg::TwoPlayerGame, i::Int, j::Int) = tpg.g2[i, j]

# Output period's value
@inline v(tpg::TwoPlayerGame, i::Int, j::Int, w::Vector{Float64}) =
    [v1(tpg, i, j, w[1]), v2(tpg, i, j, w[2])]
@inline v1(tpg::TwoPlayerGame, i::Int, j::Int, w1::Float64) =
    (1-tpg.δ)*g1(tpg, i, j) + tpg.δ*w1
@inline v2(tpg::TwoPlayerGame, i::Int, j::Int, w2::Float64) =
    (1-tpg.δ)*g2(tpg, i, j) + tpg.δ*w2

# Function to pull out each player's best response given action set
@inline bestresponse(tpg::TwoPlayerGame, i::Int, j::Int) = [tpg.br1[j], tpg.br2[i]]
@inline bestresponse1(tpg::TwoPlayerGame, i::Int, j::Int) = tpg.br1[j]
@inline bestresponse2(tpg::TwoPlayerGame, i::Int, j::Int) = tpg.br2[i]

function TwoPlayerGame(δ::Float64, g1::Array{Float64, 2}, g2::Array{Float64, 2})

    # Pull off size and then make sure matrices are same size
    na1, na2 = size(g1)
    @assert size(g2) == (na1, na2)

    # Get best responses
    br1 = Array(Int, na2)
    @inbounds for i=1:na2
        br1[i] = indmax(g1[:, i])
    end
    br2 = Array(Int, na1)
    @inbounds for i=1:na1
        br2[i] = indmax(g2[i, :])
    end

    # Get gains from deviating
    h1 = Array(Float64, na1, na2)
    h2 = Array(Float64, na1, na2)
    @inbounds for i=1:na1
        _br_2 = br2[i]

        @inbounds for j=1:na2
            _br_1 = br1[j]
            h1[i, j] = g1[_br_1, j] - g1[i, j]
            h2[i, j] = g2[i, _br_2] - g2[i, j]
        end
    end

    return TwoPlayerGame(na1, na2, δ, g1, g2, br1, br2, h1, h2)
end
