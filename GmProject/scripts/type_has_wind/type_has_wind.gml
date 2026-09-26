/// type_has_wind(type)
/// @arg type

function type_has_wind(type)
{
	return (type = e_tl_type.SCENERY || 
			type = e_tl_type.BLOCK || 
			type = e_tl_type.PARTICLE_SPAWNER || 
			type = e_tl_type.TEXT || 
			type = e_tl_type.PATH || 
			type_is_shape(type))
}
