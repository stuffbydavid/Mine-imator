#pragma once

#include <algorithm>
#include <array>
#include <chrono>
#include <charconv>
#include <cmath>
#include <cctype>
#include <cstddef>
#include <cstdlib>
#include <ctime>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <initializer_list>
#include <iostream>
#include <iterator>
#include <limits>
#include <memory>
#include <new>
#include <optional>
#include <regex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <string_view>
#include <type_traits>
#include <typeinfo>
#include <utility>
#include <unordered_map>
#include <unordered_set>
#include <vector>

namespace CppGen
{
namespace fs = std::filesystem;

// Whole-run bump allocator for reference objects. It preserves stable pointer
// identity and polymorphism while avoiding one general-purpose heap operation
// per object. Destructors run in reverse construction order;the backing blocks
// are then released together.
class ObjectArena
{
	struct Block
	{
		void* data{};
		std::size_t size{};
		std::size_t used{};
	};

	struct Destructor
	{
		Destructor* previous{};
		void* object{};
		void (*destroy)(void*){};
	};

	static constexpr std::size_t blockSize_ = 1024 * 1024;
	std::vector<Block> blocks_;
	Destructor* lastDestructor_{};

	void* allocate(std::size_t size, std::size_t alignment)
	{
		if (!blocks_.empty())
		{
			Block& block = blocks_.back();
			void* position = static_cast<std::byte*>(block.data) + block.used;
			std::size_t space = block.size - block.used;
			if (void* aligned = std::align(alignment, size, position, space))
			{
				block.used = static_cast<std::byte*>(aligned) -
					static_cast<std::byte*>(block.data) + size;
				return aligned;
			}
		}

		// Leave enough padding to align an object even when it is more strictly
		// aligned than the pointer returned by the underlying allocation.
		const std::size_t capacity = std::max(blockSize_, size + alignment - 1);
		void* data = ::operator new(capacity);
		try
		{
			blocks_.push_back({ data, capacity, 0 });
		}
		catch (...)
		{
			::operator delete(data);
			throw;
		}
		Block& block = blocks_.back();
		void* position = block.data;
		std::size_t space = block.size;
		void* aligned = std::align(alignment, size, position, space);
		block.used = static_cast<std::byte*>(aligned) -
			static_cast<std::byte*>(block.data) + size;
		return aligned;
	}

public:
	ObjectArena() = default;
	ObjectArena(const ObjectArena&) = delete;
	ObjectArena& operator=(const ObjectArena&) = delete;

	~ObjectArena()
	{
		while (lastDestructor_ != nullptr)
		{
			Destructor* current = lastDestructor_;
			lastDestructor_ = current->previous;
			current->destroy(current->object);
		}
		for (const Block& block : blocks_)
			::operator delete(block.data);
	}

	template<class T, class... Args>
	T* make(Args&&... args)
	{
		// Keep the destructor link and object in one bump allocation. This avoids
		// paying two resource allocations for every translated reference object.
		constexpr std::size_t alignment = std::max(alignof(Destructor), alignof(T));
		constexpr std::size_t objectOffset =
			(sizeof(Destructor) + alignof(T) - 1) & ~(alignof(T) - 1);
		void* block = allocate(objectOffset + sizeof(T), alignment);
		auto* destructor = new (block) Destructor{
			lastDestructor_,
			nullptr,
			[](void* value) { static_cast<T*>(value)->~T(); }
		};
		T* object = new (static_cast<std::byte*>(block) + objectOffset)
			T(std::forward<Args>(args)...);
		destructor->object = object;
		lastDestructor_ = destructor;
		return object;
	}
};

inline ObjectArena& objectArena()
{
	static ObjectArena arena;
	return arena;
}

template<class T, class... Args>
T* makeObject(Args&&... args)
{
	return objectArena().make<T>(std::forward<Args>(args)...);
}

class String;

// String to file path conversion
inline fs::path fsPath(const std::string& value)
{
	return fs::u8path(value);
}

// File path to string conversion
inline String fsString(const fs::path& value);

bool cultureStringLess(const String& left, const String& right);

// std::vector with the handful of List<T> operations used by CppGen.
template<class T>
class List : public std::vector<T>
{
public:
	using std::vector<T>::vector;

