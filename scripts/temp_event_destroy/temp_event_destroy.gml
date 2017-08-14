/// temp_event_destroy()
/// @desc Destroy event of templates

if (temp_creator != app.bench_settings)
{
	if (char_skin)
		char_skin.count--
		
	if (item_tex)
		item_tex.count--
		
	if (block_tex)
		block_tex.count--
		
	if (scenery)
		scenery.count--
		
	if (shape_tex && shape_tex.type != "camera")
		shape_tex.count--
		
	if (text_font)
		text_font.count--
}

if (char_state_map)
	ds_map_destroy(char_state_map)
	
if (item_vbuffer)
	vbuffer_destroy(item_vbuffer)
	
if (block_state_map)
	ds_map_destroy(block_state_map)

block_vbuffer_destroy()
	
if (type = "particles")
	temp_particles_type_clear()

	
with (obj_timeline)
	if (temp = other.id && !part_of)
		instance_destroy()

with (obj_particle_type)
	if (temp = other.id)
		temp = null
		
temp_edit = sortlist_remove(app.lib_list, id)
