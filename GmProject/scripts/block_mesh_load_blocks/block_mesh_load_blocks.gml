/// CppSeparate BoolType block_mesh_load_blocks(Scope<obj_block_mesh>, IntType, IntType, IntType)
/// @desc Save decoded blocks into the block mesh in XYZ order, with X varying fastest.
/// Palette entries are little-endian u16 block ID + u16 state ID.
/// Grid indices use ceil(log2(palette size)) bits, least significant bit first, without padding.
/// A palette-indexed waterlogged bitset follows the packed grid, starting at the next byte.
/// A single-entry palette has no grid bits.
/// @arg originx
/// @arg originy
/// @arg originz

function block_mesh_load_blocks(originx, originy, originz)
{
    return true
}
