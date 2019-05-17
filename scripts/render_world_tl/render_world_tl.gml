/// render_world_tl()
/// @desc Renders the 3D model of the timeline instance.

// No 3D representation?
if (type = e_tl_type.CHARACTER ||
	type = e_tl_type.SPECIAL_BLOCK ||
	type = e_tl_type.FOLDER ||
	type = e_tl_type.BACKGROUND ||
	type = e_tl_type.AUDIO)
	return 0
	
if (type = e_tl_type.MODEL && (temp.model = null || temp.model.model_format = e_model_format.MIMODEL))
	return 0
	
// Invisible?
if (!tl_get_visible())
	return 0
	
// Only render glow effect?
if ((glow && only_render_glow) && render_mode != e_render_mode.COLOR_GLOW)
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

if (foliage_tint)
	shader_blend_color = color_multiply(shader_blend_color, app.background_foliage_color)

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

render_set_uniform_int("uBlockGlow", app.setting_block_glow)

if (bleed_light)
	render_set_uniform("uBleedLight", bool_to_float(bleed_light))

var prevblend = null;

// Object blend mode
if (blend_mode != "normal" && (render_mode = e_render_mode.COLOR_FOG || render_mode = e_render_mode.COLOR_FOG_LIGHTS || render_mode = e_render_mode.ALPHA_FIX))
{
	if (render_mode = e_render_mode.ALPHA_FIX)
		return 0
	
	prevblend = gpu_get_blendmode()
	
	var blend = blend_mode_map[? blend_mode];
	if (is_array(blend))
		gpu_set_blendmode_ext(blend[0], blend[1])
	else
		gpu_set_blendmode(blend)
}

// Glow
if (glow)
{
	render_set_uniform_int("uGlow", 1)
	render_set_uniform_int("uGlowTexture", glow_texture)
	render_set_uniform_color("uGlowColor", value_inherit[e_value.GLOW_COLOR], 1)
	
	if (only_render_glow)
	{
		prevblend = gpu_get_blendmode()
		gpu_set_blendmode(bm_add)
	}
}
else
{
	render_set_uniform_int("uGlow", 0)
	render_set_uniform_int("uGlowTexture", 0)
	render_set_uniform_color("uGlowColor", c_black, 1)
}

// Render
if (type != e_tl_type.PARTICLE_SPAWNER)
{
	matrix_set(matrix_world, matrix_render)
		
	switch (type)
	{
		case e_tl_type.BODYPART:
		{
			if (model_part = null || render_res = null)
				break
			
			render_world_model_part(model_part, render_res, temp.model_texture_name_map, model_shape_vbuffer_map, temp.model_color_map, temp.model_shape_hide_list, temp.model_shape_texture_name_map, self)
			break
		}
			   
		case e_tl_type.SCENERY:
		case e_tl_type.BLOCK:
		{
			if (type = e_tl_type.BLOCK)
				render_world_block(temp.block_vbuffer, render_res, true, test(temp.block_repeat_enable, temp.block_repeat, vec3(1)), temp)
			else if (temp.scenery)
				render_world_scenery(temp.scenery, render_res, temp.block_repeat_enable, temp.block_repeat)
			break
		}
		
		case e_tl_type.ITEM:
		{
			if (item_vbuffer = null)
				render_world_item(temp.item_vbuffer, temp.item_3d, temp.item_face_camera, temp.item_bounce, temp.item_spin, temp.item_tex)
			else
				render_world_item(item_vbuffer, temp.item_3d, temp.item_face_camera, temp.item_bounce, temp.item_spin, item_res)
			break
		}
		
		case e_tl_type.TEXT:
		{
			var font = value[e_value.TEXT_FONT];
			if (font = null)
				font = temp.text_font
			render_world_text(text_vbuffer, text_texture, temp.text_face_camera, font)
			break
		}
		
		case e_tl_type.MODEL:
		{
			if (temp.model != null)
			{
				var res = value_inherit[e_value.TEXTURE_OBJ];
				if (res = null)
					res = temp.model_tex
				if (res = null || res.block_sheet_texture = null)
					res = mc_res
				render_world_block(temp.model.block_vbuffer, res)
				
				with (temp)
					res = temp_get_model_texobj(other.value_inherit[e_value.TEXTURE_OBJ])
				render_world_block_map(temp.model.model_block_map, res)
			}
			break
		}
			
		default: // Shapes
		{
			var tex;
			with (temp)
				tex = temp_get_shape_tex(temp_get_shape_texobj(other.value_inherit[e_value.TEXTURE_OBJ]))
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

matrix_world_reset()
shader_texture_surface = false
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

if (prevblend != null)
	gpu_set_blendmode(prevblend)
	
	
if (bleed_light)
	render_set_uniform("uBleedLight", 0)
