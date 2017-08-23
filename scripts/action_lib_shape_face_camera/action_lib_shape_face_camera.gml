/// action_lib_shape_face_camera(face)
/// @arg face

var face;

if (history_undo)
	face = history_data.old_value
else if (history_redo)
	face = history_data.new_value
else
{
	face = argument0
	history_set_var(action_lib_shape_face_camera, temp_edit.shape_face_camera, face, false)
}

temp_edit.shape_face_camera = face
lib_preview.update = true
