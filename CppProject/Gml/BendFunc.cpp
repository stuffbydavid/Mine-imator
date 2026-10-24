#include "Generated/GmlFunc.hpp"
#include "Asset/VertexBuffer.hpp"

#include <cmath>

namespace CppProject
{
	void vertex_bend_configure(IntType id, VecType pivot, VecType minimum, VecType maximum, VecType direction, RealType kind, RealType sharpAxis, IntType zeroBuffer)
	{
		if (VertexBuffer* buffer = FindVertexBuffer(id))
		{
			buffer->bend.enabled = true;
			buffer->bend.zeroBuffer = zeroBuffer;
			buffer->bend.pivot = pivot;
			buffer->bend.minimum = minimum;
			buffer->bend.maximum = maximum;
			buffer->bend.direction = direction;
			buffer->bend.kind = kind;
			buffer->bend.sharpAxis = sharpAxis;
		}
	}

	void vertex_bend_update(IntType id, VecType angle)
	{
		if (VertexBuffer* buffer = FindVertexBuffer(id))
		{
			for (int i = 0; i < 3; i++)
				angle.Real(i) = std::max(buffer->bend.minimum.Real(i), std::min(buffer->bend.maximum.Real(i), angle.Real(i)));
			buffer->bend.angle = angle;
			// Match the CPU generator's vec3_equals test after clamping
			buffer->bend.zeroPose = std::abs(angle.x) < 0.0001 && std::abs(angle.y) < 0.0001 && std::abs(angle.z) < 0.0001;
		}
	}

	void vertex_bend_quad(IntType id, VecType a, VecType b, VecType c, VecType d)
	{
		if (VertexBuffer* buffer = FindVertexBuffer(id))
		{
			buffer->bend.hasQuad = true;
			buffer->bend.quad[0] = a;
			buffer->bend.quad[1] = b;
			buffer->bend.quad[2] = c;
			buffer->bend.quad[3] = d;
		}
	}

	static VecType Position(const VecType& p)
	{
		return { p.x, p.y, p.z };
	}
	static void CopyPoint(float* dst, const VecType& p)
	{
		dst[0] = p.x;
		dst[1] = p.y;
		dst[2] = p.z;
		dst[3] = p.w;
	}
	static bool SamePoint(const VecType& a, const VecType& b)
	{
		return a.x == b.x && a.y == b.y && a.z == b.z && a.w == b.w;
	}

	void vertex_bend_triangle(IntType id, VecType p1, VecType p2, VecType p3, VecType uv1, VecType uv2, VecType uv3,
		VarType normal1, VarType normal2, VarType normal3, BoolType invert, RealType color, RealType alpha,
		RealType emissive, RealType wave, RealType zmin, RealType zmax, RealType subsurface)
	{
		VertexBuffer* buffer = FindVertexBuffer(id);
		if (!buffer || !buffer->bend.enabled)
			return;

		VecType points[3] = { p1, p2, p3 };
		VecType uvs[3] = { uv1, uv2, uv3 };
		bool flat = !normal1.IsContainer();
		VecType faceNormal = VecType::CrossProduct(Position(p2) - Position(p1), Position(p3) - Position(p1));
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
		BendVertex bends[3];
		RealType normalWeights[3] = { p1.w, p2.w, p3.w };
		for (int i = 0; i < 3; i++)
		{
			int j = (i + 1) % 3;
			int k = (i + 2) % 3;
			VecType p = Position(points[i]);
			vertices[i] = Vertex(p.x, p.y, p.z, normals[i].x, normals[i].y, normals[i].z,
				(IntType)color, alpha, uvs[i].x, uvs[i].y, wave == 2, wave != 0, emissive, subsurface != 0);
			BendVertex& bend = bends[i];
			bend.data[0] = points[i].w;
			bend.data[1] = flat ? 1 : 0;
			CopyPoint(bend.c, VecType(normals[i].x, normals[i].y, normals[i].z, normalWeights[i]));
			CopyPoint(bend.a, points[j]);
			CopyPoint(bend.b, points[k]);
			RealType du1 = uvs[j].x - uvs[i].x, dv1 = uvs[j].y - uvs[i].y;
			RealType du2 = uvs[k].x - uvs[i].x, dv2 = uvs[k].y - uvs[i].y;
			RealType determinant = du1 * dv2 - dv1 * du2;
			if (std::abs(determinant) > 1e-20)
			{
				bend.data[2] = dv2 / determinant;
				bend.data[3] = -dv1 / determinant;
			}

			// Offset planes average the two triangle area normals of each quad
			if (!flat && buffer->bend.hasQuad)
			{
				int qi = -1, qj = -1, qk = -1;
				for (int q = 0; q < 4; q++)
				{
					if (SamePoint(points[i], buffer->bend.quad[q]))
						qi = q;
					if (SamePoint(points[j], buffer->bend.quad[q]))
						qj = q;
					if (SamePoint(points[k], buffer->bend.quad[q]))
						qk = q;
				}
				if (qi >= 0 && qj >= 0 && qk >= 0 && qi != qj && qi != qk && qj != qk)
				{
					int qc = 6 - qi - qj - qk;
					VecType c = buffer->bend.quad[qc];
					CopyPoint(bend.c, c);
					int direction = (qj - qi + 4) % 4 == 1 || (qk - qj + 4) % 4 == 1 ? 1 : -1;
					int dA = (direction * (qj - qi) + 4) % 4;
					int dC = (direction * (qc - qi) + 4) % 4;
					int mode = dC < dA ? 2 : (dC == 2 ? 3 : 4);
					VecType a = Position(points[j]) - p, b = Position(points[k]) - p, cEdge = Position(c) - p;
					VecType area = mode == 2 ? VecType::CrossProduct(cEdge, a) + VecType::CrossProduct(a, b) :
						(mode == 3 ? VecType::CrossProduct(a, cEdge) + VecType::CrossProduct(cEdge, b) :
						VecType::CrossProduct(a, b) + VecType::CrossProduct(b, cEdge));
					bend.data[1] = normals[i].w != 0 ? mode * direction * normals[i].w :
						(VecType::DotProduct(area, normals[i]) < 0 ? -mode : mode);
				}
			}
		}
		buffer->bend.wind = VecType(wave, zmin, zmax);
		buffer->AddBendTriangle(vertices, bends);
	}
}
