#pragma once
#include "Asset.hpp"

#include <QBuffer>
#include <QIODevice>

struct AVFrame;

namespace CppProject
{
	struct Sound : Asset
	{
		Sound(StringType filename);
		~Sound();

		QBuffer buffer;
		ALuint alBuffer = 0;
		IntType samples = 0;
	};

	struct SoundInstance : Asset
	{
		SoundInstance(Sound* sound, BoolType loop);
		~SoundInstance();

		Sound* sound = nullptr;
		ALuint alSource = 0;
		BoolType paused = false;

		// Clean sounds that have finished playing.
		static void CleanSounds();

		static QVector<SoundInstance*> sounds;
	};
}