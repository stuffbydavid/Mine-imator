#include "CppGen.hpp"

namespace CppGen
{
Statement::Statement(int line) : CodeObject(line)
{}

void Statement::writeCpp(ResolveScope*)
{}

Statement::Location::Location()
{}

Statement::Location::Location(const Statement::Location& other)
{
	this->path = List<int>(other.path);
	this->level = other.level;
	this->nextId = other.nextId;
}

Statement::Location Statement::Location::next(bool addLevel)
{
	Location next;
	next.path = List<int>(this->path);
	next.level = this->level + (addLevel ? 1 : 0);
	next.path.add(this->nextId++);
	return next;
}

bool Statement::Location::contains(const Statement::Location& other) const
{
	if (this->path.size() > other.path.size())
		return false;

	for (int i = 0; i < static_cast<int>(this->path.size()); i++)
		if (other.path[i] != this->path[i])
			return false;

	return true;
}

bool Statement::Location::equals(const Statement::Location& other) const
{
	if (this->path.size() != other.path.size())
		return false;

	for (int i = 0; i < static_cast<int>(this->path.size()); i++)
		if (other.path[i] != this->path[i])
			return false;

	return true;
}

String Statement::Location::toString()
{
	String str = "";
	for (int p : this->path)
		str += (str != "" ? " -> " : "") + p;
	return "[" + str + "]";
}

Declaration::Declaration(StringId name, Expression* expr)
{
	this->name = name;
	this->expr = expr;
}

DeclarationList::DeclarationList(List<Declaration*> declarations, bool isArgs, int line) : Statement(line)
{
	this->declarations = declarations;
	this->isArgs = isArgs;

	type = Type::DeclarationList;
}

bool DeclarationList::resolve(ResolveScope* scope, const StringId& declScope, const NullableList<DataType*>& inputPars)
{
	location = *scope->location;

	bool changed = false;

	int i = 0;
	this->requiredArgs = 0;

	for (Declaration* decl : this->declarations)
	{
		// Check if name is a duplicate
		for (int j = 0; j < i; j++)
			if (this->declarations[j]->name == decl->name)
				Program::addSyntaxError("Duplicate declaration of " + String(decl->name) + " in " + String(this->func->name) + ":" + this->line);

		DataType exprType;
		if (decl->expr != nullptr) // Attempt getting type from expression
		{
			decl->expr->resolve(scope);
			exprType.reset(*decl->expr->resolvedType);
		}
		else
			this->requiredArgs = i + 1;

		// If input if supplied, apply to the expression
		if (inputPars != nullptr && i < static_cast<int>(inputPars.size()))
			if (exprType.assign(*inputPars[i], this->func, this->isArgs ? 0 : this->line))
				changed = true;

		Variable* declVar = Program::declareVariable(declScope, decl->name, exprType, this->func, *scope->location, this->isArgs ? 0 : this->line);

		if (decl->expr != nullptr)
			decl->expr->assignedTo = declVar;
		i++;
	}

	return changed;
}

void DeclarationList::writeCpp(ResolveScope* scope, WriteFormat format, String enumPrefix)
{
	List<DataType*> varTypes = List<DataType*>(); // Get variable types
	if (!this->isEnum)
	{
		for (Declaration* decl : this->declarations)
		{
			Variable* var = Program::findVariable(this->func->name, decl->name, this->func, *scope->location, this->line);
			varTypes.add(var->type);
		}
	}

	if (format == WriteFormat::Var) // One type per line
	{
		List<int> declToWrite = List<int>(); // The declaration indices left to write
		for (int i = 0; i < static_cast<int>(this->declarations.size()); i++)
			declToWrite.add(i);

		bool newLine = false;
		for (int j = 0; j < static_cast<int>(this->declarations.size()); j++)
		{
			if (declToWrite.contains(j))
			{
				if (newLine)
					CodeWriter::writeLine();
				String typeCpp = varTypes[j]->toCpp();
				CodeWriter::write(typeCpp + " ");

				int jj = 0, rowCount = 0;
				for (Declaration* decl : this->declarations)
				{
					if (declToWrite.contains(jj) && typeCpp == varTypes[jj]->toCpp()) // Write all declarations that match this type
					{
						declToWrite.removeAll([&](int i) { return i == jj; });

						if (rowCount++ > 0)
							CodeWriter::write(", ");

						CodeWriter::write(nameToCpp(decl->name));
						if (decl->expr != nullptr)
							CodeWriter::write(" = " + decl->expr->toCpp(scope));
					}
					jj++;
				}
				CodeWriter::write(";");
				newLine = true;
			}
		}
	}
	else if (format == WriteFormat::Enum) // New line for each declaration
	{
		int i = 0;
		for (Declaration* decl : this->declarations)
		{
			if (i > 0)
				CodeWriter::writeLine(",");
			CodeWriter::write(nameToCpp(enumPrefix) + "_" + nameToCpp(decl->name)); // Name (with prefix)

			if (decl->expr != nullptr) // Expression
				CodeWriter::write(" = " + decl->expr->toCpp(scope));
			i++;
		}
		CodeWriter::writeLine();
	}
	else // Single line for all declarations
	{
		int i = 0;
		for (Declaration* decl : this->declarations)
		{
			if (i > 0)
				CodeWriter::write(", ");
			CodeWriter::write(varTypes[i]->toCpp() + " " + nameToCpp(decl->name));
			if (decl->expr != nullptr && format != WriteFormat::ArgsImpl) // Expression
				CodeWriter::write(" = " + decl->expr->toCpp(scope));
			i++;
		}
	}
}

StatementList::StatementList(int line) : Statement(line)
{
	this->statements = List<Statement*>();
	type = Type::StatementList;
}

void StatementList::addStatement(Statement* stmt)
{
	this->statements.add(stmt);
}

void StatementList::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
	ResolveScope stmtsScope = scope->nextStatement();

