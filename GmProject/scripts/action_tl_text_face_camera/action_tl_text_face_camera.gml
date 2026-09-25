/// action_tl_text_face_camera(face)
/// @arg face

function action_tl_text_face_camera(face)
{
	if (!history_undo && !history_redo)
		history_set_var(action_tl_text_face_camera, tl_edit.text_face_camera, face, false)

	tl_edit.text_face_camera = face
}
