/// tl_value_save(valueid, value)
/// @arg valueid
/// @arg value

var vid, val;
vid = argument0
val = argument1

if (vid = ATTRACTOR || vid = TEXTUREOBJ || vid = SOUNDOBJ)
	return iid_get(val)
	
return val
