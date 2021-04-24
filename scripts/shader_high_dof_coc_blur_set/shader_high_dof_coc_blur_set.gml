/// shader_high_dof_coc_blur_set(checkx, checky)
/// @arg checkx
/// @arg checky

function shader_high_dof_coc_blur_set(checkx, checky)
{
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
	render_set_uniform_vec2("uPixelCheck", checkx, checky)
}
