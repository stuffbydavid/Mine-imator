#pragma once

#include "Runtime.hpp"

namespace CppGen
{

class Token;
class DataType;
class CodeObject;
class Statement;
class ResolveScope;
class Variable;
class Expression;
class ExpressionParenthesis;
class UnaryOperation;
class BinaryOperation;
class TernaryCondition;
class ExpressionArray;
class ExpressionValue;
class Accessor;
class NewExpression;
class Declaration;
class DeclarationList;
class StatementList;
class DeclareStatement;
class MacroStatement;
class EnumStatement;
class CallStatement;
class AssignStatement;
class IfStatement;
class WhileStatement;
class DoUntilStatement;
class ForStatement;
class RepeatStatement;
class WithStatement;
class SwitchStatement;
class BreakStatement;
class ContinueStatement;
class ReturnStatement;
class DeleteStatement;
class CustomCppStatement;
class Function;
class ExternalFunction;
class Object;
class Sprite;
class Shader;
class GML;
class CodeWriter;
class Program;

class Token
{
public:
	enum class Type
	{
		Unknown,
		ID, // ID to a function, variable, resource or keyword
		Number, // Number value
		String, // "String value"
		LeftBrace, // {
		RightBrace, // }
		LeftPar, // (
		RightPar, // )
		LeftSquare, // [
		RightSquare, // ]
		Separator, // ,
		Terminator, // ;
		Member, // .
		Assign, // =
		Equal, // ==
		NotEqual, // !=
		Ternary, // ?
		Colon, // :
		Inverse, // !
		Larger, // >
		LargerEq, // >=
		Less, // <
		LessEq, // <=
		And, // &&
		Or, // ||
		Add, // +
		AddLong, // +=
		AddShort, // ++
		Sub, // -
		SubLong, // -=
		SubShort, // --
		Mul, // *
		MulLong, // *=
		Div, // /
		DivLong, // /=
		DivInt, // div
		Modulus, // % or mod
		ShiftLeft, // <<
		ShiftRight, // >>
		BitwiseOr, // |
		BitwiseAnd, // &
		HashTag, // #
		ArrayRef, // @
		CppOnly,
		Error
	};

	Type type{};
	String value{};
	int fileOffset{};
	int line{};
	int lineOffset{};
	int length{};

	// Gets the C++ string of the token.
	static String toCpp(Type type);
};

// Stores the possible data types of a variable, function argument or return type.
class DataType
{
public:
	enum class Type
	{
		Unknown,
		Variant,
		Null,
		Void,
		Bool,
		IntOrReal,
		Integer,
		Real,
		String,
		Reference,
		Array,
		Vector,
		Matrix,
		List,
		AnyMap,
		IntMap,
		StringMap,
		Map,
		Grid,
		Stack,
		Priority
	};

	enum class CppType
	{
		Void,
		RealType,
		IntType,
		BoolType,
		StringType,
		VecType,
		MatrixType,
		ArrType,
		VarType
	};

	// Stores a possible data type and what function it got assigned first.
	class Assignment
	{
	public:
		Type rawType{};
		String refId = ""; // Object name
		std::unique_ptr<DataType> containerStorage{};
		DataType* containerType = nullptr;
		Function* func{};
		int line{};

		Assignment(const Assignment& other);
		Assignment(Assignment&& other) noexcept;
		Assignment& operator=(const Assignment& other);
		Assignment& operator=(Assignment&& other) noexcept;
		virtual ~Assignment();
		Assignment(const Assignment& other, Function* func, int line);
		Assignment(Type type, String refId, DataType* containerType, Function* func = nullptr, int line = 0);

		// Returns the assignment in string form with <> for containers/references.
		virtual String toString();
	};

	List<Assignment> assignments = List<Assignment>();
	CppType cppType = CppType::VarType;

	// Can be set for debugging purposes the geneate all types as VarType.
	inline static bool allVarType = false;

	// Set automatically when generating code that needs types.
	inline static bool ignoreAllVarType = false;

