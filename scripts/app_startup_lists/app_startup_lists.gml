/// app_startup_lists()

globalvar language_english_map, language_map;
globalvar biome_list, transition_list, values_list;

log("Lists startup")

// Language
language_english_map = ds_map_create()
language_map = ds_map_create()

language_load(language_file, language_english_map)
ds_map_copy(language_map, language_english_map)

// Biomes
biome_list = ds_list_create()
ds_list_add(biome_list,
	new_biome("biomeplains", 48, 146),
	new_biome("biomebeach", 60, 191),
	new_biome("biomeforest", 82, 106),
	new_biome("biomeforesthills", 44, 163),
	new_biome("biomeriver", 84, 155),
	new_biome("biomeswampland", 117, 124),
	new_biome("biomedesert", 45, 86),
	new_biome("biomedeserthills", 66, 135),
	new_biome("biomejungle", 35, 178),
	new_biome("biomejunglehills", 26, 134),
	new_biome("biomemushroomisland", 31, 122),
	new_biome("biomemushroomislandshore", 15, 211),
	new_biome("biomeextremehills", 141, 239),
	new_biome("biomeextremehillsedge", 166, 181),
	new_biome("biometaiga", 120, 245),
	new_biome("biometaigahills", 136, 213),
	new_biome("biomeiceplains", 172, 199),
	new_biome("biomeicemountains", 189, 214),
	new_biome("biomefrozenocean", 187, 230),
	new_biome("biomefrozenriver", 199, 215)
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
transition_texture = app_startup_make_transition_texture(60, 60, 12)
transition_texture_small = app_startup_make_transition_texture(36, 36, 2)
log("Transitions OK")

// Video templates
new_videotemplate("4K", 4096, 2304)
new_videotemplate("2K", 2048, 1152)
new_videotemplate("HD 1080", 1920, 1080)
new_videotemplate("HDV 720", 1280, 720)
new_videotemplate("PAL", 720, 576)
new_videotemplate("NTSC DV", 720, 480)
new_videotemplate("Internet", 640, 480)
new_videotemplate("Multimedia", 320, 240)
new_videotemplate("Avatar", 150, 150)

// Video qualitys
new_videoquality("exportmovievideoqualitybest", 5000000)
new_videoquality("exportmovievideoqualityhigh", 2500000)
new_videoquality("exportmovievideoqualitymedium", 1200000)
new_videoquality("exportmovievideoqualitylow", 700000)
new_videoquality("exportmovievideoqualityverylow", 350000)

// Values
values_list = ds_list_create()
ds_list_add(values_list,
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
	"VISIBLE",
	"TRANSITION"
)
