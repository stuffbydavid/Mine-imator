#pragma once
#include "FastVector.hpp"

#define STRINGTYPE_DEBUG DEBUG_MODE

namespace CppProject
{
	// Points to a string in a lookup table containing all commonly used strings.
	struct StringType
	{
		struct Table;
		struct QThreadData;

		StringType() {}
		StringType(IntType id);
		StringType(const QString& str);
		StringType(const char* str);
		StringType(const StringType& other) { *this = other; }
		StringType(const QByteArray& other) { *this = QString(other); }
		~StringType();

		StringType& operator=(const StringType& other);
		StringType& operator+=(const char* str);
		StringType& operator+=(const StringType& other);
		inline bool operator==(const char* str) const { return QStr() == str; }
		inline bool operator==(const StringType& other) const { return GetId() == other.GetId(); }
		inline bool operator!=(const char* str) const { return QStr() != str; }
		inline bool operator!=(const StringType& other) const { return GetId() != other.GetId(); }
		inline bool operator>(const StringType& other) const { return GetId() > other.GetId(); }
		inline bool operator<(const StringType& other) const { return GetId() < other.GetId(); }
		inline bool operator>=(const StringType& other) const { return GetId() >= other.GetId(); }
		inline bool operator<=(const StringType& other) const { return GetId() <= other.GetId(); }
		inline StringType operator+(const StringType& other) const { return QStr() + other.QStr(); }
		inline StringType operator+(const char* str) const { return QStr() + str; }

		void Set(const QString& str);
		void AddRef(IntType num);
		IntType GetId() const;
		Table* GetTable() const;
		QString* QStrPtr() const;
		inline QString QStr() const { return *QStrPtr(); }
		void Clear();
		inline operator QString() const { return QStr(); }

		// Get string length
		inline BoolType IsEmpty() const { return !id; }
		inline IntType GetLength() const { return GetTable()->entries[GetId()].len; }

		// Get string contents
		inline QChar At(IntType i) const { return QStr().at(i); }
		inline std::string ToStdString() const { return QStr().toStdString(); }
		inline QByteArray ToUtf8() const { return QStr().toUtf8(); }
		inline RealType ToReal() const { return QStr().toDouble(); }
		inline StringType ToUpper() const { return QStr().toUpper(); }
		inline StringType ToLower() const { return QStr().toLower(); }

		// Check string contents for substring
		inline BoolType Contains(const StringType& subStr) const { return QStr().contains(subStr); }
		inline BoolType StartsWith(const StringType& subStr) const { return QStr().startsWith(subStr); }
		inline BoolType EndsWith(const StringType& subStr) const { return QStr().endsWith(subStr); }
		inline IntType Count(const StringType& subStr) const { return QStr().count(subStr); }
		inline IntType IndexOf(const StringType& subStr) const { return QStr().indexOf(subStr); }

		// Return modified string
		inline StringType Removed(IntType pos, IntType n) const { return QStr().remove(pos, n); }
		inline StringType Replaced(const QRegularExpression&rx, QString after) const { return QStr().replace(rx, after); }
		inline StringType Replaced(const StringType& find, QString after) const { return QStr().replace(find, after); }
		inline StringType Replaced(IntType pos, IntType len, QString after) const { return QStr().replace(pos, len, after); }
		inline StringType Inserted(IntType pos, StringType str) const { return QStr().insert(pos, str); }
		inline StringType Repeated(IntType n) const { return QStr().repeated(n); }
		inline QStringList Split(char split) const { return QStr().split(split); }
		inline StringType Left(IntType n) const { return QStr().left(n); }
		inline StringType Mid(IntType pos, IntType n = -1) const { return QStr().mid(pos, n); }

		// Registers a predefined string to the main table and returns its id.
		static IntType Add(const char* str);

		// Add all GML strings
		static void AddGMLStrings();

		// Start a multi-threaded OpenMP task.
		static void BeginOmp();

		// Merge the newly created strings of all OpenMP threads into the main table.
		static void EndOmp();

		// Returns the active QThreadData.
		static QThreadData* GetCurrentQThreadData();

		// Adds a new QThread, copying the string tables from the main application thread.
		static void AddQThread(QThread* thread);

	#if STRINGTYPE_DEBUG
		QString* val = nullptr; // For debugging
	#endif
		IntType id = 0; // Unique string id, 0 for empty string
		BoolType omp = false; // Created on an OpenMP thread
		int8_t ompIndex = 0; // OpenMP thread index
		QThreadData* qThread = nullptr; // QThread data of the string

		struct TableEntry
		{
			uint32_t refs = 0; // References, can be safely deleted when 0
			QString* val = nullptr; // Pointer to string on heap
			IntType len = 0; // String length
		};

		struct Table
		{
			// Clean unused strings from memory.
			void Clean();

			// Debug all strings in the table.
			void Debug(QString name = "");

			QHash<IntType, TableEntry> entries; // Map string id to entry
			QHash<QString, IntType> idMap; // Map QString to id
			QHash<IntType, IntType> mainIdMap; // String id on thread table to main table id
			IntType nextId = 0;
			IntType startId = 0;
		};

		struct QThreadData
		{
			QThreadData(QThreadData* other = nullptr) {}

			Table mainTable;
			Table ompTable[OPENMP_MAX_THREADS];
			BoolType ompActive = false;
		};

		static QString empty;
		static BoolType qThreadActive;
		static QThreadData* appThreadData;
		static QThreadData* ompThreadData;
		static QHash<QThread*, QThreadData*> qThreadData;
	};

	// StringType id used for hash table
	static uint qHash(const StringType& key) { return key.GetId(); }
}