#include "Raycast.hpp"
#include "BlockPos.hpp"
#include "Asset/VertexBuffer.hpp"
#include "Generated/Scripts.hpp"

namespace CppProject
{
	void Raycast::Begin(IntType view)
	{
		objects = &viewObjects[view];
		objects->clear();
		tlId = -1;
	}

	void Raycast::End()
	{
		objects = nullptr;
		tlId = -1;
	}

	void Raycast::AddObject(const VertexBuffer& vbuf, const Matrix& transform)
	{
		if (objects && tlId >= 0 && vbuf.valid && vbuf.completed && vbuf.numIndices)
			objects->append({ vbuf.id, tlId, transform });
	}

	static obj_timeline* GetBuildTimeline(IntType id)
	{
		obj_timeline* tl = ObjTypeOpt(obj_timeline, id);
		if (!tl || tl->placed || tl->parent_is_placed)
			return nullptr;

		// Resolve model parts to their containing block timeline
		obj_timeline* root = tl;
		if (tl->type == e_tl_type_MODEL_PART)
		{
			if (tl->lock)
				return nullptr;
			
			root = ObjTypeOpt(obj_timeline, tl->part_of);
		}

		if (!root ||
			(root->type != e_tl_type_SCENERY && root->type != e_tl_type_BLOCK) ||
			tl->matrix_render.matrix.GetDeterminant() == 0)
			return nullptr;

		return tl;
	}

	static void FitBuildBox(Raycast::Hit& hit,
		const Raycast::WorldObject& sourceObject,
		const QVector<Raycast::WorldObject>& objects,
		const BlockPos& blockPos
	)
	{
		obj_timeline* tl = GetBuildTimeline(hit.tlId);
		if (!tl)
			return;

		// Convert the source block position to the hit timeline's local axes
		Matrix localTransform = tl->matrix_render.matrix.GetInversed() * sourceObject.transform;
		VecType center = (blockPos.ToVec() + VecType(0.5, 0.5, 0.5)) * block_size_;
		center.w = 1;
		center = localTransform * center;
		for (IntType axis = 0; axis < 3; axis++)
			hit.blockPos.Real(axis) = std::floor(center.Real(axis) / block_size_);

		// Combine block bounds across vertex buffers in the timeline
		BlockBounds bounds(blockPos);
		for (const Raycast::WorldObject& object : objects)
		{
			if (object.tlId != sourceObject.tlId || object.transform != sourceObject.transform)
				continue;

			VertexBuffer* vbuf = FindVertexBuffer(object.vbufId);
			if (vbuf && vbuf->valid && vbuf->completed)
				vbuf->AddBlockBounds(blockPos, bounds);
		}

		// Fit with minimum size of 4 on X/Y and 1 on Z
		Bounds fitted = bounds.Fit(4);

		hit.blockBounds = BlockPos(hit.blockPos).GetBounds();
		if (!fitted.empty)
		{
			hit.blockBounds.Reset();
			hit.blockBounds.AddBounds(fitted, localTransform);
		}

		// Keep the source block and fitted box even when the second ray misses
		hit.hasBlockPos = true;
	}

	static BoolType CastBuildBox(Raycast::Hit& hit, const VecType& origin, const VecType& direction, RealType distance)
	{
		obj_timeline* tl = GetBuildTimeline(hit.tlId);
		if (!tl || hit.blockBounds.empty)
			return false;

		// Transform the ray into the timeline's local space
		Matrix inverse = tl->matrix_render.matrix.GetInversed();
		VecType localOrigin = inverse * VecType(origin.x, origin.y, origin.z, 1);
		VecType localDirection = inverse * VecType(direction.x, direction.y, direction.z);
		IntType face = -1;

		if (!hit.blockBounds.IntersectRay(localOrigin, localDirection, distance, &face))
			return false;

		// An exit face viewed from inside the box is a backface
		if (face < 0 || distance < 0)
			return false;

		hit.distance = distance;
		hit.position = origin + direction * distance;
		hit.normal = vec3_normalize(inverse.GetTransposed() * dir_get_vec3(face));
		hit.face = face;
		hit.found = true;

		return true;
	}