	int size() const noexcept
	{
		return static_cast<int>(std::vector<T>::size());
	}

	void add(const T& value)
	{
		this->push_back(value);
	}

	void add(T&& value)
	{
		this->push_back(std::move(value));
	}

	bool contains(const T& value) const
	{
		return std::find(this->begin(), this->end(), value) != this->end();
	}

	bool remove(const T& value)
	{
		auto found = std::find(this->begin(), this->end(), value);
		if (found == this->end())
			return false;

		this->erase(found);
		return true;
	}

	void removeAt(std::size_t index)
	{
		this->erase(this->begin() + static_cast<std::ptrdiff_t>(index));
	}

	template<class Predicate>
	void removeAll(Predicate predicate)
	{
		this->erase(std::remove_if(this->begin(), this->end(), predicate), this->end());
	}

	int indexOf(const T& value) const
	{
		auto found = std::find(this->begin(), this->end(), value);
		return found == this->end() ? -1 : static_cast<int>(found - this->begin());
	}

	void sort()
	{
		if constexpr (std::is_same_v<T, String>)
			std::sort(this->begin(), this->end(), cultureStringLess);
		else
			std::sort(this->begin(), this->end());
	}
};

template<class T>
class NullableList : public List<T>
{
	bool null_{};

public:
	using List<T>::List;

	NullableList() = default;
	NullableList(std::nullptr_t) : null_(true) {}
	NullableList(const List<T>& other) : List<T>(other) {}
	NullableList(List<T>&& other) noexcept : List<T>(std::move(other)) {}

	bool operator==(std::nullptr_t) const noexcept
	{
		return null_;
	}

	bool operator!=(std::nullptr_t) const noexcept
	{
		return !null_;
	}
};

class StringId;

class String : public std::string
{
public:
	using std::string::string;
	String() = default;
	String(const std::string& value) : std::string(value) {}
	String(std::string&& value) : std::string(std::move(value)) {}
	String(const int& value) : std::string(std::to_string(value)) {}
	String(const double& value) : std::string(std::to_string(value)) {}

	int size() const noexcept
	{
		return static_cast<int>(std::string::size());
	}

	bool contains(const String& value) const
	{
		return find(value) != npos;
	}

	bool startsWith(const String& value) const
	{
		return size() >= value.size() && compare(0, value.size(), value) == 0;
	}

	String replace(const String& from, const String& to) const
	{
		String result(*this);
		if (from.empty())
			return result;

		std::size_t position = 0;
		while ((position = result.find(from, position)) != npos)
		{
			static_cast<std::string&>(result).replace(position, from.size(), to);
			position += to.size();
		}
		return result;
	}

	String substring(std::size_t start) const
	{
		return substr(start);
	}

	String substring(std::size_t start, std::size_t count) const
	{
		return substr(start, count);
	}

	int indexOf(const String& value, std::size_t start = 0) const
	{
		auto position = find(value, start);
		return position == npos ? -1 : static_cast<int>(position);
	}

	String toLower() const
	{
		String result(*this);
		std::transform(
			result.begin(), result.end(), result.begin(),
			[](unsigned char character)
			{
				return static_cast<char>(std::tolower(character));
			});
		return result;
	}

	String trim() const
	{
		auto isWhitespace = [](unsigned char character)
		{
			return std::isspace(character);
		};
		const auto first = std::find_if_not(begin(), end(), isWhitespace);
		const auto last = std::find_if_not(rbegin(), rend(), isWhitespace).base();
		return first < last ? String(first, last) : String();
	}

	String remove(std::size_t start, std::size_t count) const
	{
		String result(*this);
		result.erase(start, count);
		return result;
	}

