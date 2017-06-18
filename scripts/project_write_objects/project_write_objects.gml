/// project_write_objects()

var savenum;

// Templates
savenum = 0
with (obj_template)
    savenum += save
buffer_write_int(savenum)
with (obj_template)
    if (save)
        project_write_template()

// Timelines
savenum = 0
with (obj_timeline)
    savenum += save
buffer_write_int(savenum)
with (obj_timeline)
    if (save)
        project_write_timeline()

// Resources
savenum = 0
with (obj_resource)
    savenum += (save && id != res_def)
buffer_write_int(savenum)
with (obj_resource)
    if (save && id != res_def)
        project_write_resource()
