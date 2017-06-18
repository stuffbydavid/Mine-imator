/// block_generate_liquid()
/// @desc Creates a liquid mesh from the surrounding block data.

var bid, name, slot, sheetwidth, sheetheight, angle;
var slotstillpos, slotstillsize, slotflowpos, slotflowsize, topflow, dep, vbuf;
var cornerz, minz, averagez;

bid = snap_floor(block_id_current, 2)
name = mc_version.block_map[?bid].data_name[block_data_current]

topflow = true
angle = 0

// Still texture
slot = ds_list_find_index(mc_version.block_texture_list, "blocks/" + name + "_still")
if (slot < 0) // Animated
{
	slot = ds_list_find_index(mc_version.block_texture_ani_list, "blocks/" + name + "_still")
	if (slot < 0)
		return 0
	
	dep = res_def.block_sheet_ani_depth_list[|slot]
	vbuf = e_block_vbuffer.ANIMATED
	sheetwidth = block_sheet_ani_width
	sheetheight = block_sheet_ani_height
}
else
{ 
	dep = res_def.block_sheet_depth_list[|slot]
	vbuf = e_block_vbuffer.NORMAL
	sheetwidth = block_sheet_width
	sheetheight = block_sheet_height
}

slotstillpos = point2D((slot mod sheetwidth) * block_size, (slot div sheetwidth) * block_size)
slotstillsize = vec2(1 / (sheetwidth * block_size), 1 / (sheetheight * block_size))

// Flow texture
slot = ds_list_find_index(mc_version.block_texture_list, "blocks/" + name + "_flow")
if (slot < 0) // Animated
{
	slot = ds_list_find_index(mc_version.block_texture_ani_list, "blocks/" + name + "_flow")
	if (slot < 0){
		log(name,"not found")
		return 0
	}
}

slotflowpos = point2D((slot mod sheetwidth) * block_size, (slot div sheetwidth) * block_size)
slotflowsize = vec2(1 / (sheetwidth * block_size), 1 / (sheetheight * block_size))

