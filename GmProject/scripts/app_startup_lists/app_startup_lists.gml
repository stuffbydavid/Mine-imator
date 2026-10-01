function app_startup_lists()
{
	globalvar value_name_list, transition_list, transition_list_order;
	globalvar camera_effect_name_list, camera_effect_advanced_name_list, camera_effect_value_range_list, camera_effect_legacy_name_list;
	globalvar temp_type_name_list, tl_type_name_list, res_type_name_list;
	globalvar videotemplate_list;
	globalvar language_english_map, language_map;
	globalvar camera_values_list, camera_values_copy, camera_use_default_list;
	globalvar minecraft_block_sheet_size;
	globalvar minecraft_block_animated_sheet_frame_count, minecraft_item_sheet_size, minecraft_item_place_target_map;
	globalvar minecraft_pattern_list, minecraft_pattern_short_list, minecraft_sherd_map;
	globalvar minecraft_armor_trim_pattern_list, minecraft_armor_trim_material_list;
	globalvar minecraft_map_color_array, minecraft_swatch_array, minecraft_swatch_color_map, minecraft_swatch_dyes;
	globalvar biome_list, particle_template_list, particle_template_map;
	globalvar blend_mode_list, blend_mode_map;
	globalvar timeline_icon_list, timeline_icon_list_dark;
	globalvar render_pass_list;
	
	// Values
	value_name_list = ds_list_create()
	ds_list_add(value_name_list,
		"POS_X",
		"POS_Y",
		"POS_Z",
		"ROT_X",
		"ROT_Y",
		"ROT_Z",
		"SCA_X",
		"SCA_Y",
		"SCA_Z",
		"BEND_ANGLE",
		"BEND_ANGLE_X",
		"BEND_ANGLE_Y",
		"BEND_ANGLE_Z",
		"ALPHA",
		"RGB_ADD",
		"RGB_SUB",
		"RGB_MUL",
		"HSB_ADD",
		"HSB_SUB",
		"HSB_MUL",
		"MIX_COLOR",
		"GLOW_COLOR",
		"MIX_PERCENT",
		"EMISSIVE",
		"METALLIC",
		"ROUGHNESS",
		"SUBSURFACE",
		"SUBSURFACE_RADIUS_RED",
		"SUBSURFACE_RADIUS_GREEN",
		"SUBSURFACE_RADIUS_BLUE",
		"SUBSURFACE_COLOR",
		"WIND_INFLUENCE",
		"SPAWN",
		"FREEZE",
		"CLEAR",
		"CUSTOM_SEED",
		"SEED",
		"ATTRACTOR",
		"FORCE",
		"FORCE_DIRECTIONAL",
		"FORCE_VORTEX",
		"LIGHT_COLOR",
		"LIGHT_STRENGTH",
		"LIGHT_SPECULAR_STRENGTH",
		"LIGHT_SIZE",
		"LIGHT_RANGE",
		"LIGHT_FADE_SIZE",
		"LIGHT_SPOT_RADIUS",
		"LIGHT_SPOT_SHARPNESS",
		"CAM_FOV",
		"CAM_SIZE_USE_PROJECT",
		"CAM_SIZE_KEEP_ASPECT_RATIO",
		"CAM_WIDTH",
		"CAM_HEIGHT",
		"CAM_ROTATE",
		"CAM_ROTATE_DISTANCE",
		"CAM_ROTATE_ANGLE_XY",
		"CAM_ROTATE_ANGLE_Z",
		"CAM_FX_SHAKE_MODE",
		"CAM_FX_SHAKE_STRENGTH_X",
		"CAM_FX_SHAKE_STRENGTH_Y",
		"CAM_FX_SHAKE_STRENGTH_Z",
		"CAM_FX_SHAKE_SPEED_X",
		"CAM_FX_SHAKE_SPEED_Y",
		"CAM_FX_SHAKE_SPEED_Z",
		"CAM_FX_DOF_DEPTH",
		"CAM_FX_DOF_RANGE",
		"CAM_FX_DOF_FADE_SIZE",
		"CAM_FX_DOF_BLUR_SIZE",
		"CAM_FX_DOF_BLUR_RATIO",
		"CAM_FX_DOF_BIAS",
		"CAM_FX_DOF_THRESHOLD",
		"CAM_FX_DOF_GAIN",
		"CAM_FX_DOF_FRINGE",
		"CAM_FX_DOF_FRINGE_ANGLE_RED",
		"CAM_FX_DOF_FRINGE_ANGLE_GREEN",
		"CAM_FX_DOF_FRINGE_ANGLE_BLUE",
		"CAM_FX_DOF_FRINGE_RED",
		"CAM_FX_DOF_FRINGE_GREEN",
		"CAM_FX_DOF_FRINGE_BLUE",
		"CAM_FX_BLOOM_THRESHOLD",
		"CAM_FX_BLOOM_TRANSITION",
		"CAM_FX_BLOOM_INTENSITY",
		"CAM_FX_BLOOM_RADIUS",
		"CAM_FX_BLOOM_RATIO",
		"CAM_FX_BLOOM_BLEND",
		"CAM_FX_BLADE_AMOUNT",
		"CAM_FX_BLADE_ANGLE",
		"CAM_FX_BLADE_STRETCH",
		"CAM_FX_LENS_DIRT_BLOOM",
		"CAM_FX_LENS_DIRT_GLOW",
		"CAM_FX_LENS_DIRT_RADIUS",
		"CAM_FX_LENS_DIRT_INTENSITY",
		"CAM_FX_LENS_DIRT_POWER",
		"CAM_FX_GRAIN_STRENGTH",
		"CAM_FX_GRAIN_SATURATION",
		"CAM_FX_GRAIN_SIZE",
		"CAM_FX_VIGNETTE_RADIUS",
		"CAM_FX_VIGNETTE_SOFTNESS",
		"CAM_FX_VIGNETTE_STRENGTH",
		"CAM_FX_VIGNETTE_COLOR",
		"CAM_FX_CA_BLUR_AMOUNT",
		"CAM_FX_CA_DISTORT_CHANNELS",
		"CAM_FX_CA_RED_OFFSET",
		"CAM_FX_CA_GREEN_OFFSET",
		"CAM_FX_CA_BLUE_OFFSET",
		"CAM_FX_DISTORT_REPEAT",
		"CAM_FX_DISTORT_ZOOM_AMOUNT",
		"CAM_FX_DISTORT_AMOUNT",
		"CAM_FX_TONEMAPPER",
		"CAM_FX_EXPOSURE",
		"CAM_FX_GAMMA",
		"CAM_FX_CONTRAST",
		"CAM_FX_BRIGHTNESS",
		"CAM_FX_SATURATION",
		"CAM_FX_VIBRANCE",
		"CAM_FX_COLOR_BURN",
		"ENV_IMAGE_SHOW",
		"ENV_IMAGE_ROTATION",
		"ENV_SKY_MOON_PHASE",
		"ENV_SKY_TIME",
		"ENV_SKY_ROTATION",
		"ENV_SUNLIGHT_STRENGTH",
		"ENV_SUNLIGHT_SPECULAR_STRENGTH",
		"ENV_SUNLIGHT_ANGLE",
		"ENV_SKY_SUN_ANGLE",
		"ENV_SKY_SUN_SCALE",
		"ENV_SKY_MOON_ANGLE",
		"ENV_SKY_MOON_SCALE",
		"ENV_TWILIGHT",
		"ENV_SKY_CLOUDS_SHOW",
		"ENV_SKY_CLOUDS_SPEED",
		"ENV_SKY_CLOUDS_OFFSET_Y",
		"ENV_SKY_CLOUDS_OFFSET_Z",
		"ENV_GROUND_SHOW",
		"ENV_GROUND_SLOT",
		"ENV_BIOME",
		"ENV_SKY_COLOR",
		"ENV_SKY_CLOUDS_COLOR",
		"ENV_SUNLIGHT_COLOR",
		"ENV_AMBIENT_COLOR",
		"ENV_NIGHT_SKY_COLOR",
		"ENV_NIGHT_SKY_CLOUDS_COLOR",
		"ENV_NIGHT_SKY_STARS_COLOR",
		"ENV_NIGHT_COLOR",
		"ENV_GRASS_COLOR",
		"ENV_FOLIAGE_COLOR",
		"ENV_DRY_FOLIAGE_COLOR",
		"ENV_WATER_COLOR",
		"ENV_LEAVES_OAK_COLOR",
		"ENV_LEAVES_SPRUCE_COLOR",
		"ENV_LEAVES_BIRCH_COLOR",
		"ENV_LEAVES_JUNGLE_COLOR",
		"ENV_LEAVES_ACACIA_COLOR",
		"ENV_LEAVES_DARK_OAK_COLOR",
		"ENV_LEAVES_MANGROVE_COLOR",
		"ENV_FOG_SHOW",
		"ENV_FOG_SKY",
		"ENV_FOG_CUSTOM_COLOR",
		"ENV_FOG_COLOR",
		"ENV_FOG_CUSTOM_OBJECT_COLOR",
		"ENV_FOG_OBJECT_COLOR",
		"ENV_FOG_DISTANCE",
		"ENV_FOG_SIZE",
		"ENV_FOG_HEIGHT",
		"ENV_WIND",
		"ENV_WIND_SPEED",
		"ENV_WIND_STRENGTH",
		"ENV_WIND_DIRECTION",
		"ENV_WIND_DIRECTIONAL_SPEED",
		"ENV_WIND_DIRECTIONAL_STRENGTH",
		"ENV_TEXTURE_ANI_SPEED",
		"ENV_BRIGHTNESS",
		"TEXTURE_OBJ",
		"TEXTURE_MATERIAL_OBJ",
		"TEXTURE_NORMAL_OBJ",
		"SOUND_OBJ",
		"SOUND_VOLUME",
		"SOUND_PITCH",
		"SOUND_START",
		"SOUND_END",
		"TEXT",
		"TEXT_FONT",
		"TEXT_HALIGN",
		"TEXT_VALIGN",
		"TEXT_CUSTOM_ALIGNMENT",
		"TEXT_OUTLINE",
		"TEXT_OUTLINE_COLOR",
		"TEXT_OUTLINE_SIZE",
		"TEXT_CUSTOM_OUTLINE",
		"CUSTOM_ITEM_SLOT",
		"ITEM_SLOT",
		"ITEM_NAME",
		"PATH_OBJ",
		"PATH_OFFSET",
		"PATH_POINT_ANGLE",
		"PATH_POINT_SCALE",
		"IK_TARGET",
		"IK_BLEND",
		"IK_TARGET_ANGLE",
		"IK_ANGLE_OFFSET",
		"VISIBLE",
		"TRANSITION",
		"EASE_IN_X",
		"EASE_IN_Y",
		"EASE_OUT_X",
		"EASE_OUT_Y"
	)
	
	// Camera values
	camera_values_list = ds_list_create()
	
	for (var i = e_value.CAM_FOV; i <= e_value.CAM_HEIGHT; i++)
		ds_list_add(camera_values_list, i)
	
	camera_values_copy = ds_list_create()
	for (var i = 0; i < ds_list_size(camera_values_list); i++)
		camera_values_copy[|i] = tl_value_default(camera_values_list[|i])
	
	camera_use_default_list = ds_list_create()
	
	for (var i = 0; i < ds_list_size(camera_values_list); i++)
	{
		var valueid = camera_values_list[|i];
		
		if (tl_value_is_bool(valueid))
			camera_use_default_list[|i] = false
		else if (valueid = e_value.CAM_WIDTH || valueid = e_value.CAM_HEIGHT)
			camera_use_default_list[|i] = null
		else
			camera_use_default_list[|i] = true
	}
	
	// Camera effects
	camera_effect_name_list = ds_list_create()
	ds_list_add(camera_effect_name_list,
		"fade",
		"shake",
		"dof",
		"bloom",
		"lensdirt",
		"grain",
		"vignette",
		"ca",
		"distort",
		"lightmanagement",
		"colorcorrection"
	)
	
	camera_effect_advanced_name_list = ds_list_create()
	ds_list_add(camera_effect_advanced_name_list,
		"shake",
		"dof",
		"bloom",
		"lensdirt",
		"ca",
		"distort"
	)
	
	camera_effect_value_range_list = ds_list_create()
	ds_list_add(camera_effect_value_range_list,
		[ e_value.MIX_COLOR, e_value.MIX_PERCENT ],
		[ e_value.CAM_FX_SHAKE_MODE, e_value.CAM_FX_SHAKE_SPEED_Z ],
		[ e_value.CAM_FX_DOF_DEPTH, e_value.CAM_FX_DOF_FRINGE_BLUE ],
		[ e_value.CAM_FX_BLOOM_THRESHOLD, e_value.CAM_FX_BLOOM_BLEND ],
		[ e_value.CAM_FX_LENS_DIRT_BLOOM, e_value.CAM_FX_LENS_DIRT_POWER ],
		[ e_value.CAM_FX_GRAIN_STRENGTH, e_value.CAM_FX_GRAIN_SIZE ],
		[ e_value.CAM_FX_VIGNETTE_RADIUS, e_value.CAM_FX_VIGNETTE_COLOR ],
		[ e_value.CAM_FX_CA_BLUR_AMOUNT, e_value.CAM_FX_CA_BLUE_OFFSET ],
		[ e_value.CAM_FX_DISTORT_REPEAT, e_value.CAM_FX_DISTORT_AMOUNT ],
		[ e_value.CAM_FX_TONEMAPPER, e_value.CAM_FX_GAMMA ],
		[ e_value.CAM_FX_CONTRAST, e_value.CAM_FX_COLOR_BURN ]
	)
	
	camera_effect_legacy_name_list = ds_list_create()
	ds_list_add(camera_effect_legacy_name_list,
		"",
		"CAM_SHAKE",
		"CAM_DOF",
		"CAM_BLOOM",
		"CAM_LENS_DIRT",
		"CAM_GRAIN",
		"CAM_VIGNETTE",
		"CAM_CA",
		"CAM_DISTORT",
		"CAM_LIGHT_MANAGEMENT",
		"CAM_COLOR_CORRECTION"
	)
	
	// Template types
	temp_type_name_list = ds_list_create()
	ds_list_add(temp_type_name_list,
		"char",
		"equipment",
		"model",
		"modelpart",
		"item",
		"scenery",
		"block",
		"spblock",
		"particles",
		"text",
		"cube",
		"cone",
		"cylinder",
		"sphere",
		"surface"
	)
	
	// Timeline types
	tl_type_name_list = ds_list_create()
	ds_list_add(tl_type_name_list,
		"char",
		"equipment",
		"model",
		"modelpart",
		"item",
		"scenery",
		"block",
		"spblock",
		"particles",
		"text",
		"cube",
		"cone",
		"cylinder",
		"sphere",
		"surface",
		"camera",
		"cameraeffect",
		"audio",
		"pointlight",
		"spotlight",
		"path",
		"pathpoint",
		"environment",
		"structure",
		"folder"
	)
	
	// Resource types
	res_type_name_list = ds_list_create()
	ds_list_add(res_type_name_list,
		"pack",
		"packunzipped",
		"skin",
		"downloadskin",
		"model",
		"itemsheet",
		"fromworld",
		"schematic",
		"blocksheet",
		"legacyblocksheet",
		"sound",
		"particlesheet",
		"font",
		"texture"
	)
	
	// Transitions
	transition_list = ds_list_create()
	ds_list_add(transition_list,
		"linear",
		"instant",
		"bezier",
		"easeinquad",
		"easeoutquad",
		"easeinoutquad",
		"easeincubic",
		"easeoutcubic",
		"easeinoutcubic",
		"easeinquart",
		"easeoutquart",
		"easeinoutquart",
		"easeinquint",
		"easeoutquint",
		"easeinoutquint",
		"easeinsine",
		"easeoutsine",
		"easeinoutsine",
		"easeinexpo",
		"easeoutexpo",
		"easeinoutexpo",
		"easeincirc",
		"easeoutcirc",
		"easeinoutcirc",
		"easeinelastic",
		"easeoutelastic",
		"easeinoutelastic",
		"easeinback",
		"easeoutback",
		"easeinoutback",
		"easeinbounce",
		"easeoutbounce",
		"easeinoutbounce"
	)
	
	// Organized list
	transition_list_order = ds_list_create()
	
	for (var i = 0; i < ds_list_size(transition_list); i++)
		if (!string_contains(transition_list[|i], "ease"))
			ds_list_add(transition_list_order, transition_list[|i])
	
	for (var i = 0; i < ds_list_size(transition_list); i++)
		if (string_contains(transition_list[|i], "easein") &&
			!string_contains(transition_list[|i], "easeinout"))
				ds_list_add(transition_list_order, transition_list[|i])
	
	for (var i = 0; i < ds_list_size(transition_list); i++)
		if (string_contains(transition_list[|i], "easeout"))
			ds_list_add(transition_list_order, transition_list[|i])
	
	for (var i = 0; i < ds_list_size(transition_list); i++)
		if (string_contains(transition_list[|i], "easeinout"))
			ds_list_add(transition_list_order, transition_list[|i])
	
	log("Make transitions")
	transition_texture_map = new_transition_texture_map(36, 36, 6, true)
	transition_texture_small_map = new_transition_texture_map(24, 24, 3, false)
	
	// Video templates
	videotemplate_list = ds_list_create()
	ds_list_add(videotemplate_list,
		new_videotemplate("avatar", 512, 512),
		new_videotemplate("vga", 640, 480),
		new_videotemplate("hd_720p", 1280, 720),
		new_videotemplate("fhd_1080p", 1920, 1080),
		new_videotemplate("qhd_1440p", 2560, 1440),
		new_videotemplate("uhd_4k", 3840, 2160),
		new_videotemplate("hd_720p_cinematic", 1680, 720),
		new_videotemplate("fhd_1080p_cinematic", 2560, 1080),
		new_videotemplate("qhd_1440p_cinematic", 3440, 1440),
		new_videotemplate("uhd_4k_cinematic", 5120, 2160)
	)
	
	// Language
	language_english_map = ds_map_create()
	language_map = ds_map_create()
	
	language_load(language_file, language_english_map)
	ds_map_copy(language_map, language_english_map)
	language_new(language_file)
	
	// Biomes
	biome_list = ds_list_create()
	ds_list_add(biome_list, new_biome("custom", 0, 0, true, c_plains_biome_grass, c_plains_biome_foliage, c_plains_biome_dry_foliage, c_plains_biome_water, null))
	
	// Particles
	particle_template_list = ds_list_create()
	particle_template_map = ds_map_create()
	
	minecraft_block_sheet_size = array_create(e_block_sheet.amount)
	for (var size = 0; size < e_block_sheet.amount; size++)
		minecraft_block_sheet_size[size] = vec2(0, 0)
	minecraft_block_animated_sheet_frame_count = 0
	minecraft_item_sheet_size = array_create(e_item_sheet.amount)
	for (var size = 0; size < e_item_sheet.amount; size++)
		minecraft_item_sheet_size[size] = vec2(0, 0)
	minecraft_item_place_target_map = ds_map_create()
	
	minecraft_pattern_list = ds_list_create()
	minecraft_pattern_short_list = ds_list_create()
	minecraft_sherd_map = ds_map_create()
	
	minecraft_armor_trim_pattern_list = ds_list_create()
	minecraft_armor_trim_material_list = ds_list_create()
	minecraft_map_color_array = []
	minecraft_swatch_array = []
	minecraft_swatch_color_map = ds_map_create()
	
	blend_mode_list = ds_list_create()
	ds_list_add(blend_mode_list,
		"normal",
		"add",
		"subtract",
		"multiply",
		"screen"
	)
	
	blend_mode_map = ds_map_create()
	ds_map_add(blend_mode_map, "normal", bm_normal)
	ds_map_add(blend_mode_map, "add", bm_add)
	ds_map_add(blend_mode_map, "subtract", bm_subtract)
	ds_map_add(blend_mode_map, "multiply", [ bm_zero, bm_src_color ])
	ds_map_add(blend_mode_map, "screen", [ bm_one, bm_inv_src_color ])
	
	// List of icons in sync with e_tl_type
	/*
		CHARACTER,
		EQUIPMENT,
		MODEL,
		MODEL_PART,
		ITEM,
		SCENERY,
		BLOCK,
		SPECIAL_BLOCK,
		PARTICLE_SPAWNER,
		TEXT,
		CUBE,
		CONE,
		CYLINDER,
		SPHERE,
		SURFACE,
		CAMERA,
		AUDIO_TRACK,
		POINT_LIGHT,
		SPOT_LIGHT,
		PATH,
		PATH_POINT,
		ENVIRONMENT,
		STRUCTURE,
		FOLDER
	*/
	
	timeline_icon_list = ds_list_create()
	ds_list_add(timeline_icon_list,
		icons.CHARACTER,
		icons.SHIELD,
		icons.MODEL,
		icons.PART,
		icons.ITEM,
		icons.SCENERY,
		icons.BLOCK,
		icons.BLOCK_SPECIAL,
		icons.FIREWORKS,
		icons.TEXT,
		icons.CUBE,
		icons.CONE,
		icons.CYLINDER,
		icons.SPHERE,
		icons.PLANE,
		icons.CAMERA,
		icons.WAND,
		icons.NOTE,
		icons.LIGHT_POINT,
		icons.LIGHT_SPOT,
		icons.PATH,
		icons.PATH_POINT,
		icons.CLOUD,
		icons.SCENERY,
		icons.FOLDER
	)
	
	timeline_icon_list_dark = ds_list_create()
	ds_list_add(timeline_icon_list_dark,
		icons.CHARACTER,
		icons.SHIELD,
		icons.MODEL,
		icons.PART,
		icons.ITEM,
		icons.SCENERY,
		icons.BLOCK,
		icons.BLOCK_SPECIAL,
		icons.FIREWORKS,
		icons.TEXT,
		icons.CUBE_DARK,
		icons.CONE_DARK,
		icons.CYLINDER_DARK,
		icons.SPHERE_DARK,
		icons.PLANE,
		icons.CAMERA,
		icons.WAND,
		icons.NOTE,
		icons.LIGHT_POINT,
		icons.LIGHT_SPOT,
		icons.PATH,
		icons.PATH_POINT,
		icons.CLOUD,
		icons.SCENERY,
		icons.FOLDER
	)
	
	render_pass_list = ds_list_create()
	ds_list_add(render_pass_list,
		"combined",
		"depth",
		"normal",
		"material",
		"diffuse",
		"specular",
		"ao",
		"shadows",
		"indirect",
		"indirectshadows",
		"reflections",
		"fog",
		"mask",
		"glow",
		"subsurface",
		"subsurfacerange",
		"emissive",
		"roughness",
		"metallic",
		"fresnel",
		"ssaomask",
		"bloomthreshold",
		"bloomblur",
		"all"
	)
}
