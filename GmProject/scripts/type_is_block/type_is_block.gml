/// type_is_block(type)
/// @arg type

function type_is_block(type)
{
	return (type = e_tl_type.SCENERY ||
			type = e_tl_type.BLOCK || 
			type = e_tl_type.SPECIAL_BLOCK)
}