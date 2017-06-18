/// res_init()
/// @desc Initializes the variables of a template.

loaded = false
creator = res_creator

replaced = false
ready = true

type = ""
filename = ""
filename_out = ""
display_name = ""
pack_description = ""
count = 0

model = null
model_texture = null
model_texture_map = null
is_skin = false

block_sheet_texture = null
block_sheet_ani_texture = null
block_sheet_depth_list = null
block_sheet_ani_depth_list = null

//block_frames = 0
//block_ani[0] = 0
block_texture[32] = 0
block_preview_texture = null
block_format = null
colormap_grass_texture = null
colormap_foliage_texture = null
color_grass = null
color_foliage = null
sun_texture = null
moonphases_texture = null
moon_texture[8] = null
clouds_texture = null

item_texture = null
is_item_sheet = true
item_sheet_size = vec2(item_sheet_width, item_sheet_height)

particles_texture[0] = null
particles_texture[1] = null

block_vbuffer_reset()
scenery_size = vec3(0)

texture = null

font = null
font_preview = null
font_minecraft = false

sound_buffer = null
sound_index = null

load_stage = ""
load_audio_sample = 0
