/// @desc Adds a vertex from real-valued position, normal and texture coordinates.
/// @arg x
/// @arg y
/// @arg z
/// @arg nx
/// @arg ny
/// @arg nz
/// @arg tx
/// @arg ty

function vertex_add_real(xx, yy, zz, nx, ny, nz, tx, ty)
{
	vertex_position_3d(vbuffer_current, xx, yy, zz)
	vertex_normal(vbuffer_current, nx, ny, nz)
	vertex_color(vbuffer_current, vertex_rgb, vertex_alpha)
	vertex_texcoord(vbuffer_current, tx, ty)

	vertex_add_wave(zz)
}
