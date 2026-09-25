/// type_is_templated(type)
/// @arg type
/// @desc Whether this timeline type uses a template by default

function type_is_templated(type)
{
	return (type < e_temp_type.amount &&
		type != e_tl_type.BLOCK &&
		type != e_tl_type.SPECIAL_BLOCK &&
		type != e_tl_type.TEXT)
}
