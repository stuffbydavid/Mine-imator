/// CppSeparate void builder_set_neighbor_face(Scope<obj_builder_thread>, IntType, IntType)
/// @desc Check the opposing face of a given model for culling.

function builder_set_neighbor_face(model, face)
{
	var opposite = face ^ 1;
	
	block_face_full[face] = model.face_full[opposite]
	block_face_min_depth[face] = model.face_min_depth[opposite]
	
	// Bounds are only read when a partial face can cull geometry
	if (!block_face_full[face] && block_face_min_depth[face] != null)
	{
		block_face_min[face] = model.face_min[opposite]
		block_face_max[face] = model.face_max[opposite]
	}
}