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
	if (tllast && copy_kf_tl_save_id[k] != tllast)
	{
		pastemode = "fixed"
		break
	}
	tllast = copy_kf_tl_save_id[k]
}

if (pastemode = "fixed")
{
	// All keyframes belong to same character?
	pastemode = "char"
	tllast = null
	for (var k = 0; k < copy_kf_amount; k++)
	{
		if (tllast && copy_kf_tl_part_of_save_id[k] != tllast)
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
else if (pastemode = "char")
{
	pastemode = "fixed"
	with (obj_timeline)
	{
		if (!selected)
			continue
			
		if (part_of != null)
		{
			tlpaste = part_of
			pastemode = "char"
			break
		}
		
		if (part_amount > 0)
		{
			tlpaste = id
			pastemode = "char"
			break
		}
	}
}

// Insert
for (var k = 0; k < copy_kf_amount; k++)
{
	var newkf, tladd;
		
	if (pastemode = "fixed")
		tladd = save_id_find(copy_kf_tl_part_of_save_id[k])
	else
		tladd = tlpaste
		
	if (!tladd)
		continue
	
	if (pastemode != "free" && copy_kf_tl_model_part_name[k] != "") // Add to body part
	{
		var foundpart = false;
		
		for (var p = 0; p < ds_list_size(tladd.part_list); p++)
		{
			if (tladd.part_list[|p].model_part_name = copy_kf_tl_model_part_name[k])
			{
				tladd = part_list[|p]
				foundpart = true
				break
			}
		}
		
		if (!foundpart)
			continue
	}
	
	with (tladd)
		newkf = tl_keyframe_add(pos + app.copy_kf_pos[k])
	
	for (var v = 0; v < e_value.amount; v++)
		newkf.value[v] = tl_value_restore(v, null, copy_kf_value[k, v])
	
	tl_keyframe_select(newkf)
}