	String toString() const
	{
		return *this;
	}

	String toPath() const
	{
		return fsString(fsPath(static_cast<const std::string&>(*this)));
	}

	List<String> split(char delimiter) const;
	List<String> split(const String& delimiter) const;
};

inline String fsString(const fs::path& value)
{
	return value.generic_u8string();
}

inline bool cultureStringLess(const String& left, const String& right)
{
	auto weight = [](unsigned char value)
	{
		if (value == '_')
			return 1;
		return 16 + std::tolower(value);
	};

	const std::size_t count = std::min(left.size(), right.size());
	for (std::size_t i = 0; i < count; ++i)
	{
		const int a = weight(static_cast<unsigned char>(left[i]));
		const int b = weight(static_cast<unsigned char>(right[i]));
		if (a != b)
			return a < b;
	}

	if (left.size() != right.size())
		return left.size() < right.size();

	return static_cast<const std::string&>(left) < static_cast<const std::string&>(right);
}

inline List<String> String::split(char delimiter) const
{
	List<String> result;
	std::size_t begin = 0;
	while (begin < std::string::size())
	{
		const std::size_t end = find(delimiter, begin);
		if (end == npos)
		{
			result.emplace_back(data() + begin, std::string::size() - begin);
			break;
		}

		result.emplace_back(data() + begin, end - begin);
		begin = end + 1;
	}

	return result;
}

inline List<String> String::split(const String& delimiter) const
{
	if (delimiter.size() == 1)
		return split(delimiter[0]);

	List<String> result;
	std::size_t begin = 0;
	while (true)
	{
		auto end = find(delimiter, begin);
		if (end == npos)
		{
			result.emplace_back(data() + begin, std::string::size() - begin);
			break;
		}

		result.emplace_back(data() + begin, end - begin);
		begin = end + delimiter.size();
	}
	return result;
}

String toStringValue(const StringId& value);

// Compile-time detection keeps toStringValue compatible with translated
// classes that expose a translated toString method.
template<class T, class = void>
struct HasToString : std::false_type {};

template<class T>
struct HasToString<
	T,
	std::void_t<decltype(std::declval<const T&>().toString())>> : std::true_type {};

template<class T>
String toStringValue(const T& value)
{
	using ValueType = std::decay_t<T>;

	if constexpr (std::is_same_v<ValueType, String>)
		return value;
	else if constexpr (std::is_same_v<ValueType, std::string>)
		return String(value);
	else if constexpr (std::is_same_v<ValueType, const char*> || std::is_same_v<ValueType, char*>)
		return String(value);
	else if constexpr (std::is_same_v<ValueType, char>)
		return String(1, value);
	else if constexpr (std::is_same_v<ValueType, bool>)
		return value ? "True" : "False";
	else if constexpr (std::is_floating_point_v<ValueType>)
	{
		std::ostringstream stream;
		stream << std::setprecision(15) << value;
		return stream.str();
	}
	else if constexpr (std::is_enum_v<ValueType>)
		return toStringValue(static_cast<std::underlying_type_t<ValueType>>(value));
	else if constexpr (std::is_integral_v<ValueType>)
	{
		char buffer[std::numeric_limits<ValueType>::digits10 + 3];
		const auto result = std::to_chars(std::begin(buffer), std::end(buffer), value);
		return String(buffer, result.ptr);
	}
	else if constexpr (HasToString<T>::value)
		return value.toString();
	else
		return String(value);
}

inline String operator+(const String& left, const String& right)
{
	String result;
	result.reserve(left.size() + right.size());
	result.append(left);
	result.append(right);
	return result;
}

inline String operator+(String&& left, const String& right)
{
	left.reserve(left.size() + right.size());
	left.append(right);
	return std::move(left);
}

inline String operator+(const char* left, const String& right)
{
	return String(left) + right;
}

inline String operator+(const String& left, const char* right)
{
	return left + String(right);
}

template<class T, std::enable_if_t<!std::is_same_v<std::decay_t<T>, String>, int> = 0>
String operator+(const String& left, const T& right)
{
	const String converted = toStringValue(right);
	String result;
	result.reserve(left.size() + converted.size());
	result.append(left);
	result.append(converted);
	return result;
}

template<class T, std::enable_if_t<!std::is_same_v<std::decay_t<T>, String>, int> = 0>
String operator+(String&& left, const T& right)
{
	const String converted = toStringValue(right);
	left.reserve(left.size() + converted.size());
	left.append(converted);
	return std::move(left);
}

template<class T, std::enable_if_t<!std::is_same_v<std::decay_t<T>, String>, int> = 0>
String operator+(const T& left, const String& right)
{
	const String converted = toStringValue(left);
	String result;
	result.reserve(converted.size() + right.size());
	result.append(converted);
	result.append(right);
	return result;
}

// Optimized string identifier used during resolve stage, using a lookup table in Strings.hpp.
class StringId
{
	int id_{0};

