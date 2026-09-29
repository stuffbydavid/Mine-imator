/// CppSeparate IntType builder_get_render_model(Scope<obj_builder_thread>, IntType, IntType, IntType)
/// @desc Returns a single (non-multipart) render model instance.
/// @arg x
/// @arg y
/// @arg z

function builder_get_render_model(xx, yy, zz)
{
	var index = builder_get_render_model_index(xx, yy, zz);
	if (is_undefined(index) || index <= 0 || index >= array_length(block_rendermodels))
		return null
	
	var model = block_rendermodels[index];
	
	return is_undefined(model) ? null : model
}
