using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;

namespace CppGen
{
	class GML
	{
		public static List<string> Keywords = new List<string>();
		public static Dictionary<string, double> Constants = new Dictionary<string, double>();
		public static Dictionary<string, DataType> Variables = new Dictionary<string, DataType>();
		public static Dictionary<string, FunctionSignature> Functions = new Dictionary<string, FunctionSignature>();
		public static int TotalLines = 0;

		// Function signature
		public class FunctionSignature
		{
			public string Name;
			public DataType ReturnType;
			public List<DataType> ArgTypes = new List<DataType>();
			public bool VarArgs = false;
			public bool NeedScope = false;
			public bool VarCreateRef = false;

			public FunctionSignature(string name, DataType returnType, List<DataType> argTypes, bool varArgs, bool needScope, bool varCreateRef)
			{
				Name = name;
				ReturnType = returnType;
				ArgTypes = argTypes;
				VarArgs = varArgs;
				NeedScope = needScope;
				VarCreateRef = varCreateRef;
			}
		}

		// Parse the gml.json file and store the spec in the above variables.
		public static void ParseGMLSpec(string file)
		{
			string json = File.ReadAllText(file);
			dynamic root = JsonConvert.DeserializeObject(json);

			// Keywords
			foreach (string keyword in root["keywords"])
				Keywords.Add(keyword);

			// Integer constants
			foreach (dynamic constant in root["constants"])
			{
				dynamic constObj = root["constants"][constant.Name];
				Constants[constant.Name] = (double)constObj;
			}

			// Variables
			foreach (dynamic variable in root["variables"])
			{
				dynamic varObj = root["variables"][variable.Name];
				Variables[variable.Name] = new DataType(varObj.ToString());
			}

			// Functions
			foreach (dynamic function in root["functions"])
			{
				dynamic funcObj = root["functions"][function.Name];
				DataType retType = new DataType(funcObj["return"].ToString());
				List<DataType> argTypes = new List<DataType>();
				bool varArgs = false;
				bool needScope = false;
				bool varCreateRef = false;

				if (funcObj["varArgs"] != null)
					varArgs = true;
				else
					foreach (string arg in funcObj["args"])
						argTypes.Add(new DataType(arg));

				if (funcObj["needScope"] != null)
					needScope = true;

				if (funcObj["varCreateRef"] != null)
					varCreateRef = true;

				Functions[function.Name] = new FunctionSignature(function.Name, retType, argTypes, varArgs, needScope, varCreateRef);
			}
		}

		// Generate GML variables headers.
		public static void ExportHeader(string file)
		{
			DataType.IgnoreAllVarType = true;
			CodeWriter.Begin();
			CodeWriter.WriteLine("#pragma once");
			CodeWriter.WriteLine("#include \"Asset/Scope.hpp\"");
			CodeWriter.WriteLine();
			CodeWriter.WriteLine("#define withOne(type, id, otherId) \\" , 1);
			CodeWriter.WriteLine("if (IntType _withSelfId = id) \\");
			CodeWriter.WriteLine("if (IntType _withOtherId = otherId) \\");
			CodeWriter.WriteLine("for (Scope<type> self(_withSelfId, _withOtherId); self.IsValid(); self.Clear())");
			CodeWriter.WriteLine("", -1);
			CodeWriter.WriteLine("#define withAll(type, otherId) \\", 1);
			CodeWriter.WriteLine("if (IntType _withOtherId = otherId) \\");
			CodeWriter.WriteLine("for (Scope<type> self(Object::GetAll(ID_##type), _withOtherId); self.IsValid(); self.NextObject())");
			CodeWriter.WriteLine("", -1);
			CodeWriter.WriteLine("namespace CppProject");
			CodeWriter.WriteLine("{", 1);

			// Constants
			foreach (string constant in Constants.Keys)
			{
				string val = Constants[constant].ToString().Replace(",", ".");
				if (!val.Contains("."))
					val = "IntType(" + val + ")";
				CodeWriter.WriteLine("#define " + CodeObject.NameToCpp(constant) + " " + val);
			}

			// Variables
			CodeWriter.WriteLine();
			CodeWriter.WriteLine("struct gmlGlobal");
			CodeWriter.WriteLine("{", 1);
			foreach (string var in Variables.Keys)
				if (!Keywords.Contains(var) && var != "argument" && var != "argument_count")
					CodeWriter.WriteLine("static " + Variables[var].ToCpp() + " " + CodeObject.NameToCpp(var) + ";");
			CodeWriter.WriteLine("};", -1);

			// Functions
			CodeWriter.WriteLine();
			foreach (FunctionSignature funcSign in Functions.Values)
			{
				CodeWriter.Write(funcSign.ReturnType.ToCpp() + " " + funcSign.Name + "(");
				
				int p = 0;
				if (funcSign.NeedScope)
				{
					CodeWriter.Write("ScopeAny");
					p++;
				}

				if (funcSign.VarArgs)
				{
					if (p++ > 0)
						CodeWriter.Write(", ");
					CodeWriter.Write("VarArgs args = VarArgs()");
				}
				else
				{
					foreach (DataType type in funcSign.ArgTypes)
					{
						if (p++ > 0)
							CodeWriter.Write(", ");
						CodeWriter.Write(type.ToCpp());
					}
				}

				CodeWriter.WriteLine(");");
			}

			CodeWriter.WriteLine("}", -1);
			CodeWriter.End(file);
			DataType.IgnoreAllVarType = false;
		}

