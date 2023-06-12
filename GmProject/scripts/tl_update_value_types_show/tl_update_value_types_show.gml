/// tl_update_value_types_show()

function tl_update_value_types_show()
{
	value_type_show[e_value_type.TRANSFORM] = app.frame_editor.transform.show
	value_type_show[e_value_type.CAMERA] = app.frame_editor.camera.show
}
