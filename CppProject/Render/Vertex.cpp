#include "Vertex.hpp"

#include "AppHandler.hpp"
#include "Asset/Shader.hpp"
#include "GraphicsApiHandler.hpp"
#include "Type/VecType.hpp"

namespace CppProject
{
	PrimitiveVertex::PrimitiveVertex(QPointF pos, QPointF uv, IntType color, RealType alpha)
	{
		x = pos.x(), y = pos.y(), depth = 0.0;
		u = uv.x(), v = uv.y();

		if (color > -1)
			SetColor(GFX->IntToQColor(color, alpha));
		else
		{
			r = g = b = 1.0;
			a = alpha;
		}
	}

	void PrimitiveVertex::SetColor(QColor color)
	{
		r = color.redF();
		g = color.greenF();
		b = color.blueF();
		a = color.alphaF();
	}

	void PrimitiveVertex::Apply(QTransform transform, float depth, UvRect uvRect)
	{
		if (!transform.isIdentity())
		{
			QPointF pntT = QPointF(x, y) * transform;
			x = pntT.x();
			y = pntT.y();
		}

		this->depth = depth;

		u = uvRect.x + u * uvRect.w;
		v = uvRect.y + v * uvRect.h;
	}

	void PrimitiveVertex::SetAttributes()
	{
		if (IS_OPENGL)
		{
			QOpenGLShaderProgram* prog = GFX->shader->program;

			IntType aPosition = GFX->shader->attributeLocation[0];
			IntType aColor = GFX->shader->attributeLocation[1];
			IntType aUv = GFX->shader->attributeLocation[2];

			if (aPosition > -1)
				prog->enableAttributeArray(aPosition);

			if (aColor > -1)
				prog->enableAttributeArray(aColor);

			if (aUv > -1)
				prog->enableAttributeArray(aUv);
			
			GL_CHECK_ERROR();

			IntType offset = 0;
			if (aPosition > -1)
				prog->setAttributeBuffer(aPosition, GL_FLOAT, offset, 3, sizeof(PrimitiveVertex));
			offset += 3 * sizeof(float);

			if (aColor > -1)
				prog->setAttributeBuffer(aColor, GL_FLOAT, offset, 4, sizeof(PrimitiveVertex));
			offset += 4 * sizeof(float);

			if (aUv > -1)
				prog->setAttributeBuffer(aUv, GL_FLOAT, offset, 2, sizeof(PrimitiveVertex));

			GL_CHECK_ERROR();
		}
	}

	Vertex::Vertex(RealType x, RealType y, RealType z, RealType u, RealType v,
				   RealType nx, RealType ny, RealType nz, uint8_t colorIndex,
				   BoolType waveXY, BoolType waveZ, BoolType subsurface, RealType emissive) :
		Vertex(x, y, z, u, v, PackNormal(nx, ny, nz), colorIndex, waveXY, waveZ, subsurface, emissive)
	{
	}

	Vertex::Vertex(RealType x, RealType y, RealType z, RealType u, RealType v,
				   uint32_t packedNormal, uint8_t colorIndex,
				   BoolType waveXY, BoolType waveZ, BoolType subsurface, RealType emissive) :
		x(x), y(y), z(z), u(u), v(v), data1(packedNormal)
	{
		SetColorIndex(colorIndex);

		if (waveXY)
			EnableFlag(WAVE_XY);
		
		if (waveZ)
			EnableFlag(WAVE_Z);
		
		if (subsurface)
			EnableFlag(SUBSURFACE);

		SetEmissive(emissive);
		SetTangent(0, 0, 0);
	}

	bool Vertex::operator==(const Vertex& o) const
	{
		return (
			x == o.x && y == o.y && z == o.z &&
			u == o.u && v == o.v && data1 == o.data1
		);
	}

	void Vertex::SetNormal(RealType nx, RealType ny, RealType nz)
	{
		data1 = (data1 & 0xFF000000u) | PackNormal(nx, ny, nz);
	}

	uint32_t Vertex::PackNormal(RealType nx, RealType ny, RealType nz)
	{
		// Pack normal xyz as 0-255 in integer
		VecType normalized = VecType(nx, ny, nz).GetNormalized();
		uint8_t x8 = ((normalized.x + 1.0) / 2.0) * 255;
		uint8_t y8 = ((normalized.y + 1.0) / 2.0) * 255;
		uint8_t z8 = ((normalized.z + 1.0) / 2.0) * 255;
		
		return (z8 << 16) | (y8 << 8) | x8;
	}

	void Vertex::SetColorIndex(uint8_t index)
	{
		data1 = (data1 & 0x00FFFFFFu) | (uint32_t(index) << 24);
	}

	void Vertex::EnableFlag(Vertex::Flag flag)
	{
		// Enable bit of flag in first byte
		data2 |= 1 << ((IntType)flag);
	}

	void Vertex::SetEmissive(RealType emissive)
	{
		// Pack brightness from 0-255 in second byte
		data2 |= (IntType)(emissive * 255) << 8;
	}

	void Vertex::SetObjectIndex(IntType index)
	{
		// Pack 16 bit index in 3rd and 4th byte
		data2 |= index << 16;
	}

	void Vertex::SetTangent(RealType tx, RealType ty, RealType tz)
	{
		// Pack tangent xyz as 0-255 in integer
		uint8_t x8 = ((tx + 1.0) / 2.0) * 255;
		uint8_t y8 = ((ty + 1.0) / 2.0) * 255;
		uint8_t z8 = ((tz + 1.0) / 2.0) * 255;

		tangent = (z8 << 16) | (y8 << 8) | x8;
	}

	void Vertex::SetAttributes()
	{
		if (IS_OPENGL)
		{
			IntType aPosition = GFX->shader->attributeLocation[0];
			IntType aUv = GFX->shader->attributeLocation[1];
			IntType aData1 = GFX->shader->attributeLocation[2];
			IntType aData2 = GFX->shader->attributeLocation[3];
			IntType aTangent = GFX->shader->attributeLocation[4];

			if (aPosition > -1)
				GFX->glEnableVertexAttribArray(aPosition);

			if (aUv > -1)
				GFX->glEnableVertexAttribArray(aUv);

			if (aData1 > -1)
				GFX->glEnableVertexAttribArray(aData1);

			if (aData2 > -1)
				GFX->glEnableVertexAttribArray(aData2);

			if (aTangent > -1)
				GFX->glEnableVertexAttribArray(aTangent);
			
			GL_CHECK_ERROR();

			IntType offset = 0;
			if (aPosition > -1)
				GFX->glVertexAttribPointer(aPosition, 3, GL_FLOAT, false, sizeof(Vertex), (void*)offset);
			offset += 3 * sizeof(float);

			if (aUv > -1)
				GFX->glVertexAttribPointer(aUv, 2, GL_FLOAT, false, sizeof(Vertex), (void*)offset);
			offset += 2 * sizeof(float);

			if (aData1 > -1)
				GFX->glVertexAttribIPointer(aData1, 1, GL_UNSIGNED_INT, sizeof(Vertex), (void*)offset);
			offset += sizeof(uint32_t);

			if (aData2 > -1)
				GFX->glVertexAttribIPointer(aData2, 1, GL_UNSIGNED_INT, sizeof(Vertex), (void*)offset);
			offset += sizeof(uint32_t);

			if (aTangent > -1)
				GFX->glVertexAttribIPointer(aTangent, 1, GL_UNSIGNED_INT, sizeof(Vertex), (void*)offset);

			GL_CHECK_ERROR();
		}
	}
}
