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

// Biomes
biome_list = ds_list_create()
ds_list_add(biome_list,
	new_biome("plains", 50, 173),
	new_biome("beach", 60, 191),
	new_biome("forest", 76, 112),
	new_biome("foresthills", 76, 122),
	new_biome("river", 128, 187),
	new_biome("swampland", 117, 124),
	new_biome("desert", 0, 255),
	new_biome("deserthills", 0, 255),
	new_biome("jungle", 0, 25),
	new_biome("junglehills", 0, 35),
	new_biome("mushroomisland", 25, 25),
	new_biome("mushroomislandshore", 25, 35),
	new_biome("extremehills", 203, 239),
	new_biome("extremehillsedge", 203, 249),
	new_biome("taiga", 242, 244),
	new_biome("taigahills", 242, 254),
	new_biome("iceplains", 249, 251),
	new_biome("icemountains", 249, 251),
	new_biome("frozenocean", 249, 255),
	new_biome("frozenriver", 249, 251),
	new_biome("mesa", 255, 255),
	new_biome("nether", 0, 255),
	new_biome("theend", 127, 189)
)

// Video templates
videotemplate_list = ds_list_create()
ds_list_add(videotemplate_list,
	new_videotemplate("Avatar", 150, 150),
	new_videotemplate("Multimedia", 320, 240),
	new_videotemplate("Internet", 640, 480),
	new_videotemplate("NTSC DV", 720, 480),
	new_videotemplate("PAL", 720, 576),
	new_videotemplate("HDV 720", 1280, 720),
	new_videotemplate("HD 1080", 1920, 1080),
	new_videotemplate("2K", 2048, 1152),
	new_videotemplate("4K", 4096, 2304)
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