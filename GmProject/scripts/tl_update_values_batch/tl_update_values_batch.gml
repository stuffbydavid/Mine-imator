/// CppSeparate void tl_update_values_batch(Scope<obj_timeline>, BoolType)
/// @desc Evaluates enabled channels, with a native fast path for unchanged values
/// @arg [transitions]

function tl_update_values_batch(transitions = false)
{
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
			tl_update_values_ease(vid)

		if (type != e_tl_type.PATH && type != e_tl_type.PATH_POINT)
			for (var vid = e_value.PATH_OBJ; vid <= e_value.PATH_OFFSET; vid++)
				tl_update_values_ease(vid)
	}

	// Rotation
	if (value_type[e_value_type.TRANSFORM_ROT])
		for (var vid = e_value.ROT_X; vid <= e_value.ROT_Z; vid++)
			tl_update_values_ease(vid)

	// Scale
	if (value_type[e_value_type.TRANSFORM_SCA])
		for (var vid = e_value.SCA_X; vid <= e_value.SCA_Z; vid++)
			tl_update_values_ease(vid)

	// Bend
	if (value_type[e_value_type.TRANSFORM_BEND])
	{
		for (var vid = e_value.BEND_ANGLE_X; vid <= e_value.BEND_ANGLE_Z; vid++)
			tl_update_values_ease(vid)

		for (var vid = e_value.IK_TARGET; vid <= e_value.IK_ANGLE_OFFSET; vid++)
			tl_update_values_ease(vid)
	}

	// Path point
	if (value_type[e_value_type.TRANSFORM_PATH_POINT])
		for (var vid = e_value.PATH_POINT_ANGLE; vid <= e_value.PATH_POINT_SCALE; vid++)
			tl_update_values_ease(vid)

	// Color
	if (value_type[e_value_type.MATERIAL_COLOR])
		for (var vid = e_value.ALPHA; vid <= e_value.WIND_INFLUENCE; vid++)
			tl_update_values_ease(vid)

	// Particles
	if (value_type[e_value_type.PARTICLES])
		for (var vid = e_value.SPAWN; vid <= e_value.FORCE_VORTEX; vid++)
			tl_update_values_ease(vid)

	// Light
	if (value_type[e_value_type.LIGHT])
	{
		for (var vid = e_value.LIGHT_COLOR; vid <= e_value.LIGHT_FADE_SIZE; vid++)
			tl_update_values_ease(vid)

		// Spotlight
		if (value_type[e_value_type.SPOTLIGHT])
			for (var vid = e_value.LIGHT_SPOT_RADIUS; vid <= e_value.LIGHT_SPOT_SHARPNESS; vid++)
				tl_update_values_ease(vid)
	}

	// Camera
	if (value_type[e_value_type.CAMERA])
		for (var vid = e_value.CAM_FOV; vid <= e_value.CAM_ROTATE_ANGLE_Z; vid++)
			tl_update_values_ease(vid)

	// Camera effects
	if (value_type[e_value_type.CAMERA_EFFECT])
	{
		var fxrange = camera_effect_value_range_list[|camera_effect_type];
		for (var vid = fxrange[0]; vid <= fxrange[1]; vid++)
			if (camera_effect_type != e_cam_fx.FADE || vid != e_value.GLOW_COLOR)
				tl_update_values_ease(vid)

		if (camera_effect_type_use_aperture(camera_effect_type))
			for (var vid = e_value.CAM_FX_BLADE_AMOUNT; vid <= e_value.CAM_FX_BLADE_STRETCH; vid++)
				tl_update_values_ease(vid)

		if (camera_effect_type = e_cam_fx.COLOR_CORRECTION)
			for (var vid = e_value.RGB_ADD; vid <= e_value.HSB_MUL; vid++)
				tl_update_values_ease(vid)

		if (camera_effect_type = e_cam_fx.LENS_DIRT)
			tl_update_values_ease(e_value.TEXTURE_OBJ)
	}

	// Background
	if (value_type[e_value_type.ENVIRONMENT])
		for (var vid = e_value.ENV_IMAGE_SHOW; vid <= e_value.ENV_BRIGHTNESS; vid++)
			tl_update_values_ease(vid)

	// Texture
	if (value_type[e_value_type.MATERIAL_TEXTURE] || value_type[e_value_type.ITEM])
		for (var vid = e_value.TEXTURE_OBJ; vid <= e_value.TEXTURE_NORMAL_OBJ; vid++)
			tl_update_values_ease(vid)

	// Sound
	if (value_type[e_value_type.SOUND])
		for (var vid = e_value.SOUND_OBJ; vid <= e_value.SOUND_END; vid++)
			tl_update_values_ease(vid)

	// Text
	if (value_type[e_value_type.TEXT])
		for (var vid = e_value.TEXT; vid <= e_value.TEXT_CUSTOM_OUTLINE; vid++)
			tl_update_values_ease(vid)

	// Item
	if (value_type[e_value_type.ITEM])
		for (var vid = e_value.CUSTOM_ITEM_SLOT; vid <= e_value.ITEM_SLOT; vid++)
			tl_update_values_ease(vid)

	// Visible
	tl_update_values_ease(e_value.VISIBLE)

}