	for (Statement* stmt : this->statements)
		stmt->resolve(stmtsScope);
}

void StatementList::writeCpp(ResolveScope* scope)
{
	writeCpp(scope, true);
}

void StatementList::writeCpp(ResolveScope* scope, bool brackets)
{
	if (brackets)
	{
		CodeWriter::indent(-1);
		CodeWriter::writeLine("{", 1);
	}
	else
		CodeWriter::indent(1);

	if (scope->location->path.size() == 0 && this->func->cppLinesBegin.size() > 0)
	{
		for (String cppLine : this->func->cppLinesBegin)
			CodeWriter::writeLine(cppLine);
		this->func->cppLinesBegin.clear();
	}

	ResolveScope stmtsScope = scope->nextStatement();
	for (Statement* stmt : this->statements)
	{
		if (stmt->type == Type::Enum)
			continue;
		stmt->writeCpp(stmtsScope);
		if (stmt->hasCpp)
			CodeWriter::writeLine();
	}

	if (scope->location->path.size() == 0 && this->func->cppLinesEnd.size() > 0)
	{
		for (String cppLine : this->func->cppLinesEnd)
			CodeWriter::writeLine(cppLine);
		this->func->cppLinesEnd.clear();
	}

	if (brackets)
	{
		CodeWriter::indent(-1);
		CodeWriter::write("}");
		CodeWriter::indent(1);
	}
	else
		CodeWriter::indent(-1);
}

DeclareStatement::DeclareStatement(bool globalScope, DeclarationList* declarations, int line) : Statement(line)
{
	this->globalScope = globalScope;
	this->declarations = declarations;
	if (globalScope)
		DeclareStatement::globalDeclarations.add(this);
	type = Type::Declare;
}

void DeclareStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);

	this->declarations->resolve(scope, this->globalScope ? STR(global) : this->func->name);
}

void DeclareStatement::writeCpp(ResolveScope* scope)
{
	if (this->globalScope)
	{
		this->hasCpp = false;
		return;
	}

	this->declarations->writeCpp(scope, DeclarationList::WriteFormat::Var);
}

MacroStatement::MacroStatement(StringId name, Expression* expr, int line) : Statement(line)
{
	this->name = name;
	this->expr = expr;
	type = Type::Macro;

	Program::macros.add(this->name, this);
}

void MacroStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
	this->expr->resolve(ResolveScope(STR(global), 0, scope->calls));
	Program::declareVariable(STR(global), this->name, *this->expr->resolvedType, this->func, *scope->location);
}

void MacroStatement::writeCpp(ResolveScope* scope)
{
	CodeWriter::write("#define " + nameToCpp(this->name) + " ");
	CodeWriter::write(this->expr->toCpp(scope));
	CodeWriter::writeLine();
}

