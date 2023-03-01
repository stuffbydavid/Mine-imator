/// type_is_timeline(type)
/// @arg type

function type_is_timeline(type)
{
	return (type = e_tl_type.CAMERA || 
			type = e_tl_type.POINT_LIGHT || 
			type = e_tl_type.SPOT_LIGHT || 
			type = e_tl_type.BACKGROUND || 
			type = e_tl_type.FOLDER || 
			type = e_tl_type.AUDIO || 
			type = e_tl_type.LIGHT_SOURCE ||
			type = e_tl_type.PATH ||
			type = e_tl_type.PATH_POINT)
}
