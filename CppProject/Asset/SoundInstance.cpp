#include "Sound.hpp"

#include "AppHandler.hpp"

namespace CppProject
{
	QVector<SoundInstance*> SoundInstance::sounds;

	SoundInstance::SoundInstance(Sound* sound, BoolType loop) : Asset(ID_SoundInstance)
	{
		this->sound = sound;
		this->loop = loop;
		sounds.append(this);
		Start();
	}

	void SoundInstance::Start()
	{
		if (alSource || !sound->IsReady())
			return;

		alGenSources(1, &alSource);
		alSourcef(alSource, AL_PITCH, pitch);
		alSourcef(alSource, AL_GAIN, gain);
		alSource3f(alSource, AL_POSITION, 0, 0, 0);
		alSource3f(alSource, AL_VELOCITY, 0, 0, 0);
		alSourcei(alSource, AL_LOOPING, loop);
		alSourcei(alSource, AL_BUFFER, sound->alBuffer);
		alSourcef(alSource, AL_SEC_OFFSET, position);
		alSourcePlay(alSource);
	}

	void SoundInstance::StartPending(Sound* sound)
	{
		auto sounds = SoundInstance::sounds;
		for (SoundInstance* instance : sounds)
			if (instance->sound == sound && !instance->paused)
				instance->Start();
	}

	SoundInstance::~SoundInstance()
	{
		if (alSource)
		{
			alSourceStop(alSource);
			alDeleteSources(1, &alSource);
		}
		sounds.removeOne(this);
	}

	void SoundInstance::CleanSounds()
	{
		auto sounds = SoundInstance::sounds;
		for (SoundInstance* sound : sounds)
		{
			if (!sound->alSource)
				continue;

			ALint state;
			alGetSourcei(sound->alSource, AL_SOURCE_STATE, &state);
			if (state == AL_STOPPED)
				delete sound;
		}
	}
}