EnumStatement::EnumStatement(StringId name, DeclarationList* declarations, int line) : Statement(line)
{
	this->name = name;
	this->declarations = declarations;
	this->declarations->isEnum = true;
	type = Type::Enum;

	Program::enums.add(this->name, this);
}

void EnumStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
}

void EnumStatement::writeCpp(ResolveScope* scope)
{
	CodeWriter::writeLine("enum " + nameToCpp(this->name));
	CodeWriter::writeLine("{", 1);
	this->declarations->writeCpp(scope, DeclarationList::WriteFormat::Enum, this->name);
	CodeWriter::writeLine("};", -1);
}

CallStatement::CallStatement(Accessor* accessor, int line) : Statement(line)
{
	this->acc = accessor;
	type = Type::Call;
}

void CallStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
	this->acc->resolve(scope);
}

void CallStatement::writeCpp(ResolveScope* scope)
{
	if (this->acc->name == STR(gml_pragma))
	{
		this->hasCpp = false;
		return;
	}
	CodeWriter::write(this->acc->toCpp(scope) + ";");
}

AssignStatement::AssignStatement(Accessor* target, Token::Type op, Expression* expression, int line) : Statement(line)
{
	this->target = target;
	this->target->markAsAssign(expression);
	this->op = op;
	this->expr = expression;
	type = Type::Assign;

	// Add external function
	if (this->expr->type == Expression::Type::Accessor)
	{
		Accessor* acc = static_cast<Accessor*>(this->expr);
		if (acc->name == STR(external_define) && acc->callParameters != nullptr && acc->callParameters.size() >= 5)
		{
			// Get return type from arg[3], argument types from arg[5...]
			DataType* retType = makeObject<DataType>(static_cast<Accessor*>(acc->callParameters[3])->name == STR(ty_real) ? DataType::Type::Real : DataType::Type::String);

			List<DataType*> argTypes = List<DataType*>();
			for (int a = 5; a < static_cast<int>(acc->callParameters.size()); a++)
				argTypes.add(makeObject<DataType>(static_cast<Accessor*>(acc->callParameters[a])->name == STR(ty_real) ? DataType::Type::Real : DataType::Type::String));

			Program::externalFunctions.add(this->target->name, makeObject<ExternalFunction>(this->target->name, retType, argTypes));
		}
	}
}

void AssignStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);

	switch (this->op)
	{
		case Token::Type::AddShort: // ++, --, -=, *=, /= must be integer or double
		case Token::Type::SubShort:
		case Token::Type::SubLong:
		case Token::Type::MulLong:
		case Token::Type::DivLong:
		{
			this->target->resolve(scope);
			this->target->applyType(scope, DataType::scalar(DataType::Type::Real));
			if (this->expr != nullptr)
			{
				this->expr->resolve(scope);
				this->expr->applyType(scope, DataType::scalar(DataType::Type::Real));
			}
			break;
		}
		case Token::Type::Assign: // =, += must be same as expression
		case Token::Type::AddLong:
		{
			this->target->resolve(scope);
			this->expr->resolve(scope);
			this->target->applyType(scope, *this->expr->resolvedType);
			break;
		}
		default:
			Console::writeLine("FATAL ERROR: Invalid token in {0}:{1}", this->func->name, this->line);
			break;
	}
}

void AssignStatement::writeCpp(ResolveScope* scope)
{
	CodeWriter::write(this->target->toCpp(scope));
	if (this->expr != nullptr)
	{
		CodeWriter::write(" " + Token::toCpp(this->op) + " " + this->expr->toCpp(scope));

		if (this->target->writtenType->cppType == DataType::CppType::StringType &&
			this->expr->getResolvedCppType() == DataType::CppType::VarType) // VarType assigment to StringType (may fail)
			CodeWriter::write(".Str()");

		CodeWriter::write(";");
	}
}

IfStatement::IfStatement(Expression* condition, CppGen::Statement* statement, CppGen::Statement* elseStatement, int line) : CppGen::Statement(line)
{
	this->condition = condition;
	this->statement = statement;
	this->elseStatement = elseStatement;
	type = Type::If;
}

void IfStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
	ResolveScope ifScope = scope->nextStatement();
	std::optional<ResolveScope> elseScope;
	if (this->elseStatement != nullptr)
		elseScope = scope->nextStatement();

	this->condition->resolve(ifScope);
	this->statement->resolve(ifScope);

	if (this->elseStatement != nullptr)
		this->elseStatement->resolve(*elseScope);
}

