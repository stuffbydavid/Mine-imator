/// CppSeparate ArrType builder_get_render_model_multipart(IntType, IntType, IntType, IntType)
/// @desc Returns an array of models at an index.
/// @arg x
/// @arg y
/// @arg z
/// @arg index

function builder_get_render_model_multipart(xx, yy, zz, index)
{
	return mc_builder.block_render_model_multipart[|index]
}
