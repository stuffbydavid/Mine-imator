/// @desc Clears the material and normal texture bindings.

function render_set_material_textures_none()
{
	render_set_texture(0, e_texture_channel.MATERIAL)
	render_set_texture(0, e_texture_channel.NORMAL)
}