	Raycast::Hit Raycast::Cast(IntType view, const VecType& origin, const VecType& direction, RealType distance, BoolType placing, BoolType build)
	{
		Hit hit;
		hit.face = e_dir_amount;
		hit.distance = distance;
		hit.position = origin + direction * distance;

		auto viewObjectsIt = viewObjects.constFind(view);
		if (viewObjectsIt == viewObjects.constEnd())
		{
			if (build)
				buildBoxes.remove(view);
			
			return hit;
		}

		if (build)
		{
			if (buildBoxesWorldId != global::render_world_id)
			{
				buildBoxes.clear();
				buildBoxesWorldId = global::render_world_id;
			}

			// The previous fitted box competes with scene geometry in the initial raycast
			auto previous = buildBoxes.constFind(view);
			if (previous != buildBoxes.constEnd())
			{
				Hit boxHit = previous.value();
				BoolType tlActive = false;

				for (const WorldObject& object : viewObjectsIt.value())
				{
					if (object.tlId == boxHit.tlId)
					{
						tlActive = true;
						break;
					}
				}

				if (!tlActive)
					buildBoxes.remove(view);
				else if (CastBuildBox(boxHit, origin, direction, distance))
					hit = boxHit;
			}
		}

		const WorldObject* sourceObject = nullptr;
		BlockPos sourceBlockPos;

		for (const WorldObject& object : viewObjectsIt.value())
		{
			if (object.tlId > 0)
			{
				obj_timeline* tl = ObjTypeOpt(obj_timeline, object.tlId);
				if (!tl || (placing && (tl->placed || tl->parent_is_placed)))
					continue;

				if (tl->type == e_tl_type_MODEL_PART && tl->lock)
					continue;
			}

			VertexBuffer* vbuf = FindVertexBuffer(object.vbufId);
			if (!vbuf || !vbuf->valid || !vbuf->completed || vbuf->bounds.empty || !vbuf->bvh.triCount)
				continue;

			// Reject singular transforms before transforming the ray into mesh space
			const Matrix& matrix = object.transform;
			if (matrix.GetDeterminant() == 0)
				continue;

			Matrix inverse = matrix.GetInversed();
			VecType localOrigin = inverse * VecType(origin.x, origin.y, origin.z, 1);
			VecType localDirection = inverse * VecType(direction.x, direction.y, direction.z);

			// Keep the direction unnormalized so distances remain in world units
			RealType boundsDistance = hit.distance;
			if (!vbuf->bounds.IntersectRay(localOrigin, localDirection, boundsDistance))
				continue;

			// tinybvh preserves the unnormalized local direction and world-space distance
			tinybvh::Ray ray(
				tinybvh::bvhvec3((float)localOrigin.x, (float)localOrigin.y, (float)localOrigin.z),
				tinybvh::bvhvec3((float)localDirection.x, (float)localDirection.y, (float)localDirection.z),
				(float)hit.distance
			);
			
			// tinybvh cullBackfaces modification
			ray.cullBackfaces = true;

			vbuf->bvh.Intersect(ray);
			if (ray.hit.t >= (float)hit.distance)
				continue;

			IntType index = (IntType)ray.hit.prim * 3;
			const Vertex& a = vbuf->vertexData[vbuf->indexData[index]];
			const Vertex& b = vbuf->vertexData[vbuf->indexData[index + 1]];
			const Vertex& c = vbuf->vertexData[vbuf->indexData[index + 2]];
			VecType edge1(b.x - a.x, b.y - a.y, b.z - a.z);
			VecType edge2(c.x - a.x, c.y - a.y, c.z - a.z);

			// Orient the triangle normal using the mesh's outward vertex normal
			VecType vertexNormal(
				(a.data1 & 255) / 127.0 - 1,
				((a.data1 >> 8) & 255) / 127.0 - 1,
				((a.data1 >> 16) & 255) / 127.0 - 1
			);
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
			hit.tlId = object.tlId;

			// Find block position in vertex buffer
			if (build)
			{
				hit.hasBlockPos = false;
				hit.blockBounds.Reset();

				sourceObject = &object;
				sourceBlockPos = vbuf->GetTriangleBlockPos(ray.hit.prim);

				if (!sourceBlockPos.IsValid())
				{
					VecType pos = (localOrigin + localDirection * ray.hit.t - normal * 0.0001) / block_size_;
					for (IntType axis = 0; axis < 3; axis++)
						pos.Real(axis) = std::floor(pos.Real(axis));
					
					sourceBlockPos = BlockPos(pos);
				}
			}
		}

		// In build mode, fit the wireframe box around the block geometry and perform another raycast
		if (build)
		{
			if (sourceObject)
			{
				FitBuildBox(hit, *sourceObject, viewObjectsIt.value(), sourceBlockPos);
				CastBuildBox(hit, origin, direction, distance);

				if (!hit.blockBounds.empty)
					buildBoxes[view] = hit;
			}

			if (hit.blockBounds.empty)
				buildBoxes.remove(view);
		}

		return hit;
	}
}
