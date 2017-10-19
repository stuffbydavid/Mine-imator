/// builder_set_size()

build_size_x = build_size[X]
build_size_y = build_size[Y]
build_size_z = build_size[Z]
build_size_sqrt = ceil(sqrt(build_size_x * build_size_y * build_size_z))
build_edges = !(app.setting_schematic_remove_edges && (build_size[X] > 150 || build_size[Y] > 150))

ds_grid_resize(block_obj, build_size_sqrt, build_size_sqrt)
ds_grid_resize(block_state_id, build_size_sqrt, build_size_sqrt)
ds_grid_resize(block_render_model, build_size_sqrt, build_size_sqrt)
ds_grid_resize(block_text, build_size_sqrt, build_size_sqrt)
ds_grid_clear(block_obj, null)
ds_grid_clear(block_state_id, 0)
ds_grid_clear(block_render_model, null)
ds_grid_clear(block_text, "")