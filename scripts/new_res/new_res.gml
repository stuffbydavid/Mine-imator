/// new_res(filename, type)
/// @arg filename
/// @arg type
/// @desc Adds a new resource or replaces an existing one. Returns the new resource instance.

var fn, type, res, newfn, replaced;
fn = argument0
type = argument1

if (filename_ext(fn) = ".zip" && type != e_res_type.PACK_UNZIPPED)
	type = e_res_type.PACK

res = null
replaced = false
newfn = project_folder + "\\" + filename_name(fn)

// Check replace
with (obj_resource)
{
	if (id.type = type && filename = filename_name(fn))
	{
		res = id
		break
	}
}

var copied = false;
if (res) // Existing resource found
{
	if (question(text_get("questionreplace")))
		replaced = true
	else
	{
		res = null
		newfn = filename_get_unique(newfn)
		copied = true
		file_copy_lib(fn, newfn)
	}
}

// Add new
if (res = null)
{
	res = new(obj_resource)
	res.type = type
	res.copied = copied
	sortlist_add(res_list, res)
}

res.filename = filename_name(newfn)
res.replaced = replaced
if (copied)
	load_folder = project_folder
else
	load_folder = filename_dir(fn)
save_folder = project_folder

log("Add resource", res_type_name_list[|type])
log("filename", res.filename)

return res
