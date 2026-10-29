#include "BlockPos.hpp"
#include "Bounds.hpp"
#include "Generated/Scripts.hpp"

namespace CppProject
{
	BlockPos::BlockPos() : BlockPos(std::numeric_limits<int32_t>::min(), 0, 0)
	{
	}

	BlockPos::BlockPos(uint32_t packed, const BlockPos& origin) : BlockPos()
	{
		if (packed != NO_BLOCK_POS)
		{
			// Unpack coordinates relative to the vertex buffer origin
			x = origin.x + int32_t(packed & 63);
			y = origin.y + int32_t((packed >> 6) & 63);
			z = origin.z + int32_t((packed >> 12) & 63);
			doubleBlock = (packed & (1u << 18)) != 0;
		}
	}

	BoolType BlockPos::IsValid() const
	{
		return x != std::numeric_limits<int32_t>::min();
	}

	void BlockPos::AddPos(const BlockPos& pos)
	{
		if (!pos.IsValid())
			return;

		if (!IsValid())
			*this = pos;
		else
		{
			x = std::min(x, pos.x);
			y = std::min(y, pos.y);
			z = std::min(z, pos.z);
		}
	}

	Bounds BlockPos::GetBounds() const
	{
		VecType lower = ToVec() * block_size_;
		Bounds bounds(lower, lower + VecType(block_size_, block_size_, block_size_));

		// Allow the fitted box to reach the upper block
		if (doubleBlock)
			bounds.maxPoint.z += block_size_;

		return bounds;
	}

	uint32_t BlockPos::Pack(const BlockPos& origin) const
	{
		if (!IsValid())
			return NO_BLOCK_POS;

		// Store six bits per axis followed by the double-block flag
		return uint32_t(x - origin.x) |
			   (uint32_t(y - origin.y) << 6) |
			   (uint32_t(z - origin.z) << 12) |
			   (doubleBlock ? (1u << 18) : 0);
	}
}
