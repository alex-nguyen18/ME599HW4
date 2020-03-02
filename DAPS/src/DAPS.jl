module DAPS
#I just took the first letter of each of our names


function ccw(A,B,C)
    val = (C(2)-A(2)) * (B(1)-A(1)) > (B(2)-A(2)) * (C(1)-A(1));
end # ccw

function noCollision(n2, n1, o)
    A = [n1(1) n1(2)];
    B = [n2(1) n2(2)];
    obs = [o(1) o(2) o(1)+o(3) o(2)+o(4)];
    
    C1 = [obs(1),obs(2)];
    D1 = [obs(1),obs(4)];
    C2 = [obs(1),obs(2)];
    D2 = [obs(3),obs(2)];
    C3 = [obs(3),obs(4)];
    D3 = [obs(3),obs(2)];
    C4 = [obs(3),obs(4)];
    D4 = [obs(1),obs(4)];
    
    # Check if path from n1 to n2 intersects any of the four edges of the
    # obstacle
    
    ints1 = ccw(A,C1,D1) != ccw(B,C1,D1) && ccw(A,B,C1) != ccw(A,B,D1); 
    ints2 = ccw(A,C2,D2) != ccw(B,C2,D2) && ccw(A,B,C2) != ccw(A,B,D2);
    ints3 = ccw(A,C3,D3) != ccw(B,C3,D3) && ccw(A,B,C3) != ccw(A,B,D3);
    ints4 = ccw(A,C4,D4) != ccw(B,C4,D4) && ccw(A,B,C4) != ccw(A,B,D4);
    if ints1==0 && ints2==0 && ints3==0 && ints4==0
        nc = 1;
    else
        nc = 0;
    end
end # noCollision

# steer towards qn with maximum step size of eps
function steer(qr, qn, val, eps)
    qnew = [0,0];
    if val >= eps
        qnew(1) = qn(1) + ((qr(1)-qn(1))*eps)/dist(qr, qn);
        qnew(2) = qn(2) + ((qr(2)-qn(2))*eps)/dist(qr, qn);
        qnew(3) = qn(3) + ((qr(3)-qn(3))*eps)/dist(qr, qn);
    else
        qnew(1) = qr(1);
        qnew(2) = qr(2);
        qnew(3) = qr(3);
    end
    A = [qnew(1), qnew(2), qnew(3)];
end # steer

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
    Obstacles = [O;floor_obstacle]

    for i = 1:1:maxN
        q_rand = [floor(rand(1)*g[1,1]); floor*rand(1)*g[1,2]; floor(rand(1)*g[1,3]];
        # pick the closest node from existing list to branch out from
        ndist = []
        for j = 1:1:length(nodes)
            n = nodes(j)
            tmp = dist(n.coordinates, q_rand)
            ndist = [ndist tmp]
        end 

        [val, idx] = min(ndist)
        q_near = nodes(idx)

        q_new_coordinates = steer(q_rand, q_near_coordinates, val, EPS);
        if noCollision(q_rand, q_new_coordinates, Obstacles)
            q_new_cost = dist(q_new_coordinates, q_near.coordinates) + q_near.cost;

            # Within radius, find all existing nodes
            q_nearest = []
            r = 60;
            neighbor_count = 1;
            for j = 1:1:length(nodes)
                if noCollision(nodes(j.coordinates), q_new_coordinates, O) && dist(nodes(j).coord, q_new.coord) <= r
                    q_nearest(neighbor_count).coordinates = nodes(j).coordinates;
                    q_nearest(neighbor_count).cost = nodes(j).cost;
                    neighbor_count = neighbor_count + 1;
                end
            end

             # initialize cost to currently known value
             q_min = q_near;
             C_min = q_new_cost;

              # iterate through all nearest neighbors to find alternate lowest cost paths
            for k = 1:1:length(q_nearest)
                if noCollision(q_nearest(k).coord, q_new.coord, O) && q_nearest(k).cost + dist(q_nearest(k).coord, q_new.coord) < C_min
                    q_min = q_nearest(k);
                    C_min = q_nearest(k).cost + dist(q_nearest(k).coord, q_new.coord);            
                end
            end

            # update parent to least cost-from node
            for j = 1:1:length(nodes)
                if nodes(j).coordinates == q_min.coordinates
                    q_new.parent = j;
                end
            end

            # append to nodes
            nodes = [nodes; q_new_coordinates]
        end 
    end
    D = []
    for j = 1:1:length(nodes)
        tmpdist = dist(nodes(j).coordinates, goal_point.coordinates);
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
