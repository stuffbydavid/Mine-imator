#include "Generated/Scripts.hpp"

#include "Asset/DataStructure.hpp"
#include "Asset/Sound.hpp"
#include "AppHandler.hpp"

namespace CppProject
{
	BoolType audio_is_ready(IntType index)
	{
		if (Sound* sound = FindSound(index))
			return sound->IsReady();
		return false;
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

	static BoolType IsDigit(QChar character)
	{
		return character >= QChar('0') && character <= QChar('9');
	}

	static IntType NaturalCompare(const QString& left, const QString& right)
	{
		int leftIndex = 0;
		int rightIndex = 0;

		while (leftIndex < left.size() && rightIndex < right.size())
		{
			QChar leftCharacter = left[leftIndex];
			QChar rightCharacter = right[rightIndex];

			if (IsDigit(leftCharacter) && IsDigit(rightCharacter))
			{
				int leftEnd = leftIndex;
				int rightEnd = rightIndex;
				while (leftEnd < left.size() && IsDigit(left[leftEnd]))
					leftEnd++;
				while (rightEnd < right.size() && IsDigit(right[rightEnd]))
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
				IntType compare = NaturalCompare(left.name, right.name);
				return compare ? compare < 0 : left.index < right.index;
			});

		QVector<List::ListValue> sorted;
		sorted.reserve(list->vec.size());
		for (const SoundSortRow& row : rows)
			sorted.append(list->vec[row.index]);
		list->vec.swap(sorted);
	}
}
