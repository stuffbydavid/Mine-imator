function shader_high_dof_coc_blur_set(checkx, checky)
{
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)
	render_set_uniform_vec2(e_uniform.PIXEL_CHECK, checkx, checky)
}
