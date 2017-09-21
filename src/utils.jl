
function intersect_QW(ep::Vector{Point{Float64}}, w1, w2)
    # TODO: Need to consider special cases where it is not binding on one side
    # but is on the other. It should be as simple as returning all extrema to
    # the right side of the binding extreme. Right thing to do here is break
    # this function into cases and write the cases out, that will make it
    # look much less messy

    # Number of extreme points
    npts = length(ep)
    o = Point(w1, w2)

    # Counters to determine whether points belong in the
    # set or not. vcount and hcount are for number of intersections
    # the line makes with the convex hull each way. If either are
    # even then origin is not in intersection
    checknext = true
    storecurr = false
    vcount = 0
    hcount = 0
    # Start a convex hull to store outpoints in
    outhull = []

    # Will check between each point individually
    # Points need to be ordered either clockwise
    # or counter-clockwise
    for i=2:npts+1
        # Pull out points
        if i<=npts
            x1 = ep[i-1]
            x2 = ep[i]
        else
            x1 = ep[npts]
            x2 = ep[1]
        end

        # First add point if we are supposed to store
        if storecurr
            push!(outhull, x1)
        end

        # Check whether intersects
        w1intersect = evalliney(x1, x2, o.x)
        w2intersect = evallinex(x1, x2, o.y)
        cond1 = ((x2.x - o.x)*(x1.x - o.x) < 0) && (w1intersect >= o.y)
        cond2 = ((x2.y - o.y)*(x1.y - o.y) < 0) && (w2intersect >= o.x)

        # Check first condition
        if cond1
            storecurr = !storecurr
            push!(outhull, Point(w1, w1intersect))
            vcount += 1
        # Account for if point is right on top of value
        elseif isapprox(x2.x, o.x) && isapprox(x2.y, w1intersect)
            if storecurr
                push!(outhull, x2)
            end
            storecurr = !storecurr
            vcount += 1
        end

        # Check second condition
        if cond2
            storecurr = !storecurr
            # Make sure we don't double count if both conditions hold
            push!(outhull, Point(w2intersect, w2))
            hcount += 1
        elseif isapprox(x2.y, o.y) && isapprox(x2.x, w2intersect)
            if storecurr
                push!(outhull, x2)
            end
            storecurr = !storecurr
            hcount += 1
        end
    end

    if (hcount*vcount)%2!=0 || (o.x<minx(ep)[1].x && o.y<miny(ep)[1].y)
        push!(outhull, o)
    end

    return outhull
end
