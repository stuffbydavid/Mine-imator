# Reads vanilla block states and models (with parents) from an extracted assets folder.
import json, os

# Folder containing blockstates/, models/ and textures/ (assets/minecraft of the target version)
A = os.environ.get('MC_ASSETS', '')
_cache = {}
def strip(n):
    n = n.replace('minecraft:', '')
    return n
def load_model(name):
    name = strip(name)
    if name in _cache: return _cache[name]
    p = A + '/models/' + name + '.json'
    m = json.load(open(p)) if os.path.exists(p) else {}
    res = {'textures': {}, 'elements': None}
    if 'parent' in m and not m['parent'].startswith('builtin'):
        par = load_model(m['parent'])
        res['textures'].update(par['textures']); res['elements'] = par['elements']
    for k, v in m.get('textures', {}).items():
        res['textures'][k] = v['sprite'] if isinstance(v, dict) else v
    if 'elements' in m: res['elements'] = m['elements']
    _cache[name] = res
    return res
def resolve_tex(model, ref, depth=0):
    if not ref.startswith('#') and ref in model['textures']:
        ref = '#' + ref
    while ref.startswith('#') and depth < 10:
        ref = model['textures'].get(ref[1:], ref); depth += 1
    return None if ref.startswith('#') else strip(ref)
def block_models(block):
    bs = json.load(open(A + '/blockstates/' + block + '.json'))
    out = []
    def add(v):
        if isinstance(v, list):
            for x in v: add(x)
        else: out.append(v['model'])
    for v in bs.get('variants', {}).values(): add(v)
    for p in bs.get('multipart', []): add(p['apply'])
    return sorted(set(strip(x) for x in out))
def block_textures(block):
    tex = set()
    for mn in block_models(block):
        m = load_model(mn)
        for e in (m['elements'] or []):
            for f in e.get('faces', {}).values():
                t = resolve_tex(m, f['texture'])
                if t: tex.add(t)
    return tex
def has_geometry(block):
    return any(load_model(mn)['elements'] for mn in block_models(block))
