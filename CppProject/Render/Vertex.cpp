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
	#if API_OPENGL
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
	#endif
	}

	Vertex::Vertex(RealType x, RealType y, RealType z,
				   RealType nx, RealType ny, RealType nz,
				   IntType color, RealType alpha,
				   RealType u, RealType v,
				   BoolType waveXY, BoolType waveZ, RealType emissive, BoolType subsurface) :
		x(x), y(y), z(z), u(u), v(v)
	{
		SetNormal(nx, ny, nz);
		SetTangent(0, 0, 0);
		SetColor(color, alpha);

		if (waveXY)
			EnableFlag(WAVE_XY);
		if (waveZ)
			EnableFlag(WAVE_Z);
		SetEmissive(emissive);
		if (subsurface)
			EnableFlag(SUBSURFACE);
	}

	bool Vertex::operator==(const Vertex& o) const
	{
		return (
			x == o.x && y == o.y && z == o.z &&
			normal == o.normal && u == o.u && v == o.v &&
			block == o.block && light == o.light && midTex == o.midTex && midBlock == o.midBlock
		);
	}

	void Vertex::SetNormal(RealType nx, RealType ny, RealType nz)
	{
		// Pack normal xyz as 0-255 in integer
		VecType normalized = VecType(nx, ny, nz).GetNormalized();
		uint8_t x8 = ((normalized.x + 1.0) / 2.0) * 255;
		uint8_t y8 = ((normalized.y + 1.0) / 2.0) * 255;
		uint8_t z8 = ((normalized.z + 1.0) / 2.0) * 255;
		normal = (z8 << 16) | (y8 << 8) | x8;
	}

	void Vertex::SetTangent(RealType tx, RealType ty, RealType tz)
	{
		// Pack tangent xyz as 0-255 in integer
		uint8_t x8 = ((tx + 1.0) / 2.0) * 255;
		uint8_t y8 = ((ty + 1.0) / 2.0) * 255;
		uint8_t z8 = ((tz + 1.0) / 2.0) * 255;
		tangent = (z8 << 16) | (y8 << 8) | x8;
	}

	void Vertex::SetColor(IntType rgb, RealType alpha)
	{
		// Pack color rgb and alpha from 0-255 in integer
		color = rgb | ((uint8_t)(alpha * 255.0) << 24);
	}

	void Vertex::EnableFlag(Vertex::Flag flag)
	{
		// Enable bit of flag in first byte
		data |= 1 << ((IntType)flag);
	}

	void Vertex::SetEmissive(RealType emissive)
	{
		// Pack brightness from 0-255 in second byte
		data |= (IntType)(emissive * 255) << 8;
	}

	void Vertex::SetIndex(IntType index)
	{
		// Pack 16 bit index in 3rd and 4th byte
		data |= index << 16;
	}

	void Vertex::SetBlock(IntType blockId, IntType stateId)
	{
		block = ((uint32_t)blockId & 4095u) | ((uint32_t)stateId << 12);
	}

	void Vertex::SetLight(RealType blockLight, RealType skyLight, RealType ao)
	{
		uint32_t b = (uint32_t)qBound(0, (int)std::round(blockLight * 16.0), 240);
		uint32_t s = (uint32_t)qBound(0, (int)std::round(skyLight * 16.0), 240);
		uint32_t a = (uint32_t)qBound(0, (int)std::round(ao * 255.0), 255);
		light = (light & 0xFF000000u) | b | (s << 8) | (a << 16);
	}

	void Vertex::SetFluid(BoolType fluid)
	{
		light = fluid ? (light | (1u << 24)) : (light & ~(1u << 24));
	}

	void Vertex::SetMidTexCoord(RealType mu, RealType mv)
	{
		uint32_t u16 = (uint32_t)qBound(0, (int)std::round(mu * 65535.0), 65535);
		uint32_t v16 = (uint32_t)qBound(0, (int)std::round(mv * 65535.0), 65535);
		midTex = u16 | (v16 << 16);
	}

	void Vertex::SetMidBlock(RealType dx, RealType dy, RealType dz, IntType emission)
	{
		auto pack = [](RealType v) { return (uint32_t)(uint8_t)(int8_t)qBound(-127, (int)std::round(v), 127); };
		midBlock = pack(dx) | (pack(dy) << 8) | (pack(dz) << 16) | ((uint32_t)qBound(0, (int)emission, 15) << 24);
	}

	void Vertex::SetAttributes()
	{
	#if API_OPENGL
		IntType aPosition = GFX->shader->attributeLocation[0];
		IntType aNormal = GFX->shader->attributeLocation[1];
		IntType aColor = GFX->shader->attributeLocation[2];
		IntType aUv = GFX->shader->attributeLocation[3];
		IntType aData = GFX->shader->attributeLocation[4];
		IntType aTangent = GFX->shader->attributeLocation[5];

		if (aPosition > -1)
			GFX->glEnableVertexAttribArray(aPosition);
		if (aNormal > -1)
			GFX->glEnableVertexAttribArray(aNormal);
		if (aColor > -1)
			GFX->glEnableVertexAttribArray(aColor);
		if (aUv > -1)
			GFX->glEnableVertexAttribArray(aUv);
		if (aData > -1)
			GFX->glEnableVertexAttribArray(aData);
		if (aTangent > -1)
			GFX->glEnableVertexAttribArray(aTangent);
		GL_CHECK_ERROR();
		
		IntType offset = 0;
		if (aPosition > -1)
			GFX->glVertexAttribPointer(aPosition, 3, GL_FLOAT, false, sizeof(Vertex), (void*)offset);
		offset += 3 * sizeof(float);

		if (aNormal > -1)
			GFX->glVertexAttribIPointer(aNormal, 1, GL_UNSIGNED_INT, sizeof(Vertex), (void*)offset);
		offset += sizeof(uint32_t);

		if (aColor > -1)
			GFX->glVertexAttribIPointer(aColor, 1, GL_UNSIGNED_INT, sizeof(Vertex), (void*)offset);
		offset += sizeof(uint32_t);

		if (aUv > -1)
			GFX->glVertexAttribPointer(aUv, 2, GL_FLOAT, false, sizeof(Vertex), (void*)offset);
		offset += 2 * sizeof(float);

		if (aData > -1)
			GFX->glVertexAttribIPointer(aData, 1, GL_UNSIGNED_INT, sizeof(Vertex), (void*)offset);
		offset += sizeof(uint32_t);

		if (aTangent > -1)
			GFX->glVertexAttribIPointer(aTangent, 1, GL_UNSIGNED_INT, sizeof(Vertex), (void*)offset);

		GL_CHECK_ERROR();
	#endif
	}
}