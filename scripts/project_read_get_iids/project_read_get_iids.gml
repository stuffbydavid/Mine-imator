/// project_read_get_iids(import)
/// @arg import


// Get real ids
log("Get template iids")
with (obj_template)
{
	if (!loaded)
		continue
		
	char_skin = iid_find(char_skin)
	item_tex = iid_find(item_tex)
	block_tex = iid_find(block_tex)
	scenery = iid_find(scenery)
	shape_tex = iid_find(shape_tex)
	text_font = iid_find(text_font)
	if (temp_creator != app.bench_settings)
	{
		if (char_skin)
			char_skin.count++
			
		if (item_tex)
			item_tex.count++
			
		if (block_tex)
			block_tex.count++
			
		if (scenery)
			scenery.count++
			
		if (shape_tex && shape_tex.type != "camera")
			shape_tex.count++
			
		if (text_font)
			text_font.count++
	}
}

log("Get particle type iids")
with (obj_particle_type)
{
	if (!loaded)
		continue
		
	if (iid < 0)
		iid = iid_current++
	
	temp = iid_find(temp)
	sprite_tex = iid_find(sprite_tex)
	if (temp_creator != app.bench_settings)
		sprite_tex.count++
	ptype_update_sprite_vbuffers()
}

log("Get keyframe iids")
with (obj_keyframe)
{
	if (!loaded)
		continue
		
	value[ATTRACTOR] = iid_find(value[ATTRACTOR])
	value[TEXTUREOBJ] = iid_find(value[TEXTUREOBJ])
	value[SOUNDOBJ] = iid_find(value[SOUNDOBJ])
	if (value[SOUNDOBJ])
		value[SOUNDOBJ].count++
}

log("Get timeline iids")
with (obj_timeline)
{
	if (!loaded)
		continue
	
	part_of = iid_find(part_of)
	for (var p = 0; p < part_amount; p++)
		part[p] = iid_find(part[p])
		
	if (parent = 1) // Demo bug?
		parent = 0
		
	parent = iid_find(parent)
	
	if (parent < 0)
		parent = app
		
	if ((parent = app && argument0) || parent_pos_read < 0) // Imported are added to end of tree
		parent_pos_read = parent.tree_amount
	
	if (part_of)
		if (bodypart < temp.char_model.part_amount)
			value_type_show[POSITION] = true// temp.char_model.part_show_position[bodypart] // TODO
	
	value[ATTRACTOR] = iid_find(value[ATTRACTOR])
	value[TEXTUREOBJ] = iid_find(value[TEXTUREOBJ])
	value[SOUNDOBJ] = iid_find(value[SOUNDOBJ])
	value_inherit[ATTRACTOR] = value[ATTRACTOR]
	value_inherit[TEXTUREOBJ] = value[TEXTUREOBJ]
	value_inherit[SOUNDOBJ] = value[SOUNDOBJ]
}

// Build trees
log("Build trees")
with (obj_timeline)
{
	if (parent_pos_read < 0)
		continue
		
	for (parent_pos = 0; parent_pos < parent.tree_amount; parent_pos++)
		if (parent.tree[parent_pos].parent_pos_read > parent_pos_read)
			break
			
	//tl_parent_add() // TODO ds_list_insert...
}

log("Reset read positions")
with (obj_timeline)
	parent_pos_read = null

// Hide
if (load_format < project_100debug)
{
	log("Update pre 1.0.0 hide")
	for (var t = 0; t < tree_amount; t++)
		with (tree[t])
			tl_update_hide()
}
