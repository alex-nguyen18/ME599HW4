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

    nodes = cat(start_point, goal_point; dims=3)
    numNodes = 2
    RRT_edges =[]
    EPS = 15

    # add the floor as an obstacle, infinite radius circle at origin
    floor_obstacle = [0 0 0 Base.Inf 0]
    # adding the floor to the obstacle matrix
    O = [O;floor_obstacle]

    # Read the total number of obstacles from the input + floor
    O_number_rows = size(O)[1]
    
    # code from PRM, unsure how it is supposed to differ from RRT
    #
    # while (numNodes < maxN)
    #    index = rand(collect(2:numNodes))
    #    newPoint = addPoint(nodes[:,index])
    #
    #    if checkFrame(newPoint, O)
    #        nodes = cat(nodes,newPoint; dims = 2)
    #        numNodes += 1
    #        for i = 1:size(nodes,2)
    #            d_nodes = dist(newPoint,nodes[:,i])
    #           if d_nodes < radCluster
    #               if checkEdge(newPoint,nodes[:,i],O)
    #                    edges = (edges..., (numNodes,i,d_nodes))
    #                    if i == 1
    #                        path = findpath(nodes, edges)
    #                        order = (nodes[1,:],)
    #                       for p = 2:size(path,1)
    #                        order = (nodes[p,:],order...)
    #                        end
    #                        return order
    #                    end
    #                end
    #            end
    #        end
    #    end
    # end
    # return undef

    for i = 1:1:maxN
        q_rand = [floor(rand(1)*g[1,1]); floor*rand(1)*g[1,2]; floor(rand(1)*g[1,3]]
        # pick the closest node from existing list to branch out from
        ndist = []
        for j = 1:1:length(nodes)
            n = nodes(j)
            tmp = dist(n.coord, q_rand)
            ndist = [ndist tmp]
        end 

        [val, idx] = min(ndist)
        q_near = nodes(idx)

        q_new.coord = steer(q_rand, q_near.coord, val, EPS);
        if checkEdge(q_rand, q_new.coord, O)
            q_new_cost = dist(q_new.coord, q_near.coord) + q_near.cost;

            # Within radius, find all existing nodes
            q_nearest = []
            r = 60;
            neighbor_count = 1;
            for j = 1:1:length(nodes)
                if checkEdge(nodes(j.coord), q_new.coord, O) && dist(nodes(j).coord, q_new.coord) <= r
                    q_nearest(neighbor_count).coord = nodes(j).coord;
                    q_nearest(neighbor_count).cost = nodes(j).cost;
                    neighbor_count = neighbor_count + 1;
                end
            end

            # initialize cost to currently known value
            q_min = q_near;
            C_min = q_new_cost;

            # iterate through all nearest neighbors to find alternate lowest cost paths
            for k = 1:1:length(q_nearest)
                if checkEdge(q_nearest(k).coord, q_new.coord, O) && q_nearest(k).cost + dist(q_nearest(k).coord, q_new.coord) < C_min
                    q_min = q_nearest(k);
                    C_min = q_nearest(k).cost + dist(q_nearest(k).coord, q_new.coord);            
                end
            end

            # update parent to least cost-from node
            for j = 1:1:length(nodes)
                if nodes(j).coord == q_min.coord
                    q_new.parent = j;
                end
            end

            # append to nodes
            nodes = [nodes q_new];
        end
    end

    D = []
    for j = 1:1:length(nodes)
        tmpdist = dist(nodes(j).coord, goal_point.coord);
        D = [D tmpdist];
    end

    # Search backwards from goal to start to find the optimal path
    [val, idx] = min(D);
    q_final = nodes(idx)
    goal_point.parent = idx;
    q_end = goal_point;
    nodes = [nodes goal_point];
    while q_end.parent != 0
        start = q_end.parent;
        q_end = nodes(start);
end # end RRT

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
