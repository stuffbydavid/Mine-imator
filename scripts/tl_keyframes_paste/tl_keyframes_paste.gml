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
	if (tllast && copy_kf_tl[k] != tllast)
	{
		pastemode = "fixed"
		break
	}
	tllast = copy_kf_tl[k]
}

if (pastemode = "fixed")
{
	// All keyframes belong to same character?
	pastemode = "char"
	tllast = null
	for (var k = 0; k < copy_kf_amount; k++)
	{
		if (tllast && copy_kf_tl_bodypart_of[k] != tllast)
		{
			pastemode = "fixed"
			break
		}
		tllast = copy_kf_tl_bodypart_of[k]
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
		if (!select)
			continue
			
		if (part_of)
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
		tladd = iid_find(copy_kf_tl_bodypart_of[k])
	else
		tladd = tlpaste
		
	if (!tladd)
		continue
	
	if (pastemode != "free" && copy_kf_tl_bodypart[k] != null) // Add to body part
	{
		if (copy_kf_tl_bodypart[k] >= tladd.part_amount)
			continue
		tladd = tladd.part[copy_kf_tl_bodypart[k]]
	}
	
	with (tladd)
		newkf = tl_keyframe_add(pos + app.copy_kf_pos[k])
	
	for (var v = 0; v < values; v++)
		newkf.value[v] = tl_value_restore(v, null, copy_kf_value[k, v])
	
	tl_keyframe_select(newkf)
}
