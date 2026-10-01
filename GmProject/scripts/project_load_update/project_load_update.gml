/// @desc Update program after reading a file.

function project_load_update()
{
	// Load resources
	with (obj_resource)
		if (loaded)
			res_load()
	
	with (mc_res)
		res_update_colors()
	
	if (ds_priority_size(load_queue) > 0)
		load_start(ds_priority_find_max(load_queue), res_load_start)
	
	else if (popup_current != null)
		popup_close()
	
	// Convert Pre-2.1 camera settings to camera effect children
	if (load_format < e_project.FORMAT_210)
	{
		var cameras = [];
		with (obj_timeline)
			if (loaded && type = e_tl_type.CAMERA && is_array(legacy_camera_effect_available))
				array_add(cameras, id)
		
		for (var c = 0; c < array_length(cameras); c++)
		{
			var cam = cameras[c];
			for (var fx = 0; fx < e_cam_fx.amount; fx++)
			{
				if (!cam.legacy_camera_effect_available[fx])
					continue
				
				var effects = new_tl(e_tl_type.CAMERA_EFFECT);
				effects.loaded = true
				effects.hide = cam.hide
				effects.camera_effect_type = fx
				
				with (effects)
				{
					tl_set_parent(cam)
					tl_update()
				}
				
				var fxrange = camera_effect_value_range_list[|fx];
				for (var v = fxrange[0]; v <= fxrange[1]; v++)
				{
					if (fx = e_cam_fx.FADE && v = e_value.GLOW_COLOR)
						continue
					
					effects.value_default[v] = cam.value_default[v]
					effects.value[v] = cam.value_default[v]
				}
				
				if (camera_effect_type_use_aperture(fx))
				{
					for (var v = e_value.CAM_FX_BLADE_AMOUNT; v <= e_value.CAM_FX_BLADE_STRETCH; v++)
					{
						effects.value_default[v] = cam.value_default[v]
						effects.value[v] = cam.value_default[v]
					}
				}
				
				if (fx = e_cam_fx.FADE && cam.value_default[e_value.ALPHA] < 1)
				{
					effects.value_default[e_value.MIX_COLOR] = c_black
					effects.value_default[e_value.MIX_PERCENT] = 1 - cam.value_default[e_value.ALPHA]
					effects.value[e_value.MIX_COLOR] = c_black
					effects.value[e_value.MIX_PERCENT] = effects.value_default[e_value.MIX_PERCENT]
				}
				
				if (fx = e_cam_fx.COLOR_CORRECTION)
				{
					for (var v = e_value.RGB_ADD; v <= e_value.HSB_MUL; v++)
					{
						effects.value_default[v] = cam.value_default[v]
						effects.value[v] = cam.value_default[v]
					}
				}
				
				if (fx = e_cam_fx.LENS_DIRT)
				{
					effects.value_default[e_value.TEXTURE_OBJ] = cam.value_default[e_value.TEXTURE_OBJ]
					effects.value[e_value.TEXTURE_OBJ] = cam.value_default[e_value.TEXTURE_OBJ]
				}
				
				effects.value_default[e_value.VISIBLE] = cam.value_default[e_value.VISIBLE] && cam.legacy_camera_effect_default[fx]
				effects.value[e_value.VISIBLE] = effects.value_default[e_value.VISIBLE]
				
				for (var k = 0; k < ds_list_size(cam.keyframe_list); k++)
				{
					var oldkey, newkey;
					oldkey = cam.keyframe_list[|k]
					newkey = new_obj(obj_keyframe)
					newkey.position = oldkey.position
					newkey.timeline = effects
					newkey.loaded = true
					newkey.selected = false
					newkey.sound_play_index = null
					
					for (var v = 0; v < e_value.amount; v++)
						newkey.value[v] = effects.value_default[v]
					
					for (var v = fxrange[0]; v <= fxrange[1]; v++)
						if (fx != e_cam_fx.FADE || v != e_value.GLOW_COLOR)
							newkey.value[v] = oldkey.value[v]
					
					if (camera_effect_type_use_aperture(fx))
						for (var v = e_value.CAM_FX_BLADE_AMOUNT; v <= e_value.CAM_FX_BLADE_STRETCH; v++)
							newkey.value[v] = oldkey.value[v]
					
					if (fx = e_cam_fx.FADE && oldkey.value[e_value.ALPHA] < 1)
					{
						newkey.value[e_value.MIX_COLOR] = c_black
						newkey.value[e_value.MIX_PERCENT] = 1 - oldkey.value[e_value.ALPHA]
					}
					
					if (fx = e_cam_fx.COLOR_CORRECTION)
						for (var v = e_value.RGB_ADD; v <= e_value.HSB_MUL; v++)
							newkey.value[v] = oldkey.value[v]
					
					if (fx = e_cam_fx.LENS_DIRT)
						newkey.value[e_value.TEXTURE_OBJ] = oldkey.value[e_value.TEXTURE_OBJ]
					newkey.value[e_value.VISIBLE] = oldkey.value[e_value.VISIBLE] && oldkey.legacy_camera_effect_enabled[fx]
					for (var v = e_value.TRANSITION; v <= e_value.EASE_OUT_Y; v++)
						newkey.value[v] = oldkey.value[v]
					ds_list_add(effects.keyframe_list, newkey)
				}
			}
			
			for (var fx = 0; fx < e_cam_fx.amount; fx++)
			{
				var fxrange = camera_effect_value_range_list[|fx];
				for (var v = fxrange[0]; v <= fxrange[1]; v++)
				{
					cam.value_default[v] = app.value_default[v]
					cam.value[v] = app.value_default[v]
					
					for (var k = 0; k < ds_list_size(cam.keyframe_list); k++)
						cam.keyframe_list[|k].value[v] = app.value_default[v]
				}
			}
			
			for (var v = e_value.CAM_FX_BLADE_AMOUNT; v <= e_value.CAM_FX_BLADE_STRETCH; v++)
			{
				cam.value_default[v] = app.value_default[v]
				cam.value[v] = app.value_default[v]
				
				for (var k = 0; k < ds_list_size(cam.keyframe_list); k++)
					cam.keyframe_list[|k].value[v] = app.value_default[v]
			}
			
			for (var v = e_value.ALPHA; v <= e_value.EMISSIVE; v++)
			{
				cam.value_default[v] = app.value_default[v]
				cam.value[v] = app.value_default[v]
				
				for (var k = 0; k < ds_list_size(cam.keyframe_list); k++)
					cam.keyframe_list[|k].value[v] = app.value_default[v]
			}
			
			cam.value_default[e_value.TEXTURE_OBJ] = app.value_default[e_value.TEXTURE_OBJ]
			cam.value[e_value.TEXTURE_OBJ] = app.value_default[e_value.TEXTURE_OBJ]
			
			for (var k = 0; k < ds_list_size(cam.keyframe_list); k++)
			{
				cam.keyframe_list[|k].value[e_value.TEXTURE_OBJ] = app.value_default[e_value.TEXTURE_OBJ]
				cam.keyframe_list[|k].legacy_camera_effect_enabled = null
			}
			
			cam.legacy_camera_effect_default = null
			cam.legacy_camera_effect_available = null
		}
	}
	
	tl_update_list()
	
	// Update sky
	if (env_loaded)
	{
		env_sky_update_clouds()
		env_ground_update_texture()
		env_ground_update_texture_material()
		env_ground_update_texture_normal()
	}
	
	// Update scenery parts
	with (obj_timeline)
		if (loaded && (part_of != null ||
			(!has_temp && (type = e_tl_type.BLOCK || type = e_tl_type.SPECIAL_BLOCK))))
			tl_update_scenery_part()

	// Update templates and timelines
	with (obj_template)
	{
		if (!loaded)
			continue
		
		temp_update()
		
		if (type = e_temp_type.CHARACTER || type = e_temp_type.EQUIPMENT || type = e_temp_type.SPECIAL_BLOCK || type = e_temp_type.MODEL || type = e_temp_type.MODEL_PART)
		{
			if (load_format >= e_project.FORMAT_110_PRE_1 && !load_update_tree)
				temp_update_model_timeline_parts()
			else
				temp_update_model_timeline_tree()
		}
		
		if (pattern_type != "")
			array_add(pattern_update, id)
		
		temp_update_armor(id)
	}
	
	with (obj_timeline)
	{
		if (!loaded)
			continue
		
		// Convert legacy bending
		if (load_format < e_project.FORMAT_113 && model_part != null && model_part.bend_part != null)
		{
			var legacyaxis;
			for (legacyaxis = X; legacyaxis <= Z; legacyaxis++)
				if (model_part.bend_axis[legacyaxis])
					break
			
			for (var i = 0; i < ds_list_size(keyframe_list); i++)
			{
				with (keyframe_list[|i])
				{
					value[e_value.BEND_ANGLE_X + legacyaxis] = value[e_value.BEND_ANGLE_LEGACY]
					value[e_value.BEND_ANGLE_LEGACY] = 0
				}
			}
		}
		
		// Set item slot if item name is set
		if (type = e_tl_type.ITEM)
		{
			for (var i = 0; i < ds_list_size(keyframe_list); i++)
			{
				with (keyframe_list[|i])
				{
					if (value[e_value.ITEM_NAME] != "")
						value[e_value.ITEM_SLOT] = minecraft_assets_texture_picker_slot_find(value[e_value.ITEM_NAME], mc_assets.item_texture_list)
					
					if (value[e_value.ITEM_SLOT] < 0)
						value[e_value.ITEM_SLOT] = minecraft_assets_texture_picker_slot_find(default_item, mc_assets.item_texture_list)
				}
			}
		}
		
		// Update
		tl_update()
		tl_update_values()
		
		// Animate scenery
		if (type = e_tl_type.SCENERY && temp.scenery != null && load_format < e_project.FORMAT_110_PRE_1)
		{
			if (temp.scenery.ready)
				tl_animate_scenery()
			else
				scenery_animate = true
		}
		
		if (pattern_type != "")
			array_add(pattern_update, id)
	}
	
	// Update paths
	with (obj_timeline)
	{
		if (type = e_tl_type.PATH)
			tl_update_path()
	}
	
	with (obj_particle_type)
		if (loaded)
			ptype_update_sprite_vbuffers()
	
	app.update_matrix = true
	tl_update_length()
	tl_update_matrix()
	
	project_update_counts()
}
