/// tl_value_restore(valueid, oldvalue, newvalue)
/// @arg valueid
/// @arg oldvalue
/// @arg newvalue

var vid, oldval, newval;
vid = argument0
oldval = argument1
newval = argument2

if (vid = SOUNDOBJ && oldval)
{
	var obj = iid_find(oldval);
	obj.count--
}

if (vid = ATTRACTOR || vid = TEXTUREOBJ || vid = SOUNDOBJ)
	newval = iid_find(newval)
	
if (vid = SOUNDOBJ && newval)
	newval.count++
	
return newval
