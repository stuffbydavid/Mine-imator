/// vec4_homogenize(vector)
/// @arg vector

//gml_pragma("forceinline")

var vec = argument0;

return vec3(vec[X] / vec[W], vec[Y] / vec[W], vec[Z] / vec[W])
 