		// Parses a GML script file and generates functions with tokens.
		public static void ParseGMLScript(string file)
		{
			string gml = File.ReadAllText(file);
			Function currentFunction = null;
			bool isMultilineComment = false;
			bool isLineComment = false;
			bool isCppSeparate = false;
			string cppSeparateHeader = "";

			// Find IDs
			Regex idRegex = new Regex(@"\w(?<!\d)[\w]*");
			MatchCollection idCollection = idRegex.Matches(gml);
			int idOffset = 0;

			// Find digits
			Regex digitRegex = new Regex(@"\d+(\.\d+(e[-+]?\d+)?)?");
			MatchCollection digitCollection = digitRegex.Matches(gml);
			int digitOffset = 0;

			// Find strings
			Regex stringRegex = new Regex(@"""[^""\\]*(?:\\.[^""\\]*)*""");
			MatchCollection stringCollection = stringRegex.Matches(gml);
			int stringOffset = 0;

			// Iterate characters and find tokens
			for (int pos = 0, line = 1, linePos = 0; pos < gml.Length;)
			{
				char currentChar = gml[pos];
				char nextChar = '\0';
				if (pos < gml.Length - 1)
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
					TotalLines++;
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
						string cppSep = "/// CppSeparate";
						string cppOnly = "/// CppOnly";

						if (pos + cppSep.Length > gml.Length)
						{
							pos++;
                            continue;
						}

                        if (gml.Substring(pos, cppSep.Length) == cppSep)
						{
							isCppSeparate = true;
							pos += cppSep.Length + 1;
							cppSeparateHeader = gml.Substring(pos, gml.IndexOf("\n", pos) - pos).Replace("\r", "");
							pos += cppSeparateHeader.Length;
							continue;
						}

						else if (gml.Substring(pos, cppOnly.Length) == cppOnly && currentFunction != null)
						{
							pos += cppOnly.Length + 1;
							Token cppOnlyToken = new Token();
							cppOnlyToken.type = Token.Type.CppOnly;
							cppOnlyToken.Value = gml.Substring(pos, gml.IndexOf("\n", pos) - pos).Replace("\r", "");
							cppOnlyToken.FileOffset = pos;
							cppOnlyToken.Line = line;
							cppOnlyToken.LineOffset = linePos;
							currentFunction.Tokens.Add(cppOnlyToken);
							pos += cppOnlyToken.Value.Length;
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

				Token token = new Token();
				token.type = Token.Type.Unknown;
				token.FileOffset = pos;
				token.Line = line;
				token.LineOffset = linePos;
				token.Length = 1;

				// Check IDs
				while (idOffset < idCollection.Count)
				{
					Match match = idCollection[idOffset];
					if (match.Groups.Count > 0 && match.Groups[0].Captures.Count > 0)
					{
						Capture capture = match.Groups[0].Captures[0];
						if (capture.Index > pos) // Index is beyond this position, must be a digit
							break;

						idOffset++;
						if (capture.Index == pos) // Index matches position
						{
							token.type = Token.Type.ID;
							token.Value = capture.Value;
							token.Length = capture.Length;
							break;
						}
					}
				}

				// Check digits
				if (token.type == Token.Type.Unknown)
				{
					while (digitOffset < digitCollection.Count)
					{
						Match match = digitCollection[digitOffset];
						if (match.Groups.Count > 0 && match.Groups[0].Captures.Count > 0)
						{
							Capture capture = match.Groups[0].Captures[0];
							if (capture.Index > pos) // Index is beyond this position, invalid token
								break;

							digitOffset++;
							if (capture.Index == pos) // Index matches position
							{
								token.type = Token.Type.Number;
								token.Value = capture.Value;
								token.Length = capture.Length;
								break;
							}
						}
					}
				}

				if (token.type == Token.Type.Unknown)
				{
					switch (currentChar)
					{
						// Blank space
						case ' ':
						case '\r':
						case '\t': break;
						case '\n': line++; TotalLines++; linePos = pos; break;

						case '{': token.type = Token.Type.LeftBrace; break;
						case '}': token.type = Token.Type.RightBrace; break;
						case '(': token.type = Token.Type.LeftPar; break;
						case ')': token.type = Token.Type.RightPar; break;
						case '[': token.type = Token.Type.LeftSquare; break;
						case ']': token.type = Token.Type.RightSquare; break;

						case ',': token.type = Token.Type.Separator; break;
						case ';': token.type = Token.Type.Terminator; break;
						case '.': token.type = Token.Type.Member; break;

						case '=': token.type = (nextChar == '=' ? Token.Type.Equal : Token.Type.Assign); break;
						case '?': token.type = Token.Type.Ternary; break;
						case ':': token.type = Token.Type.Colon; break;
						case '!': token.type = (nextChar == '=' ? Token.Type.NotEqual : Token.Type.Inverse); break;
						case '&': token.type = (nextChar == '&' ? Token.Type.And : Token.Type.BitwiseAnd); break;
						case '|': token.type = (nextChar == '|' ? Token.Type.Or : Token.Type.BitwiseOr); break;
						case '>': token.type = (nextChar == '>' ? Token.Type.ShiftRight : (nextChar == '=' ? Token.Type.LargerEq : Token.Type.Larger)); break;
						case '<': token.type = (nextChar == '>' ? Token.Type.NotEqual : (nextChar == '<' ? Token.Type.ShiftLeft : (nextChar == '=' ? Token.Type.LessEq : Token.Type.Less))); break;
						case '+': token.type = (nextChar == '+' ? Token.Type.AddShort : (nextChar == '=' ? Token.Type.AddLong : Token.Type.Add)); break;
						case '-': token.type = (nextChar == '-' ? Token.Type.SubShort : (nextChar == '=' ? Token.Type.SubLong : Token.Type.Sub)); break;
						case '*': token.type = (nextChar == '=' ? Token.Type.MulLong : Token.Type.Mul); break;
						case '/': token.type = (nextChar == '=' ? Token.Type.DivLong : Token.Type.Div); break;
						case '%': token.type = Token.Type.Modulus; break;
						case '#': token.type = Token.Type.HashTag; break;
						case '@': token.type = Token.Type.ArrayRef; break;
						case '"':
						{
							// Check strings
							while (stringOffset < stringCollection.Count)
							{
								Match match = stringCollection[stringOffset];
								if (match.Groups.Count > 0 && match.Groups[0].Captures.Count > 0)
								{
									Capture capture = match.Groups[0].Captures[0];
									if (capture.Index > pos) // Index is beyond this position, invalid string
										break;

									stringOffset++;
									if (capture.Index == pos) // Index matches position
									{
										token.type = Token.Type.String;
										token.Value = capture.Value.Substring(1, capture.Value.Length - 2);
										if (!Program.Strings.Contains(token.Value))
											Program.Strings.Add(token.Value);
										token.Length = capture.Length;
										break;
									}
								}
							}

							if (token.type == Token.Type.Unknown)
							{
								Console.WriteLine("FATAL ERROR in {0}:", file);
								Console.WriteLine("  Invalid string at line {0}, {1}", token.Line, token.FileOffset - token.LineOffset);
								System.Environment.Exit(1);
							}
							break;
						}

						default:
						{
							Console.WriteLine("FATAL ERROR in {0}:", file);
							Console.WriteLine("  Unexpected {0} token at line {1}, {2}", currentChar, token.Line, token.FileOffset - token.LineOffset);
							Environment.Exit(1);
							break;
						}
					}
				}

				// 2 letter tokens
				if (token.type == Token.Type.Equal ||
					token.type == Token.Type.NotEqual ||
					token.type == Token.Type.And ||
					token.type == Token.Type.Or ||
					token.type == Token.Type.LargerEq ||
					token.type == Token.Type.LessEq ||
					token.type == Token.Type.AddLong ||
					token.type == Token.Type.AddShort ||
					token.type == Token.Type.SubLong ||
					token.type == Token.Type.SubShort ||
					token.type == Token.Type.MulLong ||
					token.type == Token.Type.DivLong ||
					token.type == Token.Type.ShiftRight ||
					token.type == Token.Type.ShiftLeft)
					token.Length = 2;

				if (token.type != Token.Type.Unknown)
				{
					if (token.type == Token.Type.ID)
					{
						// Start new function
						if (token.Value == "function" && currentFunction?.Tokens[currentFunction.Tokens.Count - 1].type != Token.Type.Assign)
						{
							currentFunction = new Function("", gml, isCppSeparate, cppSeparateHeader);
							isCppSeparate = false;
						}

						// Get name of function
						else if (currentFunction.Name == "")
						{
							currentFunction.Name = token.Value;
							Program.Functions.Add(token.Value, currentFunction);
						}

						// Integer division
						else if (token.Value == "div")
							token.type = Token.Type.DivInt;

						// Modulus
						else if (token.Value == "mod")
							token.type = Token.Type.Modulus;
					}

					// . 45 -> .45
					if (token.type == Token.Type.Number && currentFunction?.Tokens[currentFunction.Tokens.Count - 1].type == Token.Type.Member)
					{
						Token lastToken = currentFunction.Tokens[currentFunction.Tokens.Count - 1];
						lastToken.type = Token.Type.Number;
						lastToken.Value = "." + token.Value;
						lastToken.Length += token.Length;
					}

					// Remove regions
					else if (token.type == Token.Type.ID && (token.Value == "region" || token.Value == "endregion") &&
							currentFunction?.Tokens[currentFunction.Tokens.Count - 1].type == Token.Type.HashTag)
					{
						currentFunction.Tokens.RemoveAt(currentFunction.Tokens.Count - 1);
						isLineComment = true;
					}
					else
						currentFunction.Tokens.Add(token);
				}

				pos += token.Length;
			}
		}
	}
}
