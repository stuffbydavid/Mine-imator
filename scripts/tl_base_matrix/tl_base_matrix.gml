/// tl_base_matrix(pos, rot, scale, partpos, partrot)

var pos, rot, scale, partpos, partrot, bp;
pos = argument0
rot = argument1
scale = argument2
partpos = argument3
partrot = argument4

bp = false

if (type = e_temp_type.BODYPART && part_of)
	if (bodypart < temp.char_model.part_amount)
		bp = true

if (bp) { // Is valid body part
	var char = temp.char_model;
	return matrix_build(
		value[XPOS] * pos + char.part_xp[bodypart] * partpos, value[YPOS] * pos + char.part_yp[bodypart] * partpos, value[ZPOS] * pos + char.part_zp[bodypart] * partpos, 
		value[XROT] * rot + char.part_xr[bodypart] * partrot, value[YROT] * rot + char.part_yr[bodypart] * partrot, value[ZROT] * rot + char.part_zr[bodypart] * partrot, 
		(value[XSCA] - 1) * scale + 1, (value[YSCA] - 1) * scale + 1, (value[ZSCA] - 1) * scale + 1
	)
} else {
	return matrix_build(
		value[XPOS] * pos, value[YPOS] * pos, value[ZPOS] * pos, 
		value[XROT] * rot, value[YROT] * rot, value[ZROT] * rot, 
		(value[XSCA] - 1) * scale + 1, (value[YSCA] - 1) * scale + 1, (value[ZSCA] - 1) * scale + 1
	)
}
