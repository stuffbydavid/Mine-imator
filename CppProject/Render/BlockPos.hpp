#pragma once
#include "Type/VecType.hpp"

namespace CppProject
{
	struct Bounds;

	// Stores an unpacked block position from a triangle in a vertex buffer, relative to an origin position.
	struct BlockPos
	{
		BlockPos();
		BlockPos(const VecType& pos) : BlockPos((int32_t)pos.x, (int32_t)pos.y, (int32_t)pos.z) {}
		BlockPos(int32_t x, int32_t y, int32_t z, bool doubleBlock = false) : x(x), y(y), z(z), doubleBlock(doubleBlock) {}
		BlockPos(uint32_t packed, const BlockPos& origin);

		bool operator==(const BlockPos& other) const { return x == other.x && y == other.y && z == other.z; }

		// Returns whether a block position is stored.
		BoolType IsValid() const;

		// Returns the block coordinates as a vector.
		VecType ToVec() const { return VecType(x, y, z); }

		// Tracks the minimum coordinates used as the packing origin.
		void AddPos(const BlockPos& pos);

		// Returns the block bounds, including the upper block for double blocks.
		Bounds GetBounds() const;

		// Packs the coordinates and double-block flag relative to the buffer origin.
		uint32_t Pack(const BlockPos& origin) const;

		int32_t x, y, z;
		bool doubleBlock;

		static constexpr uint32_t NO_BLOCK_POS = 0xFFFFFFFFu;
	};
}