	// Copy a DataType
	DataType(const DataType& other);
	DataType(DataType* other) : DataType(*other) {}
	DataType(DataType&&) noexcept = default;
	DataType& operator=(const DataType& other);
	DataType& operator=(DataType&&) noexcept = default;
	virtual ~DataType() = default;

	// Create a generic type
	DataType(Type rawType = Type::Unknown);

	// Create a reference type
	DataType(Type rawType, String refId);

	// Create a container type
	DataType(Type rawType, DataType* containerType);

	// Create a DataType from a text string
	DataType(String name);

	// Update the C++ type.
	void updateCppType();

	// Returns the C++ struct of the type.
	String toCpp();

	// Converts the type to a C++ member macro.
	String toCppMemberMacro();

	// Converts the type to a default value in C++.
	String toCppDefaultValue();

	// Converts the type to the Type character in C++.
	String toCppEnum();

	// Returns whether the type is a C++ VarType.
	bool isCppVarType();

	// Returns a string with all type assignments in the project, if more than one.
	String getAssignmentsString(String tabs = "");

	// Returns the type in string form with <> for containers/references or "Variant" for multiple types.
	virtual String toString();

	// Returns whether the type has not been assigned any raw type.
	bool isUnknown();

	// Returns whether the given raw type is a real number.
	static bool isRawTypeReal(Type type);

	// Returns whether the given raw type is accessed using [i] or [@i].
	static bool isRawTypeArray(Type type);

	// Returns whether the given raw type is a map.
	static bool isRawTypeMap(Type type);

	// Returns whether the type has been assigned a real number.
	bool isReal();

	// Returns whether the type can store other types and use the [] operator.
	bool isContainer();

	// Returns the first assignment that matches the raw type, or null if not found.
	Assignment* getFirstAssignment(Type rawType = Type::Unknown);

	// Returns all assignments that matches the raw type.
	List<Assignment*> getAssignments(Type rawType = Type::Unknown);

	// Returns an unique object reference id assigned to the type, or empty string if not found.
	String getUniqueReferenceId();

	// Returns the map type of the datatype.
	Type getMapType();

	// Assign another DataType class to this one. Returns whether the type was updated.
	bool assign(const DataType& inputType, Function* func, int line, int containerLevel = 0);

	// Reinitializes solver-owned storage without changing its stable address.
	void reset(Type rawType = Type::Unknown);
	void reset(Type rawType, const String& refId);
	void reset(Type rawType, DataType* containerType);
	void reset(Type rawType, DataType containerType);
	void reset(const DataType& other);
	void reset(DataType* other) { reset(*other); }
};

// A statement or expression in the code.
class CodeObject
{
public:
	Function* func{};
	int line{};
	inline static int totalObjects = 0;
	inline static int unknownScopes = 0;

	CodeObject(int line);
	virtual ~CodeObject() = default;

	// Writes a variable name in a C++ safe format.
	static String nameToCpp(String name);

	// Adds object/function/global variables from within the CodeObject and saves the evaulated GML type.
	virtual void resolve(ResolveScope* scope);
};

// Generic statement
class Statement : public CodeObject
{
public:
	enum class Type
	{
		DeclarationList,
		StatementList,
		Declare,
		Macro,
		Enum,
		Call,
		Assign,
		If,
		While,
		DoUntil,
		For,
		Repeat,
		With,
		Switch,
		Break,
		Continue,
		Return,
		Delete,
		CustomCpp
	};

	// A location of a statement in a function.
	class Location
	{
	public:
		List<int> path = List<int>(); // Empty list for root, remaining are a sequence of int Ids
		int level = 0;
		int nextId = 0;

		Location();
		Location(const Location& other);
		Location& operator=(const Location& other) = default;
		virtual ~Location() = default;

		// Returns the next location.
		Location next(bool addLevel = false);

		// Returns whether the given location is a statement inside this one.
		bool contains(const Location& other) const;

		// Returns whether this location equals another.
		bool equals(const Location& other) const;
		virtual String toString();
	};

	Type type{};
	bool hasCpp = true;
	std::optional<Location> location{};

	Statement(int line);

