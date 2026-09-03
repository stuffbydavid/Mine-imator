#include "CppGen.hpp"

#include <array>
#include <cstdint>
#include <unordered_map>

namespace CppGen
{
namespace
{
constexpr std::uint32_t CacheMagic = 0x43475043; // CGPC
constexpr std::uint32_t CacheVersion = 7;
constexpr std::uint64_t MaxCacheFileSize = 128ull * 1024 * 1024;
constexpr std::uint32_t MaxCacheItems = 4 * 1024 * 1024;

void hashBytes(std::uint64_t& hash, const char* bytes, std::size_t size)
{
	for (std::size_t i = 0; i < size; i++)
	{
		hash ^= static_cast<unsigned char>(bytes[i]);
		hash *= 1099511628211ull;
	}
}

std::uint64_t hashData(const String& data)
{
	std::uint64_t hash = 1469598103934665603ull;
	hashBytes(hash, data.data(), data.size());
	return hash;
}

void hashFile(std::uint64_t& hash, const fs::path& path)
{
	const String pathName = fsString(path.lexically_normal());
	hashBytes(hash, pathName.data(), pathName.size());
	const char separator = '\0';
	hashBytes(hash, &separator, 1);

	std::ifstream stream(path, std::ios::binary);
	std::array<char, 64 * 1024> buffer;
	while (stream.good())
	{
		stream.read(buffer.data(), static_cast<std::streamsize>(buffer.size()));
		hashBytes(hash, buffer.data(), static_cast<std::size_t>(stream.gcount()));
	}
	hashBytes(hash, &separator, 1);
}

void collectFingerprintFiles(List<fs::path>& files, const fs::path& root, const List<String>& extensions)
{
	if (!fs::exists(root))
		return;

	for (const fs::directory_entry& entry : fs::recursive_directory_iterator(root))
		if (entry.is_regular_file() && extensions.contains(fsString(entry.path().extension())))
			files.add(entry.path());
}

template<class T>
void writeValue(std::ostream& stream, const T& value)
{
	stream.write(reinterpret_cast<const char*>(&value), sizeof(value));
}

template<class T>
bool readValue(std::istream& stream, T& value)
{
	stream.read(reinterpret_cast<char*>(&value), sizeof(value));
	return static_cast<bool>(stream);
}

void writeString(std::ostream& stream, const String& input)
{
	writeValue(stream, static_cast<std::uint64_t>(input.size()));
	stream.write(input.data(), static_cast<std::streamsize>(input.size()));
}

bool readString(std::istream& stream, String& output)
{
	std::uint64_t size{};
	if (!readValue(stream, size) || size > MaxCacheFileSize)
		return false;
	output.resize(static_cast<std::size_t>(size));
	stream.read(output.data(), static_cast<std::streamsize>(size));
	return static_cast<bool>(stream);
}

void writeStringIdTable(std::ostream& stream)
{
	const List<String> values = StringId::allValues();
	writeValue(stream, static_cast<std::uint32_t>(values.size()));
	for (const String& value : values)
		writeString(stream, value);
}

bool readStringIdTable(std::istream& stream, List<StringId>& values)
{
	std::uint32_t count{};
	if (!readValue(stream, count) || count == 0 || count > MaxCacheItems)
		return false;

	values.clear();
	values.reserve(count);
	for (std::uint32_t i = 0; i < count; i++)
	{
		String value;
		if (!readString(stream, value))
			return false;
		values.add(StringId(value));
	}
	return true;
}

void writeGmlStrings(std::ostream& stream)
{
	writeValue(stream, static_cast<std::uint32_t>(Program::strings.size()));
	for (StringId value : Program::strings)
		writeString(stream, String(value));
}

bool readGmlStrings(std::istream& stream, List<String>& values)
{
	std::uint32_t count{};
	if (!readValue(stream, count) || count > MaxCacheItems)
		return false;

	values.clear();
	values.reserve(count);
	for (std::uint32_t i = 0; i < count; i++)
	{
		String value;
		if (!readString(stream, value) || values.contains(value))
			return false;
		values.add(std::move(value));
	}
	return true;
}

void mergeGmlStrings(const List<String>& cachedValues)
{
	List<String> parsedValues;
	parsedValues.reserve(Program::strings.size());
	for (StringId value : Program::strings)
		parsedValues.add(String(value));

	Program::strings.clear();
	for (const String& value : cachedValues)
		Program::strings.add(StringId(value));
	for (const String& value : parsedValues)
		if (!cachedValues.contains(value))
			Program::strings.add(StringId(value));
}

std::int64_t gmlTimestamp(const String& file)
{
	std::error_code error;
	const fs::file_time_type timestamp = fs::last_write_time(fsPath(file), error);
	return error ?
		std::numeric_limits<std::int64_t>::min() :
		static_cast<std::int64_t>(timestamp.time_since_epoch().count());
}

void writeGmlTimestamps(std::ostream& stream)
{
	writeValue(stream, static_cast<std::uint32_t>(Program::scripts.size()));
	for (Script* script : Program::scripts.values)
	{
		writeString(stream, script->filename);
		writeValue(stream, gmlTimestamp(script->filename));
	}
}

bool readGmlTimestamps(std::istream& stream, List<String>& modifiedFiles)
{
	std::uint32_t count{};
	if (!readValue(stream, count) || count != Program::scripts.size())
		return false;

	OrderedMap<std::int64_t> timestamps;
	for (std::uint32_t i = 0; i < count; i++)
	{
		String filename;
		std::int64_t timestamp{};
		if (!readString(stream, filename) || !readValue(stream, timestamp) || timestamps.containsKey(filename))
			return false;
		timestamps.add(filename, timestamp);
	}

	for (Script* script : Program::scripts.values)
	{
		if (!timestamps.containsKey(script->filename))
			return false;
		if (timestamps[script->filename] != gmlTimestamp(script->filename))
			modifiedFiles.add(script->filename);
	}
	return true;
}

class CacheWriter
{
	std::ostream& stream_;

public:
	std::unordered_map<const Variable*, std::uint32_t> variableIds;

