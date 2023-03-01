/// tl_value_is_texture(valueid)
/// @arg valueid

function tl_value_is_texture(vid)
{
	return (vid = e_value.TEXTURE_OBJ ||
			vid = e_value.TEXTURE_MATERIAL_OBJ ||
			vid = e_value.TEXTURE_NORMAL_OBJ)
}
