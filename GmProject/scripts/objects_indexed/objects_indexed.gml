/// objects_indexed()
/// Defines which object types require a type-wide instance index for:
///		with (object)
///		instance_exists(object)
///		instance_number(object)
function objects_indexed()
{
	globalvar objects_indexed_array;
	
	objects_indexed_array = array(
		obj_bench_settings,
		obj_biome,
		obj_context_menu_level,
		obj_history,
		obj_history_save,
		obj_keybind,
		obj_keyframe,
		obj_language,
		obj_list_item,
		obj_marker,
		obj_menu,
		obj_panel,
		obj_particle,
		obj_particle_type,
		obj_popup,
		obj_preview,
		obj_recent,
		obj_resource,
		obj_scrollbar,
		obj_shader,
		obj_tab,
		obj_template,
		obj_theme,
		obj_timeline,
		obj_toast,
		obj_videoquality,
		obj_videotemplate,
		obj_view
	);
	
	// No type-wide use:
	//	app, obj_block, obj_block_load_element,
	//	obj_block_load_model_file, obj_block_load_multipart_case,
	//	obj_block_load_state_file, obj_block_load_variant, obj_block_render_element,
	//  obj_block_render_model, obj_block_state, obj_block_tl, obj_block_tl_state,
	//  obj_builder, obj_builder_thread, obj_category, obj_colorpicker, obj_data,
	//  obj_deactivate, obj_list, obj_micro_animation, obj_minecraft_assets, obj_model,
	//  obj_model_file, obj_model_part, obj_model_shape, obj_model_state,
	//  obj_particle_template, obj_sortlist, obj_swatch, obj_textbox
}
