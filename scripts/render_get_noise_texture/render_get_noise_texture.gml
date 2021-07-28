/// render_get_noise_texture(index)
/// @arg index

function render_get_noise_texture(index)
{
	if (array_length(render_sample_noise_texture_array) < (index + 1) || !surface_exists(render_sample_noise_texture_array[index]))
		render_sample_noise_texture_array[index] = render_generate_noise(render_sample_noise_size, render_sample_noise_size, null)
	
	return render_sample_noise_texture_array[index]
}