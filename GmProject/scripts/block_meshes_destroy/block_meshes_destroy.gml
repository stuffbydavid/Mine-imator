function block_meshes_destroy()
{
	for (var s = 0; s < array_length(block_meshes); s++)
		if (block_meshes[s] != null)
			with (block_meshes[s])
				instance_destroy()

	block_meshes = []
	block_meshes_transparent = false
}
