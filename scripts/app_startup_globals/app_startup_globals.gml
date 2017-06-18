/// app_startup_globals()

log("Globals startup")

// Program
globalvar trial_version, current_step, minute_steps, delta,
          buffer_current, vbuffer_current, load_format, load_folder, save_folder, load_iid_offset, 
          debug_indent, debug_timer, history_data;
current_step = 0
minute_steps = 60 * 60
delta = 1

// Assets
globalvar temp_edit, ptype_edit, tl_edit_amount, tl_edit, res_edit, axis_edit,
          temp_creator, res_creator, iid_current;
temp_edit = null
ptype_edit = null
tl_edit = null
tl_edit_amount = 0
res_edit = null
axis_edit = X
temp_creator = app
res_creator = app
iid_current = 1

// Camera
globalvar cam_from, cam_to, cam_up, cam_fov, cam_ratio, cam_near, cam_far, cam_window, cam_render;
cam_from = point3D(0, 0, 0)
cam_window = camera_create()
cam_render = camera_create()
view_set_camera(0, cam_window)



// TODO (RE)MOVE

globalvar res_def;
res_def = new(obj_resource)
res_def.type = "pack"
res_def.display_name = "Minecraft"
res_def.font_minecraft = true
res_def.font = new_minecraft_font()
res_def.font_preview = res_def.font
with (res_def)
    res_pack_load_folder(data_directory + "Textures")

/*res_def.block_frames = 32
res_def.block_ani[32 * 16] = false
res_def.block_ani[0 + 3 * 32] = true // Flowing water
res_def.block_ani[1 + 3 * 32] = true // Water
res_def.block_ani[2 + 3 * 32] = true // Flowing lava
res_def.block_ani[3 + 3 * 32] = true // Lava
res_def.block_ani[4 + 3 * 32] = true // Fire
res_def.block_ani[19 + 3 * 32] = true // Portal*/

// Schematic
globalvar sch_load_queue, sch_load_stage, sch_load_z, sch_load_vbuffer, 
          sch_load_xsize, sch_load_ysize, sch_load_zsize, 
          sch_isblock, sch_value, sch_data, sch_edges, 
          sch_file, sch_buffer, sch_buffer_schematic, 
          sch_block_pos, sch_data_pos, 
          sch_x, sch_y, sch_z, 
          sch_bx, sch_by, sch_bz, 
          sch_block_value, sch_block_data, sch_block_solid;
sch_load_queue = ds_queue_create()

// Resource pack
globalvar pack_load_queue, pack_load_stage, 
          pack_load_amount, pack_load_texture, pack_load_name, 
          pack_load_block_size, pack_load_item_size, pack_load_mob_size, 
          block062newx, block062newy, 
          block07newx, block07newy;
pack_load_queue = ds_queue_create()