	CacheWriter(std::ostream& stream) : stream_(stream) {}

	template<class T>
	void value(const T& input) { writeValue(stream_, input); }
	void bytes(const String& input) { stream_.write(input.data(), static_cast<std::streamsize>(input.size())); }

	void boolean(bool input) { value(static_cast<std::uint8_t>(input)); }
	void stringId(StringId input) { value(static_cast<std::int32_t>(input.id())); }

	void dataType(const DataType& input)
	{
		value(static_cast<std::uint32_t>(input.assignments.size()));
		for (const DataType::Assignment& assignment : input.assignments)
		{
			value(static_cast<std::int32_t>(assignment.rawType));
			stringId(assignment.refId);
			boolean(assignment.containerStorage != nullptr);
			if (assignment.containerStorage != nullptr)
				dataType(*assignment.containerStorage);
		}
	}

	void location(const Statement::Location& input)
	{
		value(static_cast<std::uint32_t>(input.path.size()));
		for (int part : input.path)
			value(static_cast<std::int32_t>(part));
		value(static_cast<std::int32_t>(input.level));
		value(static_cast<std::int32_t>(input.nextId));
	}

	void variable(const Variable* input)
	{
		stringId(input->scope);
		stringId(input->name);
		dataType(*input->type);
		value(static_cast<std::int32_t>(input->line));
		location(input->location);
		boolean(input->isReference);
	}

	void declarationList(DeclarationList* input)
	{
		for (Declaration* declaration : input->declarations)
		{
			boolean(declaration->isReference);
			if (declaration->expr != nullptr)
				expression(declaration->expr);
		}
	}

