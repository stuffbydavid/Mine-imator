#include "CppGen.hpp"

namespace CppGen
{
Expression::Expression(int line) : CodeObject(line)
{}

bool Expression::applyType(ResolveScope*, const DataType&)
{
	return false;
}

String Expression::toCpp(ResolveScope*)
{
	return "";
}

String Expression::toConditionCpp(ResolveScope* scope, bool)
{
	return toCpp(scope);
}

String Expression::toTernaryCpp(ResolveScope* scope, Expression* expr1, Expression* expr2, Expression* expr3)
{
	bool expr2TypeVarType = expr2->getResolvedCppType() == DataType::CppType::VarType;
	bool expr3TypeVarType = expr3->getResolvedCppType() == DataType::CppType::VarType;

	String cpp = expr1->toConditionCpp(scope, true) + " ? ";

	if (expr3TypeVarType && !expr2TypeVarType) // Wrap expr2 in VarType() if expr3 is VarType
		cpp += "VarType(" + expr2->toCpp(scope) + ")";
	else
		cpp += expr2->toCpp(scope);

	cpp += " : ";

	if (expr2TypeVarType && !expr3TypeVarType) // Wrap expr3 in VarType() if expr2 is VarType
		cpp += "VarType(" + expr3->toCpp(scope) + ")";
	else
		cpp += expr3->toCpp(scope);

	return cpp;
}

String Expression::toExpressionArrayCpp(ResolveScope* scope, List<Expression*> expressions)
{
	if (expressions.size() == 0)
		return "{}";

	String cpp = "{ ";
	int p = 0;
	for (Expression* expr : expressions)
		cpp += (p++ > 0 ? ", " : "") + expr->toCpp(scope);
	cpp += " }";
	return cpp;
}

bool Expression::isIntValue()
{
	if (type != Type::Value)
		return false;

	ExpressionValue* exprValue = static_cast<ExpressionValue*>(this);
	return (exprValue->valueType == Token::Type::Number && !String(exprValue->value).contains("."));
}

StringId Expression::getAccessorName()
{
	return Strings::Empty;
}

DataType::CppType Expression::getResolvedCppType()
{
	return this->resolvedTypeCpp != DataType::CppType::Void ? this->resolvedTypeCpp : this->resolvedType->cppType;
}

ExpressionParenthesis::ExpressionParenthesis(Expression* expr, int line) : Expression(line)
{
	this->expr = expr;
	type = Type::Parenthesis;
}

void ExpressionParenthesis::resolve(ResolveScope* scope)
{
	this->expr->resolve(scope);
	this->resolvedType = this->expr->resolvedType;
	this->resolvedTypeCpp = this->expr->resolvedTypeCpp;
}

bool ExpressionParenthesis::applyType(ResolveScope* scope, const DataType& inputType)
{
	bool changed = this->expr->applyType(scope, inputType);
	this->resolvedType = this->expr->resolvedType;
	this->resolvedTypeCpp = this->expr->resolvedTypeCpp;
	return changed;
}

String ExpressionParenthesis::toCpp(ResolveScope* scope)
{
	return "(" + this->expr->toCpp(scope) + ")";
}

String ExpressionParenthesis::toConditionCpp(ResolveScope* scope, bool)
{
	return "(" + this->expr->toConditionCpp(scope, false) + ")";
}

UnaryOperation::UnaryOperation(Token::Type op, Expression* expr, int line) : Expression(line)
{
	this->op = op;
	this->expr = expr;
	type = Type::UnaryOperation;
}

void UnaryOperation::resolve(ResolveScope* scope)
{
	this->expr->resolve(scope);

	if (this->op == Token::Type::Sub) // -
	{
		this->expr->applyType(scope, DataType::scalar(DataType::Type::IntOrReal));
		this->resolvedType = this->expr->resolvedType;
	}
	else // !
		this->resolvedType->reset(DataType::Type::Bool);
}

bool UnaryOperation::applyType(ResolveScope* scope, const DataType& inputType)
{
	if (this->op == Token::Type::Sub)
	{
		bool changed = this->expr->applyType(scope, inputType);
		this->resolvedType = this->expr->resolvedType;
		return changed;
	}
	else
		return false;
}

String UnaryOperation::toCpp(ResolveScope* scope)
{
	if (this->op == Token::Type::Sub) // -
		return "-" + this->expr->toCpp(scope);
	else // !
		return "!" + this->expr->toConditionCpp(scope, true);
}

BinaryOperation::BinaryOperation(Token::Type op, Expression* left, Expression* right, int line) : Expression(line)
{
	this->op = op;
	this->left = left;
	this->right = right;
	type = Type::BinaryOperation;
}

void BinaryOperation::resolve(ResolveScope* scope)
{
	this->left->resolve(scope);
	this->right->resolve(scope);

	if (this->op == Token::Type::BitwiseAnd || this->op == Token::Type::BitwiseOr ||
		this->op == Token::Type::ShiftLeft || this->op == Token::Type::ShiftRight) //  &, |, <<, >>, both expressions must be integer
	{
		this->left->applyType(scope, DataType::scalar(DataType::Type::Integer));
		this->right->applyType(scope, DataType::scalar(DataType::Type::Integer));
	}
	else if (this->op == Token::Type::Div) // /, both expressions must be real
	{
		this->left->applyType(scope, DataType::scalar(DataType::Type::Real));
		this->right->applyType(scope, DataType::scalar(DataType::Type::Real));
	}

	if (this->op == Token::Type::Or || this->op == Token::Type::And || this->op == Token::Type::Equal || this->op == Token::Type::NotEqual) // ||, &&, ==, != returns bool
		this->resolvedType->reset(DataType::Type::Bool);
	else if (this->op == Token::Type::Add)
		this->resolvedType = this->left->resolvedType;
	else
	{
		if (this->op != Token::Type::Div)
			if (this->left->getResolvedCppType() == DataType::CppType::VarType ||
				this->right->getResolvedCppType() == DataType::CppType::VarType)
				this->resolvedTypeCpp = DataType::CppType::VarType;

		this->resolvedType->reset(DataType::Type::Real);
	}
}

bool BinaryOperation::applyType(ResolveScope* scope, const DataType& inputType)
{
	bool leftChanged = false, rightChanged = false;
	if (this->op == Token::Type::Add) // +, both types are the same
	{
		leftChanged = this->left->applyType(scope, inputType);
		rightChanged = this->right->applyType(scope, inputType);
	}

	return (leftChanged || rightChanged);
}

String BinaryOperation::toCpp(ResolveScope* scope)
{
	if (this->op == Token::Type::Modulus) // mod
		return "mod(" + this->left->toCpp(scope) + ", " + this->right->toCpp(scope) + ")";

	if (this->left->type == Type::Accessor && this->right->type == Type::Accessor) // App pointer to app asset id
	{
		if (((Accessor*)this->left)->name == STR(object_index))
			((Accessor*)this->right)->appToId = false;
		if (((Accessor*)this->right)->name == STR(object_index))
			((Accessor*)this->left)->appToId = false;
	}

	String cpp = "";
	bool opNeedInts = (
		this->op == Token::Type::ShiftLeft ||
		this->op == Token::Type::ShiftRight ||
		this->op == Token::Type::BitwiseAnd ||
		this->op == Token::Type::BitwiseOr
	);
	if (opNeedInts) // Cast left to int
		cpp += "(IntType)";
	else if (this->op == Token::Type::Mul && this->left->resolvedType->cppType == DataType::CppType::BoolType) // Cast left bool to int when multiplying
		cpp += "(IntType)";
	else if (this->op == Token::Type::Div && this->left->resolvedType->cppType != DataType::CppType::RealType) // Cast left to real for division
		cpp += "(RealType)";
	else if (this->op == Token::Type::DivInt) // Cast result of division to int
		cpp += "(IntType)(";

	if (this->op == Token::Type::And || this->op == Token::Type::Or) // Convert to x > 0 for accessors
		cpp += this->left->toConditionCpp(scope, false);
	else
		cpp += this->left->toCpp(scope);

	cpp += " " + Token::toCpp(this->op) + " ";

	if (opNeedInts) // Cast left to int
		cpp += "(IntType)";
	else if (this->op == Token::Type::Mul && this->right->resolvedType->cppType == DataType::CppType::BoolType) // Cast right bool to int when multiplying
		cpp += "(IntType)";

	if (this->op == Token::Type::And || this->op == Token::Type::Or) // Convert to x > 0 for accessors
		cpp += this->right->toConditionCpp(scope, false);
	else
		cpp += this->right->toCpp(scope);

	if (this->op == Token::Type::DivInt) // Cast result of division to int
		cpp += ")";

	return cpp;
}

TernaryCondition::TernaryCondition(Expression* expr1, Expression* expr2, Expression* expr3, int line) : Expression(line)
{
	this->expr1 = expr1;
	this->expr2 = expr2;
	this->expr3 = expr3;
	type = Type::TernaryCondition;
}

void TernaryCondition::resolve(ResolveScope* scope)
{
	this->expr1->resolve(scope);
	this->expr2->resolve(scope);
	this->expr3->resolve(scope);

	this->expr1->applyType(scope, DataType::scalar(DataType::Type::IntOrReal));

	// Both types should be the same
	this->expr3->applyType(scope, *this->expr2->resolvedType);
	this->expr2->applyType(scope, *this->expr3->resolvedType);

	this->resolvedType->reset(*this->expr3->resolvedType);
	this->resolvedType->assign(*this->expr2->resolvedType, this->func, this->line);
}

bool TernaryCondition::applyType(ResolveScope* scope, const DataType& inputType)
{
	bool expr2Changed = this->expr2->applyType(scope, inputType);
	bool expr3Changed = this->expr3->applyType(scope, inputType);

	return (expr2Changed || expr3Changed);
}

String TernaryCondition::toCpp(ResolveScope* scope)
{
	return toTernaryCpp(scope, this->expr1, this->expr2, this->expr3);
}

ExpressionArray::ExpressionArray(List<Expression*> expressions, int line) : Expression(line)
{
	this->expressions = expressions;
	type = Type::Array;
}

void ExpressionArray::resolve(ResolveScope* scope)
{
	DataType elementType;
	this->resolvedType->reset(DataType::Type::Array, &elementType);
	for (Expression* expr : this->expressions)
	{
		expr->resolve(scope);
		this->resolvedType->assign(DataType(DataType::Type::Array, expr->resolvedType), this->func, this->line);
	}
}

String ExpressionArray::toCpp(ResolveScope* scope)
{
	return "ArrType::From(" + toExpressionArrayCpp(scope, this->expressions) + ")";
}

ExpressionValue::ExpressionValue(Token::Type valueType, StringId value, int line) : Expression(line)
{
	this->valueType = valueType;
	this->value = value;
	type = Type::Value;
}

void ExpressionValue::resolve(ResolveScope*)
{
	if (this->valueType == Token::Type::Number)
	{
		if (!knowValueHasDecimal)
		{
			valueHasDecimal = String(this->value).contains(".");
			knowValueHasDecimal = true;
		}
		if (valueHasDecimal)
			this->resolvedType->reset(DataType::Type::Real);
		else
			this->resolvedType->reset(DataType::Type::IntOrReal);
	}
	else
		this->resolvedType->reset(DataType::Type::String);
}

bool ExpressionValue::applyType(ResolveScope*, const DataType& inputType)
{
	return this->resolvedType->assign(inputType, this->func, this->line);
}

String ExpressionValue::toCpp(ResolveScope*)
{
	if (this->valueType == Token::Type::String) // String
		return "/*\"" + String(this->value) + "\"*/ STR(" + Program::strings.indexOf(this->value) + ")";
	else if (this->resolvedType->getAssignments(DataType::Type::Real).size() == 0) // Integer
		return "IntType(" + String(this->value) + ")";
	else if (!String(this->value).contains(".")) // Convert to Real
		return String(this->value) + ".0";
	else // Already real
		return String(this->value);
}

NewExpression::NewExpression(Accessor* accessor, int line) : Expression(line)
{
	this->acc = accessor;
	type = Type::New;
}

void NewExpression::resolve(ResolveScope* scope)
{
	ResolveScope newScope = scope->nextStatement(true);
	this->acc->resolve(newScope);
	this->resolvedType = this->acc->resolvedType;
}

String NewExpression::toCpp(ResolveScope* scope)
{
	ResolveScope newScope = scope->nextStatement(true);
	return "(new " + this->acc->toCpp(newScope) + ")->id";
}

}
