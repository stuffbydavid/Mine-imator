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

	QVector<VecType> Bounds::GetPoints() const
	{
		return {
			{ minPoint.x, minPoint.y, minPoint.z, 1 },
			{ maxPoint.x, minPoint.y, minPoint.z, 1 },
			{ minPoint.x, maxPoint.y, minPoint.z, 1 },
			{ maxPoint.x, maxPoint.y, minPoint.z, 1 },
			{ minPoint.x, minPoint.y, maxPoint.z, 1 },
			{ maxPoint.x, minPoint.y, maxPoint.z, 1 },
			{ minPoint.x, maxPoint.y, maxPoint.z, 1 },
			{ maxPoint.x, maxPoint.y, maxPoint.z, 1 }
		};
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

		AddPoint(bounds.minPoint);
		AddPoint(bounds.maxPoint);
	}

	void Bounds::AddBounds(const Bounds& bounds, Matrix transform)
	{
		if (bounds.empty)
			return;

		for (const VecType& pnt : bounds.GetPoints())
			AddPoint(transform * pnt);
	}
}