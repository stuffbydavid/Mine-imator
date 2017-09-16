/// block_tile_entity_bed(map)

var map, colorid;
map = argument0
colorid = map[?"color"]

if (!is_string(colorid))
	return 0

var colorarr = array("white", "orange", "magenta", "light_blue",
					 "yellow", "lime", "pink", "gray",
					 "silver", "cyan", "purple", "blue",
					 "brown", "green", "red", "black")

if (colorid >= array_length_1d(colorarr))
	return 0

array3D_set(block_state, build_pos, "color=" + colorarr[colorid])