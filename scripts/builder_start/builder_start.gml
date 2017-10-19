/// builder_start()

build_size_x = build_size[X]
build_size_y = build_size[Y]
build_size_z = build_size[Z]
build_size_total = build_size_x * build_size_y * build_size_z
build_size_sqrt = ceil(sqrt(build_size_total))
build_edges = !(app.setting_schematic_remove_edges && (build_size[X] > 150 || build_size[Y] > 150))

block_obj = buffer_create(build_size_total * 4, buffer_fixed, 4)
block_state_id = buffer_create(build_size_total * 4, buffer_fixed, 4)
block_render_model = ds_grid_create(build_size_sqrt, build_size_sqrt)
ds_grid_clear(block_render_model, null)
ds_map_clear(block_text_map)