void IfStatement::writeCpp(ResolveScope* scope)
{
	ResolveScope ifScope = scope->nextStatement();
	std::optional<ResolveScope> elseScope;
	if (this->elseStatement != nullptr)
		elseScope = scope->nextStatement();

	CodeWriter::writeLine("if (" + this->condition->toConditionCpp(ifScope, false) + ")", 1);
	this->statement->writeCpp(ifScope);
	CodeWriter::indent(-1);

	if (this->elseStatement != nullptr)
	{
		if (!CodeWriter::isNewLine)
			CodeWriter::writeLine();
		CodeWriter::writeLine("else", 1);
		this->elseStatement->writeCpp(*elseScope);
		CodeWriter::writeLine("", -1);
	}
}

WhileStatement::WhileStatement(Expression* loopCondition, CppGen::Statement* statement, int line) : CppGen::Statement(line)
{
	this->loopCondition = loopCondition;
	this->statement = statement;
	type = Type::While;
}

void WhileStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
	ResolveScope whileScope = scope->nextStatement();

	this->loopCondition->resolve(whileScope);
	this->statement->resolve(whileScope);
}

void WhileStatement::writeCpp(ResolveScope* scope)
{
	ResolveScope whileScope = scope->nextStatement();
	CodeWriter::writeLine("while (" + this->loopCondition->toConditionCpp(whileScope, false) + ")", 1);
	this->statement->writeCpp(whileScope);
	CodeWriter::writeLine("", -1);
}

DoUntilStatement::DoUntilStatement(CppGen::Statement* statement, Expression* breakCondition, int line) : CppGen::Statement(line)
{
	this->statement = statement;
	this->breakCondition = breakCondition;
	type = Type::DoUntil;
}

void DoUntilStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
	ResolveScope stmtScope = scope->nextStatement();

	this->statement->resolve(stmtScope);
	this->breakCondition->resolve(scope);
}

void DoUntilStatement::writeCpp(ResolveScope* scope)
{
	ResolveScope stmtScope = scope->nextStatement();
	CodeWriter::writeLine("do", 1);
	this->statement->writeCpp(stmtScope);
	CodeWriter::writeLine("", -1);
	CodeWriter::write("while (!(" + this->breakCondition->toConditionCpp(scope, false) + "));");
}

ForStatement::ForStatement(CppGen::Statement* initStatement, Expression* loopCondition, CppGen::Statement* incStatement, CppGen::Statement* statement, int line) : CppGen::Statement(line)
{
	this->initStatement = initStatement;
	this->loopCondition = loopCondition;
	this->incStatement = incStatement;
	this->statement = statement;
	type = Type::For;
}

void ForStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
	ResolveScope forScope = scope->nextStatement();

	if (this->initStatement != nullptr) // Initialize
		this->initStatement->resolve(forScope);

	if (this->loopCondition != nullptr) // Loop
	{
		this->loopCondition->resolve(forScope);
		this->loopCondition->applyType(forScope, DataType::scalar(DataType::Type::Bool));
	}

	if (this->incStatement != nullptr) // Increment
		if (this->incStatement) this->incStatement->resolve(forScope);

	this->statement->resolve(forScope);
}

void ForStatement::writeCpp(ResolveScope* scope)
{
	ResolveScope forScope = scope->nextStatement();
	CodeWriter::write("for (");

	if (this->initStatement != nullptr)
	{
		this->initStatement->writeCpp(forScope);
		CodeWriter::write(" ");
	}
	else
		CodeWriter::write("; ");

	if (this->loopCondition != nullptr)
		CodeWriter::write(this->loopCondition->toConditionCpp(forScope, false));
	CodeWriter::write("; ");

	if (this->incStatement) this->incStatement->writeCpp(forScope);
	if (this->incStatement != nullptr)
		CodeWriter::erase(1); // Remove ;
	CodeWriter::writeLine(")", 1);
	this->statement->writeCpp(forScope);
	CodeWriter::indent(-1);
}

RepeatStatement::RepeatStatement(Expression* expr, CppGen::Statement* statement, int line) : CppGen::Statement(line)
{
	this->expr = expr;
	this->statement = statement;
	type = Type::Repeat;
}

void RepeatStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
	ResolveScope repeatScope = scope->nextStatement();

	this->expr->resolve(repeatScope);
	this->expr->applyType(repeatScope, DataType::scalar(DataType::Type::Integer));
	this->statement->resolve(repeatScope);
}

