/// temp_event_destroy()
/// @desc Destroy event of templates

if (model_texture_name_map != null)	
	ds_map_destroy(model_texture_name_map)
	
if (model_hide_list != null)
	ds_list_destroy(model_hide_list)
	
if (temp_creator != app.bench_settings)
{
	if (model_tex != null)
		model_tex.count--
		
	if (item_tex != null)
		item_tex.count--
		
	if (block_tex != null)
		block_tex.count--
		
	if (scenery > 0)
		scenery.count--
		
	if (shape_tex != null && shape_tex.type != e_tl_type.CAMERA)
		shape_tex.count--
		
	if (text_font != null)
		text_font.count--
}
	
if (item_vbuffer != null)
	vbuffer_destroy(item_vbuffer)

block_vbuffer_destroy()
	
if (type = e_temp_type.PARTICLE_SPAWNER)
	temp_particles_type_clear()
	
with (obj_timeline)
	if (temp = other.id && part_of == null)
		instance_destroy()

with (obj_particle_type)
	if (temp = other.id)
		temp = null
		
temp_edit = sortlist_remove(app.lib_list, id)