	// Write the C++ code of the statement using the CodeWriter class.
	virtual void writeCpp(ResolveScope* scope);
};

// Stores the current and previous context when resolving functions, statements and expressions.
class ResolveScope
{
public:
	class Call
	{
	public:
		String funcName{};
		int line{};

		Call(const String& funcName, int line);
	};

	InternedString current = "";
	InternedString currentInChain = ""; // For tracking the scope in accessor chains
	InternedString previous = "";
	Function* funcUpdateScope = nullptr;
	std::shared_ptr<const List<Call>> calls{};
	std::shared_ptr<Statement::Location> location{};

	ResolveScope(const String& current = "", const String& previous = "", const std::shared_ptr<const List<Call>>& updatedCalls = nullptr, const String& currentInChain = "", const std::shared_ptr<Statement::Location>& location = nullptr, Function* funcUpdateScope = nullptr);

	// Adds a new function call to a copy of the scope
	ResolveScope(const ResolveScope& scope, const String& callFunc, int callLine);

	// Enters a new statement.
	ResolveScope nextStatement(bool addLevel = false);

	// Enters a new with() statement.
	ResolveScope enterWithStatement(const String& newScope, const String& otherScope);

	// Moves to the next in the Accessor chain
	ResolveScope nextInChain(const String& nextInChain);

	// Returns the ResolveScope outside of the current chain (if any)
	ResolveScope outsideChain();

	ResolveScope* operator->() { return this; }
	const ResolveScope* operator->() const { return this; }
	operator ResolveScope*() { return this; }

	// Returns whether a function has been called.
	bool isCalled(const String& funcName);

	// Prints the list of calls to the log
	void debugCalls();
};

// An instance, local or global variable
class Variable
{
public:
	String scope{}; // Can be an object name, function name, "global" or "" for unknown
	String name{};
	DataType typeStorage{};
	DataType* type = &typeStorage;
	int line{};
	Statement::Location location{};
	bool isReference = false;
	inline static int totalVariables = 0;
	inline static int variantVariables = 0;

	Variable(String scope, String name, const DataType& type, int line = 0, const Statement::Location& location = Statement::Location());
	bool assignType(const DataType& inputType, Function* sourceFunc, int sourceLine);

	// Marks a function argument as a reference.
	void markReference();
};

// Expression base class
class Expression : public CodeObject
{
public:
	enum class Type
	{
		Accessor,
		Parenthesis,
		BinaryOperation,
		UnaryOperation,
		TernaryCondition,
		Array,
		Value,
		New
	};

	Type type{};
	DataType resolvedTypeStorage{};
	DataType* resolvedType = &resolvedTypeStorage;
	DataType writtenTypeStorage{};
	DataType* writtenType = &writtenTypeStorage;
	DataType::CppType resolvedTypeCpp = DataType::CppType::Void; // If not void, can override the resolved C++ type
	Variable* assignedTo = nullptr;

	Expression(int line);

	// Applies a derived type to the Expression and sub-expressions. Returns whether it will modify a variable in the project.
	virtual bool applyType(ResolveScope* scope, const DataType& inputType);

	// Returns the C++ code of the expression.
	virtual String toCpp(ResolveScope* scope);

	// Wraps an expression in (x > 0) if needed, since C++ conditions are true for negative values.
	virtual String toConditionCpp(ResolveScope* scope, bool parenthesis);

	// Returns a C++ ternary string from the given expressions.
	static String toTernaryCpp(ResolveScope* scope, Expression* expr1, Expression* expr2, Expression* expr3);

	// Returns a C++ array containing the given expressions as elements.
	static String toExpressionArrayCpp(ResolveScope* scope, List<Expression*> expressions);

	// Returns whether the expression is a integer value.
	bool isIntValue();

	// Returns whether the expression is a real value.
	bool isRealValue();

	// If the expression is an accessor without a chain, returns the name of it.
	virtual String getAccessorName();

	// Returns the resolved type as a C++ type
	DataType::CppType getResolvedCppType();
};

// An expression in parenthesis
class ExpressionParenthesis : public Expression
{
public:
	Expression* expr{};

