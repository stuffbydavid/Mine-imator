#pragma once
#include "Asset.hpp"
#include "Type/ArrType.hpp"

#include <atomic>
#include <memory>
#include <QByteArray>
#include <QVector>

struct AVFrame;

namespace CppProject
{
	struct SoundDecodeData
	{
		std::atomic<BoolType> complete = false;
		BoolType success = false;
		QByteArray pcm;
		QVector<RealType> waveformMax;
		QVector<RealType> waveformMin;
		IntType samples = 0;
		QString error;
	};

	struct Sound : Asset
	{
		Sound();
		~Sound();

		void LoadAsync(QString filename, IntType resourceId, QString tempFilename = "");
		BoolType IsReady() const;
		static void UpdateLoads();

		QByteArray pcm;
		ArrType waveform_max;
		ArrType waveform_min;
		ALuint alBuffer = 0;
		IntType samples = 0;
		IntType resourceId = -1;
		std::atomic<BoolType> ready = false;
		std::shared_ptr<SoundDecodeData> decode;

		static QVector<Sound*> loadingSounds;
	};

	struct SoundInstance : Asset
	{
		SoundInstance(Sound* sound, BoolType loop);
		~SoundInstance();

		Sound* sound = nullptr;
		ALuint alSource = 0;
		BoolType paused = false;
		BoolType loop = false;
		RealType gain = 1;
		RealType pitch = 1;
		RealType position = 0;

		void Start();
		static void StartPending(Sound* sound);

		// Clean sounds that have finished playing.
		static void CleanSounds();

		static QVector<SoundInstance*> sounds;
	};
}
