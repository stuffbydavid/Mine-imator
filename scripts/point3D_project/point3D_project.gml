/// point3D_project(point, matrix, width, height)
/// @arg point
/// @arg matrix
/// @arg width 
/// @arg height

var pnt, mat, w, h, clipspace, device;
pnt = argument0
mat = argument1
w = argument2
h = argument3

clipspace = point4D_mul_matrix(point4D(pnt[X], pnt[Y], pnt[Z], 1), mat)
if (clipspace[W] <= 0)
{
    point3D_project_error = true
    return point2D(0, 0)
}

point3D_project_error = false

device = point4D_homogenize(clipspace)
return point2D(((device[X] + 1) / 2) * w, ((1 - device[Y]) / 2) * h)