	ExpressionParenthesis(Expression* expr, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual bool applyType(ResolveScope* scope, const DataType& inputType) override;
	virtual String toCpp(ResolveScope* scope) override;
	virtual String toConditionCpp(ResolveScope* scope, bool parenthesis) override;
};

// Operation taking a single expression
class UnaryOperation : public Expression
{
public:
	Token::Type op{};
	Expression* expr{};

	UnaryOperation(Token::Type op, Expression* expr, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual bool applyType(ResolveScope* scope, const DataType& inputType) override;
	virtual String toCpp(ResolveScope* scope) override;
};

// Operation taking two expressions
class BinaryOperation : public Expression
{
public:
	Token::Type op{};
	Expression* left{};
	Expression* right{};

	BinaryOperation(Token::Type op, Expression* left, Expression* right, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual bool applyType(ResolveScope* scope, const DataType& inputType) override;
	virtual String toCpp(ResolveScope* scope) override;
};

// Ternary expression
class TernaryCondition : public Expression
{
public:
	Expression* expr1{};
	Expression* expr2{};
	Expression* expr3{};

	TernaryCondition(Expression* expr1, Expression* expr2, Expression* expr3, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual bool applyType(ResolveScope* scope, const DataType& inputType) override;
	virtual String toCpp(ResolveScope* scope) override;
};

// Array
class ExpressionArray : public Expression
{
public:
	List<Expression*> expressions{};

	ExpressionArray(List<Expression*> expressions, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual String toCpp(ResolveScope* scope) override;
};

// Expression value (string or number)
class ExpressionValue : public Expression
{
public:
	Token::Type valueType{};
	String value{};

	ExpressionValue(Token::Type valueType, String value, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual bool applyType(ResolveScope* scope, const DataType& inputType) override;
	virtual String toCpp(ResolveScope* scope) override;
};

// Variable/Function accessor
// Accessors can be chained via the member symbol . and have array accessors/function parameters.
//  varName
//  instanceVarName.member
//  funcName(parameters...)
//  structName.funcName(parameters...)
//  array[type expression]
//  array[type expression].member
class Accessor : public Expression
{
public:
	class ArrayAccessor
	{
	public:
		DataType::Type type{};
		Expression* expr{};
		bool isReference{};

		ArrayAccessor(DataType::Type type, Expression* expression, bool isRef);
	};

	String name{};
	List<ArrayAccessor*> arrayAccessors{};
	List<Expression*> callParameters{};
	Accessor* nextInChain = nullptr;
	Accessor* previousInChain = nullptr;
	Token::Type addSubOp = Token::Type::Unknown;
	Expression* assignExpr = nullptr;
	bool needLtZero = false;
	bool appToId = true;
	inline static bool resolveUnknownMapTypes = false;
	inline static bool resolveUnknownScope = false;
	inline static bool resolveFunctionReferences = false;
	ResolveScope lastToCppScope{};
	bool lastToCppScopeSet = false;

	Accessor(String name, List<ArrayAccessor*> arrayAccessors, List<Expression*> callParameters, Accessor* member, Token::Type addSubOp, int line);

	// Marks the accessor as an assignment.
	void markAsAssign(Expression* expr);

	// Resolve accessor (when used within an expression or function call statement)
	virtual void resolve(ResolveScope* scope) override;

	// Apply a type to the accessor when assigned
	virtual bool applyType(ResolveScope* scope, const DataType& inputType) override;

	// Write the C++ code of the accessor.
	virtual String toCpp(ResolveScope* scope) override;

	// Wraps an accessor in (x > 0) since C++ conditions are true for negative values.
	virtual String toConditionCpp(ResolveScope* scope, bool parenthesis) override;

	// Find the scope of the accessor next in the chain.
	String getNextInChainScope(ResolveScope* scope);

	// Finds an user function with the given name in a scope, or null if none exists.
	Function* getUserFunction(ResolveScope* scope);
	virtual String getAccessorName() override;
};

// New expression
class NewExpression : public Expression
{
public:
	Accessor* acc{};

