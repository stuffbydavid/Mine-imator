#include "Bounds.hpp"
#include "BlockPos.hpp"

namespace CppProject
{
	Bounds::Bounds(const Heap<Vertex>& vertexData)
	{
		for (IntType i = 0; i < vertexData.Size(); i++)
		{
			const Vertex& vertex = vertexData.Value(i);
			AddPoint({ vertex.x, vertex.y, vertex.z });
		}
	}

	BoolType Bounds::ContainsPoint(VecType point) const
	{
		return (!empty &&
			point.x >= minPoint.x && point.x <= maxPoint.x &&
			point.y >= minPoint.y && point.y <= maxPoint.y &&
			point.z >= minPoint.z && point.z <= maxPoint.z);
	}

	BoolType Bounds::Intersects(const Bounds& bounds) const
	{
		return !empty && !bounds.empty &&
			minPoint.x <= bounds.maxPoint.x && maxPoint.x >= bounds.minPoint.x &&
			minPoint.y <= bounds.maxPoint.y && maxPoint.y >= bounds.minPoint.y &&
			minPoint.z <= bounds.maxPoint.z && maxPoint.z >= bounds.minPoint.z;
	}

	BoolType Bounds::IntersectRay(const VecType& origin, const VecType& direction, RealType& distance, IntType* face) const
	{
		if (empty)
			return false;

		RealType first = -std::numeric_limits<RealType>::infinity();
		RealType last = distance;
		IntType entryFace = -1;

		// Clip the ray interval against each axis
		for (IntType axis = 0; axis < 3; axis++)
		{
			RealType start = origin.Value(axis).ToReal(), step = direction.Value(axis).ToReal();
			RealType lower = minPoint.Value(axis).ToReal(), upper = maxPoint.Value(axis).ToReal();
			if (step == 0)
			{
				if (start < lower || start > upper)
					return false;
				continue;
			}

			RealType nearDistance = (lower - start) / step, farDistance = (upper - start) / step;
			if (nearDistance > farDistance)
				std::swap(nearDistance, farDistance);
			
			if (nearDistance > first)
			{
				first = nearDistance;
				entryFace = axis * 2 + (step > 0 ? 1 : 0);
			}
			
			last = std::min(last, farDistance);
			if (first > last)
				return false;
		}

		if (last < 0)
			return false;

		distance = first;
		
		// Store entry face index in bounds
		if (face)
			*face = entryFace;
		
		return true;
	}

	void Bounds::AddPoint(VecType point)
	{
		if (empty)
		{
			minPoint = point;
			maxPoint = point;
			empty = false;
		}
		else
		{
			minPoint = { std::min(minPoint.x, point.x), std::min(minPoint.y, point.y), std::min(minPoint.z, point.z) };
			maxPoint = { std::max(maxPoint.x, point.x), std::max(maxPoint.y, point.y), std::max(maxPoint.z, point.z) };
		}
	}

	void Bounds::AddBounds(const Bounds& bounds)
	{
		if (bounds.empty)
			return;

		if (empty)
		{
			minPoint = bounds.minPoint;
			maxPoint = bounds.maxPoint;
			empty = false;

			return;
		}

		minPoint.x = std::min(minPoint.x, bounds.minPoint.x);
		minPoint.y = std::min(minPoint.y, bounds.minPoint.y);
		minPoint.z = std::min(minPoint.z, bounds.minPoint.z);
		maxPoint.x = std::max(maxPoint.x, bounds.maxPoint.x);
		maxPoint.y = std::max(maxPoint.y, bounds.maxPoint.y);
		maxPoint.z = std::max(maxPoint.z, bounds.maxPoint.z);
	}

	void Bounds::AddBounds(const Bounds& bounds, const Matrix& transform)
	{
		if (bounds.empty)
			return;

		const VecType center(
			(bounds.minPoint.x + bounds.maxPoint.x) * 0.5,
			(bounds.minPoint.y + bounds.maxPoint.y) * 0.5,
			(bounds.minPoint.z + bounds.maxPoint.z) * 0.5,
			1.0
		);
		const VecType extents(
			(bounds.maxPoint.x - bounds.minPoint.x) * 0.5,
			(bounds.maxPoint.y - bounds.minPoint.y) * 0.5,
			(bounds.maxPoint.z - bounds.minPoint.z) * 0.5
		);
		const VecType worldCenter = transform * center;
		const VecType worldExtents(
			std::abs(transform.m[0]) * extents.x + std::abs(transform.m[4]) * extents.y + std::abs(transform.m[8]) * extents.z,
			std::abs(transform.m[1]) * extents.x + std::abs(transform.m[5]) * extents.y + std::abs(transform.m[9]) * extents.z,
			std::abs(transform.m[2]) * extents.x + std::abs(transform.m[6]) * extents.y + std::abs(transform.m[10]) * extents.z
		);

		AddPoint({ worldCenter.x - worldExtents.x, worldCenter.y - worldExtents.y, worldCenter.z - worldExtents.z });
		AddPoint({ worldCenter.x + worldExtents.x, worldCenter.y + worldExtents.y, worldCenter.z + worldExtents.z });
	}

	BlockBounds::BlockBounds(const BlockPos& blockPos) : blockBounds(blockPos.GetBounds())
	{}

	Bounds BlockBounds::Fit(RealType minSize) const
	{
		Bounds fitted = triangleBounds;
		if (fitted.empty)
			return fitted;

		for (IntType axis = 0; axis < 3; axis++)
		{
			RealType minLimit = blockBounds.minPoint.Value(axis).ToReal();
			RealType maxLimit = blockBounds.maxPoint.Value(axis).ToReal();
			RealType& lower = fitted.minPoint.Real(axis);
			RealType& upper = fitted.maxPoint.Real(axis);

			// Clamp triangle bounds to the allowed block area
			lower = std::max(lower, minLimit);
			upper = std::min(upper, maxLimit);

			// Extend behind an exposed face when the opposite face was culled
			uint8_t axisFaces = (faces >> (axis * 2)) & 3;
			if (axisFaces == 1)
				lower = minLimit;
			else if (axisFaces == 2)
				upper = maxLimit;

			// Anchor the minimum height to the bottom of the cell
			if (axis == 2)
			{
				if (upper - lower < 1)
				{
					lower = minLimit;
					upper = lower + 1;
				}
			}

			// Center the minimum X/Y size around the fitted bounds
			else if (upper - lower < minSize)
			{
				RealType center = (lower + upper) * 0.5;
				lower = center - minSize * 0.5;
				upper = center + minSize * 0.5;
			}
		}

		return fitted;
	}
}
