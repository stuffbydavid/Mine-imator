/// tl_bend_matrix(bend, char, part)
/// Returns the transformation matrix for bending.

var bend, char, part, xt, yt, zt, xr, yr, zr, scale;
bend = argument0
char = argument1
part = argument2

if (part >= char.part_amount)
	return matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1)
	
if (!char.part_hasbend[part])
	return matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1)

if (char.part_benddir[part] = 1)
	bend = max(0, bend)
if (char.part_benddir[part] = -1)
	bend = min(0, -bend)
if (char.part_bendflip[part])   
	bend *= -1

xt = 0
yt = 0
zt = 0
xr = 0
yr = 0
zr = 0

switch (char.part_bendaxis[part]) {
	case bend_x:
		zt = -(char.part_zoff[part] - char.part_zsize[part] / 2)
		yt = char.part_yoff[part] - char.part_ysize[part] / 2
		xr = -bend
		break
		
	case bend_y:
		xt = char.part_xoff[part] - char.part_xsize[part] / 2
		yr = bend
		break
		
	case bend_z:
		zr = bend
		xt = char.part_xoff[part] - char.part_xsize[part] / 2
		break
}

if (bend != 0)
	scale = app.setting_bend_scale
else
	scale = 1

return matrix_build(-xt, -yt, -zt, xr, yr, zr, scale, scale, scale)
