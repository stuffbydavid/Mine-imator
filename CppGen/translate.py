"""Mechanical translator for the deliberately small C# subset used by CppGen.

This is a source-to-source maintenance tool, not a build dependency.  It keeps
the C++ files structurally paired with their original .cs files while moving
method bodies out of class declarations (required for C++ cross-file types).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import re
import textwrap

ROOT = Path(__file__).resolve().parents[1]
CS_DIR = ROOT / "CppGen_old" / "CppGen"
OUT_DIR = Path(__file__).resolve().parent / "src"

ORDER = [
    "Token", "DataType", "CodeObject", "Statement", "ResolveScope", "Variable",
    "Expression", "ExpressionParenthesis", "UnaryOperation", "BinaryOperation",
    "TernaryCondition", "ExpressionArray", "ExpressionValue", "Accessor",
    "NewExpression", "Declaration", "DeclarationList", "StatementList",
    "DeclareStatement", "MacroStatement", "EnumStatement", "CallStatement",
    "AssignStatement", "IfStatement", "WhileStatement", "DoUntilStatement",
    "ForStatement", "RepeatStatement", "WithStatement", "SwitchStatement",
    "BreakStatement", "ContinueStatement", "ReturnStatement", "DeleteStatement",
    "CustomCppStatement", "Function", "ExternalFunction", "Object", "Sprite",
    "Shader", "GML", "CodeWriter", "Program",
]

ENUM_TYPES = {
    "Token.Type", "DataType.Type", "DataType.CppType", "Statement.Type",
    "Expression.Type", "DeclarationList.WriteFormat",
}
VALUE_TYPES = {
    "String", "FileInfo", "DirectoryInfo", "Stopwatch", "StringBuilder",
    "Regex", "MatchCollection", "Match", "Capture", "Json", "fs::path",
}

NESTED_PARENTS = {
    "Assignment": "DataType", "Location": "Statement", "Call": "ResolveScope",
    "ArrayAccessor": "Accessor", "Case": "SwitchStatement", "FileModification": "Shader",
    "FunctionSignature": "GML", "ScopeAssignment": "Function",
}


IDENTIFIER_OVERRIDES = {
    "Return": "returnStatement",
}


def lower_first(name: str) -> str:
    """Lowercase an identifier's first letter while preserving the remainder."""
    return IDENTIFIER_OVERRIDES.get(name, name[:1].lower() + name[1:])


@dataclass
class Member:
    kind: str
    header: str
    body: str = ""
    comments: list[str] = field(default_factory=list)
    inline_comment: str | None = None


@dataclass
class ClassDef:
    name: str
    base: str | None
    source: Path
    members: list[Member] = field(default_factory=list)
    nested: list["ClassDef"] = field(default_factory=list)
    parent: "ClassDef | None" = None
    comments: list[str] = field(default_factory=list)

    @property
    def qualified(self) -> str:
        return f"{self.parent.qualified}::{self.name}" if self.parent else self.name


def mask_code(code: str) -> str:
    out = list(code)
    i = 0
    while i < len(code):
        if code.startswith("//", i):
            end = code.find("\n", i)
            end = len(code) if end < 0 else end
            for j in range(i, end): out[j] = " "
            i = end
        elif code.startswith("/*", i):
            end = code.find("*/", i + 2)
            end = len(code) - 2 if end < 0 else end
            for j in range(i, end + 2):
                if out[j] != "\n": out[j] = " "
            i = end + 2
        elif code[i] in {'"', "'"} or (code[i] == '@' and i + 1 < len(code) and code[i + 1] == '"'):
            verbatim = code[i] == '@'
            quote = code[i + 1] if verbatim else code[i]
            start = i
            i += 2 if verbatim else 1
            while i < len(code):
                if verbatim and code.startswith('""', i):
                    i += 2
                    continue
                if code[i] == quote:
                    escaped = False
                    if not verbatim:
                        backslashes = 0
                        check = i - 1
                        while check >= start and code[check] == "\\":
                            backslashes += 1
                            check -= 1
                        escaped = (backslashes % 2) == 1
                    if not escaped:
                        i += 1
                        break
                i += 1
            for j in range(start, i):
                if out[j] != "\n": out[j] = " "
        else:
            i += 1
    return "".join(out)


def matching_brace(mask: str, opening: int) -> int:
    depth = 1
    for i in range(opening + 1, len(mask)):
        if mask[i] == "{": depth += 1
        elif mask[i] == "}":
            depth -= 1
            if depth == 0: return i
    raise ValueError(f"unmatched brace at {opening}")


def clean_header(text: str) -> str:
    text = re.sub(r"//.*", "", text)
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    return text.strip()


def full_line_comments(text: str, start: int, end: int) -> list[str]:
    """Return comment-only // lines in a trivia range."""
    result: list[str] = []
    for match in re.finditer(r"//[^\r\n]*", text[start:end]):
        position = start + match.start()
        line_start = text.rfind("\n", 0, position) + 1
        if not text[line_start:position].strip():
            result.append(match.group(0).rstrip())
    return result


def preceding_line_comments(text: str, position: int) -> list[str]:
    """Return the contiguous comment block immediately above a declaration."""
    line_start = text.rfind("\n", 0, position) + 1
    lines = text[:line_start].splitlines()
    result: list[str] = []
    for line in reversed(lines):
        stripped = line.strip()
        if not stripped.startswith("//"):
            break
        result.append(stripped)
    return list(reversed(result))


def same_line_comment(text: str, position: int) -> str | None:
    line_end = text.find("\n", position)
    if line_end < 0:
        line_end = len(text)
    match = re.search(r"//[^\r\n]*", text[position:line_end])
    return match.group(0).rstrip() if match else None


def visual_indent(line: str, tab_width: int = 4) -> int:
    columns = 0
    for char in line:
        if char == " ":
            columns += 1
        elif char == "\t":
            columns += tab_width - (columns % tab_width)
        else:
            break
    return columns