	void expression(Expression* input)
	{
		dataType(*input->resolvedType);
		value(static_cast<std::int32_t>(input->resolvedTypeCpp));
		const auto found = variableIds.find(input->assignedTo);
		value(found == variableIds.end() ? 0u : found->second + 1u);

		switch (input->type)
		{
			case Expression::Type::Parenthesis:
				expression(static_cast<ExpressionParenthesis*>(input)->expr);
				break;
			case Expression::Type::UnaryOperation:
				expression(static_cast<UnaryOperation*>(input)->expr);
				break;
			case Expression::Type::BinaryOperation:
			{
				BinaryOperation* operation = static_cast<BinaryOperation*>(input);
				expression(operation->left);
				expression(operation->right);
				break;
			}
			case Expression::Type::TernaryCondition:
			{
				TernaryCondition* condition = static_cast<TernaryCondition*>(input);
				expression(condition->expr1);
				expression(condition->expr2);
				expression(condition->expr3);
				break;
			}
			case Expression::Type::Array:
				for (Expression* expressionValue : static_cast<ExpressionArray*>(input)->expressions)
					expression(expressionValue);
				break;
			case Expression::Type::Value:
			{
				ExpressionValue* valueExpression = static_cast<ExpressionValue*>(input);
				boolean(valueExpression->valueHasDecimal);
				boolean(valueExpression->knowValueHasDecimal);
				break;
			}
			case Expression::Type::Accessor:
			{
				Accessor* accessor = static_cast<Accessor*>(input);
				boolean(accessor->assignExpr != nullptr);
				boolean(accessor->needLtZero);
				boolean(accessor->appToId);
				for (Accessor::ArrayAccessor* arrayAccessor : accessor->arrayAccessors)
					expression(arrayAccessor->expr);
				if (accessor->callParameters != nullptr)
					for (Expression* parameter : accessor->callParameters)
						expression(parameter);
				if (accessor->nextInChain != nullptr)
					expression(accessor->nextInChain);
				break;
			}
			case Expression::Type::New:
				expression(static_cast<NewExpression*>(input)->acc);
				break;
		}
	}

	void statement(Statement* input)
	{
		switch (input->type)
		{
			case Statement::Type::DeclarationList:
				declarationList(static_cast<DeclarationList*>(input));
				break;
			case Statement::Type::StatementList:
				for (Statement* statementValue : static_cast<StatementList*>(input)->statements)
					statement(statementValue);
				break;
			case Statement::Type::Declare:
				declarationList(static_cast<DeclareStatement*>(input)->declarations);
				break;
			case Statement::Type::Macro:
				expression(static_cast<MacroStatement*>(input)->expr);
				break;
			case Statement::Type::Enum:
				declarationList(static_cast<EnumStatement*>(input)->declarations);
				break;
			case Statement::Type::Call:
				expression(static_cast<CallStatement*>(input)->acc);
				break;
			case Statement::Type::Assign:
			{
				AssignStatement* assignment = static_cast<AssignStatement*>(input);
				expression(assignment->target);
				if (assignment->expr != nullptr)
					expression(assignment->expr);
				break;
			}
			case Statement::Type::If:
			{
				IfStatement* statementValue = static_cast<IfStatement*>(input);
				expression(statementValue->condition);
				statement(statementValue->statement);
				if (statementValue->elseStatement != nullptr)
					statement(statementValue->elseStatement);
				break;
			}
			case Statement::Type::While:
			{
				WhileStatement* statementValue = static_cast<WhileStatement*>(input);
				expression(statementValue->loopCondition);
				statement(statementValue->statement);
				break;
			}
			case Statement::Type::DoUntil:
			{
				DoUntilStatement* statementValue = static_cast<DoUntilStatement*>(input);
				statement(statementValue->statement);
				expression(statementValue->breakCondition);
				break;
			}
			case Statement::Type::For:
			{
				ForStatement* statementValue = static_cast<ForStatement*>(input);
				if (statementValue->initStatement != nullptr)
					statement(statementValue->initStatement);
				if (statementValue->loopCondition != nullptr)
					expression(statementValue->loopCondition);
				if (statementValue->incStatement != nullptr)
					statement(statementValue->incStatement);
				statement(statementValue->statement);
				break;
			}
			case Statement::Type::Repeat:
			{
				RepeatStatement* statementValue = static_cast<RepeatStatement*>(input);
				expression(statementValue->expr);
				statement(statementValue->statement);
				break;
			}
			case Statement::Type::With:
			{
				WithStatement* statementValue = static_cast<WithStatement*>(input);
				value(static_cast<std::uint32_t>(statementValue->otherScopes.size()));
				for (StringId scope : statementValue->otherScopes)
					stringId(scope);
				stringId(statementValue->otherScope);
				expression(statementValue->expr);
				statement(statementValue->statement);
				break;
			}
			case Statement::Type::Switch:
			{
				SwitchStatement* statementValue = static_cast<SwitchStatement*>(input);
				dataType(*statementValue->caseResolvedType);
				expression(statementValue->expr);
				for (SwitchStatement::Case* caseValue : statementValue->cases)
				{
					expression(caseValue->expr);
					statement(caseValue->statements);
				}
				if (statementValue->defaultStatements != nullptr)
					statement(statementValue->defaultStatements);
				break;
			}
			case Statement::Type::Return:
			{
				ReturnStatement* statementValue = static_cast<ReturnStatement*>(input);
				if (statementValue->expr != nullptr)
					expression(statementValue->expr);
				break;
			}
			case Statement::Type::Delete:
				expression(static_cast<DeleteStatement*>(input)->expr);
				break;
			case Statement::Type::Break:
			case Statement::Type::Continue:
			case Statement::Type::CustomCpp:
				break;
		}
	}

