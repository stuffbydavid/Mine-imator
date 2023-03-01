#include "StringType.hpp"
#include "Generated/Scripts.hpp"

namespace CppProject
{
	QString StringType::empty = "";
	BoolType StringType::qThreadActive = false;
	StringType::QThreadData* StringType::appThreadData = nullptr;
	StringType::QThreadData* StringType::ompThreadData = nullptr;
	QHash<QThread*, StringType::QThreadData*> StringType::qThreadData;

	StringType::StringType(IntType id) : id(id)
	{
	#if STRINGTYPE_DEBUG
		val = QStrPtr();
	#endif
	}

	StringType::StringType(const QString& str)
	{
		if (!str.isEmpty())
			Set(str);
	}

	StringType::StringType(const char* str)
	{
		if (strlen(str))
			Set(str);
	}

	StringType::~StringType()
	{
		AddRef(-1);
	}

	StringType& StringType::operator=(const StringType& other)
	{
		if (id == other.id && omp == other.omp && ompIndex == other.ompIndex) // Identical
			return *this;

		AddRef(-1);
		id = other.id;
		omp = other.omp;
		ompIndex = other.ompIndex;
	#if STRINGTYPE_DEBUG
		val = QStrPtr();
	#endif
		AddRef(1);

		return *this;
	}

	StringType& StringType::operator+=(const char* str)
	{
		Set(QStr() + str);
		return *this;
	}

	StringType& StringType::operator+=(const StringType& other)
	{
		Set(QStr() + other.QStr());
		return *this;
	}

	void StringType::Set(const QString& str)
	{
		AddRef(-1);

		// id from string
		if (qThread->ompActive)
		{
			omp = true;
			ompIndex = omp_get_thread_num();
			id = qThread->ompTable[ompIndex].idMap.value(str, -1);
			if (id < 0) // Look in main table
				id = qThread->mainTable.idMap.value(str, -1);
		}
		else
		{
			omp = false;
			ompIndex = 0;
			id = qThread->mainTable.idMap.value(str, -1);
		}

		if (id < 0) // New
		{
			Table& table = omp ? qThread->ompTable[ompIndex] : qThread->mainTable;
			id = table.nextId++;
			table.idMap[str] = id;
			table.entries[id] = { 1, new QString(str), str.length() }; // Add entry with reference count of 1
		}
		else
			AddRef(1);

	#if STRINGTYPE_DEBUG
		val = QStrPtr();
	#endif
	}

	void StringType::AddRef(IntType num)
	{
		// Assign QThread data
		if (!qThread)
			qThread = GetCurrentQThreadData();

		if (!qThread) // Invalid QThread, can happen on application close
			return;

		Table* table = GetTable();
		if (omp && table == &qThread->mainTable) // Can't write to main table on OpenMP thread
			return;

		IntType tableId = GetId();
		if (tableId >= table->startId)
		{
		#if STRINGTYPE_DEBUG
			if (!table->entries.contains(tableId))
				WARNING(NumStr(tableId) + " not in table");
			else
		#endif
				table->entries[tableId].refs += num;
		}
	}

	IntType StringType::GetId() const
	{
		if (omp)
		{
			QThreadData* qThread = this->qThread ? this->qThread : GetCurrentQThreadData();
			if (qThread->ompTable[ompIndex].mainIdMap.contains(id)) // String mapped to main table
				return qThread->ompTable[ompIndex].mainIdMap.value(id);
		}

		return id;
	}

	StringType::Table* StringType::GetTable() const
	{
		QThreadData* qThread = this->qThread ? this->qThread : GetCurrentQThreadData();
		if (omp &&
			id >= qThread->ompTable[ompIndex].startId &&
			!qThread->ompTable[ompIndex].mainIdMap.contains(id)) // String stored in OpenMP table (not remapped)
			return &qThread->ompTable[ompIndex];

		return &qThread->mainTable; // String stored in main table
	}

	QString* StringType::QStrPtr() const
	{
		QThreadData* qThread = this->qThread ? this->qThread : GetCurrentQThreadData();

		if (!id) // Empty string
			return &empty;

		Table* table = GetTable();
		if (id < table->startId) // Main table id
			return qThread->mainTable.entries.value(id).val;

		const TableEntry& entry = table->entries.value(GetId());
		if (!entry.val)
		{
			WARNING("String not found with id " + NumStr(GetId()));
			return &empty;
		}

		return entry.val;
	}

	void StringType::Clear()
	{
		AddRef(-1);
		id = 0;
	}

	IntType StringType::Add(const char* str)
	{
		Table& mainTable = GetCurrentQThreadData()->mainTable;
		QString* qStr = new QString(str);
		IntType id = mainTable.nextId++;
		mainTable.idMap[str] = id;
		mainTable.entries[id] = { 1, qStr, qStr->length() };
		mainTable.startId++;
		return id;
	}

