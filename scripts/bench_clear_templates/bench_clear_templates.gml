/// bench_clear_templates()
/// Clear templates associated with the workbench.

with (obj_template)
    if (creator = app.bench_settings)
        instance_destroy()
