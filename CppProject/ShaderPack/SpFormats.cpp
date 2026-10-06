#include "SpFormats.hpp"

#include <qopengl.h>

// Enums that may be missing from older OpenGL headers
#ifndef GL_R8_SNORM
#define GL_R8_SNORM 0x8F94
#define GL_RG8_SNORM 0x8F95
#define GL_RGB8_SNORM 0x8F96
#define GL_RGBA8_SNORM 0x8F97
#define GL_R16_SNORM 0x8F98
#define GL_RG16_SNORM 0x8F99
#define GL_RGB16_SNORM 0x8F9A
#define GL_RGBA16_SNORM 0x8F9B
#endif
#ifndef GL_TEXTURE_RECTANGLE
#define GL_TEXTURE_RECTANGLE 0x84F5
#endif

namespace ShaderPacks
{
	namespace
	{
		struct FormatEntry
		{
			const char* name;
			unsigned int internal, format, type;
			bool integer;
		};

		const FormatEntry formats[] = {
			// Normalized
			{ "R8", GL_R8, GL_RED, GL_UNSIGNED_BYTE, false },
			{ "RG8", GL_RG8, GL_RG, GL_UNSIGNED_BYTE, false },
			{ "RGB8", GL_RGB8, GL_RGB, GL_UNSIGNED_BYTE, false },
			{ "RGBA8", GL_RGBA8, GL_RGBA, GL_UNSIGNED_BYTE, false },
			{ "R8_SNORM", GL_R8_SNORM, GL_RED, GL_BYTE, false },
			{ "RG8_SNORM", GL_RG8_SNORM, GL_RG, GL_BYTE, false },
			{ "RGB8_SNORM", GL_RGB8_SNORM, GL_RGB, GL_BYTE, false },
			{ "RGBA8_SNORM", GL_RGBA8_SNORM, GL_RGBA, GL_BYTE, false },
			{ "R16", GL_R16, GL_RED, GL_UNSIGNED_SHORT, false },
			{ "RG16", GL_RG16, GL_RG, GL_UNSIGNED_SHORT, false },
			{ "RGB16", GL_RGB16, GL_RGB, GL_UNSIGNED_SHORT, false },
			{ "RGBA16", GL_RGBA16, GL_RGBA, GL_UNSIGNED_SHORT, false },
			{ "R16_SNORM", GL_R16_SNORM, GL_RED, GL_SHORT, false },
			{ "RG16_SNORM", GL_RG16_SNORM, GL_RG, GL_SHORT, false },
			{ "RGB16_SNORM", GL_RGB16_SNORM, GL_RGB, GL_SHORT, false },
			{ "RGBA16_SNORM", GL_RGBA16_SNORM, GL_RGBA, GL_SHORT, false },
			{ "RGBA2", GL_RGBA2, GL_RGBA, GL_UNSIGNED_BYTE, false },
			{ "RGBA4", GL_RGBA4, GL_RGBA, GL_UNSIGNED_BYTE, false },
			{ "R3_G3_B2", GL_R3_G3_B2, GL_RGB, GL_UNSIGNED_BYTE, false },
			{ "RGB5_A1", GL_RGB5_A1, GL_RGBA, GL_UNSIGNED_BYTE, false },
			{ "RGB10_A2", GL_RGB10_A2, GL_RGBA, GL_UNSIGNED_INT_10_10_10_2, false },
			{ "RGB10_A2UI", GL_RGB10_A2UI, GL_RGBA_INTEGER, GL_UNSIGNED_INT_10_10_10_2, true },
			{ "SRGB8", GL_SRGB8, GL_RGB, GL_UNSIGNED_BYTE, false },
			{ "SRGB8_ALPHA8", GL_SRGB8_ALPHA8, GL_RGBA, GL_UNSIGNED_BYTE, false },
			// Floating point
			{ "R16F", GL_R16F, GL_RED, GL_HALF_FLOAT, false },
			{ "RG16F", GL_RG16F, GL_RG, GL_HALF_FLOAT, false },
			{ "RGB16F", GL_RGB16F, GL_RGB, GL_HALF_FLOAT, false },
			{ "RGBA16F", GL_RGBA16F, GL_RGBA, GL_HALF_FLOAT, false },
			{ "R32F", GL_R32F, GL_RED, GL_FLOAT, false },
			{ "RG32F", GL_RG32F, GL_RG, GL_FLOAT, false },
			{ "RGB32F", GL_RGB32F, GL_RGB, GL_FLOAT, false },
			{ "RGBA32F", GL_RGBA32F, GL_RGBA, GL_FLOAT, false },
			{ "R11F_G11F_B10F", GL_R11F_G11F_B10F, GL_RGB, GL_UNSIGNED_INT_10F_11F_11F_REV, false },
			{ "RGB9_E5", GL_RGB9_E5, GL_RGB, GL_UNSIGNED_INT_5_9_9_9_REV, false },
			// Integer
			{ "R8I", GL_R8I, GL_RED_INTEGER, GL_BYTE, true },
			{ "RG8I", GL_RG8I, GL_RG_INTEGER, GL_BYTE, true },
			{ "RGB8I", GL_RGB8I, GL_RGB_INTEGER, GL_BYTE, true },
			{ "RGBA8I", GL_RGBA8I, GL_RGBA_INTEGER, GL_BYTE, true },
			{ "R8UI", GL_R8UI, GL_RED_INTEGER, GL_UNSIGNED_BYTE, true },
			{ "RG8UI", GL_RG8UI, GL_RG_INTEGER, GL_UNSIGNED_BYTE, true },
			{ "RGB8UI", GL_RGB8UI, GL_RGB_INTEGER, GL_UNSIGNED_BYTE, true },
			{ "RGBA8UI", GL_RGBA8UI, GL_RGBA_INTEGER, GL_UNSIGNED_BYTE, true },
			{ "R16I", GL_R16I, GL_RED_INTEGER, GL_SHORT, true },
			{ "RG16I", GL_RG16I, GL_RG_INTEGER, GL_SHORT, true },
			{ "RGB16I", GL_RGB16I, GL_RGB_INTEGER, GL_SHORT, true },
			{ "RGBA16I", GL_RGBA16I, GL_RGBA_INTEGER, GL_SHORT, true },
			{ "R16UI", GL_R16UI, GL_RED_INTEGER, GL_UNSIGNED_SHORT, true },
			{ "RG16UI", GL_RG16UI, GL_RG_INTEGER, GL_UNSIGNED_SHORT, true },
			{ "RGB16UI", GL_RGB16UI, GL_RGB_INTEGER, GL_UNSIGNED_SHORT, true },
			{ "RGBA16UI", GL_RGBA16UI, GL_RGBA_INTEGER, GL_UNSIGNED_SHORT, true },
			{ "R32I", GL_R32I, GL_RED_INTEGER, GL_INT, true },
			{ "RG32I", GL_RG32I, GL_RG_INTEGER, GL_INT, true },
			{ "RGB32I", GL_RGB32I, GL_RGB_INTEGER, GL_INT, true },
			{ "RGBA32I", GL_RGBA32I, GL_RGBA_INTEGER, GL_INT, true },
			{ "R32UI", GL_R32UI, GL_RED_INTEGER, GL_UNSIGNED_INT, true },
			{ "RG32UI", GL_RG32UI, GL_RG_INTEGER, GL_UNSIGNED_INT, true },
			{ "RGB32UI", GL_RGB32UI, GL_RGB_INTEGER, GL_UNSIGNED_INT, true },
			{ "RGBA32UI", GL_RGBA32UI, GL_RGBA_INTEGER, GL_UNSIGNED_INT, true },
		};

