#include "Generated/Scripts.hpp"

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
			alSourcei(instance->alSource, AL_SOURCE_STATE, AL_PAUSED);
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
			alSourcei(instance->alSource, AL_SOURCE_STATE, AL_PLAYING);
		}
	}

	void audio_sound_gain(IntType index, RealType volume, RealType time)
	{
		if (SoundInstance* instance = FindSoundInstance(index))
			alSourcef(instance->alSource, AL_GAIN, volume);
	}

	RealType audio_sound_get_track_position(IntType index)
	{
		if (SoundInstance* instance = FindSoundInstance(index))
		{
			ALfloat secs;
			alGetSourcef(instance->alSource, AL_SEC_OFFSET, &secs);
			return secs;
		}
		return 0;
	}

	void audio_sound_pitch(IntType index, RealType pitch)
	{
		if (SoundInstance* instance = FindSoundInstance(index))
			alSourcef(instance->alSource, AL_PITCH, pitch);
	}

	void audio_sound_set_track_position(IntType index, RealType time)
	{
		if (SoundInstance* instance = FindSoundInstance(index))
			alSourcef(instance->alSource, AL_SEC_OFFSET, time);
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

	void res_load_audio(ScopeAny self)
	{
		obj_resource* res = ObjType(obj_resource, self->id);
		StringType fname = global::load_folder + "/" + res->filename;
		if (res->sound_index)
			delete FindSound(res->sound_index);

		res->sound_index = null_;
		res->sound_samples = 0;

		if (!file_exists_lib(fname))
		{
			res->load_stage = "";
			return;
		}

		// Decode file
		Sound* snd = new Sound(fname);
		if (snd->pcm.isEmpty())
		{
			error("errorloadaudio");
			res->load_stage = "";
			delete snd;
			return;
		}

		res->sound_index = snd->id;
		res->sound_samples = snd->samples;

		res->sound_max_sample = snd->waveform_max;
		res->sound_min_sample = snd->waveform_min;

		res->ready = true;
		res->load_stage = "";
		tl_update_length();
	}
}
