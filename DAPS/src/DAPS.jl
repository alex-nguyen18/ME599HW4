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
              x_coordinate = O[i,1] # read the x coordinate of cylinder position
              y_coordinate = O[i,2] # read the y coordinate of cylinder position
              height_cylinder = O[i,3] # read the height of the cylinder
              radius_cylinder = O[i,4] # read the radius of the cylinder
            function cylinder # draw cylinder obstacle using coordinates and height
              # creates the geometry of the cylinder through 2 circles at varius heights and a common radius
                geom = Cylinder([x_coordinate; y_coordinate; z_coordinate], radius_cylinder, height_cylinder)
            end # end cylinder function
        else # if not a cylinder, use sphere
              x_coordinate = O[i,1] # read the x coordinate of sphere position
              y_coordinate = O[i,2] # read the y coordinate of sphere position
              z_coordinate = O[i,3] # read the z coordinate of sphere position
              radius_sphere = O[i,4] # read the radius of the sphere
            function sphere # draw sphere obstacle with coordinates and radius
            # creates the geometry of the sphere through origin and radius
                geom = Sphere([x_coordinate; y_coordinate; z_coordinate],radius_sphere)
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