		struct NameValue
		{
			const char* name;
			unsigned int value;
		};
	}

	InternalFormatInfo ParseInternalFormat(const QString& name, bool* ok)
	{
		QString n = name.trimmed().toUpper();
		if (n.startsWith("GL_"))
			n = n.mid(3);

		for (const FormatEntry& f : formats)
		{
			if (n == QLatin1String(f.name))
			{
				if (ok)
					*ok = true;
				InternalFormatInfo info;
				info.internalFormat = f.internal;
				info.pixelFormat = f.format;
				info.pixelType = f.type;
				info.isInteger = f.integer;
				return info;
			}
		}

		if (ok)
			*ok = false;
		InternalFormatInfo info;
		info.internalFormat = GL_RGBA8;
		info.pixelFormat = GL_RGBA;
		info.pixelType = GL_UNSIGNED_BYTE;
		return info;
	}

	unsigned int ParsePixelFormat(const QString& name)
	{
		static const NameValue values[] = {
			{ "RED", GL_RED }, { "RG", GL_RG }, { "RGB", GL_RGB }, { "BGR", GL_BGR }, { "RGBA", GL_RGBA }, { "BGRA", GL_BGRA },
			{ "RED_INTEGER", GL_RED_INTEGER }, { "RG_INTEGER", GL_RG_INTEGER }, { "RGB_INTEGER", GL_RGB_INTEGER },
			{ "BGR_INTEGER", GL_BGR_INTEGER }, { "RGBA_INTEGER", GL_RGBA_INTEGER }, { "BGRA_INTEGER", GL_BGRA_INTEGER },
		};
		QString n = name.trimmed().toUpper();
		if (n.startsWith("GL_"))
			n = n.mid(3);
		for (const NameValue& v : values)
			if (n == QLatin1String(v.name))
				return v.value;
		return 0;
	}

