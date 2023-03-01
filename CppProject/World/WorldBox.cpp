#include "World.hpp"

namespace CppProject
{
	void WorldBox::Adjust()
	{
		WorldVec startPos = GetStart();
		WorldVec endPos = GetEnd();
		start = startPos;
		end = endPos;
	}

	WorldVec WorldBox::GetStart() const
	{
		return {
			std::min(start.x, end.x - 1),
			std::min(start.y, end.y - 1),
			std::min(start.z, end.z - 1)
		};
	}

	WorldVec WorldBox::GetEnd() const
	{
		return {
			std::max(start.x + 1, end.x),
			std::max(start.y + 1, end.y),
			std::max(start.z + 1, end.z)
		};
	}

	BoolType WorldBox::Contains(const WorldVec& pos) const
	{
		return (pos.x >= start.x && pos.x < end.x &&
				pos.y >= start.y && pos.y < end.y &&
				pos.z >= start.z && pos.z < end.z);
	}

	BoolType WorldBox::Intersects(const WorldBox& other) const
	{
		return (start.x < other.end.x && end.x > other.start.x &&
				start.y < other.end.y && end.y > other.start.y &&
				start.z < other.end.z && end.z > other.start.z);
	}
}