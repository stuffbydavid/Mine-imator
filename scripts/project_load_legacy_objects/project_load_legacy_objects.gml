/// project_load_legacy_objects()

// Templates
repeat (buffer_read_int())
    project_load_legacy_template()
        
// Timelines
//repeat (buffer_read_int())
//    with (new(obj_timeline))
//        project_load_legacy_timeline()
        
// Resources
//repeat (buffer_read_int())
//    with (new(obj_resource))
//        project_load_legacy_resource()
