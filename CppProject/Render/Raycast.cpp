#include "Raycast.hpp"
#include "Asset/VertexBuffer.hpp"
#include "Generated/Scripts.hpp"

namespace CppProject
{
	void Raycast::Begin(IntType view)
	{
		current = &views[view];
		current->clear();
		object = -1;
	}

	void Raycast::End()
	{
		current = nullptr;
		object = -1;
	}

	void Raycast::Add(const VertexBuffer& buffer, const Matrix& transform)
	{
		if (current && object >= 0 && buffer.valid && buffer.completed && buffer.numIndices)
			current->append({ buffer.id, object, transform });
	}

	Raycast::Hit Raycast::Cast(IntType view, const VecType& origin, const VecType& direction, RealType distance, BoolType placing) const
	{
		Hit hit;
		hit.face = e_dir_amount;
		hit.distance = distance;
		hit.position = origin + direction * distance;

		auto list = views.constFind(view);
		if (list == views.constEnd())
			return hit;

		for (const Entry& entry : list.value())
		{
			if (entry.object > 0)
			{
				obj_timeline* timeline = ObjTypeOpt(obj_timeline, entry.object);
				if (!timeline || (placing && (timeline->placed || timeline->parent_is_placed)))
					continue;

				if (timeline->type == e_tl_type_MODEL_PART && timeline->lock)
					continue;
			}

			VertexBuffer* buffer = FindVertexBuffer(entry.buffer);
			if (!buffer || !buffer->valid || !buffer->completed || buffer->bounds.empty || !buffer->bvh.triCount)
				continue;

			// Reject singular transforms before transforming the ray into mesh space
			const Matrix& matrix = entry.transform;
			if (matrix.GetDeterminant() == 0)
				continue;

			Matrix inverse = matrix.GetInversed();
			VecType localOrigin = inverse * VecType(origin.x, origin.y, origin.z, 1);
			VecType localDirection = inverse * VecType(direction.x, direction.y, direction.z);

			// Keep the direction unnormalized so distances remain in world units
			RealType first = 0, last = hit.distance;
			for (IntType axis = 0; axis < 3; axis++)
			{
				RealType start = localOrigin.Real(axis), step = localDirection.Real(axis);
				RealType lower = buffer->bounds.minPoint.Real(axis), upper = buffer->bounds.maxPoint.Real(axis);
				if (step == 0)
				{
					if (start < lower || start > upper)
						last = -1;
					continue;
				}

				RealType nearDistance = (lower - start) / step, farDistance = (upper - start) / step;
				if (nearDistance > farDistance)
					std::swap(nearDistance, farDistance);
				
				first = std::max(first, nearDistance);
				last = std::min(last, farDistance);
			}

			if (first > last)
				continue;

			// tinybvh preserves the unnormalized local direction and world-space distance
			const float maxDistance = (float)hit.distance;
			tinybvh::Ray ray(
				tinybvh::bvhvec3((float)localOrigin.x, (float)localOrigin.y, (float)localOrigin.z),
				tinybvh::bvhvec3((float)localDirection.x, (float)localDirection.y, (float)localDirection.z), maxDistance);
			
			// tinybvh cullBackfaces modification
			ray.cullBackfaces = true;

			buffer->bvh.Intersect(ray);
			if (ray.hit.t >= maxDistance)
				continue;

			IntType index = (IntType)ray.hit.prim * 3;
			const Vertex& a = buffer->vertexData[buffer->indexData[index]];
			const Vertex& b = buffer->vertexData[buffer->indexData[index + 1]];
			const Vertex& c = buffer->vertexData[buffer->indexData[index + 2]];
			VecType edge1(b.x - a.x, b.y - a.y, b.z - a.z), edge2(c.x - a.x, c.y - a.y, c.z - a.z);

			// Orient the triangle normal using the mesh's outward vertex normal
			VecType vertexNormal((a.data1 & 255) / 127.0 - 1, ((a.data1 >> 8) & 255) / 127.0 - 1, ((a.data1 >> 16) & 255) / 127.0 - 1);
			VecType normal = VecType::CrossProduct(edge1, edge2).GetNormalized();
			if (VecType::DotProduct(normal, vertexNormal) < 0)
				normal = -normal;
			
			IntType axis = 0;
			if (std::abs(normal.y) > std::abs(normal.x))
				axis = 1;
			if (std::abs(normal.z) > std::max(std::abs(normal.x), std::abs(normal.y)))
				axis = 2;

			hit.found = true;
			hit.distance = ray.hit.t;
			hit.position = origin + direction * ray.hit.t;
			hit.normal = (inverse.GetTransposed() * normal).GetNormalized();
			hit.face = axis * 2 + (normal.Real(axis) < 0 ? 1 : 0);
			hit.object = entry.object;
		}

		return hit;
	}
}
