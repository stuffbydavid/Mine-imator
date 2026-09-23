/// action_res_preview_pack_image_material(material)
/// @arg material

function action_res_preview_pack_image_material(material)
{
	preview_edit.pack_image_material = material
	preview_edit.update = true
	preview_edit.reset_view = true
}
