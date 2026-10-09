/// @desc Updates randomization between samples.

function render_high_update_jitter()
{
	// Randomize blue noise
	render_sample_noise_texture = render_get_noise_texture(render_sample_current)
	
	// Progressive AA
	render_high_update_aa_jitter()
	
	// Shadows
	if (render_shadows && !project_render_shadows_jittered && project_render_shadows_blur_quality > 0 && render_sample_current > 0)
	{
		var pcsssamples, pcsskernel, diskangle;
		pcsssamples = array_length(render_pcss_kernel) / 2
		pcsskernel = render_generate_progressive_disk_samples(pcsssamples, render_sample_current)
		diskangle = frac(render_sample_current * .61803399) * pi * 2
		render_pcss_kernel_rotated = render_rotate_progressive_disk_samples(pcsskernel, diskangle)
	}
	else
		render_pcss_kernel_rotated = render_pcss_kernel
}
