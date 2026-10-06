/// render_shaderpack_active()
/// @desc Returns whether the high quality render uses the loaded shaderpack.

function render_shaderpack_active()
{
	return (project_render_shaderpack != "" && render_pass = e_render_pass.COMBINED && shaderpack_is_loaded())
}
