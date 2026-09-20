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

	BoolType audio_is_ready(IntType index)
	{
		if (Sound* sound = FindSound(index))
			return sound->IsReady();
		return false;
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

	void res_load_audio(ScopeAny self)
	{
		obj_resource* res = ObjType(obj_resource, self->id);
		StringType fname = VarGetStr(global::load_folder) + "/" + res->filename;
		if (res->sound_index)
			delete FindSound(res->sound_index);

		res->sound_index = null_;
		res->sound_samples = 0;
		res->ready = false;

		if (!file_exists_lib(fname))
		{
			res->load_stage = "";
			return;
		}

		QString tmpFname = "";
		if (res->creator == global::_app->bench_settings && res->minecraft_hash != "")
			tmpFname = fname.QStr();

		// Queue file decode
		Sound* snd = new Sound;
		res->sound_index = snd->id;
		res->sound_max_sample = ArrType();
		res->sound_min_sample = ArrType();
		snd->LoadAsync(fname.QStr(), res->id, tmpFname);
		res->load_stage = "";
	}

	static BoolType sound_sort_is_digit(QChar character)
	{
		return character >= QChar('0') && character <= QChar('9');
	}

	static IntType sound_natural_compare(const QString& left, const QString& right)
	{
		int leftIndex = 0;
		int rightIndex = 0;

		while (leftIndex < left.size() && rightIndex < right.size())
		{
			QChar leftCharacter = left[leftIndex];
			QChar rightCharacter = right[rightIndex];

			if (sound_sort_is_digit(leftCharacter) && sound_sort_is_digit(rightCharacter))
			{
				int leftEnd = leftIndex;
				int rightEnd = rightIndex;
				while (leftEnd < left.size() && sound_sort_is_digit(left[leftEnd]))
					leftEnd++;
				while (rightEnd < right.size() && sound_sort_is_digit(right[rightEnd]))
					rightEnd++;

				int leftNumber = leftIndex;
				int rightNumber = rightIndex;
				while (leftNumber < leftEnd && left[leftNumber] == QChar('0'))
					leftNumber++;
				while (rightNumber < rightEnd && right[rightNumber] == QChar('0'))
					rightNumber++;

				int leftLength = leftEnd - leftNumber;
				int rightLength = rightEnd - rightNumber;
				if (leftLength != rightLength)
					return leftLength < rightLength ? -1 : 1;

				for (int i = 0; i < leftLength; i++)
					if (left[leftNumber + i] != right[rightNumber + i])
						return left[leftNumber + i] < right[rightNumber + i] ? -1 : 1;

				leftIndex = leftEnd;
				rightIndex = rightEnd;
				continue;
			}

			if (leftCharacter != rightCharacter)
				return leftCharacter < rightCharacter ? -1 : 1;

			leftIndex++;
			rightIndex++;
		}

		if (leftIndex < left.size())
			return 1;
		if (rightIndex < right.size())
			return -1;
		return 0;
	}

	void soundlist_sort(IntType listId)
	{
		List* list = FindList(listId);
		if (!list || list->vec.size() < 2)
			return;

		struct SoundSortRow
		{
			IntType index;
			QString name;
		};

		QVector<SoundSortRow> rows;
		rows.reserve(list->vec.size());
		for (int i = 0; i < list->vec.size(); i++)
			rows.append({ i, list->vec[i].value.Value(1).Str().QStr().toLower() });

		std::sort(rows.begin(), rows.end(), [](const SoundSortRow& left, const SoundSortRow& right)
			{
				IntType compare = sound_natural_compare(left.name, right.name);
				return compare ? compare < 0 : left.index < right.index;
			});

		QVector<List::ListValue> sorted;
		sorted.reserve(list->vec.size());
		for (const SoundSortRow& row : rows)
			sorted.append(list->vec[row.index]);
		list->vec.swap(sorted);
	}
}
