#pragma once
#include "Asset.hpp"

#include "FastVector.hpp"
#include "Render/Vertex.hpp"

namespace CppProject
{
	struct TexturePageLocation;
	struct Texture;
	struct Sprite;

	// Font asset
	struct Font : Asset
	{
		Font() : Asset(ID_Font) {};
		Font(StringType filename, IntType size, BoolType bold, BoolType italic, IntType first, IntType last);
		~Font();

		// Returns the width of a single character when rendered.
		virtual IntType GetCharacterWidth(IntType ch);

		// Returns the width of the given multi-line text when rendered.
		virtual IntType GetTextWidth(StringType text);

		// Returns the height of the given multi-line text when rendered.
		virtual IntType GetTextHeight(StringType text);

		// Returns the offset when rendering a given multi-line text string using an alignment setting.
		QPoint GetTextOffset(StringType text, int halign = 0, int valign = 0, IntType lineSep = -1);

		// Returns a new word-wrapped text that fits within the given width.
		StringType GetWrappedText(StringType text, IntType maxWidth);

		// Generates the triangle primitives to render a given single-line text.
		virtual void RenderText(StringType text, QTransform transform);

		// Cleans up unused string data.
		static void CleanUnused();

		struct Glyph
		{
			RealType u0, v0, u1, v1;
			QPoint offset = { 0, 0 };
			QSize size = { 0, 0 };
			IntType advance = 0;
		};

		struct StringData
		{
			FastVector<PrimitiveVertex> vertices;
			FastVector<uint32_t> indices;
			IntType width = -1;
			bool isUsed = false;
		};

		QHash<IntType, Glyph> glyphMap;
		IntType height = 0, descent = 0;
		QHash<StringType, StringData> stringDataMap;
		TexturePageLocation* pageLoc = nullptr;
		Texture* texture = nullptr;
		BoolType aa = false;

		static BoolType fontAA;
		static QVector<Font*> fonts;
	};

	// Sprite font asset
	struct SpriteFont : Font
	{
		SpriteFont(Sprite* spr, StringType chars, IntType sep);
		Sprite* spr = nullptr;
	};
}