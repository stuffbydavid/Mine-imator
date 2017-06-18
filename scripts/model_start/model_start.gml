/// model_start()

vertex_buff = vertex_create_buffer()
vertex_begin(vertex_buff, vertex_format)
repeat (3) // vertex_freeze glitch
    vertex_add(0, 0, 0, 0, 0, 0, 0, 0)

return vertex_buff
