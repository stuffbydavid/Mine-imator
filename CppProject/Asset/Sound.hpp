#pragma once
#include "Asset.hpp"
#include "Type/ArrType.hpp"

#include <QByteArray>

struct AVFrame;

namespace CppProject
{
	struct Sound : Asset
	{
		Sound(StringType filename);
		~Sound();

		QByteArray pcm;
		ArrType waveform_max;
		ArrType waveform_min;
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
