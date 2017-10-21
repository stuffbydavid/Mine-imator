/// tl_keyframes_paste(position)
/// @arg position

var pos, pastemode, tllast, tlpaste;
pos = argument0
pastemode = "free"
tlpaste = tl_edit

tl_keyframes_deselect_all()

tllast = null
for (var k = 0; k < copy_kf_amount; k++) // All keyframes belong to same timeline?
{
	if (tllast != null && copy_kf_tl_save_id[k] != tllast)
	{
		pastemode = "fixed"
		break
	}
	tllast = copy_kf_tl_save_id[k]
}

if (pastemode = "fixed")
{
	// All keyframes belong to same model?
	pastemode = "model"
	tllast = null
	for (var k = 0; k < copy_kf_amount; k++)
	{
		if (tllast != null && copy_kf_tl_part_of_save_id[k] != tllast)
		{
			pastemode = "fixed"
			break
		}
		tllast = copy_kf_tl_part_of_save_id[k]
	}
}

if (pastemode = "free")
{
	if (tl_edit_amount != 1) // 1 timeline must be selected for free moving
		pastemode = "fixed"
}

// Find character to paste into (first selected found)
else if (pastemode = "model")
{
	pastemode = "fixed"
	with (obj_timeline)
	{
		if (!selected)
			continue
			
		if (part_of != null)
		{
			tlpaste = part_of
			pastemode = "model"
			break
		}
		
		if (part_list != null)
		{
			tlpaste = id
			pastemode = "model"
			break
		}
	}
}

// Insert
for (var k = 0; k < copy_kf_amount; k++)
{
	var tladd;
		
	if (pastemode = "fixed")
		tladd = save_id_find(copy_kf_tl_part_of_save_id[k])
	else
		tladd = tlpaste
		
	if (tladd = null)
		continue
	
	if (pastemode != "free" && tladd.part_list != null && copy_kf_tl_model_part_name[k] != "") // Add to body part
	{
		var part;
		with (tladd)
			part = tl_part_find(app.copy_kf_tl_model_part_name[k])
		
		if (part != null)
			tladd = part
		else
			continue
	}
	
	var newkf;
	
	with (tladd)
		newkf = tl_keyframe_add(pos + app.copy_kf_pos[k])
	
	for (var v = 0; v < e_value.amount; v++)
		newkf.value[v] = tl_value_find_save_id(v, null, copy_kf_value[k, v])
	
	tl_keyframe_select(newkf)
}
