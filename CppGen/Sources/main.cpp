#include "CppGen.hpp"

int main(int argc, char** argv)
{
	CppGen::List<CppGen::String> arguments;
	for (int i = 1; i < argc; ++i)
		arguments.add(argv[i]);
	CppGen::Program::main(arguments);
	return CppGen::Program::syntaxErrors.empty() ? 0 : 1;
}
