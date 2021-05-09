/// render_world_ground()
/// @desc Renders a seemingly infinite plane with a repeated texture.

function render_world_ground()
{
	if (!background_ground_show)
		return 0
	
	render_set_uniform("uMetallic", 0)
	render_set_uniform("uRoughness", 1)
	
	// Blend
	var blend = block_texture_get_blend(background_ground_name, background_ground_tex);
	if (render_mode = e_render_mode.COLOR_FOG_LIGHTS) // Simulate normal
		blend = color_multiply(color_add(background_ambient_color_final, background_sunlight_color_final), blend)
	
	// Shading
	render_set_uniform_int("uIsGround", 1)
	render_set_uniform_color("uBlendColor", blend, 1)
	render_set_uniform_color("uGlowColor", c_black, 1)
	render_set_uniform_int("uGlowTexture", 0)
	
	// Texture
	shader_texture_filter_mipmap = app.setting_texture_filtering
	if (background_ground_ani)
		render_set_texture(background_ground_ani_texture[block_texture_get_frame()])
	else
		render_set_texture(background_ground_texture)
	
	// Submit ground mesh at an offset from the camera
	var xo, yo;
	xo = (cam_from[X] div 16) * 16
	yo = (cam_from[Y] div 16) * 16
	vbuffer_render(background_ground_vbuffer, point3D(xo, yo, 0))
	
	// Reset
	render_set_uniform_int("uIsGround", 0)
	shader_texture_filter_mipmap = false
}
