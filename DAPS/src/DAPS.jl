module DAPS

# I am thinking that this may be a good implementation to aim for
# https://www.cs.princeton.edu/courses/archive/fall11/cos495/COS495-Lab8-MotionPlanning.pdf

using StaticArrays
#I just took the first letter of each of our names
const maxN = 1000
const radCluster = 10
    
# frame are assumed to be 3x1 vectors [x; y; z]

function norm3(f,S)
    return ((f[1]-S[1])^2+(f[2]-S[2])^2+(f[3]-S[3])^2)^.5
end

function norm2(f,C)
    return ((f[1]-C[1])^2+(f[2]-C[2])^2)
end

function checkFrame(f,O)
    if f[3] < 1
    for i = 1:size(O,1) 
        # Check if cylinder or sphere
        if O[i,5] == 1
            # Check if it is outside of cylinder space (Over estimate the cylinder)
            if (f[3] < O[i,3] + 1 && O[i,4] + 1 < norm2(f,O[i]))
                return false
            end
        else
            # Check if it is outside sphere space
            if O[i,4] + 1 < norm3(f,O[i]) 
                return false
            end
        end
    end
    return true #if no collisions, then true
end

# Homogenous Trans. Matrix of X-Y-Z euler rotation
#function eulerRotationMatrix(theta1,theta2,theta3)
#	Rx = [1 0 0 0; 0 cos(theta1) -sin(theta1) 0; 0 sin(theta1) cos(theta1) 0; 0 0 0 1]
#	Ry = [cos(theta2) 0 sin(theta2) 0; 0 1 0 0; -sin(theta2) 0 cos(theta2) 0; 0 0 0 1]
#	Rz = [cos(theta3) -sin(theta3) 0 0; sin(theta3) cos(theta3) 0 0; 0 0 1 0; 0 0 0 1]
#	return Rx*Ry*Rz
#end

# Add a new random point/configuration
# Add a random point within a 10-edge length cube around the point of interest
# .1 unit increments
function addPoint(p)
    dx = rand(LinRange(-5, 5, 110))
    dy = rand(LinRange(-5, 5, 110))
    dz = rand(LinRange(-5, 5, 110))
    return [p[1]+dx;p[2]+dy;p[3]+dz]
    #r = rand(collect(1:radCluster))
    #trans = p + [0 0 0 0; 0 0 0 0; 0 0 0 r; 0 0 0 0]
    #rAng = rand(3)
    #rRot = eulerRotationMatrix(rAng[1],rAng[2],rAng[3])
    #return trans*rRot
end

#function getPos(f)
#    return [0 0 0 f[1,4]; 0 0 0 f[2,4]; 0 0 0 f[3,4]; 0 0 0 0]
#end

# check if edge is realistic (I was thinking 10% increments)
function checkEdge(f1,f2,O)
    v = f2-f1
    for i = 1:10
        p = f1 + (i/10)(v)
        if !checkFrame(p,O)
            return false
    end
    return true
end

# given a graph with edges, find the path from start to finish (DFS or BFS)
function findpath(nodes, edges)
    order = [2,]
    while ()
        
    end
end

# Prob. Road Map
function PRM(s,g,O)
    const Vec3f = SVector{3, Float64}
    # read the starting point from the input
    start_point = Vec3f(s[1:3,4])
    # read the goal from the input
    goal_point = Vec3f(g[1:3,4])
    nodes = cat(goal_point, start_point; dims=2) # stack horizontally because they are naturally vertical
    numNodes = 2
    edges = []
    while (numNodes < maxN)
        # don't allow the finish to grow a node
        index = rand(collect(2:numNodes))
        # add a new frame
        newPoint = addPoint(nodes[:,index])
        # check if new point is in
        if checkFrame(newPoint,O)
            # add node position if it passes
            nodes = cat(nodes,newPoint; dims=3)
            numNodes += 1
            for i = 1:size(nodes,3)
                # if this is within an acceptable radius, then add the node
                if norm3([newPoint[1,4] newPoint[2,4] newPoint[3,4]],[nodes[i][1,4] nodes[i][2,4] nodes[i][3,4]]) < radCluster
                    if checkEdge(newPoint,nodes[:,i],O)
                        edges = [edges; numNodes+1 i]
                        if i == 1
                            path = findpath(nodes, edges)
                        end
                    end
                end
                # create a check for edges (idk how to very robustly)
            end
        end
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