	void set(const String& value);

public:
	StringId() { clear(); }
	StringId(const StringId& other) { id_ = other.id_; }
	StringId(const String& value) { set(value); }
	StringId(const char* value) { set(value); }
	StringId(const int& id) { id_ = id; }

	StringId& operator=(const StringId& other) { id_ = other.id_; return *this; }
	StringId& operator=(const String& value) { set(value); return *this; }
	StringId& operator=(const char* value) { set(value); return *this; }
	StringId& operator=(int id) { id_ = id; return *this; }

	void clear() noexcept { id_ = 0; }

	operator const String& () const;
	const int& id() const { return id_; };

	bool operator==(const StringId& other) const { return id_ == other.id_; }
	bool operator!=(const StringId& other) const { return id_ != other.id_; }
	bool operator==(const int& other) const { return id_ == other; }
	bool operator!=(const int& other) const { return id_ != other; }

	static void initialize();
	static List<String> allValues();
};

inline String toStringValue(const StringId& value)
{
	return static_cast<const String&>(value);
}

struct StringIdHash
{
	std::size_t operator()(const StringId& value) const noexcept
	{
		return std::hash<int>{}(value.id());
	}
};

// Dictionary that preserves previous insertion order and average O(1) lookup.
template<class V>
class OrderedMap
{
	std::unordered_map<StringId, std::size_t, StringIdHash> indices_;

public:
	List<StringId> keys;
	List<V> values;

	OrderedMap() = default;

	OrderedMap(std::initializer_list<std::pair<StringId, V>> values)
	{
		indices_.reserve(values.size());
		keys.reserve(values.size());
		this->values.reserve(values.size());
		for (const auto& value : values)
			add(value.first, value.second);
	}

	bool containsKey(const StringId& key) const
	{
		return indices_.find(key) != indices_.end();
	}

	void add(const StringId& key, const V& value)
	{
		const std::size_t index = values.size();
		const bool inserted = indices_.emplace(key, index).second;
		if (!inserted)
			throw std::runtime_error("Duplicate dictionary key: " + std::string(key));

		keys.emplace_back(key);
		values.emplace_back(value);
	}

	V& operator[](const StringId& key)
	{
		const std::size_t index = values.size();
		auto [found, inserted] = indices_.try_emplace(key, index);
		if (inserted)
		{
			keys.emplace_back(key);
			values.emplace_back();
		}
		return values[found->second];
	}

	const V& operator[](const StringId& key) const
	{
		return values.at(indices_.at(key));
	}

	bool remove(const StringId& key)
	{
		auto found = indices_.find(key);
		if (found == indices_.end())
			return false;

		const auto index = found->second;
		indices_.erase(found);
		keys.removeAt(index);
		values.removeAt(index);

		for (std::size_t i = index; i < static_cast<std::size_t>(keys.size()); ++i)
			indices_[keys[i]] = i;

		return true;
	}

	void clear()
	{
		indices_.clear();
		keys.clear();
		values.clear();
	}

