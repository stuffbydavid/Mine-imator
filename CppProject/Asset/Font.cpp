#include "Font.hpp"

#include "AppHandler.hpp"
#include "Generated/GmlFunc.hpp"
#include "Render/PrimitiveRenderer.hpp"
#include "Render/TexturePage.hpp"
#include "Render/Texture.hpp"

#include <ft2build.h>
#include FT_FREETYPE_H  

namespace CppProject
{
	QVector<Font*> Font::fonts;
	BoolType Font::fontAA = true;

	Font::Font(StringType filename, IntType size, BoolType bold, BoolType italic, IntType first, IntType last) : Asset(ID_Font)
	{
		fonts.append(this);

		try
		{
			QFile file(filename);
			if (!file.open(QFile::ReadOnly))
				throw "Could not open font " + filename.QStr() + ": " + file.errorString();

			// Load font
			FT_Library ft;
			FT_Face face;
			FT_Error err = FT_Init_FreeType(&ft);
			if (err != 0)
				throw "FT_Init_FreeType error: " + NumStr(err);

			QByteArray data = file.readAll();
			err = FT_New_Memory_Face(ft, (FT_Byte*)data.constData(), data.size(), 0, &face);
			if (err != 0) 
				throw "FT_New_Memory_Face error: " + NumStr(err);

			err = FT_Set_Char_Size(face, 0, size << 6, 96, 96);
			if (err != 0)
				throw "FT_Set_Char_Size error: " + NumStr(err);

			const FT_Size_Metrics& metrics = face->size->metrics;
			RealType scale = metrics.y_scale / 65536.0;
			height = ceil((face->height / 64) * scale);
			descent = ceil((face->descender / 64) * scale);

			// Get number of characters
			IntType numChars = 0;
			FT_UInt charIndex;
			FT_ULong charCode = FT_Get_First_Char(face, &charIndex);
			while (charIndex)
			{
				charCode = FT_Get_Next_Char(face, charCode, &charIndex);
				numChars++;
			}

			// Get atlas dimensions
			IntType atlasSize = height * ceilf(sqrtf(numChars));

			// Render glyphs to atlas
			uchar* pixels = new uchar[atlasSize * atlasSize];
			memset(pixels, 0, atlasSize * atlasSize);
			IntType penX = 0, penY = 0;

			charCode = FT_Get_First_Char(face, &charIndex);
			while (charIndex)
			{
				err = FT_Load_Char(face, charCode, FT_LOAD_RENDER | (fontAA ? FT_LOAD_TARGET_LIGHT : FT_LOAD_MONOCHROME));
				if (err == 0)
				{
					FT_Bitmap* bmp = &face->glyph->bitmap;

					if (penX + (IntType)bmp->width >= atlasSize)
					{
						penX = 0;
						penY += height;
					}

					for (IntType by = 0; by < (IntType)bmp->rows; by++)
					{
						for (IntType bx = 0; bx < (IntType)bmp->width; bx++)
						{
							IntType x = penX + bx;
							IntType y = penY + by;
							if (bmp->pixel_mode == FT_PIXEL_MODE_MONO) // 1 bit per pixel
							{
								IntType index = by * bmp->pitch + bx / 8;
								IntType bufferBit = 7 - (bx % 8); // MSB order
								pixels[y * atlasSize + x] = ((bmp->buffer[index] >> bufferBit) & 1) * 255;
							}
							else // Grayscale
								pixels[y * atlasSize + x] = bmp->buffer[by * bmp->pitch + bx];
						}
					}

					glyphMap[charCode] = {
						(float)penX,
						(float)penY,
						(float)(penX + bmp->width),
						(float)(penY + bmp->rows),
						{ face->glyph->bitmap_left, face->glyph->bitmap_top },
						{ (int)bmp->width, (int)bmp->rows },
						face->glyph->advance.x / 64
					};

					penX += bmp->width + 1;
				}

				charCode = FT_Get_Next_Char(face, charCode, &charIndex);
			}
			penY += height;

			// Convert UVs
			for (IntType code : glyphMap.keys())
			{
				Glyph& glyph = glyphMap[code];
				glyph.u0 /= atlasSize;
				glyph.v0 /= penY;
				glyph.u1 /= atlasSize;
				glyph.v1 /= penY;
			}

			uchar* atlasData = new uchar[atlasSize * penY * 4];
			IntType index = 0;
			for (IntType y = 0; y < penY; y++)
			{
				for (IntType x = 0; x < atlasSize; x++)
				{
					atlasData[index * 4 + 0] = 255;
					atlasData[index * 4 + 1] = 255;
					atlasData[index * 4 + 2] = 255;
					atlasData[index * 4 + 3] = pixels[y * atlasSize + x];
					index++;
				}
			}
			QImage atlasImg(atlasData, atlasSize, penY, QImage::Format_RGBA8888);
			pageLoc = TexturePage::Add(atlasImg);
			if (!pageLoc) // Too big for texture page
				texture = new Texture(atlasImg);
			delete[] pixels;
			delete[] atlasData;

			err = FT_Done_FreeType(ft);
			if (err != 0)
				throw "FT_Done_FreeType error: " + NumStr(err);
		}
		catch (const QString& err)
		{
			WARNING(err);
		}
	}

	Font::~Font()
	{
		fonts.removeOne(this);
		deleteAndReset(pageLoc);
		deleteAndReset(texture);
	}

	IntType Font::GetCharacterWidth(IntType ch)
	{
		return glyphMap.value(ch).advance;
	}

