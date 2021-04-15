/// scissor_start(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height

render_shader_obj = shader_map[?shader_scissor]
with (render_shader_obj)
{
	shader_set(shader_scissor)
	shader_scissor_set(argument0, argument1, argument2, argument3)
}