	unsigned int ParsePixelType(const QString& name)
	{
		static const NameValue values[] = {
			{ "BYTE", GL_BYTE }, { "SHORT", GL_SHORT }, { "INT", GL_INT }, { "HALF_FLOAT", GL_HALF_FLOAT }, { "FLOAT", GL_FLOAT },
			{ "UNSIGNED_BYTE", GL_UNSIGNED_BYTE }, { "UNSIGNED_BYTE_3_3_2", GL_UNSIGNED_BYTE_3_3_2 },
			{ "UNSIGNED_BYTE_2_3_3_REV", GL_UNSIGNED_BYTE_2_3_3_REV }, { "UNSIGNED_SHORT", GL_UNSIGNED_SHORT },
			{ "UNSIGNED_SHORT_5_6_5", GL_UNSIGNED_SHORT_5_6_5 }, { "UNSIGNED_SHORT_5_6_5_REV", GL_UNSIGNED_SHORT_5_6_5_REV },
			{ "UNSIGNED_SHORT_4_4_4_4", GL_UNSIGNED_SHORT_4_4_4_4 }, { "UNSIGNED_SHORT_4_4_4_4_REV", GL_UNSIGNED_SHORT_4_4_4_4_REV },
			{ "UNSIGNED_SHORT_5_5_5_1", GL_UNSIGNED_SHORT_5_5_5_1 }, { "UNSIGNED_SHORT_1_5_5_5_REV", GL_UNSIGNED_SHORT_1_5_5_5_REV },
			{ "UNSIGNED_INT", GL_UNSIGNED_INT }, { "UNSIGNED_INT_8_8_8_8", GL_UNSIGNED_INT_8_8_8_8 },
			{ "UNSIGNED_INT_8_8_8_8_REV", GL_UNSIGNED_INT_8_8_8_8_REV }, { "UNSIGNED_INT_10_10_10_2", GL_UNSIGNED_INT_10_10_10_2 },
			{ "UNSIGNED_INT_2_10_10_10_REV", GL_UNSIGNED_INT_2_10_10_10_REV },
		};
		QString n = name.trimmed().toUpper();
		if (n.startsWith("GL_"))
			n = n.mid(3);
		for (const NameValue& v : values)
			if (n == QLatin1String(v.name))
				return v.value;
		return 0;
	}

	unsigned int ParseTextureTarget(const QString& name)
	{
		static const NameValue values[] = {
			{ "TEXTURE_1D", GL_TEXTURE_1D }, { "TEXTURE_2D", GL_TEXTURE_2D }, { "TEXTURE_3D", GL_TEXTURE_3D },
			{ "TEXTURE_RECTANGLE", GL_TEXTURE_RECTANGLE },
		};
		QString n = name.trimmed().toUpper();
		if (n.startsWith("GL_"))
			n = n.mid(3);
		for (const NameValue& v : values)
			if (n == QLatin1String(v.name))
				return v.value;
		return 0;
	}

	int ParseBlendFactor(const QString& name)
	{
		static const NameValue values[] = {
			{ "ZERO", GL_ZERO }, { "ONE", GL_ONE }, { "SRC_COLOR", GL_SRC_COLOR }, { "ONE_MINUS_SRC_COLOR", GL_ONE_MINUS_SRC_COLOR },
			{ "DST_COLOR", GL_DST_COLOR }, { "ONE_MINUS_DST_COLOR", GL_ONE_MINUS_DST_COLOR }, { "SRC_ALPHA", GL_SRC_ALPHA },
			{ "ONE_MINUS_SRC_ALPHA", GL_ONE_MINUS_SRC_ALPHA }, { "DST_ALPHA", GL_DST_ALPHA }, { "ONE_MINUS_DST_ALPHA", GL_ONE_MINUS_DST_ALPHA },
			{ "SRC_ALPHA_SATURATE", GL_SRC_ALPHA_SATURATE },
		};
		QString n = name.trimmed().toUpper();
		if (n.startsWith("GL_"))
			n = n.mid(3);
		for (const NameValue& v : values)
			if (n == QLatin1String(v.name))
				return (int)v.value;
		return -1;
	}

	unsigned int ParseCompareFunc(const QString& name)
	{
		static const NameValue values[] = {
			{ "NEVER", GL_NEVER }, { "LESS", GL_LESS }, { "EQUAL", GL_EQUAL }, { "LEQUAL", GL_LEQUAL }, { "GREATER", GL_GREATER },
			{ "NOTEQUAL", GL_NOTEQUAL }, { "GEQUAL", GL_GEQUAL }, { "ALWAYS", GL_ALWAYS },
		};
		QString n = name.trimmed().toUpper();
		if (n.startsWith("GL_"))
			n = n.mid(3);
		for (const NameValue& v : values)
			if (n == QLatin1String(v.name))
				return v.value;
		return 0;
	}

	QString ImageFormatQualifier(unsigned int internalFormat)
	{
		for (const FormatEntry& f : formats)
			if (f.internal == internalFormat)
				return QString(f.name).toLower();
		return "rgba8";
	}
}
