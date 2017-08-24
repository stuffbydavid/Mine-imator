/// tl_value_save(valueid, value)
/// @arg valueid
/// @arg value

var vid, val;
vid = argument0
val = argument1

if (vid = e_value.ATTRACTOR || vid = e_value.TEXTURE_OBJ || vid = e_value.SOUND_OBJ)
	return save_id_get(val)
	
return val