// Falling
if (block_data_current div 8)
{
	for (var d = 0; d < 4; d++)
		cornerz[d] = block_size
	minz = block_size
	averagez = block_size
	topflow = false
}
else
{
	var flow, sidedata, cornerdata, myz, sidez, cornerz;
	flow[e_dir.NORTH] = 0
	
	// Data at sides
	for (var d = e_dir.EAST; d <= e_dir.NORTH; d++)
	{
		sidedata[d] = 7
		cornerdata[d] = 7
		if (!build_edge[d] && snap_floor(array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(d))), 2) = bid)
		{
			sidedata[d] = array3D_get(block_data, point3D_add(build_pos, dir_get_vec3(d)))
			
			if (sidedata[d] mod 8 < block_data_current)
				flow[dir_get_opposite(d)]++ 
			else if (sidedata[d] mod 8 > block_data_current)
				flow[d]++
		}
	}

	// Data in corners
	if (!build_edge[e_dir.WEST] && !build_edge[e_dir.NORTH] && snap_floor(array3D_get(block_id, point3D_add(build_pos, vec3(-1, -1, 0))), 2) = bid)
		cornerdata[0] = array3D_get(block_data, point3D_add(build_pos, vec3(-1, -1, 0)))
		
	if (!build_edge[e_dir.EAST] && !build_edge[e_dir.NORTH] && snap_floor(array3D_get(block_id, point3D_add(build_pos, vec3(1, -1, 0))), 2) = bid)
		cornerdata[1] = array3D_get(block_data, point3D_add(build_pos, vec3(1, -1, 0)))
		
	if (!build_edge[e_dir.WEST] && !build_edge[e_dir.SOUTH] && snap_floor(array3D_get(block_id, point3D_add(build_pos, vec3(1, 1, 0))), 2) = bid)
		cornerdata[2] = array3D_get(block_data, point3D_add(build_pos, vec3(1, 1, 0)))
		
	if (!build_edge[e_dir.EAST] && !build_edge[e_dir.SOUTH] && snap_floor(array3D_get(block_id, point3D_add(build_pos, vec3(-1, 1, 0))), 2) = bid)
		cornerdata[3] = array3D_get(block_data, point3D_add(build_pos, vec3(-1, 1, 0)))
		
	// Set Zs
	myz = 14 - (block_data_current / 7) * 13.5
	for (var i = 0; i < 4; i++)
	{
		// Corner
		if (cornerdata[i] div 8)
			cornerz[i] = block_size
		else
			cornerz[i] = 14 - (cornerdata[i] / 7) * 13.5
		
		// Side
		if (sidedata[i] div 8)
			sidez[i] = block_size
		else
			sidez[i] = 14 - (sidedata[i] / 7) * 13.5
	}
	
	// Max corner levels
	cornerz[0] = max(cornerz[0], sidez[e_dir.WEST], sidez[e_dir.NORTH], myz)
	cornerz[1] = max(cornerz[1], sidez[e_dir.EAST], sidez[e_dir.NORTH], myz)
	cornerz[2] = max(cornerz[2], sidez[e_dir.EAST], sidez[e_dir.SOUTH], myz)
	cornerz[3] = max(cornerz[3], sidez[e_dir.WEST], sidez[e_dir.SOUTH], myz)
	
	// Set mininum and average
	averagez = 0
	minz = block_size
	for (var i = 0; i < 4; i++)
	{
		averagez += cornerz[i] / 4
		minz = min(minz, cornerz[i])
	}
	
	// Set texture orientation
	if ((!flow[e_dir.WEST] && !flow[e_dir.EAST] && !flow[e_dir.NORTH] && !flow[e_dir.SOUTH]) || 
	    (flow[e_dir.WEST] && flow[e_dir.EAST] && flow[e_dir.NORTH] && flow[e_dir.SOUTH]) || 
	    (flow[e_dir.WEST] && flow[e_dir.EAST] && !flow[e_dir.NORTH] && !flow[e_dir.SOUTH]) || 
	    (!flow[e_dir.WEST] && !flow[e_dir.EAST] && flow[e_dir.NORTH] && flow[e_dir.SOUTH]))
	    topflow = false
	else if (flow[e_dir.WEST] && flow[e_dir.EAST] && flow[e_dir.SOUTH])
	    angle = 0
	else if (flow[e_dir.WEST] && flow[e_dir.EAST] && flow[e_dir.NORTH])
	    angle = 180
	else if (flow[e_dir.EAST] && flow[e_dir.NORTH] && flow[e_dir.SOUTH])
	    angle = 90
	else if (flow[e_dir.WEST] && flow[e_dir.NORTH] && flow[e_dir.SOUTH])
	    angle = 270
	else if (flow[e_dir.WEST] && flow[e_dir.NORTH])
	    angle = 180 + 45 + 10 * (flow[e_dir.WEST] - 1) - 10 * (flow[e_dir.NORTH] - 1)
	else if (flow[e_dir.EAST] && flow[e_dir.NORTH])
	    angle = 180 - 45 + 10 * (flow[e_dir.NORTH] - 1) - 10 * (flow[e_dir.EAST] - 1)
	else if (flow[e_dir.WEST] && flow[e_dir.SOUTH])
	    angle = 270 + 45 + 10 * (flow[e_dir.SOUTH] - 1) - 10 * (flow[e_dir.WEST] - 1)
	else if (flow[e_dir.EAST] && flow[e_dir.SOUTH])
	    angle = 45 + 10 * (flow[e_dir.EAST] - 1) - 10 * (flow[e_dir.SOUTH] - 1)
	else if (flow[e_dir.SOUTH])
	    angle = 0
	else if (flow[e_dir.EAST])
	    angle = 90
	else if (flow[e_dir.NORTH])
	    angle = 180
	else if (flow[e_dir.WEST])
	    angle = 270
}

// Add triangles
var x1, x2, y1, y2, z1, z2;
var corner, mid;
var mat, toptex, topmidtex, sidetex, cornerlefttex, cornerrighttex;

x1 = 0; y1 = 0; z1 = 0;
x2 = block_size; y2 = block_size; z2 = minz;

// Shape points
corner[0] = point3D(x1, y1, cornerz[0])
corner[1] = point3D(x2, y1, cornerz[1])
corner[2] = point3D(x2, y2, cornerz[2])
corner[3] = point3D(x1, y2, cornerz[3])
mid = point3D(x1 + block_size / 2, y1 + block_size / 2, averagez)

// Texture coordinates (clockwise starting at top-left)

// Top texture
if (angle <> 0)
{
	var p = (mod_fix(angle, 90) / 90) * block_size;
	switch (angle div 90)
	{
		case 0:
			toptex = array(
				point2D(p, 0),
				point2D(block_size, p),
				point2D(block_size - p, block_size),
				point2D(0, block_size - p)
			)
			break
			
		case 1:
			toptex = array(
				point2D(block_size, p),
				point2D(block_size - p, block_size),
				point2D(0, block_size - p),
				point2D(p, 0)
			)
			break
			
		case 2:
			toptex = array(
				point2D(block_size - p, block_size),
				point2D(0, block_size - p),
				point2D(p, 0),
				point2D(block_size, p)
			)
			break
			
		case 3:
			toptex = array(
				point2D(0, block_size - p),
				point2D(p, 0),
				point2D(block_size, p),
				point2D(block_size - p, block_size)
			)
			break
	}
}
else
{
	toptex = array(
		point2D(0, 0),
		point2D(block_size, 0),
		point2D(block_size, block_size),
		point2D(0, block_size)
	)
}

topmidtex = point2D(block_size / 2, block_size / 2)

