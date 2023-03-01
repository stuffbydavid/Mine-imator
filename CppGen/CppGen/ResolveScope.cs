using System;
using System.Collections.Generic;

namespace CppGen
{
	// Stores the current and previous context when resolving functions, statements and expressions.
	public class ResolveScope
	{
		public string Current = "";
		public string CurrentInChain = ""; // For tracking the scope in accessor chains
		public string Previous = "";
		public Function FuncUpdateScope = null;
		public List<Call> Calls;
		public Statement.Location Location;

		public class Call
		{
			public string FuncName;
			public int Line;

			public Call(string funcName, int line)
			{
				FuncName = funcName;
				Line = line;
			}
		}

		public ResolveScope(string current, string previous = "", List<Call> calls = null, string currentInChain = "", Statement.Location location = null, Function funcUpdateScope = null)
		{
			Current = current;
			Previous = previous;

			if (calls != null)
				Calls = calls;
			else
				Calls = new List<Call>();

			if (currentInChain != "")
				CurrentInChain = currentInChain;
			else
				CurrentInChain = Current;

			if (location != null)
				Location = location;
			else
				Location = new Statement.Location();

			FuncUpdateScope = funcUpdateScope;
		}

		// Adds a new function call to a copy of the scope
		public ResolveScope(ResolveScope scope, string callFunc, int callLine)
		{
			Current = scope.Current;
			CurrentInChain = scope.CurrentInChain;
			Previous = scope.Previous;
			Location = scope.Location;
			Calls = new List<Call>(scope.Calls);
			Calls.Add(new Call(callFunc, callLine));
		}

		// Enters a new statement.
		public ResolveScope NextStatement(bool addLevel = false)
		{
			return new ResolveScope(Current, Previous, Calls, CurrentInChain, Location.Next(addLevel), FuncUpdateScope);
		}

		// Enters a new with() statement.
		public ResolveScope EnterWithStatement(string newScope, string otherScope)
		{
			return new ResolveScope(newScope, otherScope, Calls, newScope, Location);
		}

		// Moves to the next in the Accessor chain
		public ResolveScope NextInChain(string nextInChain)
		{
			return new ResolveScope(Current, Previous, Calls, nextInChain, Location, FuncUpdateScope);
		}

		// Returns the ResolveScope outside of the current chain (if any)
		public ResolveScope OutsideChain()
		{
			return new ResolveScope(Current, Previous, Calls, Current, Location, FuncUpdateScope);
		}

		// Returns whether a function has been called.
		public bool IsCalled(string funcName)
		{
			foreach (Call call in Calls)
				if (call.FuncName == funcName)
					return true;

			return false;
		}

		// Prints the list of calls to the log
		public void DebugCalls()
		{
			if (Calls.Count == 0)
				return;

			string callStr = "    Calls: ";
			int i = 0;
			foreach (Call call in Calls)
				callStr += (i++ > 0 ? " -> " : "") + call.FuncName + ":" + call.Line;
			Console.WriteLine(callStr);
		}
	}
}