	IntType Font::GetTextWidth(StringType text)
	{
		if (text == "")
			return 0;
		if (text.GetLength() == 1)
			return GetCharacterWidth(text.At(0).unicode());

		IntType width = stringDataMap[text].width;
		if (width < 0) // Calculate
		{
			width = 0;
			if (text.Contains("\n")) // Multi-line
			{
				QStringList lines = text.Split('\n');
				for (const QString& line : lines)
					width = std::max(width, GetTextWidth(line));
			}
			else // Single-line
				for (const QChar& ch : (QString)text)
					width += GetCharacterWidth(ch.unicode());

			// Cache size
			stringDataMap[text].width = width;
		}

		stringDataMap[text].isUsed = true;
		return width;
	}

	IntType Font::GetTextHeight(StringType text)
	{
		if (text == "")
			return 0;
		return height + height * text.Count("\n");
	}

	StringType Font::GetWrappedText(StringType text, IntType maxWidth)
	{
		if (maxWidth <= 0) // No wrapping
			return text;

		IntType dx, width;
		QStringList lines = text.Split('\n');
		StringType wrapped = "";
		IntType spaceWidth = GetCharacterWidth(' ');

		dx = width = 0;
		for (const QString& line : lines)
		{
			if (wrapped != "")
				wrapped += "\n";

			dx = 0;
			QStringList words = line.split(' ');
			for (const QString& word : words)
			{
				if (dx > 0)
				{
					wrapped += " ";
					dx += spaceWidth;
				}

				IntType wordWidth = GetTextWidth(word);
				if (dx > 0 && dx + wordWidth > maxWidth)
				{
					wrapped += "\n";
					dx = 0;
				}

				wrapped += word;
				dx += wordWidth;
				width = std::max(width, dx);
			}
		}

		return wrapped;
	}

	QPoint Font::GetTextOffset(StringType text, int halign, int valign, IntType lineSep)
	{
		QPoint offset = { 0, -1 };
		if (lineSep < 0)
			lineSep = height;

		// Align horizontally
		if (halign != fa_left)
		{
			IntType wid = GetTextWidth(text);
			if (halign == fa_center)
				offset.rx() -= wid / 2;
			else if (halign == fa_right)
				offset.rx() -= wid;
		}

		// Align vertically
		if (valign != fa_top)
		{
			IntType hei = height + text.Count("\n") * lineSep;
			if (valign == fa_middle)
				offset.ry() -= hei / 2;
			else if (valign == fa_bottom)
				offset.ry() -= hei;
		}

		return offset;
	}

	void Font::RenderText(StringType text, QTransform transform)
	{
		PR->Begin(pr_trianglelist, pageLoc ? pageLoc->id : texture->GetId(), transform);

		FastVector<PrimitiveVertex>& vertices = stringDataMap[text].vertices;
		FastVector<uint32_t>& indices = stringDataMap[text].indices;
		if (vertices.Size() == 0)
		{
			IntType textLength = text.GetLength();
			vertices.Alloc(textLength * 4);
			indices.Alloc(textLength * 6);

			IntType dx = 0;
			for (const QChar& ch : (QString)text)
			{
				const Glyph& glyph = glyphMap.value(ch.unicode());
				if (glyph.size.width() > 0)
				{
					// Create vertices for glyph
					IntType glyphStartIndex = vertices.Size();
					QPoint p1 = { (int)dx + glyph.offset.x(), (int)height + (int)descent - glyph.offset.y() };
					QPoint p2 = { p1.x() + glyph.size.width(), p1.y() + glyph.size.height() };
					vertices.Append({ { (float)p1.x(), (float)p1.y() }, { glyph.u0, glyph.v0 } });
					vertices.Append({ { (float)p2.x(), (float)p1.y() }, { glyph.u1, glyph.v0 } });
					vertices.Append({ { (float)p2.x(), (float)p2.y() }, { glyph.u1, glyph.v1 } });
					vertices.Append({ { (float)p1.x(), (float)p2.y() }, { glyph.u0, glyph.v1 } });

					// Define triangles
					indices.Append(glyphStartIndex + 0);
					indices.Append(glyphStartIndex + 1);
					indices.Append(glyphStartIndex + 2);
					indices.Append(glyphStartIndex + 2);
					indices.Append(glyphStartIndex + 3);
					indices.Append(glyphStartIndex + 0);
				}

				dx += glyph.advance;
			}
		}

		// Add indices
		for (IntType i = 0; i < indices.Size(); i++)
			PR->indices.Append(PR->vertices.Size() + indices.Value(i));
		PR->currentIndex += indices.Size();

		// Add vertices
		for (IntType v = 0; v < vertices.Size(); v++)
		{
			PrimitiveVertex vertexCopy = vertices.Value(v);
			vertexCopy.SetColor(PR->color);
			vertexCopy.Apply(transform, PR->depth, pageLoc ? pageLoc->uvRect : UvRect({ 0.0, 0.0, 1.0, 1.0 }));
			PR->vertices.Append(vertexCopy);
		}

		stringDataMap[text].isUsed = true;
	}

	void Font::CleanUnused()
	{
		for (Font* font : fonts)
		{
			QList<StringType> texts = font->stringDataMap.keys();
			for (const StringType& text : texts)
			{
				if (!font->stringDataMap[text].isUsed)
					font->stringDataMap.remove(text);
				else
					font->stringDataMap[text].isUsed = false;
			}
		}
	}
}
