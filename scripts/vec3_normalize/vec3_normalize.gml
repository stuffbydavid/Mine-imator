/// vec3_normalize(vector)
/// @arg vector

var vec, len;
vec = argument0
len = vec3_length(vec)

return vec3_div(vec, len)
