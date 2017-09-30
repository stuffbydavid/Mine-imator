/// angle_difference_fix(angle1, angle2)
/// @arg angle1
/// @arg angle2

//gml_pragma("forceinline")

return ((((argument0 - argument1) mod 360) + 540) mod 360) - 180;
