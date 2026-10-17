// @desc Disables point/spot light shadows setting if the number of existing lights reaches a threshold.

function tl_light_check_shadows()
{
	var numlights = 0;
	with (obj_timeline)
		if (id != other.id && type_is_light(type) && shadows)
			numlights++
					
	if (numlights >= light_shadows_threshold)
		shadows = false
}