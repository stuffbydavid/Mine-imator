/// res_eval(id)
/// @desc Evaluates a resource ID and returns an object.

function res_eval(res)
{
	if (res = project_pack_res)
		res = app.project_pack
	
	if (res = mc_res || !instance_exists(res))
		return mc_res

	if (res.object_index != obj_resource)
		return res
	
	return res.ready ? res : mc_res
}
