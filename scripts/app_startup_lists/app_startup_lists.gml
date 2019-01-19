/// app_startup_lists()

globalvar value_name_list, transition_list;
globalvar temp_type_name_list, tl_type_name_list, res_type_name_list;
globalvar biome_list, videotemplate_list, videoquality_list;
globalvar language_english_map, language_map;
globalvar camera_values_list, camera_values_copy, camera_use_default_list;
globalvar minecraft_color_name_list, minecraft_color_list, minecraft_banner_pattern_list, minecraft_banner_pattern_short_list;

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
	"CAM_DOF_BLUR_SIZE",
	"CAM_DOF_FRINGE",
	"CAM_DOF_FRINGE_ANGLE_RED",
	"CAM_DOF_FRINGE_ANGLE_GREEN",
	"CAM_DOF_FRINGE_ANGLE_BLUE",
	"CAM_DOF_FRINGE_RED",
	"CAM_DOF_FRINGE_GREEN",
	"CAM_DOF_FRINGE_BLUE",
	"CAM_BLOOM",
	"CAM_BLOOM_THRESHOLD",
	"CAM_BLOOM_INTENSITY",
	"CAM_BLOOM_RADIUS",
	"CAM_BLOOM_BLEND",
	"CAM_COLOR_CORRECTION",
	"CAM_CONTRAST",
	"CAM_BRIGHTNESS",
	"CAM_SATURATION",
	"CAM_COLOR_BURN",
	"CAM_GRAIN",
	"CAM_GRAIN_STRENGTH",
	"CAM_GRAIN_SATURATION",
	"CAM_GRAIN_SIZE",
	"CAM_VIGNETTE",
	"CAM_VIGNETTE_RADIUS",
	"CAM_VIGNETTE_SOFTNESS",
	"CAM_VIGNETTE_STRENGTH",
	"CAM_SIZE_USE_PROJECT",
	"CAM_SIZE_KEEP_ASPECT_RATIO",
	"CAM_WIDTH",
	"CAM_HEIGHT",
	"BG_IMAGE_SHOW",
	"BG_SKY_MOON_PHASE",
	"BG_SKY_TIME",
	"BG_SKY_ROTATION",
	"BG_SUNLIGHT_RANGE",
	"BG_SUNLIGHT_FOLLOW",
	"BG_SUNLIGHT_STRENGTH",
	"BG_DESATURATE_NIGHT",
	"BG_DESATURATE_NIGHT_AMOUNT",
	"BG_SKY_CLOUDS_SHOW",
	"BG_SKY_CLOUDS_SPEED",
	"BG_SKY_CLOUDS_Z",
	"BG_SKY_CLOUDS_OFFSET",
	"BG_GROUND_SHOW",
	"BG_SKY_COLOR",
	"BG_SKY_CLOUDS_COLOR",
	"BG_SUNLIGHT_COLOR",
	"BG_AMBIENT_COLOR",
	"BG_NIGHT_COLOR",
	"BG_GRASS_COLOR",
	"BG_FOLIAGE_COLOR",
	"BG_WATER_COLOR",
	"BG_FOG_SHOW",
	"BG_FOG_SKY",
	"BG_FOG_CUSTOM_COLOR",
	"BG_FOG_COLOR",
	"BG_FOG_CUSTOM_OBJECT_COLOR",
	"BG_FOG_OBJECT_COLOR",
	"BG_FOG_DISTANCE",
	"BG_FOG_SIZE",
	"BG_FOG_HEIGHT",
	"BG_WIND",
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
	var valueid = e_value.CAM_FOV + i;
	
	if (tl_value_is_bool(valueid))
		camera_use_default_list[|i] = false
	else if (valueid = e_value.CAM_WIDTH || valueid = e_value.CAM_HEIGHT)
		camera_use_default_list[|i] = null
	else
		camera_use_default_list[|i] = true
}

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
	new_videoquality("verylow", 350000)
)

// Language
language_english_map = ds_map_create()
language_map = ds_map_create()

language_load(language_file, language_english_map)
ds_map_copy(language_map, language_english_map)

// Biomes
biome_list = ds_list_create()
ds_list_add(biome_list, new_biome("custom", 0, 0, true, c_plains_biome_grass, c_plains_biome_foliage, c_plains_biome_water, null))

// Minecraft colors
minecraft_color_name_list = ds_list_create()
ds_list_add(minecraft_color_name_list,
	"white",
	"orange",
	"magenta",
	"light_blue",
	"yellow",
	"lime",
	"pink",
	"gray",
	"light_gray",
	"cyan",
	"purple",
	"blue",
	"brown",
	"green",
	"red",
	"black"
)

minecraft_color_list = ds_list_create()
ds_list_add(minecraft_color_list,
	c_minecraft_white,
	c_minecraft_orange,
	c_minecraft_magenta,
	c_minecraft_light_blue,
	c_minecraft_yellow,
	c_minecraft_lime,
	c_minecraft_pink,
	c_minecraft_gray,
	c_minecraft_light_gray,
	c_minecraft_cyan,
	c_minecraft_purple,
	c_minecraft_blue,
	c_minecraft_brown,
	c_minecraft_green,
	c_minecraft_red,
	c_minecraft_black
)

minecraft_banner_pattern_list = ds_list_create()
ds_list_add(minecraft_banner_pattern_list,
	"base",
	"border",
	"bricks",
	"circle",
	"creeper",
	"cross",
	"curly_border",
	"diagonal_left",
	"diagonal_right",
	"diagonal_up_left",
	"diagonal_up_right",
	"flower",
	"gradient",
	"gradient_up",
	"half_horizontal",
	"half_horizontal_bottom",
	"half_vertical",
	"half_vertical_right",
	"mojang",
	"rhombus",
	"skull",
	"small_stripes",
	"square_bottom_left",
	"square_bottom_right",
	"square_top_left",
	"square_top_right",
	"straight_cross",
	"stripe_bottom",
	"stripe_center",
	"stripe_downleft",
	"stripe_downright",
	"stripe_left",
	"stripe_middle",
	"stripe_right",
	"stripe_top",
	"triangle_bottom",
	"triangle_top",
	"triangles_bottom",
	"triangles_top"
)

minecraft_banner_pattern_short_list = ds_list_create()
ds_list_add(minecraft_banner_pattern_short_list,
	"",
	"bo",
	"bri",
	"mc",
	"cre",
	"cr",
	"cbo",
	"ld",
	"rud",
	"lud",
	"rd",
	"flo",
	"gra",
	"gru",
	"hh",
	"hhb",
	"vh",
	"vhr",
	"moj",
	"mr",
	"sku",
	"ss",
	"bl",
	"br",
	"tl",
	"tr",
	"sc",
	"bs",
	"cs",
	"dls",
	"drs",
	"ls",
	"ms",
	"rs",
	"ts",
	"bt",
	"tt",
	"tts",
	"bts"
)