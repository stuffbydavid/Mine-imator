/// new_res(filename, type)
/// @arg filename
/// @arg type
/// @desc Adds a new resource or replaces an existing one. Returns the new resource instance.

var fn, type, res, newfn, replaced;
fn = argument0
type = argument1

if (filename_ext(fn) = ".zip" && type != "packunzipped")
	type = "pack"

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

if (res) // Existing resource found
{
	if (question(text_get("questionreplace")))
		replaced = true
	else
	{
		res = null
		newfn = filename_unique(newfn)
	}
}

// Add new
if (!res)
{
	res = new(obj_resource)
	res.type = type
	sortlist_add(res_list, res)
}

res.filename = filename_name(newfn)
res.replaced = replaced
load_folder = filename_dir(fn)
save_folder = project_folder

with (res)
	res_export()

log("Add resource", type)
log("filename", res.filename)

return res
