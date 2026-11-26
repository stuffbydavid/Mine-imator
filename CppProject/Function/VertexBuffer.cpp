#include "Generated/Scripts.hpp"

#include "AppHandler.hpp"
#include "Asset/VertexBuffer.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Render/PrimitiveRenderer.hpp"
#include "Render/VertexBufferRenderer.hpp"

namespace CppProject
{
	void vertex_add(VecType pos, VecType normal, VecType texcoord)
	{
		IntType vbuf = global::vbuffer_current;
		vertex_position_3d(vbuf, pos.x, pos.y, pos.z);
		vertex_normal(vbuf, normal.x, normal.y, normal.z);
		vertex_texcoord(vbuf, texcoord.x, texcoord.y);

		vertex_add_wave(pos.z);
	}

	void vertex_bend_configure(IntType id, VecType pivot, VecType minimum, VecType maximum, VecType direction, RealType kind, RealType sharpAxis, IntType zeroBuffer)
	{
		if (VertexBuffer* vbuf = FindVertexBuffer(id))
		{
			vbuf->bend.enabled = true;
			vbuf->bend.zeroBuffer = zeroBuffer;
			vbuf->bend.pivot = pivot;
			vbuf->bend.minimum = minimum;
			vbuf->bend.maximum = maximum;
			vbuf->bend.direction = direction;
			vbuf->bend.kind = kind;
			vbuf->bend.sharpAxis = sharpAxis;
		}
	}

	void vertex_bend_update(IntType id, VecType angle)
	{
		if (VertexBuffer* vbuf = FindVertexBuffer(id))
		{
			for (int i = 0; i < 3; i++)
				angle.Real(i) = std::max(vbuf->bend.minimum.Real(i), std::min(vbuf->bend.maximum.Real(i), angle.Real(i)));

			vbuf->bend.angle = angle;

			// Match the CPU generator's vec3_equals test after clamping
			vbuf->bend.zeroPose = std::abs(angle.x) < 0.0001 && std::abs(angle.y) < 0.0001 && std::abs(angle.z) < 0.0001;
		}
	}

	void vertex_bend_quad(IntType id, VecType a, VecType b, VecType c, VecType d)
	{
		if (VertexBuffer* vbuf = FindVertexBuffer(id))
		{
			vbuf->bend.hasQuad = true;
			vbuf->bend.quad[0] = a;
			vbuf->bend.quad[1] = b;
			vbuf->bend.quad[2] = c;
			vbuf->bend.quad[3] = d;
		}
	}

	void vertex_bend_triangle(IntType id, VecType p1, VecType p2, VecType p3, VecType uv1, VecType uv2, VecType uv3,
		VarType normal1, VarType normal2, VarType normal3, BoolType invert,
		RealType emissive, RealType wave, RealType zmin, RealType zmax, RealType subsurface)
	{
		VertexBuffer* vbuf = FindVertexBuffer(id);
		if (!vbuf || !vbuf->bend.enabled)
			return;

		VecType points[3] = { p1, p2, p3 };
		VecType uvs[3] = { uv1, uv2, uv3 };
		bool flat = !normal1.IsContainer();

		VecType faceNormal = VecType::CrossProduct(p2 - p1, p3 - p1);
		VecType normals[3] = { faceNormal, faceNormal, faceNormal };
		if (!flat)
		{
			normals[0] = normal1.ToVec();
			normals[1] = normal2.ToVec();
			normals[2] = normal3.ToVec();
		}

		if (invert)
		{
			std::swap(points[0], points[1]);
			std::swap(uvs[0], uvs[1]);

			// Match vbuffer_add_triangle, which negates normals without swapping them
			for (auto& normal : normals)
				normal = -normal;
		}

		Vertex vertices[3];
		VertexBuffer::BendVertex bends[3];
		RealType normalWeights[3] = { p1.w, p2.w, p3.w };
		for (int i = 0; i < 3; i++)
		{
			int j = (i + 1) % 3;
			int k = (i + 2) % 3;

			vertices[i] = Vertex(
				points[i].x, points[i].y, points[i].z,
				uvs[i].x, uvs[i].y,
				normals[i].x, normals[i].y, normals[i].z,
				(uint8_t)((IntType)subsurface / 2),
				wave == 2,
				wave != 0,
				((IntType)subsurface % 2) != 0, emissive
			);

			VertexBuffer::BendVertex& bend = bends[i];
			bend = {
				{ (float)points[i].w, flat ? 1.0f : 0.0f, 0.0f, 0.0f },
				{ (float)points[j].x, (float)points[j].y, (float)points[j].z, (float)points[j].w },
				{ (float)points[k].x, (float)points[k].y, (float)points[k].z, (float)points[k].w },
				{ (float)normals[i].x, (float)normals[i].y, (float)normals[i].z, (float)normalWeights[i] }
			};

			RealType du1 = uvs[j].x - uvs[i].x, dv1 = uvs[j].y - uvs[i].y;
			RealType du2 = uvs[k].x - uvs[i].x, dv2 = uvs[k].y - uvs[i].y;
			RealType det = du1 * dv2 - dv1 * du2;
			if (std::abs(det) > 1e-20)
			{
				bend.data[2] = dv2 / det;
				bend.data[3] = -dv1 / det;
			}

			// Offset planes average the two triangle area normals of each quad
			if (!flat && vbuf->bend.hasQuad)
			{
				int qi = -1, qj = -1, qk = -1;
				for (int q = 0; q < 4; q++)
				{
					if (points[i] == vbuf->bend.quad[q])
						qi = q;
					if (points[j] == vbuf->bend.quad[q])
						qj = q;
					if (points[k] == vbuf->bend.quad[q])
						qk = q;
				}

				if (qi >= 0 && qj >= 0 && qk >= 0 && qi != qj && qi != qk && qj != qk)
				{
					int qc = 6 - qi - qj - qk;
					VecType c = vbuf->bend.quad[qc];
					bend.c[0] = c.x;
					bend.c[1] = c.y;
					bend.c[2] = c.z;
					bend.c[3] = c.w;

					int direction = (qj - qi + 4) % 4 == 1 || (qk - qj + 4) % 4 == 1 ? 1 : -1;
					int dA = (direction * (qj - qi) + 4) % 4;
					int dC = (direction * (qc - qi) + 4) % 4;
					VecType a = points[j] - points[i], b = points[k] - points[i], cEdge = c - points[i];

					int mode;
					VecType area;
					if (dC < dA)
					{
						mode = 2;
						area = VecType::CrossProduct(cEdge, a) + VecType::CrossProduct(a, b);
					}
					else if (dC == 2)
					{
						mode = 3;
						area = VecType::CrossProduct(a, cEdge) + VecType::CrossProduct(cEdge, b);
					}
					else
					{
						mode = 4;
						area = VecType::CrossProduct(a, b) + VecType::CrossProduct(b, cEdge);
					}

					if (normals[i].w != 0)
						bend.data[1] = mode * direction * normals[i].w;
					else if (VecType::DotProduct(area, normals[i]) < 0)
						bend.data[1] = -mode;
					else
						bend.data[1] = mode;
				}
			}
		}

		vbuf->bend.wind = VecType(wave, zmin, zmax);
		vbuf->AddBendTriangle(vertices, bends);
	}

