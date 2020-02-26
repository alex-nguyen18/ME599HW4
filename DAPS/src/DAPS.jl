module DAPS
#I just took the first letter of each of our names

# Prob. Road Map
function PRM(s,g,O)

end

# Randomly-exploring Random Tree
function RRT(s,g,O)
    
    const Vec4f = SVector{4, Float64}

    # read the starting point from the input
    start_point = Vec4f(s)
    # read the goal from the input
    goal_point = Vec4f(g)

    # add the floor as an obstacle, infinite radius circle at origin
    floor = [0 0 0 Base.Inf 0]
    # adding the floor to the obstacle matrix
    O = [O;floor]

    # Read the total number of obstacles from the input + floor
    O_number_rows = size(O)[1]
    
    # Draw obstacles
    for i = 1:1:O_number_rows # iterate through all obstacle inputs
        if O[i,5] = 1 # check if the obstacle is a cylinder
            function cylinder # draw cylinder obstacle using coordinates and height
              
            end # end cylinder function
        else # if not a cylinder, use sphere
            function sphere # draw sphere obstacle with coordinates and radius
            
            end # end sphere function
        end
    end 
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
