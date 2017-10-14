/// type_is_timeline(type)
/// @arg type

var type = argument0;

return (type = e_tl_type.CAMERA || 
		type = e_tl_type.POINT_LIGHT || 
		type = e_tl_type.SPOT_LIGHT || 
		type = e_tl_type.BACKGROUND || 
		type = e_tl_type.FOLDER || 
		type = e_tl_type.AUDIO)
