/// vec3_reflect(vector, normal)
/// @arg vector
/// @arg normal

var v, n;
v = argument0
n = argument1

return vec3_sub(v, vec3_mul(vec3_mul(n, vec3_dot(v, n)), 2))