	void function(Function* input)
	{
		stringId(input->name);
		dataType(*input->returnType);
		boolean(input->endsWithReturnStatement);
		boolean(input->hasInstanceVars);
		boolean(input->isUnused);
		value(static_cast<std::uint32_t>(input->scopeAssignments.size()));
		for (Function::ScopeAssignment* assignment : input->scopeAssignments)
			stringId(assignment->scope);
		value(static_cast<std::uint32_t>(input->varArgsRequiredNames.size()));
		for (StringId name : input->varArgsRequiredNames)
			stringId(name);
		if (input->args != nullptr)
			declarationList(input->args);
		statement(input->statements);
	}
};

class CacheReader
{
	std::istream& stream_;
	const List<StringId>& stringIds_;

public:
	bool valid = true;
	List<Variable*> variables;

	CacheReader(std::istream& stream, const List<StringId>& stringIds) : stream_(stream), stringIds_(stringIds) {}

	template<class T>
	T value()
	{
		T output{};
		if (valid && !readValue(stream_, output))
			valid = false;
		return output;
	}

	String bytes(std::uint64_t size)
	{
		String output;
		if (size > MaxCacheFileSize)
		{
			valid = false;
			return output;
		}
		output.resize(static_cast<std::size_t>(size));
		if (valid)
			stream_.read(output.data(), static_cast<std::streamsize>(size));
		if (!stream_)
			valid = false;
		return output;
	}

	bool boolean() { return value<std::uint8_t>() != 0; }
	StringId stringId()
	{
		const std::int32_t id = value<std::int32_t>();
		if (id < 0 || id >= static_cast<std::int32_t>(stringIds_.size()))
		{
			valid = false;
			return StringId();
		}
		return stringIds_[id];
	}

	bool count(std::uint32_t& output)
	{
		output = value<std::uint32_t>();
		if (output > MaxCacheItems)
			valid = false;
		return valid;
	}

	DataType dataType()
	{
		DataType output;
		std::uint32_t assignmentCount{};
		if (!count(assignmentCount))
			return output;

		output.assignments.clear();
		for (std::uint32_t i = 0; i < assignmentCount && valid; i++)
		{
			const auto rawType = static_cast<DataType::Type>(value<std::int32_t>());
			const StringId refId = stringId();
			const bool hasContainer = boolean();
			std::optional<DataType> container;
			if (hasContainer)
				container.emplace(dataType());
			output.assignments.emplace_back(rawType, refId, container ? &*container : nullptr);
		}
		output.updateCppType();
		return output;
	}

	Statement::Location location()
	{
		Statement::Location output;
		std::uint32_t pathCount{};
		if (!count(pathCount))
			return output;
		output.path.clear();
		output.path.reserve(pathCount);
		for (std::uint32_t i = 0; i < pathCount; i++)
			output.path.add(value<std::int32_t>());
		output.level = value<std::int32_t>();
		output.nextId = value<std::int32_t>();
		return output;
	}

	Variable* variable()
	{
		const StringId scope = stringId();
		const StringId name = stringId();
		DataType type = dataType();
		const int line = value<std::int32_t>();
		const Statement::Location sourceLocation = location();
		const bool isReference = boolean();
		if (!valid)
			return nullptr;

		Variable* output = makeObject<Variable>(scope, name, type, line, sourceLocation);
		output->isReference = isReference;
		variables.add(output);
		return output;
	}

	bool discardVariable()
	{
		(void)stringId();
		(void)stringId();
		(void)dataType();
		(void)value<std::int32_t>();
		(void)location();
		(void)boolean();
		variables.add(nullptr);
		return valid;
	}

	bool variableMap(OrderedMap<Variable*>& output)
	{
		std::uint32_t variableCount{};
		if (!count(variableCount))
			return false;
		for (std::uint32_t i = 0; i < variableCount && valid; i++)
		{
			Variable* variableValue = variable();
			if (variableValue == nullptr || output.containsKey(variableValue->name))
			{
				valid = false;
				break;
			}
			output.add(variableValue->name, variableValue);
		}
		return valid;
	}

