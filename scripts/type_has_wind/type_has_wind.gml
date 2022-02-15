/// type_has_wind(type)
/// @arg type

function type_has_wind(type)
{
	return (type = e_temp_type.SCENERY || 
			type = e_temp_type.BLOCK || 
			type = e_temp_type.PARTICLE_SPAWNER || 
			type = e_temp_type.TEXT || 
			type_is_shape(type))
}
