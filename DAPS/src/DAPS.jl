module DAPS

# I am thinking that this may be a good implementation to aim for
# https://www.cs.princeton.edu/courses/archive/fall11/cos495/COS495-Lab8-MotionPlanning.pdf

using StaticArrays
#I just took the first letter of each of our names
const maxN = 1000
const radCluster = 9

function dist(f,S)
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
                if (f[3] < O[i,3] + 1 && O[i,4] + 1 < norm2(f,O[i,:]))
                    return false
                end
            else
            # Check if it is outside sphere space
                if O[i,4] + 1 < dist(f,O[i,:]) 
                    return false
                end
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
        p = f1 + (i/10)*(v)
        if !checkFrame(p,O)
            return false
        end
    end
    return true
end

# given a graph with edges, find the path from start to finish (Dijkstra)
function findpath(nodes, edges)
    #rder = [1,]
    #index = 2
    #not sure if we need this line below
    #check = BitArray(undef,size(nodes,1))
    nodeorder=(size(nodes,2),)
    prev = ones(Int,size(nodes,2))
    weights = fill(Inf,size(nodes,2))
    weights[1] = 0
    #iterate through all nodes
    for i = 1:size(nodes,1)
        #it is assumed that the newer nodes are lower on the list
        for j = 1:size(edges,1)
            #if the edge contains the node, check if the path to that point is shorter
            #this will the case taken early on to set up the older node weights
            if edges[j][1] == i && weights[edges[j][2]] + edges[j][3] < weights[edges[j][1]]
                weights[edges[j][1]] = weights[edges[j][2]] + edges[j][3]
                prev[i] = edges[j][2]
            #this will the case taken later, to update with the newer node information
            elseif edges[j][2] == i && weights[edges[j][1]] + edges[j][3] < weights[edges[j][2]]
                weights[edges[j][2]] = weights[edges[j][1]] + edges[j][3]
                prev[i] = edges[j][1]
            end
        end
        #else
    end
    prev_i = prev[size(nodes,1)]
    while prev_i != 1
        nodeorder = (nodeorder..., prev_i)
        prev_i = prev[prev_i]
    end
    return nodeorder
    #=
    # create an n by n matrix
    paths = zeros(Float64,size(nodes,1),size(nodes,1))
    # iterate through one edge of the matrix
    for i = 1:size(nodes,1)
        # iterate only a triangle of the matrix
        for j = 1:i
            for k = 1:size(edges,1)
                if edges[k,1] = i
                    paths[i,edges[k,2]] = paths[edges[k,2],i] = edges[k,3]
                end
            end
        end
    end
    while (index != 1)
        
    end
    =#
end

# Prob. Road Map
function PRM(s,g,O)
    Vec3f = SVector{3, Float64}
    # read the starting point from the input
    start_point = Vec3f(s[1:3,4])
    # read the goal from the input nodes[i1]
    goal_point = Vec3f(g[1:3,4])
    nodes = cat(goal_point, start_point; dims=2) # stack horizontally because they are naturally vertical
    numNodes = 2
    # row of edges is [index1 index2 distanceBetweeni1i2]
    edges = ((1,1,0.0),)
    while (numNodes < maxN)
        # don't allow the finish to grow a node
        index = rand(collect(2:numNodes))
        # add a new frame
        newPoint = addPoint(nodes[:,index])
        #print(newPoint)
        # check if new point is in
        if checkFrame(newPoint,O)
            # add node position if it passes
            nodes = cat(nodes,newPoint; dims=2)
            numNodes += 1
            for i = 1:size(nodes,2)
                # if this is within an acceptable radius, then add the node
                d_nodes = dist(newPoint,nodes[:,i])
                if d_nodes < radCluster
                    if checkEdge(newPoint,nodes[:,i],O)
                        # newpoint oldpoint length
                        edges = (edges..., (numNodes,i,d_nodes,))
                        if i == 1
                            #println("found!")
                            #print(nodes)
                            path = findpath(nodes, edges)
                            order = (nodes[1,:],)
                            for p = 2:size(path,1)
                                order = (nodes[p,:],order...)
                            end
                            return order
                        end
                    end
                end
            end
        end
    end
    return undef
end

# Randomly-exploring Random Tree
function RRT(s,g,O)


end

# I think we could just do total distance here
# Assume that frames include the target frame too
function pathcost(f)
    sum = 0.0 #needs to be a float at least
    for i = 1:size(f,1)
        sum += dist(f[i],f[i+1])
    end
    return sum
end

end # module
