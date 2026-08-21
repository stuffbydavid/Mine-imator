#include "CppGen.hpp"

namespace CppGen
{
void GML::parseGMLSpec(String file)
{
	String json = File::readAllText(file);
	Json root = JsonConvert::deserializeObject(json);

	// Keywords
	for (String keyword : root["keywords"])
		GML::keywords.add(keyword);

	// Integer constants
	for (Json constant : root["constants"])
	{
		Json constObj = root["constants"][constant.name];
		GML::constants[constant.name] = (double)constObj;
	}

	// Variables
	for (Json variable : root["variables"])
	{
		Json varObj = root["variables"][variable.name];
		GML::variables[variable.name] = makeObject<DataType>(toStringValue(varObj));
	}

	// Functions
	for (Json function : root["functions"])
	{
		Json funcObj = root["functions"][function.name];
		DataType* retType = makeObject<DataType>(toStringValue(funcObj["return"]));
		List<DataType*> argTypes = List<DataType*>();
		bool varArgs = false;
		bool needScope = false;
		bool varCreateRef = false;

		if (funcObj["varArgs"] != nullptr)
			varArgs = true;
		else
			for (String arg : funcObj["args"])
				argTypes.add(makeObject<DataType>(arg));

		if (funcObj["needScope"] != nullptr)
			needScope = true;

		if (funcObj["varCreateRef"] != nullptr)
			varCreateRef = true;

		GML::functions[function.name] = makeObject<FunctionSignature>(function.name, retType, argTypes, varArgs, needScope, varCreateRef);
	}
}

void GML::exportHeader(String file)
{
	DataType::ignoreAllVarType = true;
	CodeWriter::begin();
	CodeWriter::writeLine("#pragma once");
	CodeWriter::writeLine("#include \"Asset/Scope.hpp\"");
	CodeWriter::writeLine();
	CodeWriter::writeLine("#define withOne(type, id, otherId) \\" , 1);
	CodeWriter::writeLine("if (IntType _withSelfId = id) \\");
	CodeWriter::writeLine("if (IntType _withOtherId = otherId) \\");
	CodeWriter::writeLine("for (Scope<type> self(_withSelfId, _withOtherId); self.IsValid(); self.Clear())");
	CodeWriter::writeLine("", -1);
	CodeWriter::writeLine("#define withAll(type, otherId) \\", 1);
	CodeWriter::writeLine("if (IntType _withOtherId = otherId) \\");
	CodeWriter::writeLine("for (Scope<type> self(Object::GetAll(ID_##type), _withOtherId); self.IsValid(); self.NextObject())");
	CodeWriter::writeLine("", -1);
	CodeWriter::writeLine("namespace CppProject");
	CodeWriter::writeLine("{", 1);

	// Constants
	for (String constant : GML::constants.keys)
	{
		String val = toStringValue(GML::constants[constant]).replace(",", ".");
		if (!val.contains("."))
			val = "IntType(" + val + ")";
		CodeWriter::writeLine("#define " + CodeObject::nameToCpp(constant) + " " + val);
	}

	// Variables
	CodeWriter::writeLine();
	CodeWriter::writeLine("struct gmlGlobal");
	CodeWriter::writeLine("{", 1);
	for (String var : GML::variables.keys)
		if (!GML::keywords.contains(var) && var != "argument" && var != "argument_count")
			CodeWriter::writeLine("static " + GML::variables[var]->toCpp() + " " + CodeObject::nameToCpp(var) + ";");
	CodeWriter::writeLine("};", -1);

	// Functions
	CodeWriter::writeLine();
	for (FunctionSignature* funcSign : GML::functions.values)
	{
		CodeWriter::write(funcSign->returnType->toCpp() + " " + funcSign->name + "(");

		int p = 0;
		if (funcSign->needScope)
		{
			CodeWriter::write("ScopeAny");
			p++;
		}

		if (funcSign->varArgs)
		{
			if (p++ > 0)
				CodeWriter::write(", ");
			CodeWriter::write("VarArgs args = VarArgs()");
		}
		else
		{
			for (DataType* type : funcSign->argTypes)
			{
				if (p++ > 0)
					CodeWriter::write(", ");
				CodeWriter::write(type->toCpp());
			}
		}

		CodeWriter::writeLine(");");
	}

	CodeWriter::writeLine("}", -1);
	CodeWriter::end(file);
	DataType::ignoreAllVarType = false;
}

void GML::parseGMLScript(String file)
{
	String gml = File::readAllText(file);
	Function* currentFunction = nullptr;
	bool isMultilineComment = false;
	bool isLineComment = false;
	bool isCppSeparate = false;
	String cppSeparateHeader = "";
	const int gmlLength = static_cast<int>(gml.size());

	// Iterate characters and find tokens
	for (int pos = 0, line = 1, linePos = 0; pos < gmlLength;)
	{
		char currentChar = gml[pos];
		char nextChar = '\0';
		if (pos < gmlLength - 1)
			nextChar = gml[pos + 1];

		// Check comment end
		if (isMultilineComment && currentChar == '*' && nextChar == '/')
		{
			isMultilineComment = false;
			pos += 2;
			continue;
		}
		if (isLineComment && currentChar == '\n')
		{
			isLineComment = false;
			pos++;
			line++;
			GML::totalLines++;
			linePos = pos;
			continue;
		}

		// Check comment begin
		if (currentChar == '/')
		{
			if (nextChar == '/')
			{
				isLineComment = true;

				// Check for CppSeparate/CppOnly
				String cppSep = "/// CppSeparate";
				String cppOnly = "/// CppOnly";

				if (pos + cppSep.size() > gml.size())
				{
					pos++;
					continue;
				}

				if (gml.substring(pos, cppSep.size()) == cppSep)
				{
					isCppSeparate = true;
					pos += cppSep.size() + 1;
					cppSeparateHeader = gml.substring(pos, gml.indexOf("\n", pos) - pos).replace("\r", "");
					pos += cppSeparateHeader.size();
					continue;
				}

				else if (gml.substring(pos, cppOnly.size()) == cppOnly && currentFunction != nullptr)
				{
					pos += cppOnly.size() + 1;
					Token cppOnlyToken;
					cppOnlyToken.type = Token::Type::CppOnly;
					cppOnlyToken.value = gml.substring(pos, gml.indexOf("\n", pos) - pos).replace("\r", "");
					cppOnlyToken.fileOffset = pos;
					cppOnlyToken.line = line;
					cppOnlyToken.lineOffset = linePos;
					pos += cppOnlyToken.value.size();
					currentFunction->tokens.add(std::move(cppOnlyToken));
					continue;
				}
			}
			else if (nextChar == '*')
				isMultilineComment = true;
		}

		if (isMultilineComment || isLineComment)
		{
			pos++;
			continue;
		}

		// Whitespace never produces a token, so skip it before allocating.
		if (currentChar == ' ' || currentChar == '\r' || currentChar == '\t')
		{
			pos++;
			continue;
		}
		if (currentChar == '\n')
		{
			line++;
			GML::totalLines++;
			linePos = pos;
			pos++;
			continue;
		}

		Token::Type tokenType = Token::Type::Unknown;
		String tokenValue = "";
		int tokenLength = 1;
		bool isIdentifierStart = currentChar == '_' ||
			(currentChar >= 'a' && currentChar <= 'z') ||
			(currentChar >= 'A' && currentChar <= 'Z');
		bool isDigit = currentChar >= '0' && currentChar <= '9';

		if (isIdentifierStart)
		{
			int end = pos + 1;
			while (end < gmlLength)
			{
				char character = gml[end];
				bool isIdentifierCharacter = character == '_' ||
					(character >= 'a' && character <= 'z') ||
					(character >= 'A' && character <= 'Z') ||
					(character >= '0' && character <= '9');
				if (!isIdentifierCharacter)
					break;
				end++;
			}

			tokenType = Token::Type::ID;
			tokenLength = end - pos;
			tokenValue = gml.substring(pos, tokenLength);
		}
		else if (isDigit)
		{
			int end = pos + 1;
			while (end < gmlLength && gml[end] >= '0' && gml[end] <= '9')
				end++;

			// Match the original number grammar: digits, then an optional
			// fractional part, then an optional lowercase exponent.
			if (end + 1 < gmlLength && gml[end] == '.' &&
				gml[end + 1] >= '0' && gml[end + 1] <= '9')
			{
				end += 2;
				while (end < gmlLength && gml[end] >= '0' && gml[end] <= '9')
					end++;

				if (end < gmlLength && gml[end] == 'e')
				{
					int exponentEnd = end + 1;
					if (exponentEnd < gmlLength &&
						(gml[exponentEnd] == '-' || gml[exponentEnd] == '+'))
						exponentEnd++;

					int exponentDigits = exponentEnd;
					while (exponentEnd < gmlLength &&
						gml[exponentEnd] >= '0' && gml[exponentEnd] <= '9')
						exponentEnd++;
					if (exponentEnd > exponentDigits)
						end = exponentEnd;
				}
			}

			tokenType = Token::Type::Number;
			tokenLength = end - pos;
			tokenValue = gml.substring(pos, tokenLength);
		}
		else if (currentChar == '"')
		{
			int end = pos + 1;
			bool terminated = false;
			while (end < gmlLength)
			{
				if (gml[end] == '\\')
				{
					end += 2;
					continue;
				}
				if (gml[end] == '"')
				{
					end++;
					terminated = true;
					break;
				}
				end++;
			}

			if (!terminated)
			{
				Console::writeLine("FATAL ERROR in {0}:", file);
				Console::writeLine("  Invalid string at line {0}, {1}", line, pos - linePos);
				Environment::exit(1);
			}

			tokenType = Token::Type::String;
			tokenLength = end - pos;
			tokenValue = gml.substring(pos + 1, tokenLength - 2);
		}
		else
		{
			switch (currentChar)
			{
				case '{': tokenType = Token::Type::LeftBrace; break;
				case '}': tokenType = Token::Type::RightBrace; break;
				case '(': tokenType = Token::Type::LeftPar; break;
				case ')': tokenType = Token::Type::RightPar; break;
				case '[': tokenType = Token::Type::LeftSquare; break;
				case ']': tokenType = Token::Type::RightSquare; break;
				case ',': tokenType = Token::Type::Separator; break;
				case ';': tokenType = Token::Type::Terminator; break;
				case '.': tokenType = Token::Type::Member; break;
				case '=': tokenType = nextChar == '=' ? Token::Type::Equal : Token::Type::Assign; break;
				case '?': tokenType = Token::Type::Ternary; break;
				case ':': tokenType = Token::Type::Colon; break;
				case '!': tokenType = nextChar == '=' ? Token::Type::NotEqual : Token::Type::Inverse; break;
				case '&': tokenType = nextChar == '&' ? Token::Type::And : Token::Type::BitwiseAnd; break;
				case '|': tokenType = nextChar == '|' ? Token::Type::Or : Token::Type::BitwiseOr; break;
				case '>': tokenType = nextChar == '>' ? Token::Type::ShiftRight : (nextChar == '=' ? Token::Type::LargerEq : Token::Type::Larger); break;
				case '<': tokenType = nextChar == '>' ? Token::Type::NotEqual : (nextChar == '<' ? Token::Type::ShiftLeft : (nextChar == '=' ? Token::Type::LessEq : Token::Type::Less)); break;
				case '+': tokenType = nextChar == '+' ? Token::Type::AddShort : (nextChar == '=' ? Token::Type::AddLong : Token::Type::Add); break;
				case '-': tokenType = nextChar == '-' ? Token::Type::SubShort : (nextChar == '=' ? Token::Type::SubLong : Token::Type::Sub); break;
				case '*': tokenType = nextChar == '=' ? Token::Type::MulLong : Token::Type::Mul; break;
				case '/': tokenType = nextChar == '=' ? Token::Type::DivLong : Token::Type::Div; break;
				case '%': tokenType = Token::Type::Modulus; break;
				case '#': tokenType = Token::Type::HashTag; break;
				case '@': tokenType = Token::Type::ArrayRef; break;
				default:
					Console::writeLine("FATAL ERROR in {0}:", file);
					Console::writeLine("  Unexpected {0} token at line {1}, {2}", currentChar, line, pos - linePos);
					Environment::exit(1);
					break;
			}
		}

		Token token;
		token.type = tokenType;
		token.value = std::move(tokenValue);
		token.fileOffset = pos;
		token.line = line;
		token.lineOffset = linePos;
		token.length = tokenLength;
		if (token.type == Token::Type::String && !Program::strings.contains(token.value))
			Program::strings.add(token.value);

		// 2 letter tokens
		if (token.type == Token::Type::Equal ||
			token.type == Token::Type::NotEqual ||
			token.type == Token::Type::And ||
			token.type == Token::Type::Or ||
			token.type == Token::Type::LargerEq ||
			token.type == Token::Type::LessEq ||
			token.type == Token::Type::AddLong ||
			token.type == Token::Type::AddShort ||
			token.type == Token::Type::SubLong ||
			token.type == Token::Type::SubShort ||
			token.type == Token::Type::MulLong ||
			token.type == Token::Type::DivLong ||
			token.type == Token::Type::ShiftRight ||
			token.type == Token::Type::ShiftLeft)
			token.length = 2;

		if (token.type != Token::Type::Unknown)
		{
			if (token.type == Token::Type::ID)
			{
				// Start new function
				if (token.value == "function" && (currentFunction == nullptr || currentFunction->tokens[currentFunction->tokens.size() - 1].type != Token::Type::Assign))
				{
					currentFunction = makeObject<Function>("", gml, isCppSeparate, cppSeparateHeader);
					isCppSeparate = false;
				}

				// Get name of function
				else if (currentFunction->name == "")
				{
					currentFunction->name = token.value;
					Program::functions.add(token.value, currentFunction);
				}

				// Integer division
				else if (token.value == "div")
					token.type = Token::Type::DivInt;

				// Modulus
				else if (token.value == "mod")
					token.type = Token::Type::Modulus;
			}

			// . 45 -> .45
			if (token.type == Token::Type::Number && (currentFunction != nullptr && currentFunction->tokens[currentFunction->tokens.size() - 1].type == Token::Type::Member))
			{
				Token& lastToken = currentFunction->tokens[currentFunction->tokens.size() - 1];
				lastToken.type = Token::Type::Number;
				lastToken.value = "." + token.value;
				lastToken.length += token.length;
			}

			// Remove regions
			else if (token.type == Token::Type::ID && (token.value == "region" || token.value == "endregion") &&
					(currentFunction != nullptr && currentFunction->tokens[currentFunction->tokens.size() - 1].type == Token::Type::HashTag))
			{
				currentFunction->tokens.removeAt(currentFunction->tokens.size() - 1);
				isLineComment = true;
			}
			else
				currentFunction->tokens.add(std::move(token));
		}

		pos += token.length;
	}
}

GML::FunctionSignature::FunctionSignature(String name, DataType* returnType, List<DataType*> argTypes, bool varArgs, bool needScope, bool varCreateRef)
{
	this->name = name;
	this->returnType = returnType;
	this->argTypes = argTypes;
	this->varArgs = varArgs;
	this->needScope = needScope;
	this->varCreateRef = varCreateRef;
}

}
