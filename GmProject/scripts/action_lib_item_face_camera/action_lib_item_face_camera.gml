function action_lib_item_face_camera(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_item_face_camera, temp_edit.item_face_camera, enabled, false)
	
	temp_edit.item_face_camera = enabled
	lib_preview.update = true
}
