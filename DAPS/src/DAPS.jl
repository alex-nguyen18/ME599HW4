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
    return ((f[1]-C[1])^2+(f[2]-C[2])^2)^.5
end

function checkFrame(f,O)
    if f[3] < 1
        return false
    end
    for i = 1:size(O,1) 
        # Check if cylinder or sphere
        if O[i,5] == 1
            # Check if it is outside of cylinder space (Over estimate the cylinder)
            if (O[i,4] + 1 > norm2(f,O[i,:]))
                if f[3] < O[i,3] + 1
                    return false
                end
            end
        else
            # Check if it is outside sphere space
            if O[i,4] + 1 > dist(f,O[i,:]) 
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
function addPoint(s,g)
    x = rand(LinRange(s[1], g[1], 1000))
    y = rand(LinRange(s[2], g[2], 1000))
    z = rand(LinRange(s[3], g[3], 1000))
    return [x;y;z]
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
    nodeorder=(1,)
    #to mark visited nodes
    checked = fill(false,size(nodes,2))
    #track which node was the shortest for the given node
    prev = zeros(Int,size(nodes,2))
    #hold the weights of each node
    weights = fill(Inf,size(nodes,2))
    weights[2] = 0
    curr = 2
    while curr!=1
        minI = 0
        min = Inf
        #iterate through the nodes and relax the edges
        for i = 1:size(edges,1)
            if edges[i][1] == curr
                if edges[i][3] + weights[curr] < weights[edges[i][2]]
                    weights[edges[i][2]] = edges[i][3] + weights[curr]
                    prev[edges[i][2]] = curr
                end
            elseif edges[i][2] == curr
                if edges[i][3] + weights[curr] < weights[edges[i][1]]
                    weights[edges[i][1]] = edges[i][3] + weights[curr]
                    prev[edges[i][1]] = curr
                end
            end
        end
        checked[curr] = true
        #find shortest edge to select next node to visit
        for i = 1:size(checked,1)
            if !checked[i] && weights[i] < min
                min = weights[i]
                minI = i
            end
        end
        curr = minI
        #condition where the rest of the nodes are not connected
        if curr == 0
            return undef
        end
    end
    #after we have relaxed all nodes, get the order using the prev array
    prev_i = prev[1]
    while prev_i != 2
        nodeorder = (prev_i, nodeorder...,)
        prev_i = prev[prev_i]
    end
    nodeorder = (prev_i, nodeorder...,)
    return nodeorder
end

# I think we could just do total distance here
# Assume that frames include the target frame too
function pathcost(f)
    sum = 0.0 #needs to be a float at least
    for i = 1:size(f,1)-1
        sum += dist(f[i][1:3,4],f[i+1][1:3,4])
    end
    return sum
end

function nearestNode(N, P)
	#### finds the nearest nodes to Qrand
	#### input: 
	#### Qrand: a random point, a 1x3 array 
	#### N: a list of nodes, nx3 array
    minD = Inf
    minI = 0
    for i = 2:size(N,2)
		d = dist(N[:,i],P)
        if d < minD
            minD = d
            minI = i
        end
	end
    return minI
end

