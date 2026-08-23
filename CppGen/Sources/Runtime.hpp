#pragma once

#include <algorithm>
#include <chrono>
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
#include <memory>
#include <new>
#include <optional>
#include <regex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <type_traits>
#include <typeinfo>
#include <utility>
#include <unordered_map>
#include <unordered_set>
#include <vector>

namespace CppGen
{
namespace fs = std::filesystem;

// Whole-run bump allocator for translated C# reference objects. It preserves
// stable pointer identity and polymorphism while avoiding one general-purpose
// heap operation per object. Destructors run in reverse construction order;
// the backing blocks are then released together.
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

inline fs::path fsPath(const std::string& value)
{
	return fs::u8path(value);
}

// Return UTF-8 paths with portable forward separators on every platform.
inline String fsString(const fs::path& value);

bool cultureStringLess(const String& left, const String& right);

// std::vector with the handful of List<T> operations used by CppGen. A null
// flag is retained because translated optional lists compare against nullptr.
template<class T>
class List : public std::vector<T>
{
	bool null_{};

public:
	using std::vector<T>::vector;

	List(const std::vector<T>& other) : std::vector<T>(other) {}
	List(std::nullptr_t) : null_(true) {}
	int size() const noexcept
	{
		return static_cast<int>(std::vector<T>::size());
	}

	bool operator==(std::nullptr_t) const
	{
		return null_;
	}

	bool operator!=(std::nullptr_t) const
	{
		return !null_;
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

	void clear()
	{
		std::vector<T>::clear();
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

class String : public std::string
{
public:
	using std::string::string;
	String() = default;
	String(const std::string& value) : std::string(value) {}
	String(std::string&& value) : std::string(std::move(value)) {}
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
	std::stringstream stream(*this);
	std::string item;
	while (std::getline(stream, item, delimiter))
		result.add(item);

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
			result.add(substr(begin));
			break;
		}

		result.add(substr(begin, end - begin));
		begin = end + delimiter.size();
	}
	return result;
}

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
	{
		return value;
	}
	else if constexpr (std::is_same_v<ValueType, std::string>)
	{
		return String(value);
	}
	else if constexpr (std::is_same_v<ValueType, const char*> ||
					  std::is_same_v<ValueType, char*>)
	{
		return String(value);
	}
	else if constexpr (std::is_same_v<ValueType, char>)
	{
		return String(1, value);
	}
	else if constexpr (std::is_same_v<ValueType, bool>)
	{
		return value ? "True" : "False";
	}
	else if constexpr (std::is_floating_point_v<std::decay_t<T>>)
	{
		std::ostringstream stream;
		stream << std::setprecision(15) << value;
		return stream.str();
	}
	else if constexpr (std::is_enum_v<T>)
	{
		return std::to_string(static_cast<std::underlying_type_t<T>>(value));
	}
	else if constexpr (HasToString<T>::value)
	{
		return value.toString();
	}
	else
	{
		std::ostringstream stream;
		stream << value;
		return stream.str();
	}
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
	String result = toStringValue(left);
	result.reserve(result.size() + right.size());
	result.append(right);
	return result;
}

// Small immutable handle for frequently copied scope names. Unique strings are
// retained once, while ResolveScope copies only a pointer-sized handle.
class InternedString
{
	const String* value_{};

	static const String& intern(const String& value)
	{
		static std::unordered_map<std::string, std::unique_ptr<String>> values;
		auto found = values.find(value);
		if (found != values.end())
			return *found->second;

		auto stored = std::make_unique<String>(value);
		const String& result = *stored;
		values.emplace(value, std::move(stored));
		return result;
	}

public:
	InternedString() : value_(&intern("")) {}
	InternedString(const String& value) : value_(&intern(value)) {}
	InternedString(const char* value) : value_(&intern(value)) {}

	InternedString& operator=(const String& value)
	{
		value_ = &intern(value);
		return *this;
	}

	InternedString& operator=(const char* value)
	{
		value_ = &intern(value);
		return *this;
	}

	const String& get() const { return *value_; }
	operator const String&() const { return *value_; }
	String toString() const { return *value_; }

	bool operator==(const InternedString& other) const { return value_ == other.value_; }
	bool operator!=(const InternedString& other) const { return !(*this == other); }
	bool operator==(const String& other) const { return *value_ == other; }
	bool operator!=(const String& other) const { return !(*this == other); }
	bool operator==(const char* other) const { return *value_ == other; }
	bool operator!=(const char* other) const { return !(*this == other); }
};

// Dictionary that preserves C# insertion order and average O(1) lookup. The
// public key/value lists mirror Dictionary.Keys/Values.
template<class V>
class OrderedMap
{
	std::unordered_map<std::string, std::size_t> indices_;

public:
	List<String> keys;
	List<V> values;

	OrderedMap() = default;

	OrderedMap(std::initializer_list<std::pair<String, V>> values)
	{
		for (const auto& value : values)
			add(value.first, value.second);
	}

	bool containsKey(const String& key) const
	{
		return indices_.find(key) != indices_.end();
	}

	void add(const String& key, const V& value)
	{
		if (containsKey(key))
			throw std::runtime_error("Duplicate dictionary key: " + std::string(key));

		indices_[key] = values.size();
		keys.add(key);
		values.add(value);
	}

	V& operator[](const String& key)
	{
		auto found = indices_.find(key);
		if (found == indices_.end())
		{
			add(key, V{});
			found = indices_.find(key);
		}
		return values[found->second];
	}

	const V& operator[](const String& key) const
	{
		return values.at(indices_.at(key));
	}

	bool remove(const String& key)
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
		List<String> values{toStringValue(std::forward<Args>(args))...};
		for (std::size_t i = 0; i < static_cast<std::size_t>(values.size()); ++i)
			format = format.replace("{" + toStringValue(i) + "}", values[i]);

		std::cout << format << std::endl;
	}

	static String readLine()
	{
		std::string result;
		std::getline(std::cin, result);
		return result;
	}
};

struct Environment
{
	static void exit(int code)
	{
		std::exit(code);
	}

	static String getEnvironmentVariable(const String& name)
	{
#ifdef _MSC_VER
		char* value = nullptr;
		std::size_t length = 0;
		if (_dupenv_s(&value, &length, name.c_str()) != 0 || value == nullptr)
			return {};

		String result(value);
		std::free(value);
		return result;
#else
		const char* value = std::getenv(name.c_str());
		return value ? String(value) : String();
#endif
	}
};

struct Convert
{
	static int toInt32(const String& value)
	{
		return std::stoi(value);
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
			return toStringValue(number);
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
