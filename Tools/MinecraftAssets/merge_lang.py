# Inserts missing translation keys into a .milanguage file without reformatting it.
# Usage: merge_lang.py <file.milanguage> <translations.json>
import json, sys
from collections import OrderedDict

path, additions = sys.argv[1], json.load(open(sys.argv[2]), object_pairs_hook=OrderedDict)
text = open(path, encoding='utf-8').read()
data = json.loads(text, object_pairs_hook=OrderedDict)


def find_object(text, keypath):
    """Returns (start, end) indices of the braces of the object at keypath (list of keys)."""
    i = text.index('{')
    for key in keypath:
        depth, j, found = 0, i + 1, None
        while j < len(text):
            c = text[j]
            if c == '"':
                k = j + 1
                while text[k] != '"':
                    k += 2 if text[k] == '\\' else 1
                s = text[j + 1:k]
                j = k + 1
                if depth == 0 and s == key:
                    m = j
                    while text[m] in ' \t\r\n:':
                        m += 1
                    if text[m] == '{':
                        found = m
                        break
                continue
            if c in '{[':
                depth += 1
            elif c in '}]':
                if depth == 0:
                    break
                depth -= 1
            j += 1
        if found is None:
            raise KeyError(keypath)
        i = found
    # Find matching close
    depth, j = 0, i
    while True:
        c = text[j]
        if c == '"':
            k = j + 1
            while text[k] != '"':
                k += 2 if text[k] == '\\' else 1
            j = k + 1
            continue
        if c in '{[':
            depth += 1
        elif c in '}]':
            depth -= 1
            if depth == 0:
                return i, j
        j += 1


sections = {
    'block/': ['block/'],
    'block/state/': ['block/', 'state/'],
    'block/state/value/': ['block/', 'state/', 'value/'],
    'model/state/value/': ['model/', 'state/', 'value/'],
    'patterneditor/patterns/': ['patterneditor/', 'patterns/'],
    'worldsettings/': ['worldsettings/'],
}
added = 0
for section, keys in sections.items():
    existing = data
    for k in keys:
        existing = existing[k]
    new = [(k, v) for k, v in additions.get(section, {}).items() if k not in existing]
    if not new:
        continue
    start, end = find_object(text, keys)
    body = text[start + 1:end]
    # Indentation of the entries in this object
    lines = [l for l in body.split('\n') if l.strip().startswith('"')]
    indent = lines[-1][:len(lines[-1]) - len(lines[-1].lstrip())] if lines else '\t'
    # Last non-whitespace character before the closing brace gets a comma
    k = end - 1
    while text[k] in ' \t\r\n':
        k -= 1
    insert = ''.join(',\n%s%s: %s' % (indent, json.dumps(key), json.dumps(value, ensure_ascii=False)) for key, value in new)
    insert = insert[1:] if text[k] == ',' else insert
    text = text[:k + 1] + insert + text[k + 1:]
    added += len(new)

json.loads(text)  # Validate
open(path, 'w', encoding='utf-8').write(text)
print('added', added)
