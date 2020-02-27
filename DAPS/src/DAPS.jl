module DAPS

# I am thinking that this may be a good implementation to aim for
# https://www.cs.princeton.edu/courses/archive/fall11/cos495/COS495-Lab8-MotionPlanning.pdf

using StaticArrays
#I just took the first letter of each of our names
const maxN = 1000
const radCluster = 10
    
function norm3(f,S)
    return ((f[1]-S[1])^2+(f[2]-S[2])^2+(f[3]-S[3])^2)^.5
end

function norm2(f,C)
    return ((f[1]-C[1])^2+(f[2]-C[2])^2)
end

function checkFrame(f,O)
    if f[3,4] < 0
    for i = 1:size(O,1) 
        # Check if cylinder or sphere
        if O[i][5] == 1
            # Check if it is outside of cylinder space (Over estimate the cylinder)
            if (f[3][4] < O[i][3] + 1 && O[i][4] + 1 < norm2([f[1,4] f[2,4]],O[i]))
                return false
            end
        else
            # Check if it is outside sphere space
            if O[i][4] + 1 < norm3([f[1,4] f[2,4] f[3,4]],O[i]) 
                return false
            end
        end
    end
    return true
end

# Add a new random point/configuration
# Consider expanding off of a current point within a certain radius?
function addPoint()

end

# check if edge is realistic
function checkEdge(f1,f2,O)

end

# Prob. Road Map
function PRM(s,g,O)
    const Vec3f = SVector{3, Float64}
    # read the starting point from the input
    start_point = Vec3f(s[1:3,4])
    # read the goal from the input
    goal_point = Vec3f(g[1:3,4])
    nodes = cat(start_point,goal_point; dims=3) # stack horizontally because they are naturally vertical
    numNodes = 2
    edges = []
    while (numNodes < maxN)
        # add a new frame
        newPoint = addPoint()
        # check if new point is in
        if checkFrame(newPoint,O)
            # add node position if it passes
            nodes = cat(nodes,newPoint; dims=3)
            for i = 1:size(nodes,3)
                if norm3([newPoint[1,4] newPoint[2,4] newPoint[3,4]],[nodes[i][1,4] nodes[i][2,4] nodes[i][3,4]]) < radCluster
                    if checkEdge(newPoint,O[:,:,i],O)
                        edges = [edges; numNodes+1 i]
                    end
                end
                # create a check for edges (idk how to very robustly)
            end
        end
        numNodes += 1
    end
end

# Randomly-exploring Random Tree
function RRT(s,g,O)


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