	void vbuffer_add_triangle(VecType pos1, VecType pos2, VecType pos3,
		VecType tex1, VecType tex2, VecType tex3, VarType normal1, VarType normal2, VarType normal3,
		BoolType invert, VarType matrix)
	{
		VecType n1, n2, n3;
		if (!normal1.IsContainer())
		{
			n1 = vec3_cross(point3D_sub(pos1, pos2), point3D_sub(pos2, pos3));
			n2 = n1;
			n3 = n1;
		}
		else
		{
			n1 = normal1.ToVec();
			if (matrix != null_ && normal2 == null_)
				n2 = n1;
			else
				n2 = normal2.ToVec();

			if (matrix != null_ && normal3 == null_)
				n3 = n1;
			else
				n3 = normal3.ToVec();
		}

		if (matrix != null_)
		{
			MatrixType mat = matrix.ToMat();
			pos1 = point3D_mul_matrix(pos1, mat);
			pos2 = point3D_mul_matrix(pos2, mat);
			pos3 = point3D_mul_matrix(pos3, mat);
			n1 = vec3_normalize(vec3_mul_matrix(n1, mat));
			n2 = vec3_normalize(vec3_mul_matrix(n2, mat));
			n3 = vec3_normalize(vec3_mul_matrix(n3, mat));
		}

		if (invert)
		{
			std::swap(pos1, pos2);
			std::swap(tex1, tex2);
			n1 = -n1;
			n2 = -n2;
			n3 = -n3;
		}

		vertex_add(pos1, vec3_normalize(n1), tex1);
		vertex_add(pos2, vec3_normalize(n2), tex2);
		vertex_add(pos3, vec3_normalize(n3), tex3);
	}

	IntType get_vbuffer_triangles()
	{
		IntType num = VB->trianglesSubmitted;
		VB->trianglesSubmitted = 0;
		return num;
	}

	IntType get_vbuffer_render_calls()
	{
		IntType num = VB->renderCalls;
		VB->renderCalls = 0;
		return num;
	}

	IntType get_primitive_lines()
	{
		IntType num = PR->linesSubmitted;
		PR->linesSubmitted = 0;
		return num;
	}

	IntType get_primitive_triangles()
	{
		IntType num = PR->trianglesSubmitted;
		PR->trianglesSubmitted = 0;
		return num;
	}

	IntType get_primitive_render_calls()
	{
		IntType num = PR->renderCalls;
		PR->renderCalls = 0;
		return num;
	}

	void vbuffer_set_batching(IntType id, BoolType batching)
	{
		if (VertexBuffer* buf = FindVertexBuffer(id))
			buf->batching = batching;
	}

	IntType vbuffer_copy(IntType id)
	{
		if (VertexBuffer* vbuf = FindVertexBuffer(id))
			if (VertexBuffer* copy = vbuf->Copy())
				return copy->id;

		return null_;
	}

	VarType vbuffer_get_bounds(IntType id, MatrixType transform)
	{
		VertexBuffer* vbuf = FindVertexBuffer(id);
		if (!vbuf || !vbuf->valid || !vbuf->completed || !vbuf->numIndices)
			return null_;

		const Bounds& localBounds = (vbuf->bend.enabled && vbuf->bend.zeroPose) ? vbuf->bend.zeroPoseBounds : vbuf->bounds;
		if (localBounds.empty)
			return null_;

		// Project the cached local bounds into the requested space
		Bounds bounds;
		bounds.AddBounds(localBounds, transform.matrix);

		return ArrType::From({ bounds.minPoint, bounds.maxPoint });
	}

	VarType vbuffer_fit_bounds(IntType id, VecType blockPos)
	{
		if (VertexBuffer* vbuf = FindVertexBuffer(id))
		{
			// Fit only triangles recorded for the requested block position
			Bounds bounds = vbuf->FitBounds(blockPos);
			if (!bounds.empty)
				return ArrType::From({ bounds.minPoint, bounds.maxPoint });
		}

		return null_;
	}

	void vbuffer_update(IntType id)
	{
		if (VertexBuffer* vbuf = FindVertexBuffer(id))
			vbuf->UpdateBuffers();
	}

	void submit_batch()
	{
		GFX->SubmitBatch();
	}
}