# Prob. Road Map
function PRM(s,g,O)
    Vec3f = SVector{3, Float64}
    # read the starting point from the input
    start_point = Vec3f(s[1:3,4])
    # read the goal from the input nodes[i1]
    goal_point = Vec3f(g[1:3,4])
    if !checkFrame(start_point,O) || !checkFrame(goal_point,O)
        println("Poorly posed problem!")
        return undef
    end
    nodes = cat(goal_point, start_point; dims=2) # stack horizontally because they are naturally vertical
    numNodes = 2
    # row of edges is [index1 index2 distanceBetweeni1i2]
    connectstart = [false true]
    connectend = [true false]
    edges = ((2,2,0.0),)
    while (numNodes < maxN)
        # add a new frame
        newPoint = addPoint(start_point,goal_point)
        # check if new point is in
        if checkFrame(newPoint,O)
            # add node position if it passes
            nodes = cat(nodes,newPoint; dims=2)
            numNodes += 1
            for i = 1:size(nodes,2)-1
                # if this is within an acceptable radius, then add the edge
                d_nodes = dist(newPoint,nodes[:,i])
                if d_nodes < radCluster
                    if checkEdge(newPoint,nodes[:,i],O)
                        # newpoint oldpoint length
                        edges = (edges..., (numNodes,i,d_nodes,))
                        #naive, but guarantees a connection
                        #if we updated every node after every addition, this could find it "sooner" but may be costly
                        if connectstart[1,i] == true
                            connectstart = [connectstart true]
                        end
                        if connectend[1,i] == true
                            connectend = [connectend true]
                        end
                    end
                end
            end
            #case where the logic didn't find a connection
            if size(connectstart,2) < numNodes
                connectstart = [connectstart false]
            end
            if size(connectend,2) < numNodes
                connectend = [connectend false]
            end
            #once the two ends have met, then check for the path
            if connectend[1,numNodes] && connectstart[1,numNodes]
                path = findpath(nodes, edges)
                #if the path returned undef, then we return undef and print error
                if path == undef
                    println("Could not find a path! Likely, max nodes reached!")
                    return undef
                end
                #assume end point orientation for all points (since it's a sphere, it doesn't matter that much)
                orient = g[1:3,1:3]
                order = (s,)
                for p = 2:size(path,1)
                    point = vcat(hcat(orient,nodes[:,path[p]]),[0 0 0 1])
                    order = (order...,point)
                end
                #add the frames into a tuple
                order = (order...,g)
                cost = pathcost(order)
                #print total length of path
                print("The cost (dist.) of this path is: ")
                print(cost)
                println("")
                return order
            end
        end
    end
    println("Could not find a solution with given params!")
    return undef
end

# Randomly-exploring Random Tree
function RRT(s,g,O)
    Vec3f = SVector{3, Float64}
    # read the starting point from the input
    start_point = Vec3f(s[1:3,4])
    # read the goal from the input nodes[i1]
    goal_point = Vec3f(g[1:3,4])
    stopCond = dist(start_point,goal_point)
    if !checkFrame(start_point,O) || !checkFrame(goal_point,O)
        println("Poorly posed problem!")
        return undef
    end
    nodes = cat(goal_point, start_point; dims=2) # stack horizontally because they are naturally vertical
    numNodes = 2
    # row of edges is [index1 index2 distanceBetweeni1i2]
    connectstart = [false true]
    connectend = [true false]
    edges = ((2,2,0.0),)
    while (numNodes < maxN)
        # add a new frame
        newPoint = addPoint(start_point,goal_point)
        # check if new point is in
        #if checkFrame(newPoint,O)
        step = 8
        # find nearest node
        nearest = nearestNode(nodes,newPoint)
        #find a unit vector in the direction of new point
        dirVec = (newPoint - nodes[:,nearest])
        dirVec = dirVec/dist(dirVec,[0;0;0])
        #add node; if fail, reduce step size until insignificant
        while step > .25
            steer = step*dirVec
            #if both passes, add to tree and update the nearest node to the newest node but keep direction
            #Also, stop the loop if it's gotten too far
            if checkFrame(nodes[:,nearest]+steer,O) && checkEdge(nodes[:,nearest],nodes[:,nearest]+steer,O) && dist(nodes[:,nearest]+steer,goal_point) < stopCond
                numNodes += 1
                nodes = cat(nodes,nodes[:,nearest]+steer; dims=2)
                edges = edges = (edges..., (numNodes,nearest,step,))
                #if we have create a tree within the goal region, check for a path
                if dist(goal_point,nodes[:,nearest]+steer) < radCluster && checkEdge(goal_point,nodes[:,nearest]+steer,O)
                    edges = edges = (edges..., (numNodes,1,step,))
                    path = findpath(nodes, edges)
                    #assume end point orientation for all points (since it's a sphere, it doesn't matter that much)
                    orient = g[1:3,1:3]
                    order = (s,)
                    for p = 2:size(path,1)
                        point = vcat(hcat(orient,nodes[:,path[p]]),[0 0 0 1])
                        order = (order...,point)
                    end
                    #add the frames into a tuple
                    order = (order...,g)
                    cost = pathcost(order)
                    #print total length of path
                    print("The cost (dist.) of this path is: ")
                    print(cost)
                    println("")
                    return order
                end
                nearest = numNodes
            else
                step /= 2
            end
        end
    end
    println("Could not find a solution with given params!")
    return undef
end

end # module
