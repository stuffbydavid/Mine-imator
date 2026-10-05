/// @desc Renders a seemingly infinite plane with a repeated texture.

function render_world_ground()
{
	if (!env_ground_show)
		return 0
	
	if (render_mode = e_render_mode.SCENE_TEST)
		render_set_uniform_color(e_uniform.REPLACE_COLOR, c_white, 1)
	
	if (render_mode = e_render_mode.PLACE)
		render_set_uniform(e_uniform.IS_BLOCK, 1)

	var materialres, res;
	materialres = res_eval(env_ground_tex_material)
	res = res_eval(env_ground_tex)
	render_apply_res(res)

	// Blend
	var blend, iswater;
	blend = block_texture_get_blend(env_ground_name, env_ground_tex)
	iswater = (env_ground_name = "block/water_flow" || env_ground_name = "block/water_still")
	
	// Shading
	render_set_uniform_int(e_uniform.IS_GROUND, 1)
	render_set_uniform_color(e_uniform.BLEND_COLOR, blend, 1)
	render_set_uniform_color(e_uniform.GLOW_COLOR, c_black, 1)
	render_set_uniform_int(e_uniform.GLOW_TEXTURE, 0)
	render_set_uniform_int(e_uniform.FOG_SHOW, app.env_fog_show && render_mode != e_render_mode.COLOR)
	render_set_uniform_int(e_uniform.IS_WATER, iswater && app.project_render_water_reflections)
	render_set_uniform_int(e_uniform.MATERIAL_FORMAT, materialres.material_format)
	
	if (materialres = mc_res)
	{
		render_set_uniform(e_uniform.METALLIC, 0)
		render_set_uniform(e_uniform.ROUGHNESS, (iswater && app.project_render_water_reflections ? app.project_render_water_roughness : 1))
		render_set_uniform(e_uniform.EMISSIVE, 0)
	}
	else
	{
		render_set_uniform(e_uniform.METALLIC, 0)
		render_set_uniform(e_uniform.ROUGHNESS, 0)
		render_set_uniform(e_uniform.EMISSIVE, 0)
	}
	
	// Texture
	shader_texture_filter_mipmap = app.project_render_texture_filtering
	
	if (env_ground_ani)
		render_set_texture(env_ground_ani_texture[block_texture_get_frame()])
	else
		render_set_texture(env_ground_texture)
	
	if (env_ground_material_ani)
		render_set_texture(env_ground_ani_texture_material[block_texture_get_frame()], e_texture_channel.MATERIAL)
	else
		render_set_texture(env_ground_texture_material, e_texture_channel.MATERIAL)
	
	if (env_ground_normal_ani)
		render_set_texture(env_ground_ani_texture_normal[block_texture_get_frame()], e_texture_channel.NORMAL)
	else
		render_set_texture(env_ground_texture_normal, e_texture_channel.NORMAL)
	
	// Submit ground mesh at an offset from the camera
	var sheet, groundscale, groundsquare, xo, yo;
	sheet = minecraft_assets_block_texture_picker_slot_decode(env_ground_slot)[0]
	groundscale = (sheet >= 0 && sheet < e_block_sheet.static_amount ? block_size_list[sheet] / block_size : 1)
	groundsquare = block_size * groundscale
	xo = (cam_from[X] div groundsquare) * groundsquare
	yo = (cam_from[Y] div groundsquare) * groundsquare
	vbuffer_render(env_ground_vbuffer, point3D(xo, yo, 0), point3D(0, 0, 90), point3D(block_size / 16 * groundscale, block_size / 16 * groundscale, 1))
	
	// Reset
	render_set_uniform_int(e_uniform.IS_GROUND, 0)
	if (render_mode = e_render_mode.PLACE)
		render_set_uniform(e_uniform.IS_BLOCK, 0)
	
	if (iswater)
	{
		render_set_uniform(e_uniform.ROUGHNESS, 1)
		render_set_uniform_int(e_uniform.IS_WATER, 0)
	}
	
	shader_texture_filter_mipmap = false
}
