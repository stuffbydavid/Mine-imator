/// preview_event_create()
/// @desc Create event of a preview window.

function preview_event_create()
{
	select = null
	surface = null
	
	mouseon_prev = false
	
	pack_image = "preview"
	pack_image_material = "diffuse"
	pack_model_texture = "entity/player/wide/steve"
	pack_block_sheet_ani = false
	pack_colormap = 0
	pack_particles = 0
	pack_moon_phase = 0
	
	last_select = null
	texture = null
	reset_view = false
	sound_play_index = null
	sound_playing = false
	
	fov = 45
	xy_lock = false
	world_pos = point3D(0, 0, 0)
	preview_reset_view()
	particle_spawner_init()
	
	text_vbuffer = [null, null]
	text_texture = [null, null]
	text_string = ""
	text_res = null
	text_3d = false
}
