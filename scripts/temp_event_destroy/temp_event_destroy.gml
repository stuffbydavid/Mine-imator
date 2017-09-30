/// temp_event_destroy()
/// @desc Destroy event of templates

if (temp_creator != app.bench_settings)
{
	if (skin != null)
		skin.count--
		
	if (item_tex != null)
		item_tex.count--
		
	if (block_tex != null)
		block_tex.count--
		
	if (scenery > 0)
		scenery.count--
		
	if (shape_tex != null && shape_tex.type != "camera")
		shape_tex.count--
		
	if (text_font != null)
		text_font.count--
}
	
if (item_vbuffer != null)
	vbuffer_destroy(item_vbuffer)

block_vbuffer_destroy()
	
if (type = "particles")
	temp_particles_type_clear()
	
with (obj_timeline)
	if (temp = other.id && part_of == null)
		instance_destroy()

with (obj_particle_type)
	if (temp = other.id)
		temp = null
		
temp_edit = sortlist_remove(app.lib_list, id)
