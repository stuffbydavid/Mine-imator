#include "Generated/Scripts.hpp"

#include "Asset/DataStructure.hpp"
#include "Asset/Sound.hpp"
#include "AppHandler.hpp"

namespace CppProject
{
	IntType audio_create_buffer_sound(IntType bufferId, IntType bufferFormat, IntType bufferRate, IntType bufferOffset, IntType bufferLength, IntType bufferChannels)
	{
		// Unused
		return 0;
	}

	BoolType audio_exists(IntType index)
	{
		return (FindSoundInstance(index));
	}

	void audio_free_buffer_sound(IntType index)
	{
		if (Sound* sound = FindSound(index))
		{
			auto sounds = SoundInstance::sounds;
			for (SoundInstance* inst : sounds)
				if (inst->sound == sound)
					delete inst;

			delete sound;
		}
	}

	BoolType audio_is_paused(IntType index)
	{
		if (SoundInstance* instance = FindSoundInstance(index))
			return instance->paused;
		return false;
	}

	BoolType audio_is_playing(IntType index)
	{
		return (FindSoundInstance(index));
	}

	void audio_pause_sound(IntType index)
	{
		if (SoundInstance* instance = FindSoundInstance(index))
		{
			instance->paused = true;
			if (instance->alSource)
				alSourcePause(instance->alSource);
		}
	}

	IntType audio_play_sound(IntType index, IntType priority, BoolType loop)
	{
		if (App->audioSupported)
			if (Sound* sound = FindSound(index))
				return (new SoundInstance(sound, loop))->id;
		return -1;
	}

	void audio_resume_sound(IntType index)
	{
		if (SoundInstance* instance = FindSoundInstance(index))
		{
			instance->paused = false;
			instance->Start();
			if (instance->alSource)
				alSourcePlay(instance->alSource);
		}
	}

	void audio_sound_gain(IntType index, RealType volume, RealType time)
	{
		if (SoundInstance* instance = FindSoundInstance(index))
		{
			instance->gain = volume;
			if (instance->alSource)
				alSourcef(instance->alSource, AL_GAIN, volume);
		}
	}

	RealType audio_sound_get_track_position(IntType index)
	{
		if (SoundInstance* instance = FindSoundInstance(index))
		{
			if (!instance->alSource)
				return instance->position;

			ALfloat secs;
			alGetSourcef(instance->alSource, AL_SEC_OFFSET, &secs);
			return secs;
		}
		return 0;
	}

	void audio_sound_pitch(IntType index, RealType pitch)
	{
		if (SoundInstance* instance = FindSoundInstance(index))
		{
			instance->pitch = pitch;
			if (instance->alSource)
				alSourcef(instance->alSource, AL_PITCH, pitch);
		}
	}

	void audio_sound_set_track_position(IntType index, RealType time)
	{
		if (SoundInstance* instance = FindSoundInstance(index))
		{
			instance->position = time;
			if (instance->alSource)
				alSourcef(instance->alSource, AL_SEC_OFFSET, time);
		}
	}

	void audio_stop_all()
	{
		auto sounds = SoundInstance::sounds;
		for (SoundInstance* sound : sounds)
			delete sound;
	}

	void audio_stop_sound(IntType index)
	{
		if (SoundInstance* sound = FindSoundInstance(index))
			delete sound;
	}
}
