module DAPS
#I just took the first letter of each of our names

# Prob. Road Map
function PRM(s,g,O)

end

# Randomly-exploring Random Tree
function RRT(s,g,O)

end

#
function addPoints()

end

# Fairly straight forward; dot product and sqrt it
function dist(f1,f2)
    p1 = f1[1:3,4]
    p2 = hcat(f2[1:3,4])
    return ((p2*p1)[1])^.5
end

# I think we could just do total distance here
# Assume that frames include the target frame too
function pathcost(f)
    sum = 0.0 #needs to be a float at least
    for i = 1:size(f,1)
        sum += dist(f[i].f[i+1])
    end
    return sum
end

end # module
