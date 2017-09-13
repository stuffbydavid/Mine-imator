/// buffer_is_eof()

gml_pragma("forceinline")

return (buffer_tell(buffer_current) >= buffer_get_size(buffer_current))