	NewExpression(Accessor* accessor, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual String toCpp(ResolveScope* scope) override;
};

// Generic declaration
class Declaration
{
public:
	String name{};
	Expression* expr{};
	bool isReference = false;

	Declaration(String name, Expression* expr);
};

// List of local or global declarations
class DeclarationList : public Statement
{
public:
	using CodeObject::resolve;
	using Statement::writeCpp;

	enum class WriteFormat
	{
		ArgsHeader, // type1 arg1, type2 arg2 [= expr]...
		ArgsImpl, // type1 arg1, type2 arg2...
		Var, // int int1 [= expr], int2 [= expr];\n double db1 [= expr], db2 [= expr]; ...
		Enum // enumName_name1 [= expr],\n enumName_name2 [= expr] ...
	};

	List<Declaration*> declarations{};
	bool isEnum = false;
	bool isArgs = false;
	int requiredArgs = 0;

	DeclarationList(List<Declaration*> declarations, bool isArgs, int line);

	// Resolve declaration types, returns if they have changed since last time from the given input.
	bool resolve(ResolveScope* scope, const String& declScope, const List<DataType*>& inputPars = nullptr);
	void writeCpp(ResolveScope* scope, WriteFormat format, String enumPrefix = "");
};

// Statement list
class StatementList : public Statement
{
public:
	List<Statement*> statements{};

	StatementList(int line);
	void addStatement(Statement* stmt);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
	void writeCpp(ResolveScope* scope, bool brackets);
};

// Declare variable statement (var/globalvar)
class DeclareStatement : public Statement
{
public:
	bool globalScope{};
	DeclarationList* declarations{};
	inline static List<DeclareStatement*> globalDeclarations = List<DeclareStatement*>();

