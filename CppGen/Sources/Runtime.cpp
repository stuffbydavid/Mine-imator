#include "Runtime.hpp"

namespace CppGen
{
namespace
{
// Minimal recursive-descent parser for the JSON shapes used by gml.json and
// GameMaker .yy files. Object insertion order is preserved by OrderedMap.
class JsonParser
{
	const String& source_;
	int position_{};

	void skipWhitespace()
	{
		while (position_ < source_.size() &&
			   std::isspace(static_cast<unsigned char>(source_[position_])))
		{
			++position_;
		}
	}

	char peek()
	{
		skipWhitespace();
		return position_ < source_.size() ? source_[position_] : '\0';
	}

	void expect(char expected)
	{
		skipWhitespace();
		if (position_ >= source_.size() || source_[position_] != expected)
		{
			throw std::runtime_error(
				String("Invalid JSON near offset ") + position_ +
				", expected '" + expected + "', found '" +
				(position_ < source_.size() ? String(1, source_[position_]) : "EOF") +
				"'");
		}

		++position_;
	}

	String parseString()
	{
		expect('"');
		String result;

		while (position_ < source_.size())
		{
			const char current = source_[position_++];
			if (current == '"')
				return result;

			if (current != '\\')
			{
				result.push_back(current);
				continue;
			}

			if (position_ >= source_.size())
				break;

			const char escaped = source_[position_++];
			switch (escaped)
			{
				case '"':
					result.push_back('"');
					break;
				case '\\':
					result.push_back('\\');
					break;
				case '/':
					result.push_back('/');
					break;
				case 'b':
					result.push_back('\b');
					break;
				case 'f':
					result.push_back('\f');
					break;
				case 'n':
					result.push_back('\n');
					break;
				case 'r':
					result.push_back('\r');
					break;
				case 't':
					result.push_back('\t');
					break;
				case 'u':
				{
					if (position_ + 4 > source_.size())
						throw std::runtime_error("Truncated JSON unicode escape");

					const unsigned value = static_cast<unsigned>(
						std::stoul(source_.substr(position_, 4), nullptr, 16));
					position_ += 4;

					// CppGen's inputs only require Unicode values in the basic
					// multilingual plane, encoded here as one to three UTF-8 bytes.
					if (value <= 0x7f)
					{
						result.push_back(static_cast<char>(value));
					}
					else if (value <= 0x7ff)
					{
						result.push_back(static_cast<char>(0xc0 | (value >> 6)));
						result.push_back(static_cast<char>(0x80 | (value & 0x3f)));
					}
					else
					{
						result.push_back(static_cast<char>(0xe0 | (value >> 12)));
						result.push_back(static_cast<char>(0x80 | ((value >> 6) & 0x3f)));
						result.push_back(static_cast<char>(0x80 | (value & 0x3f)));
					}
					break;
				}
				default:
					throw std::runtime_error("Invalid JSON escape");
			}
		}

		throw std::runtime_error("Unterminated JSON string");
	}

	Json parseValue()
	{
		const char current = peek();
		if (current == '"')
		{
			Json result;
			result.kind = Json::Text;
			result.text = parseString();
			return result;
		}
		if (current == '{')
			return parseObject();
		if (current == '[')
			return parseArray();

		if (source_.compare(position_, 4, "true") == 0)
		{
			position_ += 4;
			Json result;
			result.kind = Json::Bool;
			result.boolean = true;
			return result;
		}
		if (source_.compare(position_, 5, "false") == 0)
		{
			position_ += 5;
			Json result;
			result.kind = Json::Bool;
			return result;
		}
		if (source_.compare(position_, 4, "null") == 0)
		{
			position_ += 4;
			return {};
		}

		const char* begin = source_.c_str() + position_;
		char* end = nullptr;
		const double number = std::strtod(begin, &end);
		if (end == begin)
		{
			throw std::runtime_error(
				"Invalid JSON value near offset " + std::to_string(position_));
		}

		position_ += static_cast<int>(end - begin);
		Json result;
		result.kind = Json::Number;
		result.number = number;
		return result;
	}

	Json parseArray()
	{
		Json result;
		result.kind = Json::Array;
		expect('[');

		if (peek() == ']')
		{
			++position_;
			return result;
		}

		while (true)
		{
			result.values.add(parseValue());
			const char next = peek();
			if (next == ']')
			{
				++position_;
				return result;
			}

			expect(',');
			// GameMaker files may contain a trailing comma.
			if (peek() == ']')
			{
				++position_;
				return result;
			}
		}
	}

	Json parseObject()
	{
		Json result;
		result.kind = Json::Object;
		expect('{');

		if (peek() == '}')
		{
			++position_;
			return result;
		}

		while (true)
		{
			const String key = parseString();
			expect(':');

			Json child = parseValue();
			child.name = key;
			result.object.add(key, child);
			result.values.add(child);

			const char next = peek();
			if (next == '}')
			{
				++position_;
				return result;
			}

			expect(',');
			// GameMaker files may contain a trailing comma.
			if (peek() == '}')
			{
				++position_;
				return result;
			}
		}
	}

public:
	explicit JsonParser(const String& source) : source_(source) {}

	Json parse()
	{
		Json result = parseValue();
		skipWhitespace();

		if (position_ != source_.size())
			throw std::runtime_error("Trailing JSON data");

		return result;
	}
};
} // namespace

Json JsonConvert::deserializeObject(const String& source)
{
	return JsonParser(source).parse();
}
} // namespace CppGen
