/// app_startup_lists()

globalvar value_name_list, transition_list;
globalvar temp_type_name_list, tl_type_name_list, res_type_name_list;
globalvar biome_list, videotemplate_list, videoquality_list;
globalvar language_english_map, language_map;

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
	"MIX_PERCENT",
	"BRIGHTNESS",
	"SPAWN",
	"FREEZE",
	"CLEAR",
	"CUSTOM_SEED",
	"SEED",
	"ATTRACTOR",
	"FORCE",
	"LIGHT_COLOR",
	"LIGHT_RANGE",
	"LIGHT_FADE_SIZE",
	"LIGHT_SPOT_RADIUS",
	"LIGHT_SPOT_SHARPNESS",
	"CAM_FOV",
	"CAM_ROTATE",
	"CAM_ROTATE_DISTANCE",
	"CAM_ROTATE_ANGLE_XY",
	"CAM_ROTATE_ANGLE_Z",
	"CAM_DOF",
	"CAM_DOF_DEPTH",
	"CAM_DOF_RANGE",
	"CAM_DOF_FADE_SIZE",
	"CAM_SIZE_USE_PROJECT",
	"CAM_SIZE_KEEP_ASPECT_RATIO",
	"CAM_WIDTH",
	"CAM_HEIGHT",
	"BG_SKY_MOON_PHASE",
	"BG_SKY_TIME",
	"BG_SKY_ROTATION",
	"BG_SKY_CLOUDS_SPEED",
	"BG_SKY_COLOR",
	"BG_SKY_CLOUDS_COLOR",
	"BG_SUNLIGHT_COLOR",
	"BG_AMBIENT_COLOR",
	"BG_NIGHT_COLOR",
	"BG_FOG_COLOR",
	"BG_FOG_DISTANCE",
	"BG_FOG_SIZE",
	"BG_FOG_HEIGHT",
	"BG_WIND_SPEED",
	"BG_WIND_STRENGTH",
	"BG_TEXTURE_ANI_SPEED",
	"TEXTURE_OBJ",
	"SOUND_OBJ",
	"SOUND_VOLUME",
	"SOUND_START",
	"SOUND_END",
	"TEXT",
	"TEXT_FONT",
	"VISIBLE",
	"TRANSITION"
)

// Template types
temp_type_name_list = ds_list_create()
ds_list_add(temp_type_name_list,
	"char",
	"spblock",
	"scenery",
	"item",
	"block",
	"bodypart",
	"particles",
	"text",
	"cube",
	"cone",
	"cylinder",
	"sphere",
	"surface",
	"model"
)

// Timeline types
tl_type_name_list = ds_list_create()
ds_list_add(tl_type_name_list,
	"char",
	"spblock",
	"scenery",
	"item",
	"block",
	"bodypart",
	"particles",
	"text",
	"cube",
	"cone",
	"cylinder",
	"sphere",
	"surface",
	"model",
	"camera",
	"spotlight",
	"pointlight",
	"folder",
	"background",
	"audio"
)

// Resource types
res_type_name_list = ds_list_create()
ds_list_add(res_type_name_list,
	"pack",
	"packunzipped",
	"skin",
	"downloadskin",
	"itemsheet",
	"legacyblocksheet",
	"blocksheet",
	"schematic",
	"fromworld",
	"particlesheet",
	"texture",
	"font",
	"sound",
	"model"
)

// Transitions
transition_list = ds_list_create()
ds_list_add(transition_list,
	"linear",
	"instant",
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

log("Make transitions")
transition_texture_map = new_transition_texture_map(60, 60, 12)
transition_texture_small_map = new_transition_texture_map(36, 36, 2)
log("Transitions OK")

// Video templates
videotemplate_list = ds_list_create()
ds_list_add(videotemplate_list,
	new_videotemplate("avatar", 512, 512),
	new_videotemplate("hd_720p", 1280, 720),
	new_videotemplate("fhd_1080p", 1920, 1080),
	new_videotemplate("qhd_1440p", 2560, 1440),
	new_videotemplate("uhd_4k", 3840, 2160),
	new_videotemplate("hd_720p_cinematic", 1680, 720),
	new_videotemplate("fhd_1080p_cinematic", 2560, 1080),
	new_videotemplate("qhd_1440p_cinematic", 3440, 1440),
	new_videotemplate("uhd_4k_cinematic", 5120, 2160)
)

// Video qualities
videoquality_list = ds_list_create()
ds_list_add(videoquality_list,
	new_videoquality("best", 5000000),
	new_videoquality("high", 2500000),
	new_videoquality("medium", 1200000),
	new_videoquality("low", 700000),
	new_videoquality("verylow", 350000),
)

// Language
language_english_map = ds_map_create()
language_map = ds_map_create()

language_load(language_file, language_english_map)
ds_map_copy(language_map, language_english_map)

// Biomes
biome_list = ds_list_create()
ds_list_add(biome_list, new_biome("custom", 0, 0, true, c_plains_biome_grass, c_plains_biome_foliage, c_plains_biome_water, null))