	DeclareStatement(bool globalScope, DeclarationList* declarations, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// Define macro statement
class MacroStatement : public Statement
{
public:
	String name{};
	Expression* expr{};

	MacroStatement(String name, Expression* expr, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// Enum statement
class EnumStatement : public Statement
{
public:
	String name{};
	DeclarationList* declarations{};

	EnumStatement(String name, DeclarationList* declarations, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// Call statement
class CallStatement : public Statement
{
public:
	Accessor* acc{};

	CallStatement(Accessor* accessor, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// Assign statement
class AssignStatement : public Statement
{
public:
	Accessor* target{};
	Token::Type op{};
	Expression* expr{};

	AssignStatement(Accessor* target, Token::Type op, Expression* expression, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// If statement
class IfStatement : public Statement
{
public:
	Expression* condition{};
	CppGen::Statement* statement{};
	CppGen::Statement* elseStatement{};

	IfStatement(Expression* condition, CppGen::Statement* statement, CppGen::Statement* elseStatement, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// While statement
class WhileStatement : public Statement
{
public:
	Expression* loopCondition{};
	CppGen::Statement* statement{};

	WhileStatement(Expression* loopCondition, CppGen::Statement* statement, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// Do statement
class DoUntilStatement : public Statement
{
public:
	CppGen::Statement* statement{};
	Expression* breakCondition{};

	DoUntilStatement(CppGen::Statement* statement, Expression* breakCondition, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// For statement
class ForStatement : public Statement
{
public:
	CppGen::Statement* initStatement{};
	Expression* loopCondition{};
	CppGen::Statement* incStatement{};
	CppGen::Statement* statement{};

	ForStatement(CppGen::Statement* initStatement, Expression* loopCondition, CppGen::Statement* incStatement, CppGen::Statement* statement, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// Repeat statement
class RepeatStatement : public Statement
{
public:
	Expression* expr{};
	CppGen::Statement* statement{};

	RepeatStatement(Expression* expr, CppGen::Statement* statement, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// With statement
class WithStatement : public Statement
{
public:
	Expression* expr{};
	CppGen::Statement* statement{};
	inline static bool resolveUnknownScope = false;
	List<String> otherScopes = List<String>();
	String otherScope = "";

	WithStatement(Expression* expression, CppGen::Statement* statement, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// Switch statement
class SwitchStatement : public Statement
{
public:
	// Case
	class Case
	{
	public:
		Expression* expr{};
		StatementList* statements{};

		Case(Expression* expression, StatementList* statements);
	};

	Expression* expr{};
	List<Case*> cases{};
	StatementList* defaultStatements{};
	DataType caseResolvedTypeStorage{};
	DataType* caseResolvedType = &caseResolvedTypeStorage;

	SwitchStatement(Expression* expression, List<Case*> cases, StatementList* defaultStatements, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// Break statement
class BreakStatement : public Statement
{
public:
	BreakStatement(int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// Continue statement
class ContinueStatement : public Statement
{
public:
	ContinueStatement(int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// Return statement
class ReturnStatement : public Statement
{
public:
	Expression* expr{};

	ReturnStatement(Expression* expr, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// Delete statement
class DeleteStatement : public Statement
{
public:
	Expression* expr{};

	DeleteStatement(Expression* expr, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// Custom C++ statement
class CustomCppStatement : public Statement
{
public:
	String cpp{};

	CustomCppStatement(String cpp, int line);
	virtual void resolve(ResolveScope* scope) override;
	virtual void writeCpp(ResolveScope* scope) override;
};

// Function
class Function
{
public:
	// Assigns a scope to a function whenever an instance variable is accessed in a with() scope, or another function with an instance scope is called.
	class ScopeAssignment
	{
	public:
		String scope{};
		Function* func{};
		int line{};

		ScopeAssignment(String scope, Function* func, int line);
	};

	String name = "";
	String gml{};
	List<Token> tokens = List<Token>();
	DeclarationList* args{};
	bool varArgs = false;
	List<Variable*> vars = List<Variable*>();
	List<String> varArgsRequiredNames = List<String>();
	StatementList* statements{};
	Object* structObject = nullptr;
	List<String> cppLinesBegin = List<String>();
	List<String> cppLinesEnd = List<String>();
	bool isCppSeparate = false;
	String cppSeparateHeader = "";
	DataType cppSeparateReturnTypeStorage{};
	DataType* cppSeparateReturnType = nullptr;
	List<Variable*> instanceVarDecls = List<Variable*>();
	List<ScopeAssignment*> scopeAssignments = List<ScopeAssignment*>();
	List<String> scopesTraversed = List<String>();
	List<Function*> sameScopeFunctions = List<Function*>();
	DataType returnTypeStorage{};
	DataType* returnType = &returnTypeStorage;
	ReturnStatement* returnStatement = nullptr;
	bool endsWithReturnStatement = false;
	bool hasInstanceVars = false;
	bool isUnused = true;
	bool isTraversed = false;
	bool isConstructor = false;
	bool isDestructor = false;
	inline static bool enableAssignScope = false;
	inline static Function* currentParseFunction = nullptr;
	inline static int currentParseLine = 0;
	int tokenIndex = 0;
	Token::Type lastPeeked{};
	Token* currentToken = nullptr;
	bool implWritten = false;

	Function(String name, String gml = "", bool isCppSeparate = false, String cppSeparateHeader = "");

	// Returns the scope of the function, or "any" when executed in multiple scopes.
	String getScope();

	// Assigns a scope to the function when an instance variable is found.
	bool assignScope(String scope, Function* func, int line, bool foundInstanceVar = false);

	// Assigns the scope of another function.
	void assignFunctionScope(Function* otherFunc, Function* func, int line);

	// Writes the C++ arguments of the function.
	void writeCppArguments(DeclarationList::WriteFormat format);

	// Write the C++ header of the function.
	void writeCppHeader();

	// Write the C++ implementation of the function. Returns whether anything was written.
	bool writeCppImplementation();

	// Returns a C++ lambda for executing the function using script_execute or the idFunc macro.
	String toExecuteCpp();

	// Returns a debug string of the function and its variables
	String toDebugString(String tabs = "");

	// Resolves the variables in the function, recursively calling other functions as they appear.
	void resolve(ResolveScope* scope, const List<DataType*>& inputPars = nullptr, Function* func = nullptr, int line = 0);

	// Sets the return type of the function, if it changes then all functions dependent on this one are marked unresolved.
	void assignReturnType(const DataType& type, Function* func, int line);

	// Gets the return type of the function.
	DataType* getReturnType();

	// Parses the tokens and creates a statement list of the function.
	void parseTokens();

	// Returns the current token type.
	Token::Type peekToken();

	// Advances to the next token.
	Token* nextToken(Token::Type expectedType, String expectedValue = "");
	StatementList* parseStatementList();
	Statement* parseStatement();
	DeclarationList* parseDeclarations(bool isArgs = false);
	Accessor* parseAccessor();
	Expression* parseExpr();
	Expression* parseExprAndOr();
	Expression* parseExprEq();
	Expression* parseExprComp();
	Expression* parseExprAddSub();
	Expression* parseExprMulDiv();
	Expression* parseExprModInvNegate();
	Expression* parseExprValue();
	List<Expression*> parseParameterList();
};

// Stores an external function whenever external_define is called.
class ExternalFunction
{
public:
	String name{};
	DataType* returnType{};
	List<DataType*> argTypes{};

	ExternalFunction(String name, DataType* returnType, List<DataType*> argTypes);

	// Writes the C++ header of the external function.
	void writeCppHeader();
};

// A GameMaker object or a struct in the code.
// For objects, the Create Event is the constructor and Destroy Event the destructor.
// For structs, the declaration is the contructor, with no destructor. Static functions are added into InstanceFunctions.
class Object
{
public:
	String name{};
	Function* createFunction = nullptr;
	Function* destroyFunction = nullptr;
	Function* constructor = nullptr;
	Function* destructor = nullptr;
	OrderedMap<Function*> instanceFunctions = OrderedMap<Function*>();
	OrderedMap<Variable*> instanceVars = OrderedMap<Variable*>();
	bool isStruct = false;
	bool implWritten = false;

	Object(String name, bool isStruct);
	Object(String dir);

	// Sets the constructor of the object.
	void setConstructor(Function* func);

	// Sets the destructor of the object.
	void setDestructor(Function* func);

	// Writes the C++ header of the object.
	void writeCppHeader();

	// Writes the C++ implementation of the object. Returns whether anything was written.
	bool writeCppImplementation();

	// Writes the commands for storing the memory locations of each object member and functions.
	void writeInitMembers();

	// Returns a string containing the functions and variables of the object.
	String toDebugString(String tabs = "");
};

class Sprite
{
public:
	String name{};
	int numFrames = 0;
	inline static int totalCopied = 0;
	int originX = 0;
	int originY = 0;

	// Copies sprite frames to the CppProject.
	Sprite(String dir, String outputFolder);
};

class Shader
{
public:
	class FileModification
	{
	public:
		String source{};
		String dest{};

		FileModification(String source, String dest);
	};

	String name{};
	bool isValid = false;
	inline static int totalCopied = 0;
	inline static List<FileModification*> modifications = List<FileModification*>();

	// Copies GLSL ES shaders to the CppProject.
	Shader(String dir, String outputFolder);
};

class GML
{
public:
	// Function signature
	class FunctionSignature
	{
	public:
		String name{};
		DataType* returnType{};
		List<DataType*> argTypes = List<DataType*>();
		bool varArgs = false;
		bool needScope = false;
		bool varCreateRef = false;

		FunctionSignature(String name, DataType* returnType, List<DataType*> argTypes, bool varArgs, bool needScope, bool varCreateRef);
	};

	inline static List<String> keywords = List<String>();
	inline static OrderedMap<double> constants = OrderedMap<double>();
	inline static OrderedMap<DataType*> variables = OrderedMap<DataType*>();
	inline static OrderedMap<FunctionSignature*> functions = OrderedMap<FunctionSignature*>();
	inline static int totalLines = 0;

	// Parse the gml.json file and store the spec in the above variables.
	static void parseGMLSpec(String file);

	// Generate GML variables headers.
	static void exportHeader(String file);

	// Parses a GML script file and generates functions with tokens.
	static void parseGMLScript(String file);
};

// Helper class for generating a code file.
class CodeWriter
{
public:
	inline static int indentLevel{};
	inline static bool indented{};
	inline static String indentString{};
	inline static int lines{};
	inline static int totalLines = 0;
	inline static int totalFilesUpdated = 0;
	inline static bool isNewLine = false;
	inline static StringBuilder builder{};

	static void begin(String indentation = "\t");
	static void write(const String& code);
	static void writeLine(const String& code = "", int indentDelta = 0);
	static void erase(int characters);
	static void indent(int delta);
	static void end(String outputFile);
	static void writeIndent();
};

// CppGen console application.
class Program
{
public:
	inline static OrderedMap<Object*> objects = OrderedMap<Object*>();
	inline static OrderedMap<Sprite*> sprites = OrderedMap<Sprite*>();
	inline static OrderedMap<Shader*> shaders = OrderedMap<Shader*>();
	inline static OrderedMap<Function*> functions = OrderedMap<Function*>();
	inline static OrderedMap<ExternalFunction*> externalFunctions = OrderedMap<ExternalFunction*>();
	inline static OrderedMap<Variable*> globalVars = OrderedMap<Variable*>();
	inline static OrderedMap<Variable*> unknownScopeVars = OrderedMap<Variable*>();
	inline static OrderedMap<MacroStatement*> macros = OrderedMap<MacroStatement*>();
	inline static OrderedMap<EnumStatement*> enums = OrderedMap<EnumStatement*>();
	inline static List<String> strings = List<String>();
	inline static Function* appStepFunction = nullptr;
	inline static Function* appDrawFunction = nullptr;
	inline static Function* appHttpFunction = nullptr;
	inline static Function* appGameEndFunction = nullptr;
	inline static List<String> syntaxErrors = List<String>();
	inline static bool mergeUnknownVars = false;
	inline static OrderedMap<DataType*> varTypeOverride = OrderedMap<DataType*>{{"build_pos", makeObject<DataType>(DataType::Type::Integer)}, {"build_pos_x", makeObject<DataType>(DataType::Type::Integer)}, {"build_pos_y", makeObject<DataType>(DataType::Type::Integer)}, {"build_pos_z", makeObject<DataType>(DataType::Type::Integer)}, {"build_size_x", makeObject<DataType>(DataType::Type::Integer)}, {"build_size_y", makeObject<DataType>(DataType::Type::Integer)}, {"build_size_z", makeObject<DataType>(DataType::Type::Integer)}, {"build_size_xy", makeObject<DataType>(DataType::Type::Integer)}, {"build_size_total", makeObject<DataType>(DataType::Type::Integer)}, {"build_single_stateid", makeObject<DataType>(DataType::Type::Integer)}, {"block_pos_x", makeObject<DataType>(DataType::Type::Integer)}, {"block_pos_y", makeObject<DataType>(DataType::Type::Integer)}, {"block_pos_z", makeObject<DataType>(DataType::Type::Integer)}, {"blockstartpos", makeObject<DataType>(DataType::Type::Integer)}, {"blockendpos", makeObject<DataType>(DataType::Type::Integer)}};

	// Main script entry.
	// Arg 0 = Mine-imator project folder (default: DEV_DIR/Mine-imator)
	// Arg 1 = gml.json file (default: ./gml.json)
	static void main(List<String> args);
	static void resolveProject();

	// Finds a variable with the given name in the current scope and line, or null if it can't be found.
	static Variable* findVariable(String scope, String name, Function* func, const Statement::Location& location, int line, Function* funcAssignScope = nullptr, bool includeUnknown = true);

	// Declares a new variable with its scope and optional type and returns it.
	static Variable* declareVariable(String scope, String name, const DataType& type, Function* func, const Statement::Location& location, int line = 0, Function* funcAssignScope = nullptr);
	static void addSyntaxError(String text);

	// Print debug files.
	static void printDebugFiles();
};
}