	bool declarationList(DeclarationList* input)
	{
		for (Declaration* declaration : input->declarations)
		{
			declaration->isReference = boolean();
			if (declaration->expr != nullptr && !expression(declaration->expr))
				return false;
		}
		return valid;
	}

	bool expression(Expression* input)
	{
		input->resolvedTypeStorage.reset(dataType());
		input->resolvedType = &input->resolvedTypeStorage;
		input->resolvedTypeCpp = static_cast<DataType::CppType>(value<std::int32_t>());
		const std::uint32_t variableId = value<std::uint32_t>();
		if (variableId > static_cast<std::uint32_t>(variables.size()))
			valid = false;
		input->assignedTo = (variableId == 0 || !valid) ? nullptr : variables[variableId - 1];

		switch (input->type)
		{
			case Expression::Type::Parenthesis:
				return expression(static_cast<ExpressionParenthesis*>(input)->expr);
			case Expression::Type::UnaryOperation:
				return expression(static_cast<UnaryOperation*>(input)->expr);
			case Expression::Type::BinaryOperation:
			{
				BinaryOperation* operation = static_cast<BinaryOperation*>(input);
				return expression(operation->left) && expression(operation->right);
			}
			case Expression::Type::TernaryCondition:
			{
				TernaryCondition* condition = static_cast<TernaryCondition*>(input);
				return expression(condition->expr1) && expression(condition->expr2) && expression(condition->expr3);
			}
			case Expression::Type::Array:
				for (Expression* expressionValue : static_cast<ExpressionArray*>(input)->expressions)
					if (!expression(expressionValue))
						return false;
				break;
			case Expression::Type::Value:
			{
				ExpressionValue* valueExpression = static_cast<ExpressionValue*>(input);
				valueExpression->valueHasDecimal = boolean();
				valueExpression->knowValueHasDecimal = boolean();
				break;
			}
			case Expression::Type::Accessor:
			{
				Accessor* accessor = static_cast<Accessor*>(input);
				accessor->assignExpr = boolean() ? accessor : nullptr;
				accessor->needLtZero = boolean();
				accessor->appToId = boolean();
				for (Accessor::ArrayAccessor* arrayAccessor : accessor->arrayAccessors)
					if (!expression(arrayAccessor->expr))
						return false;
				if (accessor->callParameters != nullptr)
					for (Expression* parameter : accessor->callParameters)
						if (!expression(parameter))
							return false;
				if (accessor->nextInChain != nullptr)
					return expression(accessor->nextInChain);
				break;
			}
			case Expression::Type::New:
				return expression(static_cast<NewExpression*>(input)->acc);
		}
		return valid;
	}

