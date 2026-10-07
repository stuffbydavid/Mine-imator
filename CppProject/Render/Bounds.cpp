#include "Bounds.hpp"

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
}