// Side textures
sidetex = array(
	point2D(0, block_size - z2),
	point2D(block_size, block_size - z2),
	point2D(block_size, block_size),
	point2D(0, block_size)
)

// Corner textures (left side)
cornerlefttex = array(
	point2D(0, block_size - cornerz[0]),
	point2D(0, block_size - cornerz[1]),
	point2D(0, block_size - cornerz[2]),
	point2D(0, block_size - cornerz[3])
)

// Corner textures (right side)
cornerrighttex = array(
	point2D(block_size, block_size - cornerz[0]),
	point2D(block_size, block_size - cornerz[1]),
	point2D(block_size, block_size - cornerz[2]),
	point2D(block_size, block_size - cornerz[3])
)

// Transform to sheet
for (var i = 0; i < 4; i++)
{
	if (topflow)
		toptex[i] = vec2_mul(point2D_add(toptex[i], slotflowpos), slotflowsize)
	else
		toptex[i] = vec2_mul(point2D_add(toptex[i], slotstillpos), slotstillsize)
	sidetex[i] = vec2_mul(point2D_add(sidetex[i], slotflowpos), slotflowsize)
	cornerlefttex[i] = vec2_mul(point2D_add(cornerlefttex[i], slotflowpos), slotflowsize)
	cornerrighttex[i] = vec2_mul(point2D_add(cornerrighttex[i], slotflowpos), slotflowsize)
}
if (topflow)
	topmidtex = vec2_mul(point2D_add(topmidtex, slotflowpos), slotflowsize)
else
	topmidtex = vec2_mul(point2D_add(topmidtex, slotstillpos), slotstillsize)

mat = matrix_create(mc_builder.block_pos, vec3(0), vec3(1))

vbuffer_current = vbuffer[dep, vbuf]

for (var d = 0; d < e_dir.amount; d++)
{
	// Cull
	if (!build_edge[d] && (snap_floor(array3D_get(block_id, point3D_add(build_pos, dir_get_vec3(d))), 2) = bid || 
						   block_render_models_get_solid(block_render_models_dir[d])))
		continue
		
	if (d = e_dir.UP)
	{
		vbuffer_add_triangle(mid, corner[0], corner[1], topmidtex, toptex[0], toptex[1], mat)
		vbuffer_add_triangle(mid, corner[1], corner[2], topmidtex, toptex[1], toptex[2], mat)
		vbuffer_add_triangle(mid, corner[2], corner[3], topmidtex, toptex[2], toptex[3], mat)
		vbuffer_add_triangle(mid, corner[3], corner[0], topmidtex, toptex[3], toptex[0], mat)
		continue
	}
	else if (d = e_dir.DOWN)
	{
		p1 = point3D(x1, y2, z1)
		p2 = point3D(x2, y2, z1)
		p3 = point3D(x2, y1, z1)
		p4 = point3D(x1, y1, z1)
		vbuffer_add_triangle(p1, p2, p3, toptex[3], toptex[2], toptex[1], mat)
		vbuffer_add_triangle(p3, p4, p1, toptex[1], toptex[0], toptex[3], mat)
		continue
	}
	
	var p1, p2, p3, p4;
	var c1, c2;
		
	switch (d)
	{
		case e_dir.EAST:
			p1 = point3D(x2, y2, z2)
			p2 = point3D(x2, y1, z2)
			p3 = point3D(x2, y1, z1)
			p4 = point3D(x2, y2, z1)
			c1 = 1
			c2 = 2
			break
			
		case e_dir.WEST:
			p1 = point3D(x1, y1, z2)
			p2 = point3D(x1, y2, z2)
			p3 = point3D(x1, y2, z1)
			p4 = point3D(x1, y1, z1)
			c1 = 3
			c2 = 0
			break
			
		case e_dir.SOUTH:
			p1 = point3D(x1, y2, z2)
			p2 = point3D(x2, y2, z2)
			p3 = point3D(x2, y2, z1)
			p4 = point3D(x1, y2, z1)
			c1 = 2
			c2 = 3
			break
			
		case e_dir.NORTH:
			p1 = point3D(x2, y1, z2)
			p2 = point3D(x1, y1, z2)
			p3 = point3D(x1, y1, z1)
			p4 = point3D(x2, y1, z1)
			c1 = 0
			c2 = 1
			break
	}
	
	vbuffer_add_triangle(p1, p2, p3, sidetex[0], sidetex[1], sidetex[2], mat)
	vbuffer_add_triangle(p3, p4, p1, sidetex[2], sidetex[3], sidetex[0], mat)
	if (cornerz[c1] > cornerz[c2])
		vbuffer_add_triangle(p2, p1, corner[c1], sidetex[1], sidetex[0], cornerrighttex[c1], mat)
	else if (cornerz[c1] < cornerz[c2])
		vbuffer_add_triangle(p2, p1, corner[c2], sidetex[1], sidetex[0], cornerlefttex[c2], mat)
}