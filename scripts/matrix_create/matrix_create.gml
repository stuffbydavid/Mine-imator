/// matrix_create(position, rotation, scale)
/// @arg position
/// @arg rotation
/// @arg scale

//gml_pragma("forceinline")

var pos, rot, sca;
pos = argument0
rot = argument1
sca = argument2

return matrix_build(pos[@ X], pos[@ Y], pos[@ Z], rot[@ X], rot[@ Y], rot[@ Z], sca[@ X], sca[@ Y], sca[@ Z])