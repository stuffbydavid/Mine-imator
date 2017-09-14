/// preview_event_create()
/// @desc Create event of a preview window.

select = null
surface = null

pack_image = "preview"
pack_model_texture = "entity/steve"
pack_block_sheet_ani = false
pack_colormap = 0
pack_particles = 0

last_select = null
texture = null
reset_view = false
sound_play_index = null

world_pos = point3D(0, 0, 0)
preview_reset_view()
particle_spawner_init()

text_vbuffer = null
text_texture = null
text_string = ""
text_res = null
text_3d = false