/// point3D_mul_matrix(point, matrix)
/// @arg point
/// @arg matrix

//gml_pragma("forceinline")

var pnt, mat, pntmat;
pnt = argument0
mat = argument1

pntmat = point4D_mul_matrix(point4D(pnt[@ X], pnt[@ Y], pnt[@ Z], 1), mat)

return point3D(pntmat[X], pntmat[Y], pntmat[Z])
 