void RepeatStatement::writeCpp(ResolveScope* scope)
{
	ResolveScope repeatScope = scope->nextStatement();
	CodeWriter::writeLine("for (IntType _it = 0, _it_max = " + this->expr->toCpp(repeatScope) + "; _it < _it_max; _it++)", 1);
	this->statement->writeCpp(repeatScope);
	CodeWriter::indent(-1);
}

WithStatement::WithStatement(Expression* expression, CppGen::Statement* statement, int line) : CppGen::Statement(line)
{
	this->expr = expression;
	this->statement = statement;
	type = Type::With;
}

void WithStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
	ResolveScope withScope = scope->nextStatement(true);

	// Update scope of "other" keyword
	if (!this->otherScopes.contains(scope->current))
		this->otherScopes.add(scope->current);
	this->otherScope = (this->otherScopes.size() == 1) ? this->otherScopes[0] : STR(any);

	this->expr->resolve(withScope);
	StringId newScope = this->expr->resolvedType->getUniqueReferenceId();
	StringId exprAccName = this->expr->getAccessorName();
	if (Program::objects.containsKey(exprAccName)) // with (objName)
		newScope = exprAccName;

	if (newScope == 0)
		newScope = STR(any);

	if (newScope == STR(any))
	{
		CodeObject::unknownScopes++;
		if (!WithStatement::resolveUnknownScope)
			return;
	}

	// Continue with the scope set to the reference ID or "any" (and drop FuncUpdateScope)
	this->statement->resolve(withScope->enterWithStatement(newScope, this->otherScope));
}

void WithStatement::writeCpp(ResolveScope* scope)
{
	ResolveScope withScope = scope->nextStatement(true);
	bool exprIsTypeId = false;
	StringId newScope = DataType::allVarType ? STR(any) : this->expr->resolvedType->getUniqueReferenceId();
	StringId previousScope = DataType::allVarType ? STR(any) : this->otherScope;

	StringId exprAccName = this->expr->getAccessorName();
	if (Program::objects.containsKey(exprAccName)) // with (objName)
	{
		newScope = exprAccName;
		exprIsTypeId = (newScope != STR(app));
	}
	if (newScope == 0)
		newScope = STR(any);

	String withType, otherId;
	if (newScope == STR(any))
		withType = "Object";
	else
		withType = newScope;

	if (withScope->current != STR(global)) // "other" will only work in non-global scopes, otherwise will be "noone"
	{
		if (this->func->structObject != nullptr) // Use "id" member directly
			otherId = "id";
		else if (this->otherScope == STR(app)) // Get global app id
			otherId = "global::_app->id";
		else
			otherId = "self->id";
	}
	else
		otherId = "noone";

	if (exprIsTypeId) // Loop
		CodeWriter::writeLine("withAll (" + withType + ", " + otherId + ")", 1);

	else // Single
		CodeWriter::writeLine("withOne (" + withType + ", " + this->expr->toCpp(withScope) + ", " + otherId + ")", 1);

	this->statement->writeCpp(withScope->enterWithStatement(newScope, previousScope));
	CodeWriter::writeLine("", -1);
}

SwitchStatement::SwitchStatement(Expression* expression, List<SwitchStatement::Case*> cases, StatementList* defaultStatements, int line) : Statement(line)
{
	this->expr = expression;
	this->cases = cases;
	this->defaultStatements = defaultStatements;
	type = Type::Switch;
}

void SwitchStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
	ResolveScope switchScope = scope->nextStatement();

	this->expr->resolve(switchScope);

	this->caseResolvedType->reset();
	for (Case* switchCase : this->cases) // Resolve cases
	{
		switchCase->expr->resolve(switchScope);
		this->caseResolvedType->reset(*switchCase->expr->resolvedType); // Derive expression type from cases
		switchCase->expr->applyType(switchScope, DataType::scalar(DataType::Type::Integer));
		switchCase->statements->resolve(switchScope);
	}

	// Apply case type to expression
	this->expr->applyType(switchScope, *this->caseResolvedType);

	if (this->defaultStatements != nullptr) // Resolve default
		this->defaultStatements->resolve(switchScope);
}

