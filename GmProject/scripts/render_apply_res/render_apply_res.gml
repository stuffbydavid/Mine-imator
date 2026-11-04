/// @desc Assigns a pack resource as the currently used while rendering. Its local texture page
/// will be used to render copies of built-in sprites or user-loaded textures without swapping.
/// @arg resource

function render_apply_res(res)
{
	if (res.type = e_res_type.PACK)
		render_pack_current = res
}