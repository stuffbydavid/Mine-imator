/// type_is_shape(type)
/// @arg type

function type_is_shape(type)
{
	return (type = e_tl_type.CUBE || 
			type = e_tl_type.CONE || 
			type = e_tl_type.CYLINDER || 
			type = e_tl_type.SPHERE || 
			type = e_tl_type.SURFACE)
}
