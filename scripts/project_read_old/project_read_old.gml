/// project_read_old(add)
/* TODO
var load, a, b, c;
load = new(obj_dummy)

// Convert to 0.7 demo format, then to 1.0.0
switch (load_format)
{
	case project_05:
	case project_06:
	case project_07demo:
		// 0.5->0.6: lockpartbend added, pars, acts removed, pyroland baby and balloonicorn id changed
		// 0.6->0.7 demo: No change
		load.lib_amount = buffer_read_short() debug("lib_amount", load.lib_amount)
		for (a = 0; a < load.lib_amount; a++)
		{
			debug("Library") debug_indent++
			load.lib_type[a] = buffer_read_string_int() debug("lib_type", load.lib_type[a])
			load.lib_name[a] = buffer_read_string_int() debug("lib_name", load.lib_name[a])
			load.lib_char_skin[a] = buffer_read_short() - 1 debug("lib_char_skin", load.lib_char_skin[a])
			//load.lib_char_model[a] = char_find(project_read_old_char_model(buffer_read_byte())) debug("lib_char_model", load.lib_char_model[a].name) // TODO
			load.lib_item_type[a] = 0
			load.lib_item_bounce[a] = 1
			load.lib_item_face[a] = 1
			switch (buffer_read_byte())
			{
				case 1: {
					load.lib_item_type[a] = 1
					break
				}
				case 2: {
					load.lib_item_bounce[a] = 0
					load.lib_item_face[a] = 1 
					break
				}
				case 3: {
					load.lib_item_bounce[a] = 1
					load.lib_item_face[a] = 0
					break
				}
				case 4: {
					load.lib_item_bounce[a] = 0
					load.lib_item_face[a] = 0
					break
				}
			}
			if (load.lib_item_type[a]) {
				load.lib_item_bounce[a] = 0
				load.lib_item_face[a] = 0
			}
			debug("lib_item_type", load.lib_item_type[a])
			debug("lib_item_bounce", load.lib_item_bounce[a])
			debug("lib_item_face", load.lib_item_face[a])
			load.lib_item_tex[a] = buffer_read_short() - 1 debug("lib_item_tex", load.lib_item_tex[a])
			load.lib_item_x[a] = buffer_read_short() debug("lib_item_x", load.lib_item_x[a])
			load.lib_item_y[a] = buffer_read_short() debug("lib_item_y", load.lib_item_y[a])
			load.lib_block_id[a] = buffer_read_short() debug("lib_block_id", load.lib_block_id[a])
			load.lib_block_data[a] = buffer_read_byte() debug("lib_block_data", load.lib_block_data[a])
			load.lib_block_tex[a] = buffer_read_short() - 1 debug("lib_block_tex", load.lib_block_tex[a])
			load.lib_scenery_source[a] = filename_name(string_replace_all(buffer_read_string_int(), " / ", "\\")) debug("lib_scenery_source", load.lib_scenery_source[a])
			load.lib_scenery_tex[a] = buffer_read_short() - 1 debug("lib_scenery_tex", load.lib_scenery_tex[a])
			for (b = 0; b < 3; b++) {
				load.lib_rotx[a, b] = buffer_read_double()
				load.lib_roty[a, b] = buffer_read_double()
				load.lib_rotz[a, b] = buffer_read_double()
			}
			debug_indent--
		}
		load.tl_amount = buffer_read_short() debug("tl_amount", load.tl_amount)
		for (a = 0; a < load.tl_amount; a++) {
			debug("Timeline") debug_indent++
			load.tl_type[a] = buffer_read_string_int() debug("tl_type", load.tl_type[a])
			load.tl_n[a] = buffer_read_short() debug("tl_n", load.tl_n[a])
			load.tl_vis[a] = buffer_read_byte() debug("tl_vis", load.tl_vis[a])
			load.tl_show[a] = buffer_read_byte() debug("tl_show", load.tl_show[a])
			load.tl_lock[a] = buffer_read_byte() debug("tl_lock", load.tl_lock[a])
			load.tl_lockparent[a] = buffer_read_short() debug("tl_lockparent", load.tl_lockparent[a])
			load.tl_lockpart[a] = buffer_read_byte() debug("tl_lockpart", load.tl_lockpart[a])
			load.tl_lockpartbend[a] = 0
			if (load_format > project_05)
				load.tl_lockpartbend[a] = buffer_read_byte() debug("tl_lockpartbend", load.tl_lockpartbend[a])
			load.tl_col[a] = buffer_read_int() debug("tl_col", load.tl_col[a])
			load.tl_valuets[a] = 1
			if (load.tl_type[a] = "char") {
				var char = load.lib_char_model[load.tl_n[a]]
				if (char.name = "characterspider" || char.name = "charactercavespider")
					load.tl_valuets[a] = 7
				else if (char.name = "characterghast")
					load.tl_valuets[a] = 8
				else if (char.name = "charactersquid")
					load.tl_valuets[a] = 6
				else if (char.name = "characterwither")
					load.tl_valuets[a] = 6
				else 
					load.tl_valuets[a] = char.part_amount + 1
			}
			debug("tl_valuets", load.tl_valuets[a])
			if (load_format = project_05) {
				load.tl_values[a] = buffer_read_byte()
				load.tl_acts[a] = buffer_read_byte()
			} else {
				load.tl_values[a] = 13 * load.tl_valuets[a]
				load.tl_acts[a] = 6*load.tl_valuets[a]
			}
			debug("tl_values", load.tl_values[a])
			debug("tl_acts", load.tl_acts[a])
			load.tl_keyframes[a] = buffer_read_short() debug("tl_keyframes", load.tl_keyframes[a]) debug_indent++
			for (b = 0; b < load.tl_keyframes[a]; b++) {
				var kf = new(obj_dummy);
				kf.pos = buffer_read_int() debug("pos", kf.pos)
				kf.value[13] = 0
				for (c = 0; c < load.tl_values[a]; c++)
					kf.value[c] = buffer_read_double()
				for (c = 0; c < load.tl_acts[a]; c++)
					buffer_read_byte()
				for (c = 0; c < 3; c++)
					kf.set[c] = buffer_read_byte()
				load.tl_keyframe[a, b] = kf
			}
			debug_indent--
			debug_indent--
		}
		
		load.skin_amount = buffer_read_short() - 1 debug("skin_amount", load.skin_amount) debug_indent++
		for (a = 0; a < load.skin_amount; a++) {
			load.skin_name[a] = filename_name(buffer_read_string_int())
			debug("skin_name", load.skin_name[a])
		}
		debug_indent--
		
		load.item_amount = buffer_read_short() - 1 debug("item_amount", load.item_amount) debug_indent++
		for (a = 0; a < load.item_amount; a++) {
			load.item_name[a] = filename_name(buffer_read_string_int())
			debug("item_name", load.item_name[a])
		}
		debug_indent--
		
		load.ter_amount = buffer_read_short() - 1 debug("ter_amount", load.ter_amount) debug_indent++
		for (a = 0; a < load.ter_amount; a++) {
			load.ter_name[a] = filename_name(buffer_read_string_int())
			debug("ter_name", load.ter_name[a])
		}
		debug_indent--
		
		load.bg_select = buffer_read_short() - 1 debug("bg_select", load.bg_select)
		load.bg_amount = buffer_read_short() - 1 debug("bg_amount", load.bg_amount) debug_indent++
		for (a = 0; a < load.bg_amount; a++) {
			load.bg_name[a] = filename_name(buffer_read_string_int())
			debug("bg_name", load.bg_name[a])
		}
		debug_indent--
		
		load.bg_show = buffer_read_byte() debug("bg_show", load.bg_show)
		load.bg_stretch = buffer_read_byte() debug("bg_stretch", load.bg_stretch)
		load.bg_box = buffer_read_byte() debug("bg_box", load.bg_box)
		load.bg_groundshow = buffer_read_byte() debug("bg_groundshow", load.bg_groundshow)
		load.bg_groundtex = buffer_read_short() - 1 debug("bg_groundtex", load.bg_groundtex)
		load.bg_groundx = buffer_read_short() debug("bg_groundx", load.bg_groundx)
		load.bg_groundy = buffer_read_short() debug("bg_groundy", load.bg_groundy)
		load.bg_groundn = load.bg_groundy * 16 + load.bg_groundx
		load.sky_color = buffer_read_int() debug("sky_color", load.sky_color)
		load.sky_time = buffer_read_double() debug("sky_time", load.sky_time)
		load.sky_light = buffer_read_byte() debug("sky_light", load.sky_light)
		load.lights_enable = buffer_read_byte() debug("lights_enable", load.lights_enable)
		load.lights_amount = buffer_read_short() debug("lights_amount", load.lights_amount) 
		for (a = 0; a < load.lights_amount; a++) {
			debug("Custom light") debug_indent++
			load.light_x[a] = buffer_read_int() debug("light_x", load.light_x[a])
			load.light_y[a] = buffer_read_int() debug("light_y", load.light_y[a])
			load.light_z[a] = buffer_read_short() debug("light_z", load.light_z[a])
			load.light_r[a] = buffer_read_short() debug("light_r", load.light_r[a])
			load.light_c[a] = buffer_read_int() debug("light_c", load.light_c[a])
			debug_indent--
		}
		load.xfrom = buffer_read_double() debug("xfrom", load.xfrom)
		load.yfrom = buffer_read_double() debug("yfrom", load.yfrom)
		load.zfrom = buffer_read_double() debug("zfrom", load.zfrom)
		load.xto = buffer_read_double() debug("xto", load.xto)
		load.yto = buffer_read_double() debug("yto", load.yto)
		load.zto = buffer_read_double() debug("zto", load.zto)
		load.camangle = buffer_read_double() debug("camangle", load.camangle)
		load.camanglez = buffer_read_double() debug("camanglez", load.camanglez)
		load.camzoom = buffer_read_double() debug("camzoom", load.camzoom)
		load.tempo = buffer_read_byte() debug("tempo", load.tempo)
		load.loop = buffer_read_byte() debug("loop", load.loop)
		load.timeline_pos = buffer_read_int() debug("timeline_pos", load.timeline_pos)
		load.timeline_scrollh = buffer_read_int() debug("timeline_scrollh", load.timeline_scrollh)
		load.timeline_zoom = buffer_read_byte() debug("timeline_zoom", load.timeline_zoom)
		break
}

// Resources
for (a = 0; a < load.skin_amount; a++) { // Skins
	var res = new(obj_resource);
	res.loaded = 1
	res.type = "skin"
	res.filename = load.skin_name[a]
	for (b = 0; b < load.lib_amount; b++) // Is this used as a skin?
		if (load.lib_char_skin[b] = a)
			break
	res.is_skin = (b < load.lib_amount)
	with (res)
		res_load()
	load.skin_res[a] = res
	sortlist_add(res_list, res)
}
for (a = 0; a < load.item_amount; a++) { // Item sheets
	var res = new(obj_resource);
	res.loaded = 1
	res.type = "itemsheet"
	res.filename = load.item_name[a]
	with (res)
		res_load()
	load.item_res[a] = res
	sortlist_add(res_list, res)
}
for (a = 0; a < load.ter_amount; a++) { // Terrain sheets
	var res = new(obj_resource);
	res.loaded = 1
	res.type = "blocksheet"
	res.filename = load.ter_name[a]
	res.block_format = load_format
	with (res)
		res_load()
	load.ter_res[a] = res
	sortlist_add(res_list, res)
}
for (a = 0; a < load.bg_amount; a++) { // Background images
	var res = new(obj_resource);
	res.loaded = 1
	res.type = "texture"
	res.filename = load.bg_name[a]
	with (res)
		res_load()
	load.bg_res[a] = res
	sortlist_add(res_list, res)
}

// Library
for (a = 0; a < load.lib_amount; a++) {
	var lib;
	if (load.lib_type[a] = "light")
		continue
	lib = new(obj_template)
	lib.loaded = 1
	load.lib_lib[a] = lib
	lib.type = load.lib_type[a]
	lib.name = load.lib_name[a]
	load.lib_rotpointx[a] = 0
	load.lib_rotpointy[a] = 0
	load.lib_rotpointz[a] = 0
	
	// Characters
	switch (lib.type) {
		case "char":
		case "spblock":
			lib.char_skin = res_def
			if (load.lib_char_skin[a] > -1)
				lib.char_skin = load.skin_res[load.lib_char_skin[a]]
			lib.char_skin.count++
			lib.char_model = load.lib_char_model[a]
			break
			
		case "item":
			lib.item_3d = load.lib_item_type[a]
			lib.item_face_camera = load.lib_item_face[a]
			lib.item_bounce = load.lib_item_bounce[a]
			lib.item_tex = res_def
			if (load.lib_item_tex[a] > -1)
				lib.item_tex = load.item_res[load.lib_item_tex[a]]
			lib.item_tex.count++
			lib.item_n = load.lib_item_y[a] * 16 + load.lib_item_x[a]
			load.lib_rotpointx[a] = load.lib_rotx[a, 0]
			load.lib_rotpointy[a] = load.lib_roty[a, 0]
			load.lib_rotpointz[a] = load.lib_rotz[a, 0]
			break
		
		case "block":
			lib.block_id = load.lib_block_id[a]
			lib.block_data = load.lib_block_data[a]
			lib.block_tex = res_def
			if (load.lib_block_tex[a] > -1)
				lib.block_tex = load.ter_res[load.lib_block_tex[a]]
			lib.block_tex.count++
			load.lib_rotpointx[a] = load.lib_rotx[a, 1]
			load.lib_rotpointy[a] = load.lib_roty[a, 1]
			load.lib_rotpointz[a] = load.lib_rotz[a, 1]
			break
			
		case "scenery":
			if (load.lib_scenery_source[a] != "") {
				var res, sch;
				res = new(obj_resource)
				sortlist_add(res_list, res)
				res.loaded = 1
				sch = filename_name(load.lib_scenery_source[a])
				res.type = "schematic"
				res.filename = sch
				with (res)
					res_load()
				lib.scenery = res
			}
			lib.block_tex = res_def
			if (load.lib_scenery_tex[a] > -1)
				lib.block_tex = load.ter_res[load.lib_scenery_tex[a]]
			lib.block_tex.count++
			load.lib_rotpointx[a] = load.lib_rotx[a, 2]
			load.lib_rotpointy[a] = load.lib_roty[a, 2]
			load.lib_rotpointz[a] = load.lib_rotz[a, 2]
			break
	}
	
	sortlist_add(lib_list, lib)
}

// Timelines
for (a = 0; a < load.tl_amount; a++) {
	var tl;
	if (a = 0) { // Camera
		if (load.tl_keyframes[a] = 0)
			continue
		tl = new(obj_timeline)
		tl.type = "camera"
		with (tl) {
			tl_set_parent_root()
			tl_update_value_types()
		}
	} else if (load.tl_type[a] = "light") {
		tl = new(obj_timeline)
		tl.type = "pointlight"
		with (tl) {
			tl_set_parent_root()
			tl_update_value_types()
		}
	} else
		with (load.lib_lib[load.tl_n[a]])
			tl = temp_animate()
	tl.loaded = true
	load.tl_tl[a] = tl
	tl.hide = !load.tl_vis[a]
	tl.color = load.tl_col[a]
	inherit_visibility = 0
	for (b = 0; b < load.tl_keyframes[a]; b++) { // keyframe_amount
		var readkf = load.tl_keyframe[a, b];
		if (tl.type = "char") { // Characters
			for (c = 0; c < load.tl_values[a]; c++) {
				var vid, bp, bptl, kf;
				vid = project_read_old_valueid(tl.type, c mod (load.tl_values[a] / load.tl_valuets[a]))
				bp = c div (load.tl_values[a] / load.tl_valuets[a])
				if (bp - 1>=tl.part_amount)
					break
				if (bp > 0) // Find the body part to add to
					bptl = tl.part[bp - 1]
				else
					bptl = tl
				if (bptl.keyframe_amount > 0 && bptl.keyframe[bptl.keyframe_amount - 1].pos = readkf.pos) // Edit existing
					kf = bptl.keyframe[bptl.keyframe_amount - 1]
				else {
					with (bptl)
						kf = tl_keyframe_add(readkf.pos)
					kf.value[TRANSITION] = project_read_old_value(TRANSITION, readkf.set[0])
					kf.value[VISIBLE] = readkf.set[1]
				}
				kf.value[vid] = project_read_old_value(vid, readkf.value[c])
			}
		} else {
			var kf;
			with (tl)
				kf = tl_keyframe_add(readkf.pos);
			for (c = 0; c < load.tl_values[a]; c++) {
				var vid = project_read_old_valueid(tl.type, c);
				if (vid < 0)
					continue
				kf.value[vid] = project_read_old_value(vid, readkf.value[c])
			}
			kf.value[TRANSITION] = project_read_old_value(TRANSITION, readkf.set[0])
			if (tl.type = "camera") {
				kf.value[CAMROTATE] = 1
				kf.value[XROT] = kf.value[CAMROTATEZANGLE]
				kf.value[ZROT] = kf.value[CAMROTATEXYANGLE]
			} else
				kf.value[VISIBLE] = readkf.set[1]
		}
		with (readkf)
			instance_destroy()
	}
	// Rotation point
	tl.rot_point_custom = true
	if (tl.type = "item" || tl.type = "block" || tl.type = "scenery") {
		tl.rot_point[XPOS] = load.lib_rotpointx[load.tl_n[a]]
		tl.rot_point[YPOS] = load.lib_rotpointy[load.tl_n[a]]
		tl.rot_point[ZPOS] = load.lib_rotpointz[load.tl_n[a]]
	}
	
}
for (a = 0; a < load.tl_amount; a++) { // Lock
	if (load.tl_lockparent[a] < 0 || !load.tl_lock[a])
		continue
	var par = load.tl_tl[load.tl_lockparent[a]];
	if (par.type = "char" && load.tl_lockpart[a] > 0)
		par = par.part[load.tl_lockpart[a] - 1]
	load.tl_tl[a].lock_bend = load.tl_lockpartbend[a]
	with (load.tl_tl[a])
		tl_set_parent(par)
}
with (obj_timeline) {
	tl_update_type_name()
	tl_update_display_name()
	tl_update_values()
}

if (!argument0) {
	// Background
	if (load.bg_select > -1) {
		background_image = load.bg_res[load.bg_select]
		background_image.count++
	}
	background_image_show = load.bg_show
	background_image_stretch = load.bg_stretch
	background_image_box = load.bg_box
	background_ground_show = load.bg_groundshow
	if (load.bg_groundtex > -1) {
		background_ground = load.ter_res[load.bg_groundtex]
		background_ground.count++
	}
	if (load_format = project_07demo) {
		if (block07newx[load.bg_groundn] > -1)
			background_ground_n = block07newy[load.bg_groundn] * 32 + block07newx[load.bg_groundn]
	} else {
		if (block062newx[load.bg_groundn] > -1)
			background_ground_n = block062newy[load.bg_groundn] * 32 + block062newx[load.bg_groundn]
	}
	background_sky_color = load.sky_color
	background_sky_time = load.sky_time
	view_main.lights = load.sky_light
	
	// Camera
	cam_work_focus[X] = load.xto
	cam_work_focus[Y] = load.yto
	cam_work_focus[Z] = load.zto
	cam_work_angle_xy = load.camangle
	cam_work_angle_z = load.camanglez
	cam_work_zoom = load.camzoom
	cam_work_zoom_goal = cam_work_zoom
	cam_work_angle_look_xy = cam_work_angle_xy
	cam_work_angle_look_z = -cam_work_angle_z
	cam_work_set_from()
	
	project_tempo = load.tempo
	timeline_repeat = load.loop
}

with (load)
	instance_destroy()
*/