def dedent_mixed(text: str, tab_width: int = 4) -> str:
    """Dedent source that mixes tabs and spaces, then normalize to tabs."""
    lines = text.splitlines()
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()
    nonempty = [line for line in lines if line.strip()]
    if not nonempty:
        return ""
    baseline = min(visual_indent(line, tab_width) for line in nonempty)
    result: list[str] = []
    for line in lines:
        if not line.strip():
            result.append("")
            continue
        columns = max(0, visual_indent(line, tab_width) - baseline)
        content = line.lstrip(" \t").rstrip()
        result.append("\t" * (columns // tab_width) + " " * (columns % tab_width) + content)
    return "\n".join(result)


def is_method_header(header: str) -> bool:
    opening = header.find("(")
    return opening >= 0 and "=" not in header[:opening]


def convert_string_switches(text: str) -> str:
    while True:
        mask = mask_code(text)
        converted = False
        for match in re.finditer(r"switch\s*\(([^()\n]+)\)\s*\{", mask):
            opening = mask.find("{", match.start())
            close = matching_brace(mask, opening)
            block_mask = mask[opening + 1:close]
            source_block = text[opening + 1:close]
            labels = []
            for label_match in re.finditer(r"(?m)^[ \t]*(case\s+\"((?:\\.|[^\"])*)\"|default)\s*:", source_block):
                before = block_mask[:label_match.start()]
                depth = before.count("{") - before.count("}")
                if depth == 0:
                    labels.append((label_match.start(), label_match.end(), label_match.group(2)))
            if not labels or labels[0][2] is None and len(labels) == 1:
                continue
            expression = text[match.start(1):match.end(1)].strip()
            branches = []
            pending = []
            default_code = None
            for number, (_, code_start, value) in enumerate(labels):
                code_end = labels[number + 1][0] if number + 1 < len(labels) else len(source_block)
                code = source_block[code_start:code_end].strip()
                if value is not None:
                    pending.append(value)
                if not code:
                    continue
                # The switch-level break can precede one or more braces when
                # a C# case body is explicitly scoped.
                code = re.sub(
                    r"\bbreak\s*;(?P<braces>(?:\s*\})*)\s*$",
                    lambda m: m.group("braces"), code).strip()
                if value is None:
                    default_code = code
                else:
                    condition = " || ".join(f'{expression} == String("{item}")' for item in pending)
                    branches.append((condition, code))
                    pending = []
            if not branches:
                continue
            line_start = text.rfind("\n", 0, match.start()) + 1
            base_indent = text[line_start:match.start()]
            if base_indent.strip():
                base_indent = ""

            def format_branch(condition: str | None, code: str, first: bool) -> str:
                header = ("if" if first else "else if") + f" ({condition})" if condition else "else"
                if not first:
                    header = base_indent + header
                # .strip() above necessarily removes indentation from the
                # first case-body line only. Dedent the remaining lines as a
                # separate block so their relative nesting stays intact.
                branch_lines = code.strip().splitlines()
                branch_body = branch_lines[0].strip()
                if len(branch_lines) > 1:
                    branch_body += "\n" + textwrap.dedent("\n".join(branch_lines[1:])).rstrip()
                branch_body = textwrap.indent(branch_body, base_indent + "\t")
                return (header + "\n" + base_indent + "{\n" +
                        branch_body + "\n" + base_indent + "}")

            replacement_parts = []
            for number, (condition, code) in enumerate(branches):
                replacement_parts.append(format_branch(condition, code, number == 0))
            if default_code is not None:
                replacement_parts.append(format_branch(None, default_code, False))
            text = text[:match.start()] + "\n".join(replacement_parts) + text[close + 1:]
            converted = True
            break
        if not converted:
            return text


def parse_class(name: str, base: str | None, body: str, source: Path,
                parent: ClassDef | None = None) -> ClassDef:
    result = ClassDef(name, base, source, parent=parent)
    mask = mask_code(body)
    cursor = 0
    while cursor < len(body):
        trivia_start = cursor
        while cursor < len(body) and mask[cursor].isspace(): cursor += 1
        if cursor >= len(body): break
        comments = full_line_comments(body, trivia_start, cursor)
        start = cursor
        paren = bracket = 0
        delimiter = None
        while cursor < len(body):
            char = mask[cursor]
            if char == "(": paren += 1
            elif char == ")": paren -= 1
            elif char == "[": bracket += 1
            elif char == "]": bracket -= 1
            elif paren == 0 and bracket == 0 and char in ";{":
                delimiter = char
                break
            cursor += 1
        if delimiter is None: break
        header = clean_header(body[start:cursor])
        if delimiter == ";":
            if header:
                if re.search(r"\bDataType\s+ResolvedType\s*,\s*WrittenType\s*=", header):
                    result.members.append(Member("field", "public DataType ResolvedType", comments=comments))
                    result.members.append(Member("field", "public DataType WrittenType = new DataType()"))
                else:
                    result.members.append(Member(
                        "method_decl" if is_method_header(header) else "field",
                        header,
                        comments=comments,
                        inline_comment=same_line_comment(body, cursor + 1)))
            cursor += 1
            continue

        close = matching_brace(mask, cursor)
        block = body[cursor + 1:close]
        class_match = re.search(r"(?:public\s+)?(?:abstract\s+)?class\s+(\w+)(?:\s*:\s*([\w.]+))?\s*$", header)
        enum_match = re.search(r"(?:public\s+)?enum\s+(\w+)\s*$", header)
        if class_match:
            nested = parse_class(class_match.group(1), class_match.group(2), block, source, result)
            nested.comments = comments
            result.nested.append(nested)
            result.members.append(Member("nested", class_match.group(1)))
            cursor = close + 1
        elif enum_match:
            result.members.append(Member("enum", enum_match.group(1), block, comments=comments))
            cursor = close + 1
        elif is_method_header(header):
            result.members.append(Member("method", header, block, comments=comments))
            cursor = close + 1
        else:
            end = close + 1
            while end < len(body) and mask[end].isspace(): end += 1
            if end < len(body) and mask[end] == ";": end += 1
            result.members.append(Member(
                "field", clean_header(body[start:end]).rstrip(";"),
                comments=comments,
                inline_comment=same_line_comment(body, end)))
            cursor = end
    return result


def parse_sources() -> tuple[dict[str, ClassDef], dict[Path, list[ClassDef]]]:
    classes: dict[str, ClassDef] = {}
    by_file: dict[Path, list[ClassDef]] = {}
    for path in sorted(CS_DIR.glob("*.cs")):
        code = path.read_text(encoding="utf-8-sig")
        mask = mask_code(code)
        found: list[ClassDef] = []
        for match in re.finditer(r"(?:public\s+)?(?:abstract\s+)?class\s+(\w+)(?:\s*:\s*([\w.]+))?\s*\{", mask):
            depth = mask[:match.start()].count("{") - mask[:match.start()].count("}")
            if depth != 1:  # namespace depth; nested classes are parsed recursively
                continue
            opening = mask.find("{", match.start())
            close = matching_brace(mask, opening)
            item = parse_class(match.group(1), match.group(2), code[opening + 1:close], path)
            item.comments = preceding_line_comments(code, match.start())
            found.append(item)
            classes[item.name] = item
        by_file[path] = found
    return classes, by_file


def split_generic(text: str) -> list[str]:
    result, start, depth = [], 0, 0
    for i, char in enumerate(text):
        if char in "<[(": depth += 1
        elif char in ">])": depth -= 1
        elif char == "," and depth == 0:
            result.append(text[start:i].strip()); start = i + 1
    result.append(text[start:].strip())
    return result


def cpp_type(text: str, class_names: set[str]) -> str:
    text = text.strip()
    text = re.sub(r"\bstring\b", "String", text)
    text = text.replace("dynamic", "Json")
    text = text.replace("Statement.Location", "Statement::Location")
    text = text.replace("DataType.Assignment", "DataType::Assignment")
    text = text.replace("ResolveScope.Call", "ResolveScope::Call")
    text = text.replace("Accessor.ArrayAccessor", "Accessor::ArrayAccessor")
    text = text.replace("SwitchStatement.Case", "SwitchStatement::Case")
    text = text.replace("DeclarationList.WriteFormat", "DeclarationList::WriteFormat")
    text = text.replace("Token.Type", "Token::Type")
    text = text.replace("DataType.Type", "DataType::Type")
    text = text.replace("DataType.CppType", "DataType::CppType")
    text = text.replace("Statement.Type", "Statement::Type")
    text = text.replace("Expression.Type", "Expression::Type")
    array = re.fullmatch(r"(.+)\[\]", text)
    if array: return f"List<{cpp_type(array.group(1), class_names)}>"
    generic = re.fullmatch(r"List<(.+)>", text)
    if generic: return f"List<{cpp_type(generic.group(1), class_names)}>"
    generic = re.fullmatch(r"Dictionary<(?:string|String),\s*(.+)>", text)
    if generic: return f"OrderedMap<{cpp_type(generic.group(1), class_names)}>"
    normalized = text.replace("::", ".")
    if normalized in ENUM_TYPES: return text
    bare = text.split("::")[-1]
    if bare in ORDER:
        return bare + "*"
    if bare in class_names or bare in {"Assignment", "Location", "Call", "ArrayAccessor", "Case"}:
        return text + "*"
    return text


def shadowed_type_names(owner: ClassDef, class_names: set[str]) -> set[str]:
    """Types hidden by same-named fields in the current class hierarchy."""
    result: set[str] = set()
    current: ClassDef | None = owner
    visited: set[str] = set()
    while current and current.name not in visited:
        visited.add(current.name)
        for member in current.members:
            if member.kind != "field":
                continue
            _, field_name, *_ = field_declaration(member.header, class_names)
            if field_name in class_names:
                result.add(field_name)
        current = next((item for item in CLASSES_ALL if item.name == current.base), None)
    return result


def qualify_shadowed_types(text: str, owner: ClassDef, class_names: set[str]) -> str:
    for name in shadowed_type_names(owner, class_names):
        text = re.sub(rf"(?<![:\w]){name}(?=\s*\*)", f"CppGen::{name}", text)
    return text


def convert_expression(text: str, class_names: set[str]) -> str:
    text = text.strip()
    text = re.sub(r"\bnull\b", "nullptr", text)
    text = re.sub(r"new\s+List<([^>]+)>\s*\((.*?)\)", lambda m: f"List<{cpp_type(m.group(1), class_names)}>({m.group(2)})", text)
    text = re.sub(r"new\s+Dictionary<string,\s*([^>]+)>\s*\(\)", lambda m: f"OrderedMap<{cpp_type(m.group(1), class_names)}>()", text)
    for name in sorted(class_names, key=len, reverse=True):
        text = re.sub(rf"\b{name}\.", f"{name}::", text)
    for enum in ENUM_TYPES:
        text = text.replace(enum.replace(".", "::") + ".", enum.replace(".", "::") + "::")
        text = text.replace(enum + ".", enum.replace(".", "::") + "::")
    text = re.sub(r"\b(Type|CppType|WriteFormat)\.", r"\1::", text)
    text = re.sub(r"\[(\"[^\"]+\")\]\s*=", r"{\1,", text)
    # Close dictionary initializer entries after constructor calls.
    text = re.sub(r"(new\s+\w+\([^\n]+?\)),\s*$", r"\1},", text, flags=re.M)
    for nested, parent in NESTED_PARENTS.items():
        qualified = f"{parent}::{nested}"
        replacement = f"{qualified}(" if qualified in VALUE_CONSTRUCTION_TYPES else f"makeObject<{qualified}>("
        text = re.sub(rf"\bnew\s+(?:{parent}\.)?{nested}\s*\(", replacement, text)
    for name in sorted(class_names, key=len, reverse=True):
        replacement = f"{name}(" if name in VALUE_CONSTRUCTION_TYPES else f"makeObject<{name}>("
        text = re.sub(rf"\bnew\s+{name}\s*\(", replacement, text)
    return text


READ_ONLY_REFERENCE_PARAMS = {
    ("ResolveScope::Call", "Call"): {"funcName"},
    ("ResolveScope", "ResolveScope"): {"current", "previous", "calls", "currentInChain", "callFunc"},
    ("ResolveScope", "EnterWithStatement"): {"newScope", "otherScope"},
    ("ResolveScope", "NextInChain"): {"nextInChain"},
    ("ResolveScope", "IsCalled"): {"funcName"},
    ("DeclarationList", "Resolve"): {"declScope", "inputPars"},
    ("Function", "Resolve"): {"inputPars"},
    ("CodeWriter", "Write"): {"code"},
    ("CodeWriter", "WriteLine"): {"code"},
}

# C# reference types normally translate to pointers. These parameters are
# exceptions: the callee only inspects them, so the generated C++ API should
# express that directly and avoid both nullability and temporary allocation.
VALUE_REFERENCE_PARAMS = {
    ("DataType", "DataType"): {"other"},
    ("DataType::Assignment", "Assignment"): {"other"},
    ("DataType", "Assign"): {"inputType"},
    ("Variable", "Variable"): {"type", "location"},
    ("Variable", "AssignType"): {"type"},
    ("Expression", "ApplyType"): {"type"},
    ("ExpressionParenthesis", "ApplyType"): {"type"},
    ("UnaryOperation", "ApplyType"): {"type"},
    ("BinaryOperation", "ApplyType"): {"type"},
    ("TernaryCondition", "ApplyType"): {"type"},
    ("ExpressionValue", "ApplyType"): {"type"},
    ("Accessor", "ApplyType"): {"type"},
    ("Function", "AssignReturnType"): {"type"},
    ("Program", "FindVariable"): {"location"},
    ("Program", "DeclareVariable"): {"type", "location"},
    ("Statement::Location", "Location"): {"other"},
    ("Statement::Location", "Contains"): {"other"},
    ("Statement::Location", "Equals"): {"other"},
    ("ResolveScope", "ResolveScope"): {"scope", "location"},
}

VALUE_LIST_REFERENCE_PARAMS = {
    ("ResolveScope", "ResolveScope"): {"calls": "ResolveScope::Call"},
}

# A few translated reference parameters use shared immutable state rather than
# copying the C# object graph for every ResolveScope navigation operation.
PARAM_TYPE_OVERRIDES = {
    ("ResolveScope", "ResolveScope", "calls"):
        "const std::shared_ptr<const List<ResolveScope::Call>>&",
    ("ResolveScope", "ResolveScope", "location"):
        "const std::shared_ptr<Statement::Location>&",
}

# Selected high-volume C# reference objects have true value semantics in the
# port. Other classes retain pointer identity and are allocated by makeObject.
VALUE_CONSTRUCTION_TYPES = {
    "Token", "ResolveScope", "DataType::Assignment", "ResolveScope::Call",
    "Statement::Location",
}

VALUE_FIELD_DECLARATIONS = {
    ("DataType", "Assignments"): "List<Assignment> assignments = List<Assignment>();",
    ("DataType::Assignment", "ContainerType"): (
        "std::unique_ptr<DataType> containerStorage{};\n"
        "DataType* containerType = nullptr;"),
    ("Function", "Tokens"): "List<Token> tokens = List<Token>();",
    ("ResolveScope", "Current"): "InternedString current = \"\";",
    ("ResolveScope", "CurrentInChain"): "InternedString currentInChain = \"\";",
    ("ResolveScope", "Previous"): "InternedString previous = \"\";",
    ("ResolveScope", "Calls"): "std::shared_ptr<const List<Call>> calls{};",
    ("ResolveScope", "Location"): "std::shared_ptr<Statement::Location> location{};",
    ("Variable", "Type"): "DataType typeStorage{};\nDataType* type = &typeStorage;",
    ("Variable", "Location"): "Statement::Location location{};",
    ("Statement", "location"): "std::optional<Location> location{};",
    ("Expression", "ResolvedType"): (
        "DataType resolvedTypeStorage{};\n"
        "DataType* resolvedType = &resolvedTypeStorage;"),
    ("Expression", "WrittenType"): (
        "DataType writtenTypeStorage{};\n"
        "DataType* writtenType = &writtenTypeStorage;"),
    ("SwitchStatement", "CaseResolvedType"): (
        "DataType caseResolvedTypeStorage{};\n"
        "DataType* caseResolvedType = &caseResolvedTypeStorage;"),
    ("Function", "CppSeparateReturnType"): (
        "DataType cppSeparateReturnTypeStorage{};\n"
        "DataType* cppSeparateReturnType = nullptr;"),
    ("Function", "ReturnType"): (
        "DataType returnTypeStorage{};\n"
        "DataType* returnType = &returnTypeStorage;"),
    ("Accessor", "LastToCppScope"): "ResolveScope lastToCppScope{};",
}

# These fields own their object in adjacent storage but intentionally keep the
# translated pointer-facing API, so member access in method bodies still uses
# `->` just like an ordinary translated C# reference.
STORAGE_POINTER_FIELDS = {
    ("DataType::Assignment", "ContainerType"),
    ("Variable", "Type"),
    ("Expression", "ResolvedType"),
    ("Expression", "WrittenType"),
    ("SwitchStatement", "CaseResolvedType"),
    ("Function", "CppSeparateReturnType"),
    ("Function", "ReturnType"),
}

CONST_METHODS = {
    ("Statement::Location", "Contains"),
    ("Statement::Location", "Equals"),
}

VALUE_RETURN_METHODS = {
    ("Statement::Location", "Next"): "Statement::Location",
    ("ResolveScope", "NextStatement"): "ResolveScope",
    ("ResolveScope", "EnterWithStatement"): "ResolveScope",
    ("ResolveScope", "NextInChain"): "ResolveScope",
    ("ResolveScope", "OutsideChain"): "ResolveScope",
}

PARAM_DEFAULT_OVERRIDES = {
    ("ResolveScope", "ResolveScope", "current"): '""',
}


# C# permits parameters and locals to shadow fields freely. Use descriptive
# context-specific names where MSVC's level-4 diagnostics reject that style.
CONTEXT_IDENTIFIER_OVERRIDES = {
    ("Accessor", "ApplyType"): {"type": "inputType"},
    ("Accessor", "ToCpp"): {"func": "targetFunc"},
    ("CodeWriter", "Begin"): {"indentString": "indentation"},
    ("Expression", "ApplyType"): {"type": "inputType"},
    ("ExpressionParenthesis", "ApplyType"): {"type": "inputType"},
    ("UnaryOperation", "ApplyType"): {"type": "inputType"},
    ("BinaryOperation", "ApplyType"): {"type": "inputType"},
    ("TernaryCondition", "ApplyType"): {"type": "inputType"},
    ("ExpressionValue", "ApplyType"): {"type": "inputType"},
    ("Function", "ParseDeclarations"): {"name": "declarationName"},
    ("ResolveScope", "ResolveScope"): {"calls": "updatedCalls"},
    ("StatementList", "WriteCpp"): {"line": "cppLine"},
    ("WithStatement", "WriteCpp"): {"otherScope": "previousScope"},
    ("Variable", "AssignType"): {
        "type": "inputType", "func": "sourceFunc", "line": "sourceLine"},
}


def context_identifier(owner: str, method: str, name: str) -> str:
    lowered = lower_first(name)
    return CONTEXT_IDENTIFIER_OVERRIDES.get((owner, method), {}).get(lowered, lowered)


def convert_params(text: str, class_names: set[str], include_defaults: bool = True,
                   owner: str = "", method: str = "") -> tuple[str, set[str], set[str]]:
    if not text.strip(): return "", set(), set()
    converted, pointers, pointer_lists = [], set(), set()
    for param in split_generic(text):
        match = re.match(r"(.+?)\s+(\w+)(\s*=\s*(.*))?$", param, re.S)
        if not match:
            converted.append(param); continue
        source_type, name, _, default = match.groups()
        target_type = cpp_type(source_type, class_names)
        override_type = PARAM_TYPE_OVERRIDES.get((owner, method, name))
        value_reference = name in VALUE_REFERENCE_PARAMS.get((owner, method), set())
        value_list = VALUE_LIST_REFERENCE_PARAMS.get((owner, method), {}).get(name)
        if override_type:
            target_type = override_type
            value_reference = False
            value_list = None
        elif value_reference:
            target_type = target_type.removesuffix("*")
            target_type = f"const {target_type}&"
        elif value_list:
            target_type = f"const List<{value_list}>&"
        elif name in READ_ONLY_REFERENCE_PARAMS.get((owner, method), set()):
            target_type = f"const {target_type}&"
        elif target_type.endswith("*"):
            pointers.add(name)
        if not value_list and re.match(r"(?:List|OrderedMap)<.*\*>", target_type):
            pointer_lists.add(name)
        item = f"{target_type} {context_identifier(owner, method, name)}"
        if default is not None and include_defaults:
            converted_default = convert_expression(default, class_names)
            if override_type and converted_default in {"Statement::Location()", "nullptr"}:
                converted_default = "nullptr"
            if value_reference and converted_default == "nullptr":
                converted_default = target_type.removeprefix("const ").removesuffix("&").strip() + "()"
            item += " = " + converted_default
        elif include_defaults and (owner, method, name) in PARAM_DEFAULT_OVERRIDES:
            item += " = " + PARAM_DEFAULT_OVERRIDES[(owner, method, name)]
        converted.append(item)
    return ", ".join(converted), pointers, pointer_lists


def method_signature(header: str, owner: ClassDef, class_names: set[str], declaration: bool) -> tuple[str, set[str], set[str]]:
    header = clean_header(header).replace("\r", " ").replace("\n", " ")
    header = re.sub(r"\s+", " ", header).strip()
    header = re.sub(r"\b(public|private|protected)\s+", "", header)
    is_static = bool(re.search(r"\bstatic\s+", header))
    is_override = bool(re.search(r"\boverride\s+", header))
    is_virtual = bool(re.search(r"\bvirtual\s+", header))
    header = re.sub(r"\b(static|override|virtual)\s+", "", header)
    opening = header.find("(")
    if opening < 0: return header, set(), set()
    depth = 0
    closing = -1
    for index in range(opening, len(header)):
        if header[index] == "(": depth += 1
        elif header[index] == ")":
            depth -= 1
            if depth == 0:
                closing = index
                break
    if closing < 0: return header, set(), set()
    prefix, params, suffix = header[:opening], header[opening + 1:closing], header[closing + 1:]
    words = prefix.split()
    method_name = words[-1]
    return_type = " ".join(words[:-1])
    converted_params, pointers, pointer_lists = convert_params(
        params, class_names, declaration, owner.qualified, method_name)
    constructor = method_name == owner.name
    assignment_clone = (
        owner.qualified == "DataType::Assignment" and constructor and
        re.search(r"\bAssignment\s+other\b", params) is not None)
    if assignment_clone:
        converted_params = re.sub(r"\s*=\s*(?:nullptr|0)", "", converted_params)
    if declaration:
        lead = ""
        if is_static: lead += "static "
        elif is_virtual or is_override: lead += "virtual "
        if constructor:
            result = f"{lead}{owner.name}({converted_params})"
        else:
            converted_return = VALUE_RETURN_METHODS.get(
                (owner.qualified, method_name), cpp_type(return_type, class_names))
            result = f"{lead}{converted_return} {lower_first(method_name)}({converted_params})"
        if is_override and owner.base: result += " override"
        if (owner.qualified, method_name) in CONST_METHODS:
            result += " const"
    else:
        if constructor:
            result = f"{owner.qualified}::{owner.name}({converted_params})"
        else:
            converted_return = VALUE_RETURN_METHODS.get(
                (owner.qualified, method_name), cpp_type(return_type, class_names))
            enum_owner = owner.parent.name if owner.parent else owner.name
            if converted_return in {"Type", "CppType"} and enum_owner in {"DataType", "Token", "Statement", "Expression"}:
                converted_return = f"{enum_owner}::{converted_return}"
            result = f"{converted_return} {owner.qualified}::{lower_first(method_name)}({converted_params})"
        if (owner.qualified, method_name) in CONST_METHODS:
            result += " const"
        if suffix.strip().startswith(": base") and owner.base:
            # A member can have the same name as its base type in C#.
            base_type = (f"CppGen::{owner.base}" if owner.base in shadowed_type_names(owner, class_names)
                         else owner.base)
            result += suffix.replace("base", base_type, 1)
    return qualify_shadowed_types(result, owner, class_names), pointers, pointer_lists


def field_declaration(header: str, class_names: set[str]) -> tuple[str, str | None, bool, bool]:
    header = re.sub(r"\b(public|private|protected)\s+", "", clean_header(header))
    static = bool(re.search(r"\bstatic\s+", header))
    header = re.sub(r"\bstatic\s+", "", header)
    parts = header.split("=", 1)
    declaration = parts[0].strip()
    initializer = parts[1].strip() if len(parts) > 1 else None
    match = re.match(r"(.+?)\s+(\w+)$", declaration, re.S)
    if not match: return header + ";", None, False, False
    source_type, name = match.groups()
    target_type = cpp_type(source_type, class_names)
    result = ("inline static " if static else "") + target_type + " " + lower_first(name)
    if initializer is not None:
        dictionary = re.fullmatch(
            r"new\s+Dictionary<\s*string\s*,\s*([^>]+)>\s*\(\)\s*\{(.*)\}\s*",
            initializer, flags=re.S)
        if dictionary:
            entries = []
            for entry in split_generic(dictionary.group(2)):
                pair = re.match(r'\s*\[\"([^\"]+)\"\]\s*=\s*(.*?)\s*$', entry, re.S)
                if pair:
                    entries.append('{"' + pair.group(1) + '", ' +
                                   convert_expression(pair.group(2), class_names) + '}')
            converted_initializer = target_type + "{" + ", ".join(entries) + "}"
        else:
            converted_initializer = convert_expression(initializer, class_names)
        result += " = " + converted_initializer
    else:
        result += "{}"
    return result + ";", name, target_type.endswith("*"), bool(re.match(r"(?:List|OrderedMap)<.*\*>", target_type))


def class_declaration(item: ClassDef, class_names: set[str], indent: str = "") -> str:
    inheritance = f" : public {item.base}" if item.base else ""
    lines = [*(indent + comment for comment in item.comments),
             f"{indent}class {item.name}{inheritance}", f"{indent}{{", f"{indent}public:"]
    # Preserve overloads hidden by the C#-specific DeclarationList helpers.
    if item.qualified == "DeclarationList":
        lines.extend([
            indent + "\tusing CodeObject::resolve;",
            indent + "\tusing Statement::writeCpp;",
        ])
    nested_by_name = {x.name: x for x in item.nested}
    # C# permits a nested type to be used before its declaration. Emit nested
    # enums/classes first so the mechanically retained field order is legal C++.
    type_members = ([m for m in item.members if m.kind == "enum"] +
                    [m for m in item.members if m.kind == "nested"])
    value_members = [m for m in item.members if m.kind not in {"nested", "enum"}]
    previous_category: str | None = None
    for member in type_members + value_members:
        category = "type" if member.kind in {"nested", "enum"} else ("field" if member.kind == "field" else "method")
        needs_space = previous_category is not None and (
            category != previous_category or category == "type" or bool(member.comments))
        if needs_space and lines[-1] != "":
            lines.append("")
        if member.kind == "nested":
            lines.append(class_declaration(nested_by_name[member.header], class_names, indent + "\t"))
        elif member.kind == "enum":
            lines.extend(indent + "\t" + comment for comment in member.comments)
            enum_body = dedent_mixed(member.body)
            enum_body = textwrap.indent(enum_body, indent + "\t\t")
            lines.append(f"{indent}\tenum class {member.header}\n{indent}\t{{\n{enum_body}\n{indent}\t}};")
        elif member.kind == "field":
            lines.extend(indent + "\t" + comment for comment in member.comments)
            field_header = clean_header(member.header).split("=", 1)[0].strip()
            field_match = re.match(r".+?\s+(\w+)$", field_header, re.S)
            source_name = field_match.group(1) if field_match else ""
            decl = VALUE_FIELD_DECLARATIONS.get((item.qualified, source_name))
            if decl is None:
                decl, *_ = field_declaration(member.header, class_names)
            decl = qualify_shadowed_types(decl, item, class_names)
            if member.inline_comment:
                decl += " " + member.inline_comment
            lines.extend(indent + "\t" + declaration_line for declaration_line in decl.splitlines())
            if (item.qualified, source_name) == ("Accessor", "LastToCppScope"):
                lines.append(indent + "\tbool lastToCppScopeSet = false;")
        elif member.kind in {"method", "method_decl"}:
            lines.extend(indent + "\t" + comment for comment in member.comments)
            signature, *_ = method_signature(member.header, item, class_names, True)
            if member.kind == "method_decl": signature += " = 0"
            lines.append(indent + "\t" + signature + ";")
            if (item.qualified == "DataType::Assignment" and
                    re.search(r"\bAssignment\s*\(\s*Assignment\s+other\b", member.header)):
                lines[-1:-1] = [
                    indent + "\tAssignment(const Assignment& other);",
                    indent + "\tAssignment(Assignment&& other) noexcept;",
                    indent + "\tAssignment& operator=(const Assignment& other);",
                    indent + "\tAssignment& operator=(Assignment&& other) noexcept;",
                    indent + "\tvirtual ~Assignment();",
                ]
            if item.qualified == "DataType" and re.search(r"\bDataType\s*\(\s*DataType\s+other\s*\)", member.header):
                lines.extend([
                    indent + "\tDataType(DataType* other) : DataType(*other) {}",
                    indent + "\tDataType(DataType&&) noexcept = default;",
                    indent + "\tDataType& operator=(const DataType& other);",
                    indent + "\tDataType& operator=(DataType&&) noexcept = default;",
                    indent + "\tvirtual ~DataType() = default;",
                ])
        previous_category = category
    if item.qualified == "DataType":
        lines.extend([
            "",
            indent + "\t// Reinitializes solver-owned storage without changing its stable address.",
            indent + "\tvoid reset(Type rawType = Type::Unknown);",
            indent + "\tvoid reset(Type rawType, const String& refId);",
            indent + "\tvoid reset(Type rawType, DataType* containerType);",
            indent + "\tvoid reset(Type rawType, DataType containerType);",
            indent + "\tvoid reset(const DataType& other);",
            indent + "\tvoid reset(DataType* other) { reset(*other); }",
        ])
    if item.qualified == "ResolveScope":
        lines.extend([
            "",
            indent + "\tResolveScope* operator->() { return this; }",
            indent + "\tconst ResolveScope* operator->() const { return this; }",
            indent + "\toperator ResolveScope*() { return this; }",
        ])
    if item.qualified == "CodeObject":
        lines.extend(["", indent + "\tvirtual ~CodeObject() = default;"])
    if item.qualified == "Statement::Location":
        lines.extend([
            "",
            indent + "\tLocation& operator=(const Location& other) = default;",
            indent + "\tvirtual ~Location() = default;",
        ])
    lines += [f"{indent}}};"]
    return "\n".join(lines)


def all_classes(root_classes: list[ClassDef]) -> list[ClassDef]:
    result: list[ClassDef] = []
    def visit(item: ClassDef):
        result.append(item)
        for nested in item.nested: visit(nested)
    for item in root_classes: visit(item)
    return result


STRING_LITERAL_WRAPPER = re.compile(
    r'(?<![A-Za-z0-9_])String\(("(?:\\.|[^"\\])*")\)')


def simplify_string_literal_wrappers(text: str, source_header: str) -> str:
    """Use plain C++ literals unless a String is needed to drive operator+."""
    string_names = set(re.findall(r"\bString\s+(\w+)", text))
    string_names.update(re.findall(r"\bstring\s+(\w+)", source_header))
    string_list_names = set(re.findall(r"\bList<String>\s+(\w+)", text))

    string_fields: set[str] = set()
    string_methods = {
        "GetCurrentDirectory", "GetEnvironmentVariable", "NameToCpp",
        "ReadAllText", "Replace", "Substring", "ToCpp", "ToConditionCpp",
        "ToCppDefaultValue", "ToCppEnum", "ToCppMemberMacro", "ToLower",
        "ToString", "Trim", "toStringValue",
    }
    for class_item in CLASSES_ALL:
        for member in class_item.members:
            header = clean_header(member.header)
            if member.kind == "field":
                match = re.match(r"(?:public\s+|private\s+|protected\s+|static\s+|readonly\s+)*string\s+(\w+)", header)
                if match:
                    string_fields.add(match.group(1))
            elif member.kind in {"method", "method_decl"}:
                match = re.match(r"(?:public\s+|private\s+|protected\s+|static\s+|override\s+|virtual\s+)*string\s+(\w+)\s*\(", header)
                if match:
                    string_methods.add(match.group(1))

    names_pattern = "|".join(sorted(map(re.escape, string_names), key=len, reverse=True))
    fields_pattern = "|".join(sorted(map(re.escape, string_fields), key=len, reverse=True))
    methods_pattern = "|".join(sorted(map(re.escape, string_methods), key=len, reverse=True))
    lists_pattern = "|".join(sorted(map(re.escape, string_list_names), key=len, reverse=True))

    def left_operand_is_string(before_plus: str) -> bool:
        operand = before_plus.rstrip()
        if re.search(r'String\((?!"(?:\\.|[^"\\])*"\))[^;\n]*\)\s*$', operand):
            return True
        bare_names = "|".join(pattern for pattern in (names_pattern, fields_pattern) if pattern)
        if bare_names and re.search(rf"\b(?:{bare_names})\s*$", operand):
            return True
        if fields_pattern and re.search(rf"(?:->|\.)\s*(?:{fields_pattern})\s*$", operand):
            return True
        if lists_pattern and re.search(rf"\b(?:{lists_pattern})\s*\[[^\]\n]+\]\s*$", operand):
            return True
        return bool(methods_pattern and re.search(
            rf"\b(?:{methods_pattern})\s*\([^;\n]*\)\s*$", operand))

    def right_operand_is_string(after_plus: str) -> bool:
        operand = after_plus.lstrip()
        if re.match(r'String\((?!"(?:\\.|[^"\\])*"\))', operand):
            return True
        bare_names = "|".join(pattern for pattern in (names_pattern, fields_pattern) if pattern)
        if bare_names and re.match(rf"(?:{bare_names})\b", operand):
            return True
        if fields_pattern and re.match(
                rf"[^,;\n+]*?(?:->|\.)\s*(?:{fields_pattern})\b", operand):
            return True
        if lists_pattern and re.match(rf"(?:{lists_pattern})\s*\[", operand):
            return True
        return bool(methods_pattern and re.match(
            rf"[^,;\n+]*?\b(?:{methods_pattern})\s*\(", operand))

    def preceding_additive_chain(before_plus: str) -> str:
        """Return the current expression to the left, excluding nested arguments."""
        masked = mask_code(before_plus)
        depth = 0
        for position in range(len(masked) - 1, -1, -1):
            char = masked[position]
            if char in ")]":
                depth += 1
            elif char in "([":
                if depth == 0:
                    return before_plus[position + 1:]
                depth -= 1
            elif depth == 0 and char in ",;{}=?\n":
                return before_plus[position + 1:]
            elif (depth == 0 and char == ":" and
                  (position == 0 or masked[position - 1] != ":") and
                  (position + 1 == len(masked) or masked[position + 1] != ":")):
                return before_plus[position + 1:]
        return before_plus

    def earlier_operand_establishes_string(before_plus: str) -> bool:
        chain = preceding_additive_chain(before_plus)
        masked = mask_code(chain)
        depth = 0
        operand_start = 0
        operands: list[str] = []
        for position, char in enumerate(masked):
            if char in "([":
                depth += 1
            elif char in ")]":
                depth = max(0, depth - 1)
            elif char == "+" and depth == 0:
                operands.append(chain[operand_start:position])
                operand_start = position + 1
        operands.append(chain[operand_start:])

        for operand in operands:
            stripped = operand.strip()
            if STRING_LITERAL_WRAPPER.fullmatch(stripped):
                return True
            if left_operand_is_string(stripped):
                return True
        return False

    def simplify(match: re.Match[str]) -> str:
        start, end = match.span()
        left = start - 1
        while left >= 0 and text[left].isspace():
            left -= 1
        right = end
        while right < len(text) and text[right].isspace():
            right += 1

        preceded_by_plus = left >= 0 and text[left] == "+"
        followed_by_plus = right < len(text) and text[right] == "+"
        followed_by_member_access = right < len(text) and text[right] == "."

        if not preceded_by_plus and not followed_by_plus and not followed_by_member_access:
            return match.group(1)
        if preceded_by_plus and left_operand_is_string(text[:left]):
            return match.group(1)
        if preceded_by_plus and earlier_operand_establishes_string(text[:left]):
            return match.group(1)
        if followed_by_plus and right_operand_is_string(text[right + 1:]):
            return match.group(1)
        return match.group(0)

    return STRING_LITERAL_WRAPPER.sub(simplify, text)


RUNTIME_MEMBERS = {
    "Add", "Append", "AppendLine", "Captures", "Clear", "Contains",
    "ContainsKey", "Copy", "CopyTo", "CreateDirectory", "Delete", "Elapsed",
    "Exists", "Exit", "FullName", "GetCurrentDirectory", "GetDirectories",
    "GetEnvironmentVariable", "GetFiles", "Groups", "Index", "IndexOf", "Keys",
    "LastWriteTime", "Length", "Matches", "Name", "Now", "ReadAllText",
    "ReadKey", "ReadLine", "Remove", "RemoveAll", "RemoveAt", "Replace",
    "Restart", "Sort", "Split", "Start", "StartsWith", "Stop", "Substring",
    "ToInt32", "ToLower", "ToString", "TotalMilliseconds", "Trim", "Value",
    "Values", "WriteAllText", "WriteLine", "DeserializeObject",
}


def source_member_name(member: Member) -> str | None:
    header = clean_header(member.header).replace("\r", " ").replace("\n", " ")
    header = re.sub(r"\s+", " ", header).strip()
    if member.kind == "field":
        declaration = header.split("=", 1)[0].strip()
        match = re.search(r"\b(\w+)\s*$", declaration)
        return match.group(1) if match else None
    if member.kind in {"method", "method_decl"}:
        prefix = header.split("(", 1)[0]
        words = prefix.split()
        return words[-1] if words else None
    return None


def lower_non_class_names(text: str, owner: ClassDef, source_header: str) -> str:
    """Lower fields, functions and variables without touching types or text."""
    protected: list[str] = []

    def stash(match: re.Match[str]) -> str:
        protected.append(match.group(0))
        return f"__CPPGEN_NAMING_{len(protected) - 1}__"

    text = re.sub(
        r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\r\n]*|/\*.*?\*/',
        stash, text, flags=re.S)

    class_member_maps: dict[str, dict[str, str]] = {}
    class_field_maps: dict[str, dict[str, tuple[str, bool]]] = {}
    all_member_renames = {name: lower_first(name) for name in RUNTIME_MEMBERS}
    all_member_renames["Delete"] = "deleteFile"
    for class_item in CLASSES_ALL:
        member_map: dict[str, str] = {}
        field_map: dict[str, tuple[str, bool]] = {}
        for member in class_item.members:
            name = source_member_name(member)
            if name and name != class_item.name and name[:1].isupper():
                member_map[name] = lower_first(name)
                all_member_renames[name] = lower_first(name)
                if member.kind == "field":
                    field_map[name] = (
                        lower_first(name),
                        bool(re.search(r"\bstatic\b", clean_header(member.header))))
        class_member_maps[class_item.qualified] = member_map
        class_field_maps[class_item.qualified] = field_map

    if all_member_renames:
        member_pattern = "|".join(
            sorted(map(re.escape, all_member_renames), key=len, reverse=True))
        text = re.sub(
            rf"(?P<access>->|\.)(?P<name>{member_pattern})\b",
            lambda match: match.group("access") +
                all_member_renames[match.group("name")], text)

    runtime_classes = {
        "Console", "Convert", "DateTime", "Directory", "Environment", "File",
        "JsonConvert", "Regex",
    }
    for class_name in runtime_classes:
        for original, lowered in all_member_renames.items():
            text = re.sub(
                rf"\b{class_name}::{re.escape(original)}\b",
                f"{class_name}::{lowered}", text)

    for class_name, member_map in class_member_maps.items():
        for original, lowered in member_map.items():
            text = re.sub(
                rf"\b(?:CppGen::)?{re.escape(class_name)}::{re.escape(original)}\b",
                lambda match, value=lowered: match.group(0)[:-len(original)] + value,
                text)

    owner_member_map: dict[str, str] = {}
    owner_field_map: dict[str, tuple[str, bool, str]] = {}
    current: ClassDef | None = owner
    visited: set[str] = set()
    while current and current.qualified not in visited:
        visited.add(current.qualified)
        owner_member_map.update(class_member_maps.get(current.qualified, {}))
        owner_field_map.update({
            original: (lowered, is_static, current.qualified)
            for original, (lowered, is_static)
            in class_field_maps.get(current.qualified, {}).items()
        })
        current = next((item for item in CLASSES_ALL if item.name == current.base), None)

    for original, (lowered, is_static, declaring_class) in owner_field_map.items():
        replacement = f"{declaring_class}::{lowered}" if is_static else f"this->{lowered}"
        text = re.sub(
            rf"(?<![:.>\w]){re.escape(original)}\b(?!\s*::)", replacement, text)
        owner_member_map.pop(original, None)

    parameter_names: dict[str, str] = {}
    opening = source_header.find("(")
    closing = source_header.rfind(")")
    if 0 <= opening < closing:
        for parameter in split_generic(source_header[opening + 1:closing]):
            match = re.match(r".+?\s+(\w+)(?:\s*=.*)?$", parameter.strip(), re.S)
            if match and match.group(1)[:1].isupper():
                parameter_names[match.group(1)] = lower_first(match.group(1))

    type_pattern = "|".join(sorted(map(re.escape, {
        "auto", "bool", "char", "double", "float", "int", "long", "size_t",
        "std::size_t", "String", "Json", "FileInfo", "DirectoryInfo", "Capture",
        "Match", "Group", "Stopwatch", "StringBuilder", *[item.name for item in CLASSES_ALL],
    }), key=len, reverse=True))
    local_names = {
        match.group(1): lower_first(match.group(1))
        for match in re.finditer(
            rf"\b(?:{type_pattern})(?:\s*\*)?\s+([A-Z]\w*)\b", text)
    }

    for original, lowered in {**owner_member_map, **parameter_names, **local_names}.items():
        text = re.sub(
            rf"(?<![:.>\w]){re.escape(original)}\b(?!\s*::)", lowered, text)

    method_match = re.search(r"\b(\w+)\s*\(", clean_header(source_header))
    method = method_match.group(1) if method_match else ""
    for original, replacement in CONTEXT_IDENTIFIER_OVERRIDES.get(
            (owner.qualified, method), {}).items():
        text = re.sub(
            rf"(?<![:.>\w]){re.escape(original)}\b(?!\s*::)", replacement, text)

    text = re.sub(
        r"__CPPGEN_NAMING_(\d+)__",
        lambda match: protected[int(match.group(1))], text)
    return text


def convert_body(body: str, owner: ClassDef, class_names: set[str], pointer_params: set[str], pointer_lists: set[str], source_header: str) -> str:
    text = body
    shadowed_types = shadowed_type_names(owner, class_names)
    def verbatim(match: re.Match[str]) -> str:
        value = match.group(1).replace('""', '"')
        value = value.replace('\\', '\\\\').replace('"', '\\"').replace('\r', '\\r').replace('\n', '\\n')
        return '"' + value + '"'
    text = re.sub(r'(?<!["\w])@"((?:""|[^"])*)"', verbatim, text)
    text = convert_string_switches(text)
    # Keep replacement-oriented C# type rewrites out of literal contents
    # (notably the data-type names "string" and "null").
    literals: list[str] = []
    def stash_literal(match: re.Match[str]) -> str:
        literals.append(match.group(0))
        return f"__CPPGEN_LITERAL_{len(literals) - 1}__"
    text = re.sub(r'(?<![\'\\])"(?:\\.|[^"\\])*"', stash_literal, text)
    text = text.replace("?.", ".")  # targeted null guards are added below
    text = re.sub(r"\bnull\b", "nullptr", text)
    text = re.sub(r"\bforeach\s*\((.+?)\s+in\s+(.+?)\)", r"for (\1 : \2)", text)
    text = re.sub(r"\bstring\[\]", "List<String>", text)
    text = re.sub(r"\bstring\b", "String", text)
    text = re.sub(r"\bdynamic\b", "Json", text)
    text = re.sub(r"\bnew\s+List<([^>]+)>\s*\((.*?)\)", lambda m: f"List<{cpp_type(m.group(1), class_names)}>({m.group(2)})", text)
    text = re.sub(r"\bnew\s+StringBuilder\s*\((.*?)\)", r"StringBuilder(\1)", text)
    text = re.sub(r"\bnew\s+(DirectoryInfo|FileInfo|Stopwatch|Regex)\s*\((.*?)\)", r"\1(\2)", text)
    text = re.sub(
        r"__CPPGEN_LITERAL_(\d+)__",
        lambda m: literals[int(m.group(1))], text)
    # C# promotes literals during string concatenation. Keeping literals as the
    # lightweight String wrapper preserves that behavior mechanically.
    text = re.sub(r'(?<![\w\'])"(?:\\.|[^"\\])*"', lambda m: "String(" + m.group(0) + ")", text)
    if owner.name == "Program":
        text = text.replace(
            'String("\\\\CppProject\\\\Generated")',
            'String("/CppProject/Generated2")')
    text = re.sub(r"\bnew\s+Dictionary<string,\s*([^>]+)>\s*\(\)", lambda m: f"OrderedMap<{cpp_type(m.group(1), class_names)}>()", text)
    text = re.sub(r"\bList<([^>]+)>", lambda m: f"List<{cpp_type(m.group(1), class_names)}>", text)
    text = re.sub(r"\bDictionary<String,\s*([^>]+)>", lambda m: f"OrderedMap<{cpp_type(m.group(1), class_names)}>", text)
    text = re.sub(r"\bDictionary<string,\s*([^>]+)>", lambda m: f"OrderedMap<{cpp_type(m.group(1), class_names)}>", text)
    for old, new in {
        "Statement.Location": "Statement::Location", "DataType.Assignment": "DataType::Assignment",
        "ResolveScope.Call": "ResolveScope::Call", "Accessor.ArrayAccessor": "Accessor::ArrayAccessor",
        "SwitchStatement.Case": "SwitchStatement::Case", "DeclarationList.WriteFormat": "DeclarationList::WriteFormat",
        "Token.Type": "Token::Type", "DataType.Type": "DataType::Type", "DataType.CppType": "DataType::CppType",
        "Statement.Type": "Statement::Type", "Expression.Type": "Expression::Type",
    }.items(): text = text.replace(old, new)
    # C# classes have reference identity and whole-run lifetime in CppGen.
    # Route their construction through the monotonic object arena instead of
    # issuing one general-purpose heap allocation per translated `new`.
    for nested, parent in NESTED_PARENTS.items():
        qualified_nested = f"{parent}::{nested}"
        if qualified_nested in VALUE_CONSTRUCTION_TYPES:
            text = re.sub(
                rf"\bnew\s+(?:{parent}::)?{nested}\s*\(",
                f"{qualified_nested}(", text)
            continue
        text = re.sub(
            rf"\bnew\s+(?:{parent}::)?{nested}\s*\(",
            f"makeObject<{parent}::{nested}>(",
            text)
    for name in sorted(class_names, key=len, reverse=True):
        qualified = f"CppGen::{name}" if name in shadowed_types else name
        if name in VALUE_CONSTRUCTION_TYPES:
            text = re.sub(rf"\bnew\s+{name}\s*\(", f"{qualified}(", text)
            continue
        text = re.sub(
            rf"\bnew\s+{name}\s*\(",
            f"makeObject<{qualified}>(",
            text)
    # Convert casts before member-access rewriting so the whole chained C#
    # operand remains inside static_cast.
    for name in sorted(class_names, key=len, reverse=True):
        qualified = f"CppGen::{name}" if name in shadowed_types else name
        operand = r"[A-Za-z_]\w*(?:\[[^\]\n]+\]|\.\w+)*"
        text = re.sub(
            rf"\(\({name}\)\s*({operand})\)\.",
            rf"static_cast<{qualified}*>(\1)->", text)
        text = re.sub(
            rf"\({name}\)\s*({operand})",
            rf"static_cast<{qualified}*>(\1)", text)
    # Convert declarations of reference types and remember their names.
    pointers = set(pointer_params)
    value_locals = {
        match.group(2)
        for match in re.finditer(
            r"\b(Token|ResolveScope|DataType::Assignment|ResolveScope::Call|Statement::Location)\s+(\w+)\s*=\s*\1\s*\(",
            text)
    }
    for match in re.finditer(r"List<[^>]*\*>\s+(\w+)", text): pointer_lists.add(match.group(1))
    for name in sorted(class_names, key=len, reverse=True):
        pattern = rf"\b{name}[ \t]+(\w+)"
        for match in re.finditer(pattern, text):
            if match.group(1) not in value_locals:
                pointers.add(match.group(1))
        qualified = f"CppGen::{name}" if name in shadowed_types else name
        text = re.sub(
            pattern,
            lambda match: (f"{qualified} {match.group(1)}" if match.group(1) in value_locals
                           else f"{qualified}* {match.group(1)}"),
            text)
    # Nested reference declarations.
    nested_pattern = r"\b(DataType::Assignment|Statement::Location|ResolveScope::Call|Accessor::ArrayAccessor|SwitchStatement::Case)[ \t]+(\w+)"
    for match in re.finditer(nested_pattern, text):
        if match.group(2) not in value_locals:
            pointers.add(match.group(2))
    text = re.sub(
        nested_pattern,
        lambda match: (f"{match.group(1)} {match.group(2)}" if match.group(2) in value_locals
                       else f"{match.group(1)}* {match.group(2)}"),
        text)
    for name in sorted(class_names, key=len, reverse=True):
        text = re.sub(rf"(?<![.>])\b{name}\.", f"{name}::", text)
    for enum in [x.replace(".", "::") for x in ENUM_TYPES]:
        text = text.replace(enum + ".", enum + "::")
    text = re.sub(r"(?<![.>])\b(Type|CppType|WriteFormat)\.", r"\1::", text)
    for name in sorted(pointers, key=len, reverse=True):
        text = re.sub(rf"\b{re.escape(name)}\.", f"{name}->", text)
    # Pointer-valued fields in any class make chained member access use ->.
    pointer_fields = set()
    owner_pointer_fields = set()
    list_fields = set(pointer_lists)
    for class_item in CLASSES_ALL:
        for member in class_item.members:
            if member.kind != "field": continue
            _, fname, is_ptr, is_ptr_list = field_declaration(member.header, class_names)
            if (class_item.qualified, fname) in STORAGE_POINTER_FIELDS:
                pointer_fields.add(fname)
                continue
            if (class_item.qualified, fname) in VALUE_FIELD_DECLARATIONS:
                continue
            if fname and is_ptr: pointer_fields.add(fname)
            if fname and is_ptr_list: list_fields.add(fname)
    current = owner
    seen_owners = set()
    while current and current.name not in seen_owners:
        seen_owners.add(current.name)
        for member in current.members:
            if member.kind == "field":
                _, fname, is_ptr, _ = field_declaration(member.header, class_names)
                if (current.qualified, fname) in STORAGE_POINTER_FIELDS:
                    owner_pointer_fields.add(fname)
                    continue
                if (current.qualified, fname) in VALUE_FIELD_DECLARATIONS:
                    continue
                if fname and is_ptr: owner_pointer_fields.add(fname)
        current = next((item for item in CLASSES_ALL if item.name == current.base), None)
    for field_name in sorted(pointer_fields, key=len, reverse=True):
        text = re.sub(rf"([.>]){field_name}\.", rf"\1{field_name}->", text)
    for field_name in sorted(owner_pointer_fields, key=len, reverse=True):
        text = re.sub(rf"(?<![.>:])\b{field_name}\.", rf"{field_name}->", text)
        text = re.sub(rf"(?<![.>:])\b{field_name}::", rf"{field_name}->", text)
    for list_name in sorted(list_fields, key=len, reverse=True):
        text = re.sub(rf"\b{list_name}(\[[^\n;]+?\])\.", rf"{list_name}\1->", text)
    for method_name in POINTER_METHODS:
        text = re.sub(rf"(\b{method_name}\([^()\n]*\))\.", rf"\1->", text)
    text = text.replace(".Count", ".size()").replace(".Length", ".size()")
    text = text.replace("->Count", ".size()")
    text = text.replace("Math.Floor", "std::floor").replace("Convert.ToInt32", "Convert::ToInt32")
    text = text.replace("Environment.Exit", "Environment::Exit").replace("System.Environment::Exit", "Environment::Exit").replace("System::Environment::Exit", "Environment::Exit")
    for api in ("Console", "Directory", "File", "JsonConvert", "Regex", "Environment"):
        text = re.sub(rf"(?<![A-Za-z0-9_]){api}\.", api + "::", text)
    text = text.replace("DateTime.Now", "DateTime::Now()")
    text = text.replace("catch (Exception ex)", "catch (const std::exception& ex)")
    text = text.replace("ex.Message", "ex.what()")
    text = text.replace("ex.what()", "String(ex.what())")
    text = re.sub(r"RemoveAll\(\(int (\w+)\) => \(\1 == (\w+)\)\)", r"RemoveAll([&](int \1) { return \1 == \2; })", text)
    # C# null-conditional statements used by this project.
    text = re.sub(r"(^\s*)(NextInChain|IncStatement)->(\w+\([^;]+\));", r"\1if (\2) \2->\3;", text, flags=re.M)
    text = re.sub(r"([A-Za-z_]\w*(?:\[[^\]]+\])?)\.ToString\(\)", r"toStringValue(\1)", text)
    # Preserve the three nullable-token checks in GML.ParseGMLScript.  C#'s
    # lifted != is true for null, while its lifted == comparisons are false.
    last_token_type = "currentFunction->Tokens[currentFunction->Tokens.size() - 1]->type"
    text = text.replace(
        last_token_type + " != Token::Type::Assign",
        "(currentFunction == nullptr || " + last_token_type + " != Token::Type::Assign)")
    for token_type in ("Member", "HashTag"):
        text = text.replace(
            last_token_type + f" == Token::Type::{token_type}",
            "(currentFunction != nullptr && " + last_token_type + f" == Token::Type::{token_type})")
    # Static class qualification must not alter generated C++ include names.
    text = text.replace("Asset/Shader::hpp", "Asset/Shader.hpp")
    text = text.replace("Asset/Sprite::hpp", "Asset/Sprite.hpp")
    # C# evaluates constructor arguments left-to-right.  Save LastPeeked before
    # recursive expression parsing, whose PeekToken calls update that field;
    # C++ intentionally leaves argument order unspecified.
    text = re.sub(
        r"(?P<i>[ \t]*)NextToken\(LastPeeked\);\n(?P=i)return new AssignStatement\(accessor, LastPeeked, ParseExpr\(\), line\);",
        lambda m: (m.group("i") + "Token::Type parsedOperation = LastPeeked;\n" +
                   m.group("i") + "NextToken(parsedOperation);\n" +
                   m.group("i") + "Expression* parsedRight = ParseExpr();\n" +
                   m.group("i") + "return new AssignStatement(accessor, parsedOperation, parsedRight, line);"),
        text)
    text = re.sub(
        r"(?P<i>[ \t]*)NextToken\(LastPeeked\);\n(?P=i)return new BinaryOperation\(LastPeeked, expr, (?P<parse>Parse\w+\(\)), CurrentParseLine\);",
        lambda m: (m.group("i") + "Token::Type parsedOperation = LastPeeked;\n" +
                   m.group("i") + "NextToken(parsedOperation);\n" +
                   m.group("i") + "Expression* parsedRight = " + m.group("parse") + ";\n" +
                   m.group("i") + "return new BinaryOperation(parsedOperation, expr, parsedRight, CurrentParseLine);"),
        text)
    text = re.sub(
        r"(?P<i>[ \t]*)NextToken\(LastPeeked\);\n(?P=i)return new UnaryOperation\(LastPeeked, (?P<parse>Parse\w+\(\)), CurrentParseLine\);",
        lambda m: (m.group("i") + "Token::Type parsedOperation = LastPeeked;\n" +
                   m.group("i") + "NextToken(parsedOperation);\n" +
                   m.group("i") + "Expression* parsedValue = " + m.group("parse") + ";\n" +
                   m.group("i") + "return new UnaryOperation(parsedOperation, parsedValue, CurrentParseLine);"),
        text)
    text = convert_string_switches(text)
    # String switches already emit String literals; the general literal pass
    # must not leave redundant String(String("...")) constructions behind.
    while True:
        collapsed = re.sub(
            r'String\(String\(("(?:\\.|[^"\\])*")\)\)', r'String(\1)', text)
        if collapsed == text:
            break
        text = collapsed
    text = simplify_string_literal_wrappers(text, source_header)
    text = lower_non_class_names(text, owner, source_header)
    return text


def format_method_body(body: str) -> str:
    body = dedent_mixed(body)
    if not body.strip():
        return ""
    lines = body.splitlines()
    return "\n" + "\n".join("\t" + line if line else "" for line in lines) + "\n"


def apply_value_semantics(text: str, owner: ClassDef, source_header: str) -> str:
    """Finish the few contextual rewrites that cannot be inferred from a C# type alone."""
    method_match = re.search(r"\b(\w+)\s*\(", clean_header(source_header))
    method = method_match.group(1) if method_match else ""

    # ResolveScope stores its statement path behind a shared pointer. Member
    # access follows that pointer, while APIs retaining Location value semantics
    # receive a dereferenced path.
    text = text.replace("scope->location.", "scope->location->")
    text = re.sub(r"(?<![\w*])scope->location(?!->|\s*=)",
                  "*scope->location", text)

    # Solver-owned DataType fields keep a stable address. Reinitialize their
    # existing storage instead of allocating an object that an iterative pass
    # will immediately overwrite.
    for field_name in ("resolvedType", "caseResolvedType", "returnType", "type"):
        text = re.sub(
            rf"((?:this|[A-Za-z_]\w*)->{field_name}) = makeObject<DataType>\(([^();]*)\);",
            rf"\1->reset(\2);", text)

    if owner.qualified == "DataType":
        text = text.replace("inputType == nullptr || inputType.assignments.size() == 0",
                            "inputType.assignments.size() == 0")
        text = re.sub(r"for \(Assignment\* (\w+) : this->assignments\)",
                      r"for (Assignment& \1 : this->assignments)", text)
        text = re.sub(r"for \(Assignment\* (\w+) : inputType.assignments\)",
                      r"for (const Assignment& \1 : inputType.assignments)", text)
        text = re.sub(r"for \(Assignment\* (\w+) : other.assignments\)",
                      r"for (const Assignment& \1 : other.assignments)", text)
        for name in ("ass", "inputAss"):
            text = text.replace(name + "->", name + ".")
        if method == "GetFirstAssignment":
            text = text.replace("return ass;", "return &ass;")
        elif method == "GetAssignments":
            text = text.replace("result.add(ass);", "result.add(&ass);")
        if method == "DataType" and re.search(r"\bstring\s+name\b", source_header):
            text = text.replace("DataType* containerType;", "DataType containerType;")
            text = re.sub(r"containerType = makeObject<DataType>\(([^;]+)\);",
                          r"containerType = DataType(\1);", text)
            text = text.replace(
                "this->assignments.add(DataType::Assignment(rawType, \"\", containerType));",
                "this->assignments.add(DataType::Assignment(rawType, \"\", &containerType));")
        if method == "ToString":
            text = text.replace("toStringValue(this->assignments[i])",
                                "this->assignments[i].toString()")
        if method == "Assign":
            text = text.replace(
                "ass.containerType.assign(inputAss.containerType, func, line, containerLevel + 1)",
                "ass.containerType->assign(*inputAss.containerType, func, line, containerLevel + 1)")

    if owner.qualified == "DataType::Assignment":
        if method == "Assignment" and re.search(r"\bAssignment\s+other\b", source_header):
            return """this->rawType = other.rawType;
this->refId = other.refId;
if (other.containerType != nullptr)
{
\tthis->containerStorage = std::make_unique<DataType>(*other.containerType);
\tthis->containerType = this->containerStorage.get();
}
this->func = func;
this->line = line;"""
        if method == "Assignment" and re.search(r"\bType\s+type\b", source_header):
            return """this->rawType = type;
this->refId = refId;
if (containerType != nullptr)
{
\tthis->containerStorage = std::make_unique<DataType>(*containerType);
\tthis->containerType = this->containerStorage.get();
}
this->func = func;
this->line = line;"""
        if method == "ToString":
            text = text.replace("toStringValue(this->containerType)",
                                "this->containerType->toString()")

    if owner.qualified == "Accessor":
        text = text.replace("List<DataType::Assignment*> assignments = this->resolvedType->assignments;",
                            "List<DataType::Assignment> assignments = this->resolvedType->assignments;")
        text = re.sub(r"for \(DataType::Assignment\* ass : assignments\)",
                      "for (DataType::Assignment& ass : assignments)", text)
        text = re.sub(r"for \(DataType::Assignment\* ass : ([^\n]+->assignments)\)",
                      r"for (DataType::Assignment& ass : \1)", text)
        text = text.replace("ass->", "ass.")
        if method == "GetNextInChainScope":
            text = text.replace("ass.", "ass->")
        text = text.replace("ResolveScope(scope,", "ResolveScope(*scope,")
        if method == "Resolve":
            text = text.replace(
                "List<DataType*> inputTypes = List<DataType*>();",
                "List<DataType> inputTypeStorage;\n"
                "inputTypeStorage.reserve(this->callParameters.size());")
            text = re.sub(
                r"(?m)^(\s*)List<DataType> inputTypeStorage;\n\s*inputTypeStorage\.reserve",
                r"\1List<DataType> inputTypeStorage;\n\1inputTypeStorage.reserve", text)
            text = text.replace(
                "inputTypes.add(makeObject<DataType>(expr->resolvedType));",
                "inputTypeStorage.add(DataType(*expr->resolvedType));")
            text = re.sub(
                r"(?m)^(\s*)if \(userFunction != nullptr\) // User function",
                lambda match: (
                    f"{match.group(1)}List<DataType*> inputTypes;\n"
                    f"{match.group(1)}inputTypes.reserve(inputTypeStorage.size());\n"
                    f"{match.group(1)}for (DataType& inputType : inputTypeStorage)\n"
                    f"{match.group(1)}\tinputTypes.add(&inputType);\n\n"
                    f"{match.group(1)}if (userFunction != nullptr) // User function"),
                text, count=1)
        if method == "ApplyType":
            text = re.sub(
                r"if \(this->arrayAccessors\.size\(\) > 0\) // Convert to container type\n"
                r"\s*inputType = makeObject<DataType>\(this->arrayAccessors\[0\]->type, inputType\);",
                "const DataType* appliedType = &inputType;\n"
                "std::optional<DataType> containerType;\n"
                "if (this->arrayAccessors.size() > 0) // Convert to container type\n"
                "{\n"
                "\tcontainerType.emplace(this->arrayAccessors[0]->type, const_cast<DataType*>(&inputType));\n"
                "\tappliedType = &*containerType;\n"
                "}", text)
            text = text.replace("assignReturnType(inputType,", "assignReturnType(*appliedType,")
            text = text.replace("assignType(inputType,", "assignType(*appliedType,")
            text = re.sub(r", inputType, this->func, (\*?scope->location),",
                          r", *appliedType, this->func, \1,", text)
        if method == "ToCpp":
            text = text.replace("this->lastToCppScope == nullptr", "!this->lastToCppScopeSet")
            text = text.replace("this->lastToCppScope = scope; // Save scope",
                                "this->lastToCppScope = *scope; // Save scope\n\tthis->lastToCppScopeSet = true;")
            text = text.replace("this->lastToCppScope != nullptr", "this->lastToCppScopeSet")
            text = text.replace("scope = this->lastToCppScope;", "scope = &this->lastToCppScope;")

    if owner.qualified == "GML":
        text = re.sub(r"Token\* (\w+) = (currentFunction->tokens\[[^\n;]+\]);",
                      r"Token& \1 = \2;", text)
        text = text.replace("lastToken->", "lastToken.")
        text = re.sub(r"\b(token|lastToken)\.size\(\)", r"\1.length", text)

    if owner.qualified == "Function":
        text = re.sub(r"Token\* token = this->tokens\[([^\]]+)\];",
                      r"Token* token = &this->tokens[\1];", text)
        text = re.sub(r"this->currentToken = this->tokens\[([^\]]+)\];",
                      r"this->currentToken = &this->tokens[\1];", text)
        if method == "Function":
            text = text.replace(
                "this->cppSeparateReturnType = makeObject<DataType>(type);",
                "this->cppSeparateReturnTypeStorage = DataType(type);\n"
                "this->cppSeparateReturnType = &this->cppSeparateReturnTypeStorage;")
        if method == "Resolve":
            text = re.sub(
                r"if \(this->structObject != nullptr\) // Switch scope to StructObject\n"
                r"\s*scope = ResolveScope\(this->structObject->name, scope->currentInChain, scope->calls\);",
                "std::optional<ResolveScope> structScope;\n"
                "if (this->structObject != nullptr) // Switch scope to StructObject\n"
                "{\n"
                "\tstructScope.emplace(this->structObject->name, scope->currentInChain, scope->calls);\n"
                "\tscope = &*structScope;\n"
                "}", text)
            text = text.replace("scope->location = Statement::Location();",
                                "scope->location = std::make_shared<Statement::Location>();")
            text = text.replace("this->returnStatement->location != nullptr",
                                "this->returnStatement->location.has_value()")
            text = text.replace("this->returnStatement->location.path",
                                "this->returnStatement->location->path")
        if method == "ToDebugString":
            text = text.replace("var->toStringValue(Location)",
                                "var->location.toString()")

    if owner.qualified == "Statement::Location" and method == "Next":
        return """Location next;
next.path = List<int>(this->path);
next.level = this->level + (addLevel ? 1 : 0);
next.path.add(this->nextId++);
return next;"""

    if owner.qualified == "Variable" and method == "Variable":
        text = re.sub(
            r"\n\s*if \(this->location == nullptr\)\n\s*this->location = Statement::Location\(\);",
            "", text)

    if owner.qualified.endswith("Statement"):
        text = text.replace("this->statement->location(*scope->location)",
                            "Location(*scope->location)")
        text = re.sub(
            r"ResolveScope\* (\w+) = scope->(nextStatement|enterWithStatement)\(([^;]*)\);",
            r"ResolveScope \1 = scope->\2(\3);", text)
        text = re.sub(
            r"ResolveScope\* (\w+) = scope->(nextStatement|enterWithStatement)\(\);",
            r"ResolveScope \1 = scope->\2();", text)
        if owner.qualified == "IfStatement" and method in {"Resolve", "WriteCpp"}:
            text = text.replace("ResolveScope* elseScope = nullptr;",
                                "std::optional<ResolveScope> elseScope;")
            text = text.replace("elseScope = scope->nextStatement();",
                                "elseScope = scope->nextStatement();")
            text = text.replace("this->elseStatement->resolve(elseScope);",
                                "this->elseStatement->resolve(*elseScope);")
            text = text.replace("this->elseStatement->writeCpp(elseScope);",
                                "this->elseStatement->writeCpp(*elseScope);")

    if owner.qualified == "Program" and method == "Main":
        text = re.sub(r", nullptr, (declStmt->(?:line|Line))\);",
                      r", Statement::Location(), \1);", text)
        text = re.sub(r"\bmiDir\b", "repoDir", text)
        text = text.replace(
            'Environment::getEnvironmentVariable("DEV_DIR") + "\\\\Mine-imator"',
            'Directory::getCurrentDirectory() + "/../.."')
        text = text.replace(
            'Directory::getCurrentDirectory() + "\\\\gml.json"',
            'Directory::getCurrentDirectory() + "/../gml.json"')

    if owner.qualified == "ResolveScope":
        if method == "ResolveScope" and re.search(r"\bstring\s+current\b", source_header):
            return """this->current = current;
this->previous = previous;

if (updatedCalls != nullptr)
\tthis->calls = updatedCalls;
else
\tthis->calls = std::make_shared<List<Call>>();

if (currentInChain != \"\")
\tthis->currentInChain = currentInChain;
else
\tthis->currentInChain = this->current;

this->location = location != nullptr
\t? location
\t: std::make_shared<Statement::Location>();

this->funcUpdateScope = funcUpdateScope;"""
        if method == "ResolveScope" and re.search(r"\bResolveScope\s+scope\b", source_header):
            return """this->current = scope.current;
this->currentInChain = scope.currentInChain;
this->previous = scope.previous;
this->location = scope.location;
auto updatedCalls = std::make_shared<List<Call>>(*scope.calls);
updatedCalls->add(Call(callFunc, callLine));
this->calls = std::move(updatedCalls);"""
        if method == "NextStatement":
            return """auto nextLocation = std::make_shared<Statement::Location>(this->location->next(addLevel));
return ResolveScope(this->current, this->previous, this->calls, this->currentInChain, nextLocation, this->funcUpdateScope);"""
        text = re.sub(r"for \((?:Call\*|Call&) (\w+) : this->calls\)",
                      r"for (const Call& \1 : *this->calls)", text)
        text = text.replace("this->calls.size()", "this->calls->size()")
        text = text.replace("call->", "call.")

    if owner.qualified == "Program" and method == "PrintDebugFiles":
        text += """

#ifndef NDEBUG
// Record arena allocations by concrete C++ class.
List<String> allocationStrings;
std::size_t totalAllocations = 0;
for (const auto& [className, count] : objectArena().allocationCounts())
{
	allocationStrings.add(String(className) + ": " + toStringValue(count));
	totalAllocations += count;
}
allocationStrings.sort();
String allocationsText = "Total: " + toStringValue(totalAllocations) + "\\n";
for (const String& allocation : allocationStrings)
	allocationsText += allocation + "\\n";
File::writeAllText(logDir + "/allocations.log", allocationsText);
#endif
"""

    if owner.name in {"Program", "Sprite", "Shader"}:
        # C++ accepts forward separators on Windows as well as POSIX. Convert
        # only literals that begin with a filesystem separator (or consist of
        # one), leaving escape sequences and generated macro continuations.
        def portable_path_literal(match: re.Match[str]) -> str:
            literal = match.group(0)
            if literal.startswith('"\\\\'):
                return literal.replace("\\\\", "/")
            return literal

        text = re.sub(r'"(?:\\.|[^"\\])*"', portable_path_literal, text)

    return text


DATATYPE_OWNERSHIP_DEFINITIONS = r'''DataType& DataType::operator=(const DataType& other)
{
	if (this != &other)
		reset(other);
	return *this;
}

void DataType::reset(Type rawType)
{
	this->assignments.clear();
	this->cppType = CppType::VarType;
	if (rawType != Type::Unknown)
		this->assignments.add(Assignment(rawType, "", nullptr));
	updateCppType();
}

void DataType::reset(Type rawType, const String& refId)
{
	this->assignments.clear();
	this->cppType = CppType::VarType;
	if (rawType != Type::Unknown)
		this->assignments.add(Assignment(rawType, refId, nullptr));
	updateCppType();
}

void DataType::reset(Type rawType, DataType* containerType)
{
	this->assignments.clear();
	this->cppType = CppType::VarType;
	if (rawType != Type::Unknown)
		this->assignments.add(Assignment(rawType, "", containerType));
	updateCppType();
}

void DataType::reset(Type rawType, DataType containerType)
{
	reset(rawType, &containerType);
}

void DataType::reset(const DataType& other)
{
	if (this == &other)
		return;

	this->assignments.clear();
	this->cppType = CppType::VarType;
	this->assignments.reserve(other.assignments.size());
	for (const Assignment& assignment : other.assignments)
		this->assignments.add(Assignment(assignment, assignment.func, assignment.line));
	updateCppType();
}

DataType::Assignment::Assignment(const DataType::Assignment& other)
	: Assignment(other, other.func, other.line)
{}

DataType::Assignment::Assignment(DataType::Assignment&& other) noexcept
{
	*this = std::move(other);
}

DataType::Assignment& DataType::Assignment::operator=(const DataType::Assignment& other)
{
	if (this == &other)
		return *this;

	this->rawType = other.rawType;
	this->refId = other.refId;
	this->containerStorage = other.containerType != nullptr
		? std::make_unique<DataType>(*other.containerType)
		: nullptr;
	this->containerType = this->containerStorage.get();
	this->func = other.func;
	this->line = other.line;
	return *this;
}

DataType::Assignment& DataType::Assignment::operator=(DataType::Assignment&& other) noexcept
{
	if (this == &other)
		return *this;

	this->rawType = other.rawType;
	this->refId = std::move(other.refId);
	this->containerStorage = std::move(other.containerStorage);
	this->containerType = this->containerStorage != nullptr
		? this->containerStorage.get()
		: other.containerType;
	this->func = other.func;
	this->line = other.line;
	other.containerType = nullptr;
	return *this;
}

DataType::Assignment::~Assignment() = default;
'''


UNUSED_DEFINITION_PARAMETERS = {
    ("CodeObject", "Resolve"): {"scope"},
    ("Expression", "ApplyType"): {"scope", "inputType"},
    ("Expression", "ToCpp"): {"scope"},
    ("Expression", "ToConditionCpp"): {"parenthesis"},
    ("ExpressionParenthesis", "ToConditionCpp"): {"parenthesis"},
    ("ExpressionValue", "Resolve"): {"scope"},
    ("ExpressionValue", "ApplyType"): {"scope"},
    ("ExpressionValue", "ToCpp"): {"scope"},
    ("Statement", "WriteCpp"): {"scope"},
    ("BreakStatement", "WriteCpp"): {"scope"},
    ("ContinueStatement", "WriteCpp"): {"scope"},
    ("CustomCppStatement", "Resolve"): {"scope"},
    ("CustomCppStatement", "WriteCpp"): {"scope"},
}


def clean_warning_prone_body(text: str, owner: ClassDef, method: str) -> str:
    """Make intentional fallthrough/default behavior explicit to strict Clang."""
    if owner.qualified == "Accessor" and method == "ToCpp":
        text = re.sub(
            r"\n\s*GML::FunctionSignature\* sign = GML::functions\[this->name\];",
            "", text)

    if owner.qualified == "DataType" and method == "UpdateCppType":
        text = text.replace(
            "\t\tswitch (ass.rawType)\n\t\t{",
            "\t\tswitch (ass.rawType)\n\t\t{\n\t\t\tcase Type::Unknown: break;")
    if owner.qualified == "DataType" and method in {
            "ToCppMemberMacro", "ToCppDefaultValue", "ToCppEnum"}:
        text = text.replace(
            "\tswitch (cppType)\n\t{",
            "\tswitch (cppType)\n\t{\n\t\tcase CppType::Void: return \"\";")

    if owner.qualified == "Function" and method == "ParseStatement":
        text = text.replace(
            "\t\t\treturn sl;\n\t\t}\n\t}\n\n\tnextToken",
            "\t\t\treturn sl;\n\t\t}\n\n\t\tdefault: break;\n\t}\n\n\tnextToken")
    if owner.qualified == "Function" and method == "ParseAccessor":
        text = text.replace(
            "\t\t\tcase Token::Type::HashTag: arrAccType = DataType::Type::Grid; break;\n\t\t}\n\t\tif",
            "\t\t\tcase Token::Type::HashTag: arrAccType = DataType::Type::Grid; break;\n"
            "\t\t\tdefault: break;\n\t\t}\n\t\tif")
    if owner.qualified == "Function" and method == "ParseExprValue":
        text = text.replace(
            "\t\t\treturn makeObject<ExpressionParenthesis>(expr, Function::currentParseLine);\n"
            "\t\t}\n\t}\n\n\treturn nullptr;",
            "\t\t\treturn makeObject<ExpressionParenthesis>(expr, Function::currentParseLine);\n"
            "\t\t}\n\n\t\tdefault: break;\n\t}\n\n\treturn nullptr;")
    if owner.qualified == "Token" and method == "ToCpp":
        text = text.replace(
            "\t\tcase Type::ArrayRef: return \"@\";\n\t}\n\treturn \"\";",
            "\t\tcase Type::ArrayRef: return \"@\";\n\t\tdefault: return \"\";\n\t}")
    return text


def method_definitions(items: list[ClassDef], class_names: set[str]) -> str:
    chunks = ['#include "CppGen.hpp"', "", "namespace CppGen", "{"]
    for item in all_classes(items):
        for member in item.members:
            if member.kind != "method": continue
            sig, pointers, pointer_lists = method_signature(member.header, item, class_names, False)
            method_match = re.search(r"\b(\w+)\s*\(", clean_header(member.header))
            method = method_match.group(1) if method_match else ""
            for parameter in UNUSED_DEFINITION_PARAMETERS.get((item.qualified, method), set()):
                sig = re.sub(rf"\b{parameter}\b(?=\s*[,\)])", "", sig)
            for nested, parent in NESTED_PARENTS.items():
                sig = re.sub(rf"(?<![:\w]){nested}\*", f"{parent}::{nested}*", sig)
            converted_body = convert_body(
                member.body, item, class_names, pointers, pointer_lists, member.header)
            body = format_method_body(apply_value_semantics(converted_body, item, member.header))
            body = clean_warning_prone_body(body, item, method)
            chunks += [sig, "{" + body + "}", ""]
    if any(item.qualified == "DataType" for item in all_classes(items)):
        chunks += [DATATYPE_OWNERSHIP_DEFINITIONS, ""]
    chunks.append("}")
    return "\n".join(chunks) + "\n"


def main() -> None:
    global CLASSES_ALL
    classes, by_file = parse_sources()
    missing = [name for name in ORDER if name not in classes]
    if missing: raise RuntimeError(f"missing parsed classes: {missing}")
    CLASSES_ALL = all_classes(list(classes.values()))
    class_names = set(classes) | {item.name for item in CLASSES_ALL}

    forwards = "\n".join(f"class {name};" for name in ORDER)
    declarations = "\n\n".join(class_declaration(classes[name], class_names) for name in ORDER)
    header = f'''#pragma once

#include "Runtime.hpp"

namespace CppGen
{{

{forwards}

{declarations}
}}
'''
    (OUT_DIR / "CppGen.hpp").write_text(header, encoding="utf-8", newline="\n")
    for path, items in by_file.items():
        (OUT_DIR / f"{path.stem}.cpp").write_text(
            method_definitions(items, class_names), encoding="utf-8", newline="\n")


CLASSES_ALL: list[ClassDef] = []
POINTER_METHODS = {
    "GetFirstAssignment", "FindVariable", "DeclareVariable", "ParseExpression",
    "ParseTernary", "ParseOr", "ParseAnd", "ParseCompare", "ParseBitwise",
    "ParseShift", "ParseAddSub", "ParseMulDiv", "ParseUnary", "ParseValue",
    "GetReturnType", "NextToken",
}

if __name__ == "__main__":
    main()
