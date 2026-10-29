#pragma once

#include "Common.hpp"

// Shader code for unpacking the vertex buffer data
#define UNPACK_VERTEX_NORMAL(attr) "vec3(" \
			"float(" attr " & uint(255)), " \
			"float((" attr " >> uint(8)) & uint(255)), " \
			"float((" attr " >> uint(16)) & uint(255))) / 127.0 - vec3(1.0)"
#define UNPACK_VERTEX_CUSTOM(attr, data1) "vec4(" \
			"float(" attr " & uint(1)), " \
			"float((" attr " & uint(2)) >> uint(1)), " \
			"float((" attr " >> uint(8)) & uint(255)) / 255.0, " \
			"float((" attr " & uint(4)) >> uint(2)) + float(" data1 " >> uint(24)) * 2.0)"

namespace CppProject
{
	// Two shared weights preserve float precision while removing two redundant floats
	struct CompactBendVertex
	{
		float data[4], a[4], b[4], c[2];
	};
	static_assert(sizeof(CompactBendVertex) == 56, "Compact bend vertex layout must occupy 56 bytes");

	struct BendVertex
	{
		float data[4] = {}; // Weight, normal mode, two UV tangent coefficients
		float a[4] = {}, b[4] = {}, c[4] = {}; // Other triangle/quad points and their weights

		bool Compact(CompactBendVertex& dst) const
		{
			if (!(data[1] >= -4 && data[1] <= 4) || data[1] != (int)data[1])
				return false;
			float secondWeight = data[0];
			const float weights[3] = { a[3], b[3], c[3] };
			int selectors = 0;
			for (int i = 0; i < 3; i++)
			{
				if (weights[i] == data[0])
					continue;
				if (secondWeight == data[0])
					secondWeight = weights[i];
				else if (weights[i] != secondWeight)
					return false;
				selectors |= 1 << i;
			}
			std::copy(data, data + 4, dst.data);
			std::copy(a, a + 3, dst.a);
			std::copy(b, b + 3, dst.b);
			// The tag identifies this layout without a new per-object uniform
			dst.data[1] = 256 + (data[1] + 4) + selectors * 16;
			dst.a[3] = secondWeight;
			dst.b[3] = c[0];
			dst.c[0] = c[1];
			dst.c[1] = c[2];
			return true;
		}
	};
	static_assert(sizeof(BendVertex) == 64, "Bend vertex attributes must occupy four vec4 slots");

	// A vertex in a primitive 2D shape.
	struct PrimitiveVertex
	{
		PrimitiveVertex(QPointF pos, QPointF uv, IntType color = -1, RealType alpha = 1.0);

		// Overrides the color of the vertex.
		void SetColor(QColor color);

		// Apply a transform to the vertex position and UVs.
		void Apply(QTransform transform, float depth, UvRect uvRect);

		// Set shader attributes.
		static void SetAttributes();

		float x, y, depth;
		float r, g, b, a;
		float u, v;
	};

	// A vertex stored in a 3D vertex buffer.
	struct Vertex
	{
		Vertex() {}
		Vertex(RealType x, RealType y, RealType z, RealType u, RealType v,
			   RealType nx, RealType ny, RealType nz, uint8_t colorIndex,
			   BoolType waveXY, BoolType waveZ, BoolType subsurface, RealType emissive);
		Vertex(RealType x, RealType y, RealType z, RealType u, RealType v,
			   uint32_t packedNormal, uint8_t colorIndex,
			   BoolType waveXY, BoolType waveZ, BoolType subsurface, RealType emissive);

		// A flag in the first byte of the data2 int, up to 8 are allowed.
		enum Flag
		{
			WAVE_XY = 0,
			WAVE_Z = 1,
			SUBSURFACE = 2
		};

		// Compare with a previously added vertex for index buffer generation.
		bool operator==(const Vertex& o) const;

		// Sets the normal vector.
		void SetNormal(RealType nx, RealType ny, RealType nz);
		static uint32_t PackNormal(RealType nx, RealType ny, RealType nz);

		// Set the color index, with zero meaning no tint.
		void SetColorIndex(uint8_t index);

		// Enables a flag.
		void EnableFlag(Flag flag);

		// Set emissive value.
		void SetEmissive(RealType emissive);

		// Set the object index.
		void SetObjectIndex(IntType index);

		// Sets the tangent vector.
		void SetTangent(RealType tx, RealType ty, RealType tz);

		// Set shader attributes.
		static void SetAttributes();

		float x = 0, y = 0, z = 0, u = 0, v = 0;

		// data1: normal xyz and color index, data2: flags, emissive and object index
		uint32_t data1 = 0, data2 = 0, tangent = 0;
	};
}
