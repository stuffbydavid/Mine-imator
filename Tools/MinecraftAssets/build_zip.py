# Builds Mine-imator's 26.3.zip from the vanilla 26.3 assets and the 1.20.2 archive.
#  - Vanilla files present in 26.3 replace the old ones, except entity textures whose layout changed
#    (Mine-imator's character models are made for the old layouts)
#  - Files only in the old archive (Mine-imator models/textures, renamed vanilla files) are kept
#  - Sign textures in the entity layout are generated for new wood types
import os, sys, zipfile, io, json
import numpy as np
from PIL import Image, ImageChops

# Usage: build_zip.py <1.20.2.zip> <folder containing assets/minecraft of 26.3> <out.zip>
OLDZIP, NEW, OUT = sys.argv[1:4]
PREFIX = 'assets/minecraft/'

old = zipfile.ZipFile(OLDZIP)
old_files = [n for n in old.namelist() if not n.endswith('/')]
old_dirs = set(os.path.dirname(n) for n in old_files)


def new_path(rel):
    return os.path.join(NEW, rel)


def layout_changed(rel):
    a = Image.open(io.BytesIO(old.read(rel))).convert('RGBA')
    b = Image.open(new_path(rel)).convert('RGBA')
    if a.size != b.size:
        return True
    aa = np.array(a)[:, :, 3] > 0
    bb = np.array(b)[:, :, 3] > 0
    return (aa != bb).sum() / max(1, aa.sum()) > 0.02


out = {}  # zip path -> bytes
kept_old, replaced, added, layout_kept = 0, 0, 0, []

for n in old_files:
    rel_mc = n[len(PREFIX):] if n.startswith(PREFIX) else None
    if rel_mc and os.path.exists(new_path(n)) and not rel_mc.startswith('models/character') and not rel_mc.startswith('models/special_block'):
        if rel_mc.startswith('textures/entity/') and n.endswith('.png') and layout_changed(n):
            out[n] = old.read(n)
            layout_kept.append(rel_mc)
        else:
            out[n] = open(new_path(n), 'rb').read()
            replaced += 1
    else:
        out[n] = old.read(n)
        kept_old += 1

# New vanilla files in the folders Mine-imator uses
include_roots = ['blockstates', 'models/block', 'textures']
for root in include_roots:
    for dp, dn, fn in os.walk(new_path(PREFIX + root)):
        rel_dir = os.path.relpath(dp, NEW)
        if root == 'textures':
            # Only texture folders that existed (or whose parent existed) in the old archive
            parent = rel_dir
            ok = False
            while parent.startswith(PREFIX + 'textures'):
                if parent in old_dirs:
                    ok = True
                    break
                parent = os.path.dirname(parent)
            if not ok:
                continue
        for f in fn:
            n = os.path.join(rel_dir, f)
            if n not in out:
                out[n] = open(os.path.join(dp, f), 'rb').read()
                added += 1


# Sign textures for new wood types, using a pixel mapping learned from woods that exist in both layouts
def learn_and_convert(old_fmt, new_fmt, woods, targets):
    olds = [np.array(Image.open(io.BytesIO(old.read(PREFIX + 'textures/' + old_fmt % w))).convert('RGBA')) for w in woods]
    news = [np.array(Image.open(new_path(PREFIX + 'textures/' + new_fmt % w)).convert('RGBA')) for w in woods]
    oh, ow = olds[0].shape[:2]
    nh, nw = news[0].shape[:2]
    pack = lambda arrs: np.stack([a.view(np.uint32).reshape(a.shape[:2]) for a in arrs], axis=-1)
    O, N = pack(olds), pack(news)
    lookup = {}
    for y in range(nh):
        for x in range(nw):
            lookup.setdefault(N[y, x].tobytes(), (y, x))
    mapping, unmapped = {}, 0
    for y in range(oh):
        for x in range(ow):
            if (olds[0][y, x, 3] == 0) and all(o[y, x, 3] == 0 for o in olds):
                continue
            q = lookup.get(O[y, x].tobytes())
            if q is None:
                unmapped += 1
            else:
                mapping[(y, x)] = q
    results = {}
    for t in targets:
        src = np.array(Image.open(new_path(PREFIX + 'textures/' + new_fmt % t)).convert('RGBA'))
        dst = np.zeros((oh, ow, 4), np.uint8)
        for (y, x), (qy, qx) in mapping.items():
            dst[y, x] = src[qy, qx]
        buf = io.BytesIO()
        Image.fromarray(dst, 'RGBA').save(buf, 'PNG')
        results[t] = buf.getvalue()
    return results, len(mapping), unmapped


woods = ['oak', 'spruce', 'birch', 'jungle', 'acacia', 'dark_oak', 'mangrove', 'cherry', 'bamboo', 'crimson', 'warped']
for old_fmt, new_fmt, out_fmt in [('entity/signs/%s.png', 'block/%s_sign.png', 'entity/signs/%s.png'),
                                  ('entity/signs/hanging/%s.png', 'block/%s_hanging_sign.png', 'entity/signs/hanging/%s.png')]:
    res, mapped, unmapped = learn_and_convert(old_fmt, new_fmt, woods, ['pale_oak', 'poplar'])
    print('sign mapping', old_fmt, 'mapped', mapped, 'unmapped', unmapped)
    for t, data in res.items():
        out[PREFIX + 'textures/' + out_fmt % t] = data

# Write
names = sorted(out)
with zipfile.ZipFile(OUT, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    dirs = set()
    for n in names:
        parts = n.split('/')[:-1]
        for i in range(1, len(parts) + 1):
            d = '/'.join(parts[:i]) + '/'
            if d not in dirs:
                dirs.add(d)
                z.writestr(d, b'')
        z.writestr(n, out[n])
print('files', len(names), 'kept old', kept_old, 'replaced', replaced, 'added', added, 'layout kept old', len(layout_kept))
print('size', os.path.getsize(OUT))
