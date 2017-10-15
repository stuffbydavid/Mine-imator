/// render_world_tl()
/// @desc Renders the 3D model of the timeline instance.

// No 3D representation?
if (type = e_tl_type.CHARACTER ||
	type = e_tl_type.SPECIAL_BLOCK ||
	type = e_tl_type.FOLDER ||
	type = e_tl_type.BACKGROUND ||
	type = e_tl_type.AUDIO)
	return 0
	
// Invisible?
if (!value_inherit[e_value.VISIBLE] || (hide && !render_hidden))
	return 0
	
// Not registered on shadow depth testing?
if (!shadows &&
	(render_mode = e_render_mode.HIGH_LIGHT_SUN_DEPTH ||
	 render_mode = e_render_mode.HIGH_LIGHT_SPOT_DEPTH ||
	 render_mode = e_render_mode.HIGH_LIGHT_POINT_DEPTH))
	return 0
	
// Click mode
if (render_mode = e_render_mode.CLICK)
{
	if (selected || lock) // Already selected when clicking?
		return 0
	
	render_set_uniform_color("uReplaceColor", id, 1)
}

// Outlined?
else if (render_mode = e_render_mode.SELECT && !parent_is_selected && !selected)
	return 0

// Box for clicking
if (type = e_tl_type.PARTICLE_SPAWNER ||
	type = e_tl_type.SPOT_LIGHT ||
	type = e_tl_type.POINT_LIGHT ||
	type = e_tl_type.CAMERA)
{
	if (render_mode = e_render_mode.CLICK)
	{
		render_set_texture(shape_texture)
		vbuffer_render(render_click_box, world_pos)
	}
	
	if (type != e_tl_type.PARTICLE_SPAWNER) // Only proceed with rendering for particles
		return 0
}

if (value_inherit[e_value.ALPHA] = 0)
	return 0

// Set render options
render_set_culling(!backfaces)
shader_texture_filter_linear = texture_blur
shader_texture_filter_mipmap = (app.setting_texture_filtering && texture_filtering)

shader_blend_color = value_inherit[e_value.RGB_MUL]
shader_blend_alpha = value_inherit[e_value.ALPHA]
render_set_uniform_color("uBlendColor", shader_blend_color, shader_blend_alpha)
if (colors_ext)
{
	render_set_uniform_int("uColorsExt", colors_ext)
	render_set_uniform_color("uRGBAdd", value_inherit[e_value.RGB_ADD], 1)
	render_set_uniform_color("uRGBSub", value_inherit[e_value.RGB_SUB], 1)
	render_set_uniform_color("uHSBAdd", value_inherit[e_value.HSB_ADD], 1)
	render_set_uniform_color("uHSBSub", value_inherit[e_value.HSB_SUB], 1)
	render_set_uniform_color("uHSBMul", value_inherit[e_value.HSB_MUL], 1)
	render_set_uniform_color("uMixColor", value_inherit[e_value.MIX_COLOR], value_inherit[e_value.MIX_PERCENT])
}
render_set_uniform("uBrightness", value_inherit[e_value.BRIGHTNESS])

if (wind)
	render_set_uniform("uWindEnable", wind)
if (!wind_terrain)
	render_set_uniform("uWindTerrain", wind_terrain)
if (!fog)
	render_set_uniform_int("uFogShow", fog)
if (!ssao)
	render_set_uniform_int("uSSAOEnable", ssao)
	
// Render
if (type != e_tl_type.PARTICLE_SPAWNER)
{
	var texobj = value_inherit[e_value.TEXTURE_OBJ];
		
	matrix_set(matrix_world, matrix_render)
		
	switch (type)
	{
		case e_tl_type.BODYPART:
		{
			if (model_part = null)
				break
					
			// Get texture
			var res = temp.skin;
				
			if (texobj && texobj.type != e_tl_type.CAMERA)
				res = texobj
				
			if (!res.ready)
				res = mc_res
				
			render_world_model_part(model_part, temp.model_texture_name_map, res, value_inherit[e_value.BEND_ANGLE], bend_vbuffer_list)
			break
		}
			   
		case e_tl_type.SCENERY:
		case e_tl_type.BLOCK:
		{
			// Get resource for texture
			var res = temp.block_tex;
			if (texobj != null && texobj.type != e_tl_type.CAMERA && res.block_sheet_texture != null)
				res = texobj
					
			if (!res.ready)
				res = mc_res
				
			// Draw
			if (type = e_tl_type.BLOCK)
				render_world_block(temp.block_vbuffer, test(temp.block_repeat_enable, temp.block_repeat, vec3(1)), res)
			else if (temp.scenery)
				render_world_scenery(temp.scenery, res, temp.block_repeat_enable, temp.block_repeat)
			break
		}
			   
		case e_tl_type.ITEM:
			render_world_item(temp.item_vbuffer, temp.item_3d, temp.item_face_camera, temp.item_bounce, temp.item_tex)
			break
			
		case e_tl_type.TEXT:
		{
			var font = value[e_value.TEXT_FONT];
			if (font = null)
				font = temp.text_font
			render_world_text(text_vbuffer, text_texture, temp.text_face_camera, font)
			break
		}
			
		default: // Shapes
		{
			var tex;
			with (temp)
				tex = temp_get_shape_tex(temp_get_shape_texobj(texobj))
			render_world_shape(temp.type, temp.shape_vbuffer, temp.shape_face_camera, tex)
			break
		}
	}
} 
else if (render_particles) 
{
	for (var p = 0; p < ds_list_size(particle_list); p++)
		with (particle_list[|p])
			render_world_particle()
}

// Reset
matrix_world_reset()
render_set_culling(true)
shader_texture_surface = false
shader_texture_filter_linear = false
shader_texture_filter_mipmap = false

render_set_uniform("uBrightness", 0)

if (colors_ext)
	render_set_uniform_int("uColorsExt", 0)
if (wind)
	render_set_uniform("uWindEnable", 0)
if (!wind_terrain)
	render_set_uniform("uWindTerrain", 1)
if (!fog)
	render_set_uniform_int("uFogShow", (render_lights && app.background_fog_show))
if (!ssao)
	render_set_uniform_int("uSSAOEnable", 1)