/// mod_fix(x, y)
/// @arg x
/// @arg y

//gml_pragma("forceinline")

var xx, yy;
xx = argument0
yy = argument1

while (xx < 0)
	xx += yy

return (xx mod yy)