void SwitchStatement::writeCpp(ResolveScope* scope)
{
	ResolveScope switchScope = scope->nextStatement();

	// String switch
	if (this->caseResolvedType->getAssignments(DataType::Type::String).size() > 0)
	{
		CodeWriter::writeLine("switch (StringType(" + this->expr->toCpp(switchScope) + ").id)");
		CodeWriter::writeLine("{", 1);
		for (Case* switchCase : this->cases)
		{
			StringId val = static_cast<ExpressionValue*>(switchCase->expr)->value;
			CodeWriter::writeLine("case " + String(Program::strings.indexOf(val)) + ": // " + String(val));
			if (switchCase->statements->statements.size() > 0) // Has statements
			{
				bool indent = (switchCase->statements->statements[0]->type != Type::StatementList);
				if (indent)
					CodeWriter::indent(1);
				switchCase->statements->writeCpp(switchScope, indent);
				CodeWriter::writeLine();
				if (indent)
					CodeWriter::indent(-1);
			}
			else
				switchScope->nextStatement(); // Still increment scope
		}

		if (this->defaultStatements != nullptr) // Default
		{
			CodeWriter::writeLine("default:");
			this->defaultStatements->writeCpp(switchScope, false);
		}
		CodeWriter::writeLine("}", -1);
	}

	// Regular switch
	else
	{
		CodeWriter::writeLine("switch ((IntType)" + this->expr->toCpp(switchScope) + ")");
		CodeWriter::writeLine("{", 1);

		for (Case* switchCase : this->cases) // Cases
		{
			CodeWriter::writeLine("case " + switchCase->expr->toCpp(switchScope) + ":");
			if (switchCase->statements->statements.size() > 0) // Has statements
			{
				bool indent = (switchCase->statements->statements[0]->type != Type::StatementList);
				if (indent)
					CodeWriter::indent(1);
				switchCase->statements->writeCpp(switchScope, indent);
				CodeWriter::writeLine();
				if (indent)
					CodeWriter::indent(-1);
			}
			else
				switchScope->nextStatement(); // Still increment scope
		}

		if (this->defaultStatements != nullptr) // Default
		{
			CodeWriter::writeLine("default:");
			this->defaultStatements->writeCpp(switchScope, false);
		}

		CodeWriter::writeLine("}", -1);
	}
}

SwitchStatement::Case::Case(Expression* expression, StatementList* statements)
{
	this->expr = expression;
	this->statements = statements;
}

BreakStatement::BreakStatement(int line) : Statement(line)
{
	type = Type::Break;
}

void BreakStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
}

void BreakStatement::writeCpp(ResolveScope*)
{
	CodeWriter::write("break;");
}

ContinueStatement::ContinueStatement(int line) : Statement(line)
{
	type = Type::Continue;
}

void ContinueStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
}

void ContinueStatement::writeCpp(ResolveScope*)
{
	CodeWriter::write("continue;");
}

ReturnStatement::ReturnStatement(Expression* expr, int line) : Statement(line)
{
	this->expr = expr;
	type = Type::Return;
}

void ReturnStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);

	if (this->expr == nullptr)
	{
		this->func->assignReturnType(DataType(DataType::Type::Void), this->func, this->line);
		return;
	}

	this->expr->resolve(scope);

	if (this->expr->resolvedType->cppType != DataType::CppType::Void)
		this->func->assignReturnType(*this->expr->resolvedType, this->func, this->line);
	else
		Console::writeLine("WARNING: Returning void type in {0}:{1}", this->func->name, this->line);
}

void ReturnStatement::writeCpp(ResolveScope* scope)
{
	if (this->expr != nullptr)
		CodeWriter::write("return " + this->expr->toCpp(scope) + ";");
	else
		CodeWriter::write("return;");
}

DeleteStatement::DeleteStatement(Expression* expr, int line) : Statement(line)
{
	this->expr = expr;
	type = Type::Delete;
}

void DeleteStatement::resolve(ResolveScope* scope)
{
	location = Location(*scope->location);
	this->expr->resolve(scope);
}

void DeleteStatement::writeCpp(ResolveScope* scope)
{
	CodeWriter::write("delete Obj(" + this->expr->toCpp(scope) + ");");
}

CustomCppStatement::CustomCppStatement(String cpp, int line) : Statement(line)
{
	this->cpp = cpp;
	type = Type::CustomCpp;
}

void CustomCppStatement::resolve(ResolveScope*)
{}

void CustomCppStatement::writeCpp(ResolveScope*)
{
	CodeWriter::write(this->cpp);
}

}
