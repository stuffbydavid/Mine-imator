#include "World.hpp"

#include "Render/GraphicsApiHandler.hpp"
#include "AppHandler.hpp"

#define DEBUG_BIOMES 0

namespace CppProject
{
	FastVector<BlockStyle*> BlockStyle::blockStyles;
	FastVector<PreviewState> BlockStyle::blockPreviewStates;
	QVector<QColor> BlockStyle::previewColors;
	QImage BlockStyle::previewImage;
	Texture* BlockStyle::previewTexture = nullptr;
	BlockStyle* BlockStyle::airStyle = nullptr;
	BlockStyle* BlockStyle::bedrockStyle = nullptr;

	BlockStyle::BlockStyle(uint16_t topPos, uint16_t sidePos, BoolType isTransparent, TintType tint, uint8_t light) :
		topPos(topPos), sidePos(sidePos), tint(tint)
	{
		index = blockStyles.Append(this);
		blockPreviewStates.Append({ index > 0, !isTransparent, false, light });
	}

	int16_t BlockStyle::Create(IntType colorTop, RealType alphaTop, IntType colorSide, RealType alphaSide, TintType tint, uint8_t light)
	{
		// No style
		if (colorTop < 0 && colorSide < 0)
			return 0;

		// Adds a new color to the block texture
		auto addBlockColor = [&](IntType colorInt, RealType alpha, BoolType checkExist = true)
		{
			if (colorInt < 0)
				return (uint16_t)0;

			QColor color = GFX->IntToQColor(colorInt, alpha);
			if (checkExist)
				for (IntType i = previewColors.size() - 1; i >= 0; i--)
					if (previewColors[i] == color) // Already added
						return (uint16_t)i;

			uint16_t nextPos = previewColors.size();
			previewImage.setPixelColor(QPoint(nextPos % PREVIEW_TEXTURE_SIZE, nextPos / PREVIEW_TEXTURE_SIZE), color);
			previewColors.append(color);
			return nextPos++;
		};

	#if DEBUG_BIOMES
		// Debug biomes
		if (previewColors.size())
		{
			colorTop = colorSide = c_white;
			alphaTop = 1.0;
		}
	#endif

		// Create optional biome variants of top color
		uint16_t topPos = 0, sidePos = 0;
		if (tint != NONE)
		{
			for (IntType b = 0; b < Preview::biomeTints.size(); b++)
			{
				const BiomeTint& biome = Preview::biomeTints[b];
				IntType tintColor = 0;
				switch (tint)
				{
					case GRASS: tintColor = biome.grass; break;
					case FOLIAGE: tintColor = biome.foliage; break;
					case WATER: tintColor = biome.water; break;
				}
				uint16_t biomePos = addBlockColor(color_multiply(colorTop, tintColor), alphaTop, false);
				if (b == 0) // Select biome 0 as style
					topPos = sidePos = biomePos;
			}
		}
		else // No tint
		{
			if (colorTop >= 0)
				topPos = addBlockColor(colorTop, alphaTop);
			if (colorSide >= 0)
				sidePos = addBlockColor(colorSide, alphaSide);

			if (colorTop < 0)
				topPos = sidePos;
			else if (colorSide < 0)
				sidePos = topPos;
		}

		// Find existing block style
		if (tint == NONE)
			for (IntType i = blockStyles.Size() - 1; i > 0; i--)
			{
				BlockStyle* style = blockStyles.Value(i);
				if (style->topPos == topPos && style->sidePos == sidePos && style->tint == tint)
					return style->index;
			}

		// Create new
		return (new BlockStyle(topPos, sidePos, ((colorTop >= 0 && alphaTop < 0.9) || (colorSide >= 0 && alphaSide < 0.9)), tint, light))->index;
	}
}