	void StringType::BeginOmp()
	{
		QThreadData* qThread = GetCurrentQThreadData();
		qThread->mainTable.Clean();

		for (IntType t = 0; t < omp_get_max_threads(); t++)
		{
			Table& table = qThread->ompTable[t];

			// Clear ompIndex table id -> main table id mapping
			for (auto it = table.mainIdMap.begin(); it != table.mainIdMap.end();)
			{
				if (!qThread->mainTable.entries.contains(it.value()))
					it = table.mainIdMap.erase(it);
				else
					++it;
			}

			// Set next ids
			table.nextId = table.startId = qThread->mainTable.nextId;
		}

		qThread->ompActive = true;
		ompThreadData = qThread;
	}

	void StringType::EndOmp()
	{
		QThreadData* qThread = GetCurrentQThreadData();

		// Find new max id to avoid duplicates
		for (IntType t = 0; t < omp_get_max_threads(); t++)
			qThread->mainTable.nextId = std::max(qThread->mainTable.nextId, qThread->ompTable[t].nextId);

		// All newly created TableEntry are moved to the main table and ids remapped for each OpenMP thread
		for (IntType t = 0; t < omp_get_max_threads(); t++)
		{
			Table& table = qThread->ompTable[t];
			table.Clean();
			for (IntType i = table.startId; i < table.nextId; i++)
			{
				if (!table.entries.contains(i))
					continue;

				const TableEntry& entry = table.entries.value(i);
				IntType mainId = qThread->mainTable.idMap.value(*entry.val, -1);
				if (mainId < 0) // New
				{
					mainId = qThread->mainTable.nextId++;
					qThread->mainTable.idMap[*entry.val] = mainId;
					qThread->mainTable.entries[mainId] = entry;
				}
				else // Existing, add references and clear string on OpenMP thread
				{
					qThread->mainTable.entries[mainId].refs += entry.refs;
					delete entry.val;
				}

				table.mainIdMap[i] = mainId;
			}
			table.entries.clear();
			table.idMap.clear();
		}

		qThread->ompActive = false;
		ompThreadData = nullptr;
	}

	StringType::QThreadData* StringType::GetCurrentQThreadData()
	{
		if (qThreadActive)
		{
			if (omp_get_num_threads() > 1) // Accessed in OpenMP thread
				return ompThreadData;
			else
				return qThreadData.value(QThread::currentThread(), nullptr);
		}
		else
		{
			if (appThreadData->ompActive)
				return ompThreadData;
			else
				return appThreadData;
		}
	}

	void StringType::AddQThread(QThread* thread)
	{
		// QThread pointer as key
		QThreadData* data = new QThreadData;
		qThreadData[thread] = data;

		// Set as application QThread
		if (!appThreadData)
			appThreadData = data;

		else // Copy from application QThread
		{
			Table& appMainTable = appThreadData->mainTable;
			data->mainTable.nextId = data->mainTable.startId = appMainTable.nextId;

			// Copy entries
			for (auto it = appMainTable.entries.begin(); it != appMainTable.entries.end(); ++it)
			{
				TableEntry entry = it.value();
				data->mainTable.entries[it.key()] = {
					entry.refs,
					new QString(*entry.val), // Allocate new QString
					entry.len
				};
			}

			// Copy QString to id mapping
			for (auto it = appMainTable.idMap.begin(); it != appMainTable.idMap.end(); ++it)
				data->mainTable.idMap[it.key()] = it.value();
		}
	}

	void StringType::Table::Clean()
	{
		for (auto it = entries.begin(); it != entries.end();)
		{
			TableEntry& entry = it.value();
			if (it.key() >= startId && !entry.refs && entry.val)
			{
				idMap.remove(*entry.val);
				delete entry.val;
				it = entries.erase(it);
			}
			else
				++it;
		}
	}

	void StringType::Table::Debug(QString name)
	{
		QFile debug(BUILD_FOLDER + "/Strings-" + name + ".txt");
		AddPerms(debug);
		if (!debug.open(QFile::WriteOnly))
			return;

		QString text = "Id\tRef\tString\n";
		for (IntType i = startId; i < nextId; i++)
		{
			if (!entries.contains(i))
				continue;

			const TableEntry& entry = entries.value(i);
			if (!entry.val)
				WARNING("Invalid string");
			QString val = entry.val ? *entry.val : "?????";
			val.replace("\n", " ");
			text += NumStr(i) + "\t" + NumStr(entry.refs) + "\t" + val + "\n";
		}
		debug.write(text.toUtf8());
		DEBUG("Saved string table for table " + name);
	}
}