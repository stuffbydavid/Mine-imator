/// CppSeparate IntType builder_add_render_model_multi_part(Scope<obj_builder_thread>, IntType, IntType, IntType, ArrType)
/// @desc Adds a multipart model array (if unique) and returns the index
function builder_add_render_model_multi_part(xx, yy, zz, arr)
{
	var size = ds_list_size(mc_builder.block_render_model_multipart);
	var index;
	for (index = size - 1; index >= 1; index--)
	{
		var othermodel = mc_builder.block_render_model_multipart[|index];
		if (array_equals(othermodel, arr))
			break;
	}
	
	if (index == 0)
	{
		index = size
		ds_list_add(mc_builder.block_render_model_multipart, arr)
	}
	
	builder_set_render_model(xx, yy, zz, -index) // negative number to use multipart grid
}