	bool statement(Statement* input)
	{
		switch (input->type)
		{
			case Statement::Type::DeclarationList:
				return declarationList(static_cast<DeclarationList*>(input));
			case Statement::Type::StatementList:
				for (Statement* statementValue : static_cast<StatementList*>(input)->statements)
					if (!statement(statementValue))
						return false;
				break;
			case Statement::Type::Declare:
				return declarationList(static_cast<DeclareStatement*>(input)->declarations);
			case Statement::Type::Macro:
				return expression(static_cast<MacroStatement*>(input)->expr);
			case Statement::Type::Enum:
				return declarationList(static_cast<EnumStatement*>(input)->declarations);
			case Statement::Type::Call:
				return expression(static_cast<CallStatement*>(input)->acc);
			case Statement::Type::Assign:
			{
				AssignStatement* assignment = static_cast<AssignStatement*>(input);
				return expression(assignment->target) && (assignment->expr == nullptr || expression(assignment->expr));
			}
			case Statement::Type::If:
			{
				IfStatement* statementValue = static_cast<IfStatement*>(input);
				return expression(statementValue->condition) && statement(statementValue->statement) &&
					(statementValue->elseStatement == nullptr || statement(statementValue->elseStatement));
			}
			case Statement::Type::While:
			{
				WhileStatement* statementValue = static_cast<WhileStatement*>(input);
				return expression(statementValue->loopCondition) && statement(statementValue->statement);
			}
			case Statement::Type::DoUntil:
			{
				DoUntilStatement* statementValue = static_cast<DoUntilStatement*>(input);
				return statement(statementValue->statement) && expression(statementValue->breakCondition);
			}
			case Statement::Type::For:
			{
				ForStatement* statementValue = static_cast<ForStatement*>(input);
				return (statementValue->initStatement == nullptr || statement(statementValue->initStatement)) &&
					(statementValue->loopCondition == nullptr || expression(statementValue->loopCondition)) &&
					(statementValue->incStatement == nullptr || statement(statementValue->incStatement)) &&
					statement(statementValue->statement);
			}
			case Statement::Type::Repeat:
			{
				RepeatStatement* statementValue = static_cast<RepeatStatement*>(input);
				return expression(statementValue->expr) && statement(statementValue->statement);
			}
			case Statement::Type::With:
			{
				WithStatement* statementValue = static_cast<WithStatement*>(input);
				std::uint32_t scopeCount{};
				if (!count(scopeCount))
					return false;
				statementValue->otherScopes.clear();
				for (std::uint32_t i = 0; i < scopeCount; i++)
					statementValue->otherScopes.add(stringId());
				statementValue->otherScope = stringId();
				return expression(statementValue->expr) && statement(statementValue->statement);
			}
			case Statement::Type::Switch:
			{
				SwitchStatement* statementValue = static_cast<SwitchStatement*>(input);
				statementValue->caseResolvedTypeStorage.reset(dataType());
				statementValue->caseResolvedType = &statementValue->caseResolvedTypeStorage;
				if (!expression(statementValue->expr))
					return false;
				for (SwitchStatement::Case* caseValue : statementValue->cases)
					if (!expression(caseValue->expr) || !statement(caseValue->statements))
						return false;
				return statementValue->defaultStatements == nullptr || statement(statementValue->defaultStatements);
			}
			case Statement::Type::Return:
			{
				ReturnStatement* statementValue = static_cast<ReturnStatement*>(input);
				return statementValue->expr == nullptr || expression(statementValue->expr);
			}
			case Statement::Type::Delete:
				return expression(static_cast<DeleteStatement*>(input)->expr);
			case Statement::Type::Break:
			case Statement::Type::Continue:
			case Statement::Type::CustomCpp:
				break;
		}
		return valid;
	}

	bool function(Function* input)
	{
		if (stringId() != input->name)
			return valid = false;
		input->returnTypeStorage.reset(dataType());
		input->returnType = &input->returnTypeStorage;
		input->endsWithReturnStatement = boolean();
		input->hasInstanceVars = boolean();
		input->isUnused = boolean();

		std::uint32_t assignmentCount{};
		if (!count(assignmentCount))
			return false;
		input->scopeAssignments.clear();
		for (std::uint32_t i = 0; i < assignmentCount; i++)
			input->scopeAssignments.add(makeObject<Function::ScopeAssignment>(stringId(), nullptr, 0));

		std::uint32_t requiredCount{};
		if (!count(requiredCount))
			return false;
		input->varArgsRequiredNames.clear();
		for (std::uint32_t i = 0; i < requiredCount; i++)
			input->varArgsRequiredNames.add(stringId());

		return (input->args == nullptr || declarationList(input->args)) && statement(input->statements);
	}

