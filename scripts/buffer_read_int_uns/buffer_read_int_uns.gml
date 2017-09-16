/// buffer_read_int_uns()
/// @desc Reads a 4 byte unsigned integer.

gml_pragma("forceinline")

return buffer_read(buffer_current, buffer_u32)