	std::size_t size() const
	{
		return values.size();
	}
};

// Mutable string accumulator matching the StringBuilder calls in CppGen.
class StringBuilder
{
	String text_;

public:
	StringBuilder(const String& initial = "") : text_(initial) {}

	void append(const String& value)
	{
		text_ += value;
	}

	void appendLine(const String& value = "")
	{
		text_ += value;
		text_ += "\r\n";
	}

	void remove(std::size_t start, std::size_t count)
	{
		text_.erase(start, count);
	}

	std::size_t length() const
	{
		return text_.size();
	}

	std::size_t size() const
	{
		return text_.size();
	}

	String toString() const
	{
		return text_;
	}
};

struct Console
{
	template<class... Args>
	static void writeLine(String format, Args&&... args)
	{
		List<String> values{ toStringValue(std::forward<Args>(args))...};
		for (std::size_t i = 0; i < static_cast<std::size_t>(values.size()); ++i)
			format = format.replace("{" + toStringValue(i) + "}", values[i]);

		std::cout << format << std::endl;
	}
};


struct File
{
	static bool exists(const String& path)
	{
		return fs::exists(fsPath(path));
	}

	static String readAllText(const String& path)
	{
		std::ifstream stream(fsPath(path), std::ios::binary);
		if (!stream)
			throw std::runtime_error("Could not read " + std::string(path));

		return {std::istreambuf_iterator<char>(stream), std::istreambuf_iterator<char>()};
	}

	static void writeAllText(const String& path, const String& text)
	{
		fs::create_directories(fsPath(path).parent_path());
		std::ofstream stream(fsPath(path), std::ios::binary | std::ios::trunc);
		if (!stream)
			throw std::runtime_error("Could not write " + std::string(path));

		stream.write(text.data(), static_cast<std::streamsize>(text.size()));
	}

	static void copy(const String& source, const String& destination, bool overwrite)
	{
		const auto options = overwrite
			? fs::copy_options::overwrite_existing
			: fs::copy_options::none;
		fs::copy_file(fsPath(source), fsPath(destination), options);
	}
};

inline bool wildcardMatch(const String& name, const String& pattern)
{
	if (pattern == "*")
		return true;
	if (pattern.startsWith("*."))
		return fsString(fsPath(name).extension()) == pattern.substring(1);

	return name == pattern;
}

struct Directory
{
	static bool exists(const String& path)
	{
		return fs::is_directory(fsPath(path));
	}

	static String getCurrentDirectory()
	{
		return fsString(fs::current_path());
	}

	static void createDirectory(const String& path)
	{
		fs::create_directories(fsPath(path));
	}

	static List<String> getDirectories(const String& path)
	{
		List<String> result;
		for (const auto& item : fs::directory_iterator(fsPath(path)))
		{
			if (item.is_directory())
				result.add(fsString(item.path()));
		}
		result.sort();
		return result;
	}

	static List<String> getFiles(const String& path, const String& pattern = "*")
	{
		List<String> result;
		for (const auto& item : fs::directory_iterator(fsPath(path)))
		{
			if (item.is_regular_file() &&
				wildcardMatch(fsString(item.path().filename()), pattern))
			{
				result.add(fsString(item.path()));
			}
		}
		result.sort();
		return result;
	}
};

class FileInfo
{
	fs::path path_;

public:
	String fullName;
	String name;
	bool exists{};
	fs::file_time_type lastWriteTime{};

	FileInfo(const String& path) :
		path_(fsPath(path)),
		fullName(fsString(path_)),
		name(fsString(path_.filename())),
		exists(fs::exists(path_))
	{
		if (exists)
			lastWriteTime = fs::last_write_time(path_);
	}

	void copyTo(const String& destination, bool overwrite) const
	{
		File::copy(fullName, destination, overwrite);
	}

	void deleteFile()
	{
		if (fs::exists(path_))
			fs::remove(path_);
		exists = false;
	}
};

class DirectoryInfo
{
	fs::path path_;

public:
	String name;

