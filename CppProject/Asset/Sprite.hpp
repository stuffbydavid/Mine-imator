#pragma once
#include "Asset.hpp"

namespace CppProject
{
	struct Texture;
	struct Surface;
	struct TexturePageLocation;

	// Sprite asset
	struct Sprite : Asset
	{
		Sprite(Sprite* other);
		Sprite(QString name, IntType subAssetId, int numFrames, QPoint origin);
		Sprite(const StringType& filename, QPoint origin);
		Sprite(Surface* surface, QPoint origin);
		Sprite(Surface* surface, QRect rect, QPoint origin);
		~Sprite();

		// Returns the QOpenGLTexture/TexturePageLocation ID of a sprite frame.
		IntType GetTexture(IntType frame);

		// Returns the color of a pixel in the given frame.
		QColor GetPixel(IntType frame, QPoint point) const;

		// Sprite frame
		struct Frame
		{
			Frame(QImage image, bool toPage);
			~Frame();

			IntType GetTexture();
			bool MoveToTexturePage();

			QImage image;
			TexturePageLocation* pageLoc = nullptr;
			Texture* texture = nullptr;
		};

		QSize size = { 0, 0 };
		QPoint origin = { 0, 0 };
		QVector<Frame*> frames;
		BoolType useTexturePage = true;

		static QVector<Sprite*> allSprites;
	};
}