	bool functionState(Function* input, bool apply)
	{
		const String payload = bytes(value<std::uint64_t>());
		if (!valid || !apply)
		{
			if (!valid)
				return false;
			std::istringstream stream(payload, std::ios::binary);
			CacheReader reader(stream, stringIds_);
			(void)reader.stringId();
			input->returnTypeStorage.reset(reader.dataType());
			input->returnType = &input->returnTypeStorage;
			input->endsWithReturnStatement = reader.boolean();
			input->hasInstanceVars = reader.boolean();
			input->isUnused = reader.boolean();
			std::uint32_t assignmentCount{};
			if (!reader.count(assignmentCount))
				return valid = false;
			for (std::uint32_t i = 0; i < assignmentCount; i++)
				input->scopeAssignments.add(makeObject<Function::ScopeAssignment>(reader.stringId(), nullptr, 0));
			return valid = reader.valid;
		}

		std::istringstream stream(payload, std::ios::binary);
		CacheReader reader(stream, stringIds_);
		reader.variables = variables;
		if (!reader.function(input) || stream.peek() != std::char_traits<char>::eof())
			valid = false;
		return valid;
	}
};

List<Function*> functionsForCache()
{
	List<Function*> output;
	for (Function* function : Program::functions.values)
		output.add(function);
	for (Object* object : Program::objects.values)
		for (Function* function : object->instanceFunctions.values)
			if (!output.contains(function))
				output.add(function);
	return output;
}

void writeVariableMap(CacheWriter& writer, const OrderedMap<Variable*>& variables)
{
	writer.value(static_cast<std::uint32_t>(variables.size()));
	for (Variable* variable : variables.values)
		writer.variable(variable);
}

void writeVariableList(CacheWriter& writer, const List<Variable*>& variables)
{
	writer.value(static_cast<std::uint32_t>(variables.size()));
	for (Variable* variable : variables)
		writer.variable(variable);
}

bool readVariableMap(CacheReader& reader, OrderedMap<Variable*>& variables)
{
	return reader.variableMap(variables);
}

bool readVariableList(CacheReader& reader, List<Variable*>& variables, bool load, bool argumentsOnly = false)
{
	std::uint32_t variableCount{};
	if (!reader.count(variableCount))
		return false;
	for (std::uint32_t i = 0; i < variableCount && reader.valid; i++)
	{
		if (!load)
		{
			if (!reader.discardVariable())
				return false;
		}
		else
		{
			Variable* variable = reader.variable();
			if (variable == nullptr)
				return false;
			if (!argumentsOnly || variable->line == 0)
				variables.add(variable);
		}
	}
	return reader.valid;
}

void collectVariableIds(CacheWriter& writer, const List<Function*>& functions)
{
	std::uint32_t nextId = 0;
	auto addMap = [&](const OrderedMap<Variable*>& variables)
	{
		for (Variable* variable : variables.values)
			writer.variableIds.emplace(variable, nextId++);
	};
	auto addList = [&](const List<Variable*>& variables)
	{
		for (Variable* variable : variables)
			writer.variableIds.emplace(variable, nextId++);
	};

	addMap(Program::globalVars);
	addMap(Program::unknownScopeVars);
	for (Object* object : Program::objects.values)
		addMap(object->instanceVars);
	for (Function* function : functions)
		addList(function->vars);
}

void saveResolverState(CacheWriter& writer)
{
	const List<Function*> functions = functionsForCache();
	collectVariableIds(writer, functions);

	writeVariableMap(writer, Program::globalVars);
	writeVariableMap(writer, Program::unknownScopeVars);
	writer.value(static_cast<std::uint32_t>(Program::objects.size()));
	for (Object* object : Program::objects.values)
	{
		writer.stringId(object->name);
		writeVariableMap(writer, object->instanceVars);
	}
	writer.value(static_cast<std::uint32_t>(functions.size()));
	for (Function* function : functions)
	{
		writer.stringId(function->name);
		writeVariableList(writer, function->vars);
	}

	for (Function* function : functions)
	{
		std::ostringstream stream(std::ios::binary);
		CacheWriter functionWriter(stream);
		functionWriter.variableIds = writer.variableIds;
		functionWriter.function(function);
		const String payload = stream.str();
		writer.value(static_cast<std::uint64_t>(payload.size()));
		writer.bytes(payload);
	}
	for (MacroStatement* macro : Program::macros.values)
		writer.expression(macro->expr);
	for (EnumStatement* enumValue : Program::enums.values)
		writer.declarationList(enumValue->declarations);
}

bool loadResolverState(CacheReader& reader, const List<String>& modifiedGmlFiles)
{
	const List<Function*> functions = functionsForCache();
	Program::globalVars.clear();
	Program::unknownScopeVars.clear();
	for (Object* object : Program::objects.values)
		object->instanceVars.clear();
	for (Function* function : functions)
	{
		function->vars.clear();
		function->scopeAssignments.clear();
		function->varArgsRequiredNames.clear();
	}
	Variable::totalVariables = 0;
	Variable::variantVariables = 0;

	if (!readVariableMap(reader, Program::globalVars) || !readVariableMap(reader, Program::unknownScopeVars))
		return false;

	std::uint32_t objectCount{};
	if (!reader.count(objectCount) || objectCount != Program::objects.size())
		return false;
	for (Object* object : Program::objects.values)
	{
		if (reader.stringId() != object->name || !readVariableMap(reader, object->instanceVars))
			return false;
	}

	std::uint32_t functionCount{};
	if (!reader.count(functionCount) || functionCount != static_cast<std::uint32_t>(functions.size()))
		return false;
	for (Function* function : functions)
	{
		const bool modified = function->sourceFile != "" && modifiedGmlFiles.contains(function->sourceFile);
		if (reader.stringId() != function->name || !readVariableList(reader, function->vars, true, modified))
			return false;
	}

	for (Function* function : functions)
		if (!reader.functionState(function, function->sourceFile == "" || !modifiedGmlFiles.contains(function->sourceFile)))
			return false;
	for (MacroStatement* macro : Program::macros.values)
		if (!reader.expression(macro->expr))
			return false;
	for (EnumStatement* enumValue : Program::enums.values)
		if (!reader.declarationList(enumValue->declarations))
			return false;

	return reader.valid;
}
}

String Program::getCacheFingerprint(const String& repoRootDir, const String& gmDir, const String& gmlSpecFile)
{
	List<fs::path> files;
	collectFingerprintFiles(files, fsPath(gmDir), { ".yy", ".yyp" });
	collectFingerprintFiles(files, fsPath(gmDir + "/objects"), { ".gml" });
	collectFingerprintFiles(files, fsPath(repoRootDir + "/CppGen/Sources"), { ".cpp", ".hpp" });
	files.add(fsPath(gmlSpecFile));
	files.sort();

	std::uint64_t hash = 1469598103934665603ull;
	for (const fs::path& file : files)
		hashFile(hash, file);

	std::ostringstream output;
	output << std::hex << hash;
	return output.str();
}

bool Program::loadResolverCache(const String& cacheFile, const String& fingerprint, List<String>& modifiedGmlFiles)
{
	std::ifstream stream(fsPath(cacheFile), std::ios::binary);
	if (!stream)
		return false;

	std::uint32_t magic{}, version{};
	String cachedFingerprint;
	List<StringId> cachedStringIds;
	List<String> cachedGmlStrings;
	std::uint64_t payloadSize{}, payloadHash{};
	if (!readValue(stream, magic) || !readValue(stream, version) || !readString(stream, cachedFingerprint) ||
		magic != CacheMagic || version != CacheVersion)
		return false;
	
	if (cachedFingerprint != fingerprint)
		return false;

	if (!readStringIdTable(stream, cachedStringIds))
		return false;

	if (!readGmlStrings(stream, cachedGmlStrings))
		return false;
	
	if (!readGmlTimestamps(stream, modifiedGmlFiles))
		return false;
	
	if (!readValue(stream, payloadSize) || !readValue(stream, payloadHash))
		return false;

	if (payloadSize == 0 || payloadSize > MaxCacheFileSize)
		return false;

	String payload(static_cast<std::size_t>(payloadSize), '\0');
	stream.read(payload.data(), static_cast<std::streamsize>(payloadSize));
	if (!stream || hashData(payload) != payloadHash)
		return false;

	mergeGmlStrings(cachedGmlStrings);
	std::istringstream payloadStream(payload, std::ios::binary);
	CacheReader reader(payloadStream, cachedStringIds);
	if (!loadResolverState(reader, modifiedGmlFiles) || payloadStream.peek() != std::char_traits<char>::eof())
		return false;

	Console::writeLine("Loaded resolved classes and types from cache");
	return true;
}

bool Program::saveResolverCache(const String& cacheFile, const String& fingerprint)
{
	std::ostringstream payloadStream(std::ios::binary);
	CacheWriter writer(payloadStream);
	saveResolverState(writer);
	const String payload = payloadStream.str();
	if (!payloadStream || payload.empty() || static_cast<std::uint64_t>(payload.size()) > MaxCacheFileSize)
	{
		Console::writeLine("WARNING: Resolver cache is too large to save");
		return false;
	}

	std::ofstream stream(fsPath(cacheFile), std::ios::binary | std::ios::trunc);
	if (!stream)
	{
		Console::writeLine("WARNING: Could not write resolver cache {0}", cacheFile);
		return false;
	}

	writeValue(stream, CacheMagic);
	writeValue(stream, CacheVersion);
	writeString(stream, fingerprint);
	writeStringIdTable(stream);
	writeGmlStrings(stream);
	writeGmlTimestamps(stream);
	writeValue(stream, static_cast<std::uint64_t>(payload.size()));
	writeValue(stream, hashData(payload));
	stream.write(payload.data(), static_cast<std::streamsize>(payload.size()));

	if (!stream)
	{
		Console::writeLine("WARNING: Could not finish writing resolver cache {0}", cacheFile);
		return false;
	}
	return true;
}
}
