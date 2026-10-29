#pragma once
#include "Matrix.hpp"
#include "Type/VecType.hpp"

namespace CppProject
{
	struct VertexBuffer;

	// Retains a flat list of source geometry and transforms for each world view.
	struct Raycast
	{
		struct Entry
		{
			IntType buffer, object;
			Matrix transform;
		};

		struct Hit
		{
			BoolType found = false;
			RealType distance = 0;
			VecType position, normal;
			IntType face = -1, object = 0;
		};

		// Replaces the geometry list when the view's color pass is rendered.
		void Begin(IntType view);

		// Stops recording before overlays and other render passes.
		void End();

		// Records source geometry before batching changes its object indices.
		void Add(const VertexBuffer& buffer, const Matrix& transform);

		// Finds the nearest triangle using each vertex buffer's BVH.
		Hit Cast(IntType view, const VecType& origin, const VecType& direction, RealType distance, BoolType placing) const;

		IntType object = -1;
		QHash<IntType, QVector<Entry>> views;
		QVector<Entry>* current = nullptr;
	};
}
