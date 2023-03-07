#include "Sound.hpp"

#include "AppHandler.hpp"

namespace CppProject
{
	QVector<SoundInstance*> SoundInstance::sounds;

	SoundInstance::SoundInstance(Sound* sound, BoolType loop) : Asset(ID_SoundInstance)
	{
		this->sound = sound;

		alGenSources(1, &alSource);
		alSourcef(alSource, AL_PITCH, 1.0f);
		alSourcef(alSource, AL_GAIN, 1.0f);
		alSource3f(alSource, AL_POSITION, 0, 0, 0);
		alSource3f(alSource, AL_VELOCITY, 0, 0, 0);
		alSourcei(alSource, AL_LOOPING, loop);
		alSourcei(alSource, AL_BUFFER, sound->alBuffer);
		alSourcePlay(alSource);

		sounds.append(this);
	}

	SoundInstance::~SoundInstance()
	{
		alSourceStop(alSource);
		alDeleteSources(1, &alSource);
		sounds.removeOne(this);
	}

	void SoundInstance::CleanSounds()
	{
		auto sounds = SoundInstance::sounds;
		for (SoundInstance* sound : sounds)
		{
			ALint state;
			alGetSourcei(sound->alSource, AL_SOURCE_STATE, &state);
			if (state == AL_STOPPED)
				delete sound;
		}
	}
}
