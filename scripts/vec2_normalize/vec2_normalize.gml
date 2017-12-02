/// vec2_normalize(vector)
/// @arg vector

var vec, len;
vec = argument0
len = vec2_length(vec)

return vec2_div(vec, len)
