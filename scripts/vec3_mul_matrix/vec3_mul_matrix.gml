/// vec3_mul_matrix(vector, matrix)
/// @arg vector
/// @arg matrix

var vec, mat, vecmat;
vec = argument0
mat = argument1

vecmat = vec4_mul_matrix(vec4(vec[@ X], vec[@ Y], vec[@ Z], 0), mat)

return vec3(vecmat[@ X], vecmat[@ Y], vecmat[@ Z]) 
