/// tl_value_restore(valueid, oldvalue, newvalue)
/// @arg valueid
/// @arg oldvalue
/// @arg newvalue

var vid, oldval, newval;
vid = argument0
oldval = argument1
newval = argument2

if (vid = SOUNDOBJ && oldval != null)
{
	var obj = save_id_find(oldval);
	obj.count--
}

if (vid = ATTRACTOR || vid = TEXTUREOBJ || vid = SOUNDOBJ)
	newval = save_id_find(newval)
	
if (vid = SOUNDOBJ && newval != null)
	newval.count++
	
return newval
