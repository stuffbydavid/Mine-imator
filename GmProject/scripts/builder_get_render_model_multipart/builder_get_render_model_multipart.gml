/// CppSeparate ArrType builder_get_render_model_multipart(IntType, IntType, IntType, IntType)
/// Returns an array of models at an index

function builder_get_render_model_multipart(xx, yy, zz, index)
{
	return mc_builder.block_render_model_multipart[|index];
}
