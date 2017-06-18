/// new_res(type, filename)
/// @arg type
/// @arg filename
/// Adds a new resource or replaces an existing one. Returns the new resource instance.

var type, fn, res, fnout, replaced;
type = argument0
fn = argument1
res = null
replaced = false

if (filename_ext(fn) = ".zip")
{
    if (type != "packunzipped")
        type = "pack"
    fnout = project_folder + "\\" + filename_new_ext(filename_name(fn), "")
}
else
    fnout = project_folder + "\\" + filename_name(fn)

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
        fnout = filename_unique(fnout)
    }
}

// Add new
if (!res)
{
    res = new(obj_resource)
    res.type = type
    sortlist_add(res_list, res)
}

res.filename = filename_name(fn)
res.filename_out = filename_name(fnout)
res.replaced = replaced
load_folder = filename_dir(fn)
save_folder = project_folder

log("Add resource", type)
log("filename", res.filename)
log("filename_out", res.filename_out)
log("load_folder", load_folder)
log("save_folder", save_folder)

return res
