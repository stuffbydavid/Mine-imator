#include "CppGen.hpp"

namespace CppGen
{
ResolveScope::ResolveScope(const String& current, const String& previous, const std::shared_ptr<const List<ResolveScope::Call>>& updatedCalls, const String& currentInChain, const std::shared_ptr<Statement::Location>& location, Function* funcUpdateScope)
{
	this->current = current;
	this->previous = previous;

	if (updatedCalls != nullptr)
		this->calls = updatedCalls;
	else
		this->calls = std::make_shared<List<Call>>();

	if (currentInChain != "")
		this->currentInChain = currentInChain;
	else
		this->currentInChain = this->current;

	this->location = location != nullptr
		? location
		: std::make_shared<Statement::Location>();

	this->funcUpdateScope = funcUpdateScope;
}

ResolveScope::ResolveScope(const ResolveScope& scope, const String& callFunc, int callLine)
{
	this->current = scope.current;
	this->currentInChain = scope.currentInChain;
	this->previous = scope.previous;
	this->location = scope.location;
	auto updatedCalls = std::make_shared<List<Call>>(*scope.calls);
	updatedCalls->add(Call(callFunc, callLine));
	this->calls = std::move(updatedCalls);
}

ResolveScope ResolveScope::nextStatement(bool addLevel)
{
	auto nextLocation = std::make_shared<Statement::Location>(this->location->next(addLevel));
	return ResolveScope(this->current, this->previous, this->calls, this->currentInChain, nextLocation, this->funcUpdateScope);
}

ResolveScope ResolveScope::enterWithStatement(const String& newScope, const String& otherScope)
{
	return ResolveScope(newScope, otherScope, this->calls, newScope, this->location);
}

ResolveScope ResolveScope::nextInChain(const String& nextInChain)
{
	return ResolveScope(this->current, this->previous, this->calls, nextInChain, this->location, this->funcUpdateScope);
}

ResolveScope ResolveScope::outsideChain()
{
	return ResolveScope(this->current, this->previous, this->calls, this->current, this->location, this->funcUpdateScope);
}

bool ResolveScope::isCalled(const String& funcName)
{
	for (const Call& call : *this->calls)
		if (call.funcName == funcName)
			return true;

	return false;
}

void ResolveScope::debugCalls()
{
	if (this->calls->size() == 0)
		return;

	String callStr = "    Calls: ";
	int i = 0;
	for (const Call& call : *this->calls)
		callStr += (i++ > 0 ? " -> " : "") + call.funcName + ":" + call.line;
	Console::writeLine(callStr);
}

ResolveScope::Call::Call(const String& funcName, int line)
{
	this->funcName = funcName;
	this->line = line;
}

}
