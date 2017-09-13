/// buffer_read_int()
/// @desc Reads a 4 byte integer.

gml_pragma("forceinline")

return buffer_read(buffer_current, buffer_s32)
