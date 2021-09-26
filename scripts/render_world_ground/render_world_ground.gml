/// render_world_ground()
/// @desc Renders a seemingly infinite plane with a repeated texture.

function render_world_ground()
{
	if (!background_ground_show)
		return 0
	
	// Blend
	var blend = block_texture_get_blend(background_ground_name, background_ground_tex);
	
	// Shading
	render_set_uniform_int("uIsGround", 1)
	render_set_uniform_color("uBlendColor", blend, 1)
	render_set_uniform_color("uGlowColor", c_black, 1)
	render_set_uniform_int("uGlowTexture", 0)
	
	if (background_ground_material_tex = mc_res)
	{
		render_set_uniform("uMetallic", 0)
		render_set_uniform("uRoughness", 1)
		render_set_uniform("uBrightness", 0)
	}
	else
	{
		render_set_uniform("uMetallic", 1)
		render_set_uniform("uRoughness", 0)
		render_set_uniform("uBrightness", 1)
	}
	
	// Texture
	shader_texture_filter_mipmap = app.project_render_texture_filtering
	
	if (background_ground_ani)
		render_set_texture(background_ground_ani_texture[block_texture_get_frame()])
	else
		render_set_texture(background_ground_texture)
	
	if (background_ground_material_ani)
		render_set_texture(background_ground_ani_material_texture[block_texture_get_frame()], "Material")
	else
		render_set_texture(background_ground_material_texture, "Material")
	
	if (background_ground_normal_ani)
		render_set_texture(background_ground_ani_normal_texture[block_texture_get_frame()], "Normal")
	else
		render_set_texture(background_ground_normal_texture, "Normal")
	
	// Submit ground mesh at an offset from the camera
	var xo, yo;
	xo = (cam_from[X] div 16) * 16
	yo = (cam_from[Y] div 16) * 16
	vbuffer_render(background_ground_vbuffer, point3D(xo, yo, 0))
	
	// Reset
	render_set_uniform_int("uIsGround", 0)
	shader_texture_filter_mipmap = false
}
