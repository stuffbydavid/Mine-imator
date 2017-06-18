/// vec3_length(vector)
/// @arg vector

gml_pragma("forceinline")

var vec = argument0;

return sqrt(vec[@ X] * vec[@ X] + vec[@ Y] * vec[@ Y] + vec[@ Z] * vec[@ Z])
