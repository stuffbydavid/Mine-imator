/// type_is_shape(type)
/// @arg type

function type_is_shape(type)
{
	return (type = e_temp_type.CUBE || 
			type = e_temp_type.SPHERE || 
			type = e_temp_type.CONE || 
			type = e_temp_type.CYLINDER || 
			type = e_temp_type.SURFACE)
}
