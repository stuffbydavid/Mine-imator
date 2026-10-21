/// @desc Disables material mapping and resets surface values.

function render_set_material_none()
{
	render_set_uniform_int(e_uniform.MATERIAL_FORMAT, e_material.FORMAT_NONE)
	render_set_uniform(e_uniform.METALLIC, 0)
	render_set_uniform(e_uniform.ROUGHNESS, 1)
	render_set_uniform(e_uniform.EMISSIVE, 0)
}
