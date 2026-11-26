/// @desc Converts pre-2.1 camera effects and removes effect-only camera keyframes.

function project_load_legacy_camera()
{
	var cam, keycount, baseline;
	cam = id
	keycount = ds_list_size(cam.keyframe_list)
	
	// Compare with defaults used when legacy projects were saved
	baseline = array_copy_1d(app.value_default)
	baseline = project_load_values_update_default(null, baseline)

	for (var fx = 0; fx < e_cam_fx.amount; fx++)
	{
		if (load_format < e_project.FORMAT_100_DEMO_4 && fx != e_cam_fx.FADE)
			continue

		var fxrange, fields, defaults, previous, keys, keep, needed;
		fxrange = camera_effect_value_range_list[|fx]
		fields = array_create(e_value.amount, false)
		defaults = array_copy_1d(cam.value_default)
		keys = []
		keep = array_create(keycount, false)

		for (var v = fxrange[0]; v <= fxrange[1]; v++)
			if (fx != e_cam_fx.FADE || v != e_value.GLOW_COLOR)
				fields[v] = true

		if (camera_effect_type_use_aperture(fx))
			for (var v = e_value.CAM_FX_BLADE_AMOUNT; v <= e_value.CAM_FX_BLADE_STRETCH; v++)
				fields[v] = true

		if (fx = e_cam_fx.COLOR_CORRECTION)
			for (var v = e_value.RGB_ADD; v <= e_value.HSB_MUL; v++)
				fields[v] = true

		if (fx = e_cam_fx.LENS_DIRT)
			fields[e_value.TEXTURE_OBJ] = true

		// Convert legacy opacity into the fade color and amount
		if (fx = e_cam_fx.FADE && defaults[e_value.ALPHA] < 1)
		{
			defaults[e_value.MIX_COLOR] = c_black
			defaults[e_value.MIX_PERCENT] = 1 - defaults[e_value.ALPHA]
		}

		defaults[e_value.VISIBLE] = cam.legacy_camera_effect_default[fx]
		needed = defaults[e_value.VISIBLE]

		for (var v = 0; v < e_value.amount; v++)
			if (fields[v] && defaults[v] != baseline[v])
				needed = true

		// Anchor value changes at the previous frame, visibility at the first frame
		previous = defaults
		for (var k = 0; k < keycount; k++)
		{
			var oldkey, values, changed;
			oldkey = cam.keyframe_list[|k]
			values = array_copy_1d(oldkey.value)

			if (fx = e_cam_fx.FADE && values[e_value.ALPHA] < 1)
			{
				values[e_value.MIX_COLOR] = c_black
				values[e_value.MIX_PERCENT] = 1 - values[e_value.ALPHA]
			}

			values[e_value.VISIBLE] = oldkey.legacy_camera_effect_enabled[fx]
			keys[k] = values
			changed = values[e_value.VISIBLE] != previous[e_value.VISIBLE]
			if (changed && k > 0)
				keep[0] = true

			for (var v = 0; v < e_value.amount; v++)
				if (fields[v] && values[v] != previous[v])
				{
					changed = true
					if (k > 0)
						keep[k - 1] = true
				}

			if (changed)
			{
				needed = true
				keep[k] = true
			}

			previous = values
		}

		if (!needed)
			continue

		// Parent visibility is inherited, so only the legacy effect toggle is copied
		var effects = new_tl(e_tl_type.CAMERA_EFFECT);
		effects.loaded = true
		effects.hide = cam.hide
		effects.animated = cam.animated
		effects.camera_effect_type = fx

		with (effects)
		{
			tl_set_parent(cam)
			tl_update()
		}

		for (var v = 0; v < e_value.amount; v++)
		{
			if (!fields[v])
				continue

			effects.value_default[v] = defaults[v]
			effects.value[v] = defaults[v]
		}

		effects.value_default[e_value.VISIBLE] = defaults[e_value.VISIBLE]
		effects.value[e_value.VISIBLE] = defaults[e_value.VISIBLE]

		for (var k = 0; k < keycount; k++)
		{
			if (!keep[k])
				continue

			var oldkey, newkey;
			oldkey = cam.keyframe_list[|k]
			newkey = new_obj(obj_keyframe)
			newkey.position = oldkey.position
			newkey.timeline = effects
			newkey.loaded = true
			newkey.selected = false
			newkey.sound_play_index = null

			for (var v = 0; v < e_value.amount; v++)
				newkey.value[v] = fields[v] ? keys[k][v] : effects.value_default[v]

			newkey.value[e_value.VISIBLE] = keys[k][e_value.VISIBLE]

			for (var v = e_value.TRANSITION; v <= e_value.EASE_OUT_Y; v++)
				newkey.value[v] = oldkey.value[v]

			ds_list_add(effects.keyframe_list, newkey)
		}
	}

	// Retain camera keyframes only for camera values and their anchors
	var keepcamera = array_create(keycount, false);
	previous = cam.value_default

	for (var k = 0; k < keycount; k++)
	{
		var values, changed;
		values = cam.keyframe_list[|k].value
		changed = values[e_value.VISIBLE] != previous[e_value.VISIBLE]

		for (var v = e_value.POS_X; v <= e_value.ROT_Z; v++)
			if (values[v] != previous[v])
				changed = true

		for (var v = e_value.PATH_OBJ; v <= e_value.PATH_OFFSET; v++)
			if (values[v] != previous[v])
				changed = true

		for (var v = e_value.CAM_FOV; v <= e_value.CAM_ROTATE_ANGLE_Z; v++)
			if (values[v] != previous[v])
				changed = true

		if (changed)
		{
			keepcamera[k] = true
			if (k > 0)
				keepcamera[k - 1] = true
		}

		previous = values
	}

	// The first keyframe already applies before its position
	if (keycount > 1 && keepcamera[0])
	{
		var next = 1;
		while (next < keycount && !keepcamera[next])
			next++
		
		if (next < keycount)
		{
			var first, later, same;
			first = cam.keyframe_list[|0].value
			later = cam.keyframe_list[|next].value
			same = (first[e_value.VISIBLE] = later[e_value.VISIBLE])
			
			for (var v = e_value.POS_X; v <= e_value.ROT_Z; v++)
				if (first[v] != later[v])
					same = false

			for (var v = e_value.PATH_OBJ; v <= e_value.PATH_OFFSET; v++)
				if (first[v] != later[v])
					same = false
			
			for (var v = e_value.CAM_FOV; v <= e_value.CAM_ROTATE_ANGLE_Z; v++)
				if (first[v] != later[v])
					same = false
			
			if (same)
				keepcamera[0] = false
		}
	}

	// Remove effect-only keyframes after their values have been copied
	for (var k = keycount - 1; k >= 0; k--)
	{
		if (keepcamera[k])
			continue

		var oldkey = cam.keyframe_list[|k];
		ds_list_delete(cam.keyframe_list, k)
		
		with (oldkey)
			instance_destroy()
	}

	// Clear values no longer owned by the camera
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
