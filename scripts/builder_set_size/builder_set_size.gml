/// builder_set_size()
					
array3D_set_size(block_obj, build_size)
array3D_set_size(block_state_id, build_size)
array3D_set_size(block_render_model, build_size)
array3D_set_size(block_text, build_size)
array3D_fill(block_obj, null)
array3D_fill(block_state_id, 0)
array3D_fill(block_render_model, null)
array3D_fill(block_text, "")

build_size_x = build_size[X]
build_size_y = build_size[Y]
build_size_z = build_size[Z]
build_edges = !(app.setting_schematic_remove_edges && (build_size[X] > 150 || build_size[Y] > 150))