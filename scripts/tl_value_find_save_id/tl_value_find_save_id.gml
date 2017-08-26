/// tl_value_find_save_id(valueid, oldvalue, newvalue)
/// @arg valueid
/// @arg oldvalue
/// @arg newvalue

var vid, oldval, newval;
vid = argument0
oldval = argument1
newval = argument2

if (vid = e_value.SOUND_OBJ && oldval != null)
{
	var obj = save_id_find(oldval);
	obj.count--
}

if (vid = e_value.ATTRACTOR || vid = e_value.TEXTURE_OBJ || vid = e_value.SOUND_OBJ)
	newval = save_id_find(newval)
	
if (vid = e_value.SOUND_OBJ && newval != null)
	newval.count++
	
return newval
