#pragma once
#include "Type/VecType.hpp"
#include "Matrix.hpp"
#include "Vertex.hpp"

namespace CppProject
{
	struct BlockPos;

	// Axis-aligned bounding box defined by 2 points.
	struct Bounds
	{
		Bounds() {}
		Bounds(VecType minPoint, VecType maxPoint) : minPoint(minPoint), maxPoint(maxPoint), empty(false) {}
		Bounds(const Heap<Vertex>& vertexData);

		// Reset the bounds.
		void Reset() { empty = true; }

		// Checks whether the point is inside or on the bounds.
		BoolType ContainsPoint(VecType point) const;

		// Checks whether the bounds intersect with another bounds.
		BoolType Intersects(const Bounds& bounds) const;

		// Clips the ray to its entry distance, optionally returning the entry face.
		BoolType IntersectRay(const VecType& origin, const VecType& direction, RealType& distance, IntType* face = nullptr) const;

		// Adds the given point to the bounds.
		void AddPoint(VecType point);

		// Adds the given bounds.
		void AddBounds(const Bounds& bounds);

		// Adds the given transformed bounds.
		void AddBounds(const Bounds& bounds, const Matrix& transform);

		VecType minPoint, maxPoint;
		BoolType empty = true;
	};

	// Defines build wireframe bounds for a block position.
	struct BlockBounds
	{
		BlockBounds(const BlockPos& blockPos);

		// Fits geometry to the block limits with an optional minimum size on X/Y.
		Bounds Fit(RealType minSize = 0) const;

		Bounds triangleBounds, blockBounds;
		uint8_t faces = 0;
	};
}
