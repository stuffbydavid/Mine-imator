/// type_is_animated(type)

function type_is_animated(type)
{
	return (!type_is_block(type) &&
			 type != e_tl_type.TEXT &&
			 type != e_tl_type.PATH &&
			 type != e_tl_type.PATH_POINT)
}