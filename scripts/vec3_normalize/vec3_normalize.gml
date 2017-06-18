/// vec3_normalize(vector)
/// @arg vector

gml_pragma("forceinline")

var vec, len;
vec = argument0
len = vec3_length(vec)

return vec3_div(vec, len)
