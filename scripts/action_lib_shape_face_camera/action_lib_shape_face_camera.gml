/// action_lib_shape_face_camera(face)
/// @arg face

function action_lib_shape_face_camera(face)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_face_camera, temp_edit.shape_face_camera, face, false)
	
	temp_edit.shape_face_camera = face
	lib_preview.update = true
}
