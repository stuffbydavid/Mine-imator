/// project_write_value_types(timeline)
/// @arg timeline

var tl = argument0;

for (var t = 0; t < value_types; t++)
    buffer_write_byte(tl.value_type[t])