	DirectoryInfo(const String& path) :
		path_(fsPath(path)),
		name(fsString(path_.filename()))
	{}

	List<FileInfo> getFiles(const String& pattern) const
	{
		List<FileInfo> result;
		for (const auto& path : Directory::getFiles(fsString(path_), pattern))
			result.add(FileInfo(path));

		return result;
	}
};

// Stopwatch accumulates elapsed time across start/stop calls, matching the
// behavior relied on by CppGen's progress reporting.
class Stopwatch
{
	using Clock = std::chrono::steady_clock;

	Clock::time_point start_{};
	double elapsedMs_{};

public:
	struct ElapsedValue
	{
		double totalMilliseconds{};
	};

	ElapsedValue elapsed;

	void start()
	{
		start_ = Clock::now();
	}

	void stop()
	{
		elapsedMs_ += std::chrono::duration<double, std::milli>(
			Clock::now() - start_).count();
		elapsed.totalMilliseconds = elapsedMs_;
	}

	void restart()
	{
		elapsedMs_ = 0;
		elapsed.totalMilliseconds = 0;
		start();
	}
};

class DateTime
{
	std::time_t value_{};

public:
	static DateTime now()
	{
		return DateTime{std::time(nullptr)};
	}

	String toString(const String& format) const
	{
		std::tm local{};
#ifdef _WIN32
		localtime_s(&local, &value_);
#else
		localtime_r(&value_, &local);
#endif
		const String converted = format
			.replace("yyyy", "%Y")
			.replace("MM", "%m")
			.replace("dd", "%d")
			.replace("HH", "%H")
			.replace("mm", "%M")
			.replace("ss", "%S");

		std::ostringstream stream;
		stream << std::put_time(&local, converted.c_str());
		return stream.str();
	}

private:
	explicit DateTime(std::time_t value) : value_(value) {}
};

// Only replacement remains regex-backed. Lexing uses a purpose-built scanner.
struct Regex
{
	static String replace(const String& input, const String& pattern, const String& replacement)
	{
		return std::regex_replace(
			std::string(input), std::regex(pattern), std::string(replacement));
	}
};

// Ordered JSON value used for gml.json and GameMaker .yy files. Both object
// lookup and source-order iteration are required by the translated parser.
class Json
{
public:
	enum Kind
	{
		Null,
		Bool,
		Number,
		Text,
		Array,
		Object
	};

	Kind kind = Null;
	String name;
	String text;
	double number{};
	bool boolean{};
	List<Json> values;
	OrderedMap<Json> object;

	Json& operator[](const String& key)
	{
		return object[key];
	}

	const Json& operator[](const String& key) const
	{
		return object[key];
	}

	Json& operator[](const char* key)
	{
		return object[String(key)];
	}

	const Json& operator[](const char* key) const
	{
		return object[String(key)];
	}

	auto begin()
	{
		return values.begin();
	}

	auto end()
	{
		return values.end();
	}

	auto begin() const
	{
		return values.begin();
	}

	auto end() const
	{
		return values.end();
	}

	operator String() const
	{
		return toString();
	}

	operator double() const
	{
		return number;
	}

	operator int() const
	{
		return static_cast<int>(number);
	}

	bool operator==(std::nullptr_t) const
	{
		return kind == Null;
	}

	bool operator!=(std::nullptr_t) const
	{
		return kind != Null;
	}

	String toString() const
	{
		if (kind == Text)
			return text;
		if (kind == Number)
			return String(number);
		if (kind == Bool)
			return boolean ? "true" : "false";

		return "";
	}
};

struct JsonConvert
{
	static Json deserializeObject(const String& source);
};
} // namespace CppGen

namespace std
{
template<>
struct hash<CppGen::String>
{
	std::size_t operator()(const CppGen::String& value) const noexcept
	{
		return hash<std::string_view>{}(std::string_view(value.data(), value.size()));
	}
};

}
