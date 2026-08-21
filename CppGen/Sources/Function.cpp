#include "CppGen.hpp"

namespace CppGen
{
Function::Function(String name, String gml, bool isCppSeparate, String cppSeparateHeader)
{
	this->name = name;
	this->gml = gml;
	this->isCppSeparate = isCppSeparate;

	if (this->isCppSeparate)
	{
		this->cppSeparateHeader = cppSeparateHeader;

		List<String> words = this->cppSeparateHeader.substring(0, this->cppSeparateHeader.indexOf("(")).split(" ");
		String type = "";
		for (int i = 0; i < static_cast<int>(words.size()) - 1; i++)
			type += (i > 0 ? " " : "") + words[i];
		this->cppSeparateReturnTypeStorage = DataType(type);
		this->cppSeparateReturnType = &this->cppSeparateReturnTypeStorage;

		this->varArgs = this->cppSeparateHeader.contains("VarArgs");
	}

	if (this->gml == "")
	{
		this->statements = makeObject<StatementList>(1);
		this->statements->func = this;
	}
}

String Function::getScope()
{
	if (this->structObject != nullptr)
		return this->structObject->name;


	if (this->scopeAssignments.size() == 0)
		return this->hasInstanceVars ? "any" : "global";

	if (this->scopeAssignments.size() > 1 || DataType::allVarType)
		return "any";

	return this->scopeAssignments[0]->scope;
}

bool Function::assignScope(String scope, Function* func, int line, bool foundInstanceVar)
{
	if (!Function::enableAssignScope || this->structObject != nullptr)
		return false;

	if (foundInstanceVar)
		this->hasInstanceVars = true;

	if (this->scopesTraversed.contains(scope)) // Avoid infinite recursion
		return false;
	this->scopesTraversed.add(scope);

	// Assign same scope to all other function that has called this outside of a with()
	for (Function* depFunc : this->sameScopeFunctions)
		depFunc->assignScope(scope, func, line, this->hasInstanceVars);

	for (ScopeAssignment* ass : this->scopeAssignments)
		if (ass->scope == scope)
			return false;

	this->scopeAssignments.add(makeObject<ScopeAssignment>(scope, func, line));
	return true;
}

void Function::assignFunctionScope(Function* otherFunc, Function* func, int line)
{
	if (!Function::enableAssignScope)
		return;

	for (ScopeAssignment* ass : otherFunc->scopeAssignments)
		assignScope(ass->scope, func, line, true);
}

void Function::writeCppArguments(DeclarationList::WriteFormat format)
{
	String scope = getScope();
	if (scope != "global" && scope != "app" && this->structObject == nullptr) // Include scope variable in non-global functions
	{
		if (scope == "any")
			CodeWriter::write("ScopeAny self");
		else
			CodeWriter::write("Scope<" + scope + "> self");
		if (this->varArgs || this->args->declarations.size() > 0)
			CodeWriter::write(", ");
	}

	if (this->varArgs) // VarArgs type
		CodeWriter::write(String("VarArgs argument") + (format == DeclarationList::WriteFormat::ArgsHeader ? " = VarArgs()": ""));
	else if (this->args != nullptr && this->args->declarations.size() > 0) // Declarations
		this->args->writeCpp(ResolveScope("global"), format);
}

void Function::writeCppHeader()
{
	if (!this->isCppSeparate)
	{
		// Name
		if (this->isConstructor)
			CodeWriter::write(this->structObject->name);
		else if (this->isDestructor)
			CodeWriter::write("~" + this->structObject->name);
		else
			CodeWriter::write(getReturnType()->toCpp() + " " + CodeObject::nameToCpp(this->name));

		CodeWriter::write("(");
		writeCppArguments(DeclarationList::WriteFormat::ArgsHeader);
		CodeWriter::writeLine(");");
	}
	else
		CodeWriter::writeLine(this->cppSeparateHeader + ";");
}

bool Function::writeCppImplementation()
{
	if (this->implWritten)
		return false;
	this->implWritten = true;

	// Name
	if (this->isConstructor)
		CodeWriter::write(this->structObject->name + "::" + this->structObject->name);
	else if (this->isDestructor)
		CodeWriter::write(this->structObject->name + "::~" + this->structObject->name);
	else
	{
		CodeWriter::write(this->returnType->toCpp() + " ");
		if (this->structObject != nullptr)
			CodeWriter::write(this->structObject->name + "::");
		CodeWriter::write(CodeObject::nameToCpp(this->name));
	}

	CodeWriter::write("(");
	writeCppArguments(DeclarationList::WriteFormat::ArgsImpl);
	CodeWriter::writeLine(")", 1);
	if (this->isConstructor)
		CodeWriter::writeLine(": Object(\"" + this->structObject->name + "\", ID_" + this->structObject->name + ")");

	if (this->varArgs) // Variable* arguments
	{
		this->cppLinesBegin.add("IntType argument_count = argument.Size();"); // Declare argument_count

		if (this->varArgsRequiredNames.size() > 0) // Declare required arguments
		{
			for (int arg = 0; arg < static_cast<int>(this->args->declarations.size()); arg++)
			{
				Variable* var = Program::findVariable(this->name, this->args->declarations[arg]->name, this, Statement::Location(), 0);
				if (this->varArgsRequiredNames.contains(var->name))
					this->cppLinesBegin.add(var->type->toCpp() + " " + CodeObject::nameToCpp(var->name) + " = argument[" + arg + "];");
			}
		}
	}

	if (!this->isConstructor && !this->isDestructor && !this->endsWithReturnStatement && this->returnType->cppType != DataType::CppType::Void)
		this->cppLinesEnd.add("return " + this->returnType->toCppDefaultValue() + ";");

	this->statements->writeCpp(ResolveScope(getScope()));
	CodeWriter::writeLine("", -1);
	CodeWriter::writeLine();
	return true;
}

String Function::toExecuteCpp()
{
	String cpp = "{ ";
	int a = 0;

	// Return
	bool isVoid = (getReturnType()->cppType == DataType::CppType::Void);
	if (!isVoid)
		cpp += "return ";

	cpp += this->name + "(";

	// Create scope with ids
	String scope = getScope();
	if (this->structObject == nullptr && scope != "global" && scope != "app")
	{
		cpp += "Scope";
		if (scope == "any")
			cpp += "Any";
		else
			cpp += "<" + scope + ">";
		cpp += "(s, o)";
		a++;
	}

	// Arguments
	if (this->varArgs)
		cpp += (a > 0 ? ", " : "") + String("a");
	else
	{
		int p = 0;
		for (Declaration* decl : this->args->declarations)
		{
			cpp += (a > 0 ? ", " : "");
			if (decl->expr != nullptr) // Optional
				cpp += String("a.Size() > ") + p + " ? a[" + p + "] : VarType(" + decl->expr->toCpp(ResolveScope("global")) + ")";
			else // Required
				cpp += String("a[") + p + "]";
			a++;
			p++;
		}
	}
	cpp += "); ";

	// Return default
	if (isVoid)
		cpp += "return VarType(); ";

	cpp += "}";
	return cpp;
}

String Function::toDebugString(String tabs)
{
	String str = tabs + "[" + getScope() + "] " + this->name;
	if (this->args != nullptr)
		str += String(" - ") + this->args->requiredArgs + " required arguments";

	str += "\n";
	tabs += "\t";
	str += tabs + "Scope assignments:\n";
	tabs += "\t";
	for (ScopeAssignment* ass : this->scopeAssignments)
	{
		str += tabs + ass->scope;
		if (ass->func != nullptr)
			str += " in " + ass->func->name + ":" + ass->line;
		str += "\n";
	}
	tabs = tabs.remove(1, 1);
	if (this->hasInstanceVars)
		str += tabs + "Contains instance variables\n";
	str += tabs + "Returns " + getReturnType()->toCpp() + "\n";
	if (this->returnType->assignments.size() > 0)
		str += this->returnType->getAssignmentsString(tabs + "    ");
	int i = 0;
	if (this->varArgs)
		str += tabs + "VarArgs\n";
	for (Variable* var : this->vars)
	{
		if (var->line == 0)
			str += tabs + "Argument " + (i++) + ": ";
		else
			str += tabs + "Line " + var->line + ": ";
		str += var->type->toCpp() + " " + var->name ;
		if (var->location.path.size() > 0)
			str += " " + var->location.toString();
		str += "\n";
		str += var->type->getAssignmentsString(tabs + "\t");
	}
	return str;
}

void Function::resolve(ResolveScope* scope, const List<DataType*>& inputPars, Function* func, int line)
{
	std::optional<ResolveScope> structScope;
	if (this->structObject != nullptr) // Switch scope to StructObject
	{
		structScope.emplace(this->structObject->name, scope->currentInChain, scope->calls);
		scope = &*structScope;
	}
	scope->funcUpdateScope = this;
	scope->location = std::make_shared<Statement::Location>();

	// Resolve arguments with given input
	bool argsChanged = false, scopeChanged = false;
	if (this->args != nullptr)
		argsChanged = this->args->resolve(scope, this->name, inputPars) && !scope->isCalled(this->name);

	if (this->isTraversed && this->hasInstanceVars) // Assign new scope
		scopeChanged = assignScope(scope->current, func, line);

	// Traverse only if first time or scope/arguments changed.
	if (this->isTraversed && !scopeChanged && !argsChanged)
		return;

	this->isTraversed = true;
	this->isUnused = false;

	// Resolve statements
	this->statements->resolve(scope);

	// Check return
	if (this->returnStatement != nullptr && this->returnStatement->location.has_value() && this->returnStatement->location->path.size() > 1)
		this->endsWithReturnStatement = false;
}

void Function::assignReturnType(const DataType& type, Function* func, int line)
{
	if (this->cppSeparateReturnType == nullptr)
		this->returnType->assign(type, func, line);
}

DataType* Function::getReturnType()
{
	if (this->cppSeparateReturnType != nullptr)
		return this->cppSeparateReturnType;
	return this->returnType;
}

void Function::parseTokens()
{
	if (this->gml == "")
		return;

	Function::currentParseFunction = this;
	Function::currentParseLine = 0;

	// Signature with arguments
	nextToken(Token::Type::ID, "function");
	nextToken(Token::Type::ID, this->name);
	nextToken(Token::Type::LeftPar);
	this->args = parseDeclarations(true);
	nextToken(Token::Type::RightPar);

	// Check if struct, make this constructor of a new object
	if (peekToken() == Token::Type::ID && this->currentToken->value == "constructor")
	{
		this->structObject = makeObject<Object>(this->name, true);
		this->structObject->setConstructor(this);
		this->returnType->reset(DataType::Type::Reference, this->name);
		Program::objects.add(this->name, this->structObject);
		nextToken(Token::Type::ID);
	}

	// Statement* list in brackets
	nextToken(Token::Type::LeftBrace);
	this->statements = parseStatementList();
	nextToken(Token::Type::RightBrace);

	// No return found, set to void function
	if (this->structObject == nullptr && this->returnStatement == nullptr)
		this->returnType->reset(DataType::Type::Void);
	else if (this->returnStatement != nullptr)
		this->endsWithReturnStatement = (this->statements->statements[this->statements->statements.size() - 1]->type == Statement::Type::Return);
}

Token::Type Function::peekToken()
{
	if (this->tokenIndex >= static_cast<int>(this->tokens.size()))
	{
		Console::writeLine("FATAL ERROR in {0}:", this->name);
		Console::writeLine("  Unexpected end of function.");
		Environment::exit(1);
	}

	this->lastPeeked = this->currentToken->type;
	return this->lastPeeked;
}

Token* Function::nextToken(Token::Type expectedType, String expectedValue)
{
	Token* token = &this->tokens[this->tokenIndex];
	if (token->type != expectedType || (expectedValue != "" && token->value != expectedValue))
	{
		Console::writeLine("FATAL ERROR in {0}:", this->name);
		if (token->type == Token::Type::ID)
			Console::writeLine("  Unexpected \"{0}\" at line {1}, {2}", token->value, token->line, token->fileOffset - token->lineOffset);
		else
			Console::writeLine("  Unexpected {0} token at line {1}, {2}", token->type, token->line, token->fileOffset - token->lineOffset);

		if (expectedType != Token::Type::Error)
			Console::writeLine("  Expected token was {0}", expectedType);
		Environment::exit(1);
	}
	this->tokenIndex++;
	if (this->tokenIndex < static_cast<int>(this->tokens.size()))
	{
		this->currentToken = &this->tokens[this->tokenIndex];
		Function::currentParseLine = this->currentToken->line;
	}
	else
		this->currentToken = nullptr;
	return token;
}

StatementList* Function::parseStatementList()
{
	StatementList* sl = makeObject<StatementList>(Function::currentParseLine);
	while (true)
	{
		if (this->currentToken->value == "case" || this->currentToken->value == "default" ||
			this->currentToken->value == "else" || this->currentToken->value == "until") // End of list
			return sl;

		int line = Function::currentParseLine;
		switch (peekToken())
		{
			case Token::Type::Terminator: // ;
			{
				nextToken(Token::Type::Terminator); // Ignore
				break;
			}

			case Token::Type::HashTag: // #macro
			{
				nextToken(Token::Type::HashTag);
				nextToken(Token::Type::ID, "macro");
				String macroName = nextToken(Token::Type::ID)->value;
				sl->addStatement(makeObject<MacroStatement>(macroName, parseExpr(), line));
				break;
			}

			case Token::Type::CppOnly: // Custom C++
			{
				String cpp = this->currentToken->value;
				nextToken(Token::Type::CppOnly);
				sl->addStatement(makeObject<CustomCppStatement>(cpp, line));
				break;
			}

			case Token::Type::ID: // name
			case Token::Type::LeftPar: // (
			case Token::Type::LeftBrace: // {
			{
				Statement* stmt = parseStatement();
				if (stmt != nullptr)
					sl->addStatement(stmt);
				break;
			}

			default:
				return sl;
		}
	}
}

Statement* Function::parseStatement()
{
	int line = Function::currentParseLine;
	switch (peekToken())
	{
		case Token::Type::ID:
		{
			if (this->currentToken->value == "enums")
			{
				// Skip enums() call
				{
					parseAccessor();
					return nullptr;
				}
			}
			else if (this->currentToken->value == "var" || this->currentToken->value == "globalvar")
			{
				// var/globalvar name [ = expr], ...
				{
					Token* declToken = nextToken(Token::Type::ID);
					return makeObject<DeclareStatement>((declToken->value == "globalvar"), parseDeclarations(), line);
				}
			}
			else if (this->currentToken->value == "if")
			{
				// if (expr) stmt [else stmt]
				{
					nextToken(Token::Type::ID);
					nextToken(Token::Type::LeftPar);
					Expression* cond = parseExpr();
					nextToken(Token::Type::RightPar);
					Statement* stmt = parseStatement();
					if (peekToken() == Token::Type::Terminator) // Optional semicolon
						nextToken(Token::Type::Terminator);
					Statement* elseStmt = nullptr;
					if (peekToken() == Token::Type::ID && this->currentToken->value == "else")
					{
						nextToken(Token::Type::ID);
						elseStmt = parseStatement();
					}
					return makeObject<IfStatement>(cond, stmt, elseStmt, line);
				}
			}
			else if (this->currentToken->value == "while")
			{
				// while (expr) stmt
				{
					nextToken(Token::Type::ID);
					nextToken(Token::Type::LeftPar);
					Expression* cond = parseExpr();
					nextToken(Token::Type::RightPar);
					Statement* stmt = parseStatement();
					return makeObject<WhileStatement>(cond, stmt, line);
				}
			}
			else if (this->currentToken->value == "do")
			{
				// do stmt until expr
				{
					nextToken(Token::Type::ID);
					Statement* stmt = parseStatement();
					nextToken(Token::Type::ID, "until");
					nextToken(Token::Type::LeftPar);
					Expression* cond = parseExpr();
					nextToken(Token::Type::RightPar);
					return makeObject<DoUntilStatement>(stmt, cond, line);
				}
			}
			else if (this->currentToken->value == "for")
			{
				// for ([stmt]; [expr]; [stmt]) stmt
				{
					nextToken(Token::Type::ID);
					nextToken(Token::Type::LeftPar);
					Statement* initStmt = nullptr;
					Expression* loopCond = nullptr;
					Statement* incStmt = nullptr;

					// Init
					if (peekToken() != Token::Type::Terminator)
						initStmt = parseStatement();
					nextToken(Token::Type::Terminator);

					// Loop
					if (peekToken() != Token::Type::Terminator)
						loopCond = parseExpr();
					nextToken(Token::Type::Terminator);

					// Increment
					if (peekToken() != Token::Type::RightBrace)
						incStmt = parseStatement();

					nextToken(Token::Type::RightPar);
					return makeObject<ForStatement>(initStmt, loopCond, incStmt, parseStatement(), line);
				}
			}
			else if (this->currentToken->value == "repeat")
			{
				// repeat (expr) stmt
				{
					nextToken(Token::Type::ID);
					nextToken(Token::Type::LeftPar);
					Expression* cond = parseExpr();
					nextToken(Token::Type::RightPar);
					Statement* stmt = parseStatement();
					return makeObject<RepeatStatement>(cond, stmt, line);
				}
			}
			else if (this->currentToken->value == "with")
			{
				// with (expr) stmt
				{
					nextToken(Token::Type::ID);
					nextToken(Token::Type::LeftPar);
					Expression* cond = parseExpr();
					nextToken(Token::Type::RightPar);
					Statement* stmt = parseStatement();
					return makeObject<WithStatement>(cond, stmt, line);
				}
			}
			else if (this->currentToken->value == "switch")
			{
				// switch (expr) { case expr1: stmtList ... [ default: stmtList ] }
				{
					nextToken(Token::Type::ID);

					nextToken(Token::Type::LeftPar);
					Expression* expr = parseExpr();
					nextToken(Token::Type::RightPar);
					List<SwitchStatement::Case*> cases = List<SwitchStatement::Case*>();
					StatementList* defaultStmts = nullptr;

					nextToken(Token::Type::LeftBrace);
					while (peekToken() != Token::Type::RightBrace)
					{
						Token* caseToken = nextToken(Token::Type::ID);
						if (caseToken->value == "case")
						{
							Expression* caseExpr = parseExpr();
							nextToken(Token::Type::Colon);
							cases.add(makeObject<SwitchStatement::Case>(caseExpr, parseStatementList()));
						}
						else if (caseToken->value == "default") // default
						{
							nextToken(Token::Type::Colon);
							defaultStmts = parseStatementList();
						}
						else
							nextToken(Token::Type::Error);
					}
					nextToken(Token::Type::RightBrace);

					return makeObject<SwitchStatement>(expr, cases, defaultStmts, line);
				}
			}
			else if (this->currentToken->value == "return")
			{
				// return expr/;
				{
					nextToken(Token::Type::ID);
					if (peekToken() == Token::Type::Terminator)
					{
						nextToken(Token::Type::Terminator);
						this->returnStatement = makeObject<ReturnStatement>(nullptr, line);
					}
					else
						this->returnStatement = makeObject<ReturnStatement>(parseExpr(), line);
					return this->returnStatement;
				}
			}
			else if (this->currentToken->value == "break")
			{
				// break
				{
					nextToken(Token::Type::ID);
					return makeObject<BreakStatement>(line);
				}
			}
			else if (this->currentToken->value == "continue")
			{
				// continue
				{
					nextToken(Token::Type::ID);
					return makeObject<ContinueStatement>(line);
				}
			}
			else if (this->currentToken->value == "enum")
			{
				// enum name { name [ = expr ], ... }
				{
					nextToken(Token::Type::ID);
					String enumName = nextToken(Token::Type::ID)->value;
					nextToken(Token::Type::LeftBrace);
					DeclarationList* decls = parseDeclarations();
					nextToken(Token::Type::RightBrace);
					return makeObject<EnumStatement>(enumName, decls, line);
				}
			}
			else if (this->currentToken->value == "delete")
			{
				// delete expr
				{
					nextToken(Token::Type::ID);
					return makeObject<DeleteStatement>(parseExpr(), line);
				}
			}
			else if (this->currentToken->value == "static")
			{
				{
					if (this->structObject == nullptr)
					{
						Console::writeLine("FATAL ERROR: Unexpected static in {0}:{1}.", this->name, line);
						Environment::exit(1);
					}
					Function* func = makeObject<Function>("", this->gml);
					Function::currentParseFunction = func;

					nextToken(Token::Type::ID);
					func->name = nextToken(Token::Type::ID)->value;
					nextToken(Token::Type::Assign);
					nextToken(Token::Type::ID, "function");
					nextToken(Token::Type::LeftPar);
					func->args = parseDeclarations(true);
					nextToken(Token::Type::RightPar);
					nextToken(Token::Type::LeftBrace);
					func->statements = parseStatementList();
					nextToken(Token::Type::RightBrace);

					// Add new function to object
					func->structObject = this->structObject;
					func->returnStatement = this->returnStatement;
					if (func->returnStatement == nullptr)
						func->returnType->reset(DataType::Type::Void);
					this->structObject->instanceFunctions.add(func->name, func);

					Function::currentParseFunction = this;
					this->returnStatement = nullptr;

					return nullptr; // Skip in constructor statement list
				}
			}
			else
			{
				// Call/Assign
				{
					Accessor* accessor = parseAccessor();
					switch (peekToken())
					{
						case Token::Type::AddShort: // accessor++
						case Token::Type::SubShort: // accessor--
						{
							nextToken(this->lastPeeked);
							accessor->addSubOp = this->lastPeeked;
							return makeObject<AssignStatement>(accessor, this->lastPeeked, nullptr, line);
						}
						case Token::Type::Assign: // accessor = expr
						case Token::Type::AddLong: // accessor += expr
						case Token::Type::SubLong: // accessor -= expr
						case Token::Type::MulLong: // accessor *= expr
						case Token::Type::DivLong: // accessor /= expr
						{
							Token::Type parsedOperation = this->lastPeeked;
							nextToken(parsedOperation);
							Expression* parsedRight = parseExpr();
							return makeObject<AssignStatement>(accessor, parsedOperation, parsedRight, line);
						}

						default: // accessor
							return makeObject<CallStatement>(accessor, line);
					}
				}
			}
		}

		case Token::Type::LeftBrace: // { stmtList }
		{
			nextToken(Token::Type::LeftBrace);
			StatementList* sl = parseStatementList();
			nextToken(Token::Type::RightBrace);
			return sl;
		}

		default: break;
	}

	nextToken(Token::Type::Error);
	return nullptr;
}

DeclarationList* Function::parseDeclarations(bool isArgs)
{
	List<Declaration*> decls = List<Declaration*>();
	while (peekToken() == Token::Type::ID)
	{
		if (GML::keywords.contains(this->currentToken->value)) // GML* keywords will break the declaration (var/globalvar)
			break;

		String declarationName = nextToken(Token::Type::ID)->value;
		Expression* expr = nullptr;
		if (peekToken() == Token::Type::Assign) // Found expression
		{
			nextToken(Token::Type::Assign);
			expr = parseExpr();
		}
		decls.add(makeObject<Declaration>(declarationName, expr));

		if (peekToken() == Token::Type::Separator)
			nextToken(Token::Type::Separator);
		else
			break;
	}
	return makeObject<DeclarationList>(decls, isArgs, Function::currentParseLine);
}

Accessor* Function::parseAccessor()
{
	int line = Function::currentParseLine;
	Token* token = nextToken(Token::Type::ID);
	List<Accessor::ArrayAccessor*> arrayAccessors = List<Accessor::ArrayAccessor*>();
	Accessor* member = nullptr;
	List<Expression*> parameterList = nullptr;
	Token::Type addSubOp = Token::Type::Unknown;

	if ((token->value == "argument" || token->value == "argument_count") && this->cppSeparateHeader == "") // Set VarArgs
		this->varArgs = true;

	if (peekToken() == Token::Type::LeftPar) // Parameter list
		parameterList = parseParameterList();

	while (peekToken() == Token::Type::LeftSquare) // Array accessors
	{
		nextToken(Token::Type::LeftSquare);
		DataType::Type arrAccType = DataType::Type::Array;
		bool isRef = false;

		// Look for token after [
		switch (peekToken())
		{
			case Token::Type::ArrayRef: isRef = true; break;
			case Token::Type::BitwiseOr: arrAccType = DataType::Type::List; break;
			case Token::Type::Ternary: arrAccType = DataType::Type::AnyMap; break;
			case Token::Type::HashTag: arrAccType = DataType::Type::Grid; break;
			default: break;
		}
		if (isRef || arrAccType != DataType::Type::Array)
			nextToken(this->lastPeeked);

		arrayAccessors.add(makeObject<Accessor::ArrayAccessor>(arrAccType, parseExpr(), isRef));

		// Look for comma separated list with more accessors
		while (peekToken() == Token::Type::Separator)
		{
			nextToken(Token::Type::Separator);
			arrayAccessors.add(makeObject<Accessor::ArrayAccessor>(arrAccType, parseExpr(), isRef));
		}
		nextToken(Token::Type::RightSquare);
	}

	if (peekToken() == Token::Type::Member) // Member
	{
		nextToken(Token::Type::Member);
		member = parseAccessor();
	}
	else if (peekToken() == Token::Type::AddShort || peekToken() == Token::Type::SubShort) // ++/--
	{
		addSubOp = this->lastPeeked;
		nextToken(this->lastPeeked);
	}


	return makeObject<Accessor>(token->value, arrayAccessors, parameterList, member, addSubOp, line);
}

Expression* Function::parseExpr()
{
	Expression* expr = parseExprAndOr();

	if (peekToken() == Token::Type::Ternary) // ? expr2 : expr3
	{
		nextToken(Token::Type::Ternary);
		Expression* expr2 = parseExpr();
		nextToken(Token::Type::Colon);
		Expression* expr3 = parseExpr();
		return makeObject<TernaryCondition>(expr, expr2, expr3, Function::currentParseLine);
	}

	return expr;
}

Expression* Function::parseExprAndOr()
{
	Expression* expr = parseExprEq();
	if (peekToken() == Token::Type::And || peekToken() == Token::Type::Or)
	{
		Token::Type parsedOperation = this->lastPeeked;
		nextToken(parsedOperation);
		Expression* parsedRight = parseExprAndOr();
		return makeObject<BinaryOperation>(parsedOperation, expr, parsedRight, Function::currentParseLine);
	}
	return expr;
}

Expression* Function::parseExprEq()
{
	Expression* expr = parseExprComp();
	if (peekToken() == Token::Type::Assign || peekToken() == Token::Type::Equal || peekToken() == Token::Type::NotEqual)
	{
		nextToken(this->lastPeeked);
		Token::Type opType = this->lastPeeked;
		if (opType == Token::Type::Assign) // Change = to ==
			opType = Token::Type::Equal;
		return makeObject<BinaryOperation>(opType, expr, parseExprEq(), Function::currentParseLine);
	}
	return expr;
}

Expression* Function::parseExprComp()
{
	Expression* expr = parseExprAddSub();
	if (peekToken() == Token::Type::Larger || peekToken() == Token::Type::LargerEq ||
		peekToken() == Token::Type::Less || peekToken() == Token::Type::LessEq)
	{
		Token::Type parsedOperation = this->lastPeeked;
		nextToken(parsedOperation);
		Expression* parsedRight = parseExprComp();
		return makeObject<BinaryOperation>(parsedOperation, expr, parsedRight, Function::currentParseLine);
	}
	return expr;
}

Expression* Function::parseExprAddSub()
{
	Expression* expr = parseExprMulDiv();
	if (peekToken() == Token::Type::Add || peekToken() == Token::Type::Sub)
	{
		Token::Type parsedOperation = this->lastPeeked;
		nextToken(parsedOperation);
		Expression* parsedRight = parseExprAddSub();
		return makeObject<BinaryOperation>(parsedOperation, expr, parsedRight, Function::currentParseLine);
	}
	return expr;
}

Expression* Function::parseExprMulDiv()
{
	Expression* expr = parseExprModInvNegate();
	if (peekToken() == Token::Type::Mul || peekToken() == Token::Type::Div || peekToken() == Token::Type::DivInt ||
		peekToken() == Token::Type::BitwiseAnd || peekToken() == Token::Type::BitwiseOr ||
		peekToken() == Token::Type::ShiftLeft || peekToken() == Token::Type::ShiftRight)
	{
		Token::Type parsedOperation = this->lastPeeked;
		nextToken(parsedOperation);
		Expression* parsedRight = parseExprMulDiv();
		return makeObject<BinaryOperation>(parsedOperation, expr, parsedRight, Function::currentParseLine);
	}
	return expr;
}

Expression* Function::parseExprModInvNegate()
{
	if (peekToken() == Token::Type::Inverse || peekToken() == Token::Type::Sub)
	{
		Token::Type parsedOperation = this->lastPeeked;
		nextToken(parsedOperation);
		Expression* parsedValue = parseExprValue();
		return makeObject<UnaryOperation>(parsedOperation, parsedValue, Function::currentParseLine);
	}

	Expression* expr = parseExprValue();
	if (peekToken() == Token::Type::Modulus)
	{
		Token::Type parsedOperation = this->lastPeeked;
		nextToken(parsedOperation);
		Expression* parsedRight = parseExprModInvNegate();
		return makeObject<BinaryOperation>(parsedOperation, expr, parsedRight, Function::currentParseLine);
	}

	return expr;
}

Expression* Function::parseExprValue()
{
	switch (peekToken())
	{
		case Token::Type::Number:
		case Token::Type::String: // Number/String
			return makeObject<ExpressionValue>(this->lastPeeked, nextToken(this->lastPeeked)->value, Function::currentParseLine);

		case Token::Type::ID: // ID [ arrayAccessors... ] [ . ]/[( parameterList )]
		{
			if (this->currentToken->value == "new") // new accessor
			{
				nextToken(Token::Type::ID);
				return makeObject<NewExpression>(parseAccessor(), Function::currentParseLine);
			}
			else
				return parseAccessor();
		}

		case Token::Type::LeftSquare: // [ expr, ... ]
		{
			nextToken(Token::Type::LeftSquare);
			List<Expression*> exprs = List<Expression*>();

			while (peekToken() != Token::Type::RightSquare) // Comma separated array values
			{
				exprs.add(parseExpr());
				if (peekToken() == Token::Type::Separator)
					nextToken(Token::Type::Separator);
			}
			nextToken(Token::Type::RightSquare);
			return makeObject<ExpressionArray>(exprs, Function::currentParseLine);
		}

		case Token::Type::LeftPar: // ( expr )
		{
			nextToken(Token::Type::LeftPar);
			Expression* expr = parseExpr();
			nextToken(Token::Type::RightPar);
			return makeObject<ExpressionParenthesis>(expr, Function::currentParseLine);
		}

		default: break;
	}

	return nullptr;
}

List<Expression*> Function::parseParameterList()
{
	List<Expression*> pars = List<Expression*>();
	nextToken(Token::Type::LeftPar);
	while (true)
	{
		if (peekToken() == Token::Type::Separator)
			nextToken(Token::Type::Separator);
		else if (peekToken() == Token::Type::RightPar)
			break;
		else
			pars.add(parseExpr());
	}
	nextToken(Token::Type::RightPar);
	return pars;
}

Function::ScopeAssignment::ScopeAssignment(String scope, Function* func, int line)
{
	this->scope = scope;
	this->func = func;
	this->line = line;
}

}
