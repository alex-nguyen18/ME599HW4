module DAPS

function PRM(s,g,O)

end

function RRT(s,g,O)

end

function addPoints()

end

# Fairly straight forward
function dist(f1,f2)
    p1 = f1[1:3,4]
    p2 = hcat(f2[1:3,4])
    return (p2*p1)^.5
end

# I think we could just do total distance here
function pathcost(f)

end

end # module
