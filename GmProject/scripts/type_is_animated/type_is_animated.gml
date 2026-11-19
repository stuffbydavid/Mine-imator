function type_is_animated(type)
{
	return (type != e_tl_type.SCENERY &&
			type != e_tl_type.STRUCTURE &&
			type != e_tl_type.TEXT &&
			type != e_tl_type.PATH &&
			type != e_tl_type.PATH_POINT)
}
