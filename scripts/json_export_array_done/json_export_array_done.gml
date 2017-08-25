/// json_export_array_done()

json_indent = string_replace(json_indent, "\t", "")
json_string += "\n" + json_indent + "]"
json_add_comma = true