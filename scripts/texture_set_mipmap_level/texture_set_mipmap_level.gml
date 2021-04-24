/// texture_set_mipmap_level(level)
/// @arg level

function texture_set_mipmap_level(level)
{
	gpu_set_tex_mip_bias(-level)
}
