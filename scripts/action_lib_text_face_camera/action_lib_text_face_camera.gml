/// action_lib_text_face_camera(face)
/// @arg face

var face;

if (history_undo)
	face = history_data.oldval
else if (history_redo)
	face = history_data.newval
else
{
	face = argument0
	history_set_var(action_lib_text_face_camera, temp_edit.text_face_camera, face, false)
}

temp_edit.text_face_camera = face
lib_preview.update = true
