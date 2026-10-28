/// CppSeparate void tl_update_values_batch(Scope<obj_timeline>, BoolType)
/// @desc Evaluates enabled channels, with a native fast path for unchanged values
/// @arg [transitions]

function tl_update_values_batch(transitions = false)
{
	if (keyframe_value_cache_reuse)
	{
		if (!transitions)
			for (var i = 0; i < array_length(keyframe_value_cache_channels); i++)
				tl_update_values_ease(keyframe_value_cache_channels[i])
		
		return 0
	}

	if (transitions)
	{
		for (var vid = e_value.TRANSITION; vid <= e_value.EASE_OUT_Y; vid++)
			tl_update_values_ease(vid)
		
		return 0
	}

	// Position
	if (value_type[e_value_type.TRANSFORM_POS])
	{
		for (var vid = e_value.POS_X; vid <= e_value.POS_Z; vid++)
			tl_update_values_ease(vid, true)

		if (type != e_tl_type.PATH && type != e_tl_type.PATH_POINT)
			for (var vid = e_value.PATH_OBJ; vid <= e_value.PATH_OFFSET; vid++)
				tl_update_values_ease(vid, true)
	}

	// Rotation
	if (value_type[e_value_type.TRANSFORM_ROT])
		for (var vid = e_value.ROT_X; vid <= e_value.ROT_Z; vid++)
			tl_update_values_ease(vid, true)

	// Scale
	if (value_type[e_value_type.TRANSFORM_SCA])
		for (var vid = e_value.SCA_X; vid <= e_value.SCA_Z; vid++)
			tl_update_values_ease(vid, true)

	// Bend
	if (value_type[e_value_type.TRANSFORM_BEND])
	{
		for (var vid = e_value.BEND_ANGLE_X; vid <= e_value.BEND_ANGLE_Z; vid++)
			tl_update_values_ease(vid, true)

		for (var vid = e_value.IK_TARGET; vid <= e_value.IK_ANGLE_OFFSET; vid++)
			tl_update_values_ease(vid, true)
	}

	// Path point
	if (value_type[e_value_type.TRANSFORM_PATH_POINT])
		for (var vid = e_value.PATH_POINT_ANGLE; vid <= e_value.PATH_POINT_SCALE; vid++)
			tl_update_values_ease(vid, true)

	// Color
	if (value_type[e_value_type.MATERIAL_COLOR])
		for (var vid = e_value.ALPHA; vid <= e_value.WIND_INFLUENCE; vid++)
			tl_update_values_ease(vid, true)

	// Particles
	if (value_type[e_value_type.PARTICLES])
		for (var vid = e_value.SPAWN; vid <= e_value.FORCE_VORTEX; vid++)
			tl_update_values_ease(vid, true)

	// Light
	if (value_type[e_value_type.LIGHT])
	{
		for (var vid = e_value.LIGHT_COLOR; vid <= e_value.LIGHT_FADE_SIZE; vid++)
			tl_update_values_ease(vid, true)

		// Spotlight
		if (value_type[e_value_type.SPOTLIGHT])
			for (var vid = e_value.LIGHT_SPOT_RADIUS; vid <= e_value.LIGHT_SPOT_SHARPNESS; vid++)
				tl_update_values_ease(vid, true)
	}

	// Camera
	if (value_type[e_value_type.CAMERA])
		for (var vid = e_value.CAM_FOV; vid <= e_value.CAM_ROTATE_ANGLE_Z; vid++)
			tl_update_values_ease(vid, true)

	// Camera effects
	if (value_type[e_value_type.CAMERA_EFFECT])
	{
		var fxrange = camera_effect_value_range_list[|camera_effect_type];
		for (var vid = fxrange[0]; vid <= fxrange[1]; vid++)
			if (camera_effect_type != e_cam_fx.FADE || vid != e_value.GLOW_COLOR)
				tl_update_values_ease(vid, true)

		if (camera_effect_type_use_aperture(camera_effect_type))
			for (var vid = e_value.CAM_FX_BLADE_AMOUNT; vid <= e_value.CAM_FX_BLADE_STRETCH; vid++)
				tl_update_values_ease(vid, true)

		if (camera_effect_type = e_cam_fx.COLOR_CORRECTION)
			for (var vid = e_value.RGB_ADD; vid <= e_value.HSB_MUL; vid++)
				tl_update_values_ease(vid, true)

		if (camera_effect_type = e_cam_fx.LENS_DIRT)
			tl_update_values_ease(e_value.TEXTURE_OBJ)
	}

	// Background
	if (value_type[e_value_type.ENVIRONMENT])
		for (var vid = e_value.ENV_IMAGE_SHOW; vid <= e_value.ENV_BRIGHTNESS; vid++)
			tl_update_values_ease(vid, true)

	// Texture
	if (value_type[e_value_type.MATERIAL_TEXTURE] || value_type[e_value_type.ITEM])
		for (var vid = e_value.TEXTURE_OBJ; vid <= e_value.TEXTURE_NORMAL_OBJ; vid++)
			tl_update_values_ease(vid, true)

	// Sound
	if (value_type[e_value_type.SOUND])
		for (var vid = e_value.SOUND_OBJ; vid <= e_value.SOUND_END; vid++)
			tl_update_values_ease(vid, true)

	// Text
	if (value_type[e_value_type.TEXT])
		for (var vid = e_value.TEXT; vid <= e_value.TEXT_CUSTOM_OUTLINE; vid++)
			tl_update_values_ease(vid, true)

	// Item
	if (value_type[e_value_type.ITEM])
		for (var vid = e_value.CUSTOM_ITEM_SLOT; vid <= e_value.ITEM_SLOT; vid++)
			tl_update_values_ease(vid, true)

	// Visible
	tl_update_values_ease(e_value.VISIBLE, true)

}
