#include "Generated/Scripts.hpp"
#include "Asset/VertexBuffer.hpp"

#include <cmath>

namespace CppProject
{
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
}
