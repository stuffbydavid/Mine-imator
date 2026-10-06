# Generates Mine-imator's 26.3.midata from 1.20.2.midata and the vanilla 26.3 assets.
# Usage: MC_ASSETS=<assets/minecraft> gen_midata.py <1.20.2.midata> <blocks data.json> <out.midata> <out translations.json>
#  - blocks data.json is the block summary (properties and defaults), e.g. from misode/mcmeta (26.3-summary/blocks/data.min.json)
#  - The translations are merged into the language file with merge_lang.py
import json, os, sys, copy
from collections import OrderedDict
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from mcmodels import A, block_models, load_model, resolve_tex

OLD, SUMMARY, OUT, LANG_OUT = sys.argv[1:5]

d = json.load(open(OLD), object_pairs_hook=OrderedDict)
summary = json.load(open(SUMMARY))
blocks = OrderedDict((b['name'], b) for b in d['blocks'])
special = OrderedDict((b['name'], b) for b in d['special_blocks'])
lang = {'block/': {}, 'block/state/': {}, 'block/state/value/': {}, 'model/state/value/': {}, 'patterneditor/patterns/': {}}
handled = set()
warnings = []

COLORS = ['white', 'orange', 'magenta', 'light_blue', 'yellow', 'lime', 'pink', 'gray', 'light_gray', 'cyan', 'purple',
          'blue', 'brown', 'green', 'red', 'black']
NEW_WOODS = ['pale_oak', 'poplar']
OXIDATION = ['', 'exposed_', 'weathered_', 'oxidized_']


def title(s):
    return ' '.join(w.capitalize() for w in s.split('_'))


def props(mcid):
    """Minecraft properties of a block (without waterlogged), with values and default."""
    p, default = summary.get(mcid, [{}, {}])
    states = OrderedDict((k, v) for k, v in p.items() if k != 'waterlogged')
    return states, {k: v for k, v in default.items() if k != 'waterlogged'}


def exists(mcid):
    return os.path.exists(A + '/blockstates/' + mcid + '.json')


def ids_dict(block):
    i = block.get('id')
    if isinstance(i, str):
        i = OrderedDict([(i, '')])
        block['id'] = i
    elif i is None:
        i = OrderedDict()
        block['id'] = i
    return i


def check_props(group, mcid, skip=()):
    states, _ = props(mcid)
    for k in states:
        if k not in group.get('states', {}) and k not in skip:
            warnings.append('%s: property %s not in group %s' % (mcid, k, group['name']))


def add_variant(group_name, value, mcid, key='variant', extra=None, id_vars=None):
    """Adds a value for a Minecraft block to an existing Mine-imator block."""
    assert exists(mcid), mcid
    group = blocks[group_name]
    values = group['states'][key]
    entry = OrderedDict([('value', value), ('file', mcid + '.json')])
    if extra:
        entry.update(extra)
    if not any((v['value'] if isinstance(v, dict) else v) == value for v in values):
        values.append(entry)
    ids_dict(group)['minecraft:' + mcid] = id_vars or (key + '=' + value)
    check_props(group, mcid)
    lang['block/state/value/'][value] = title(value)
    handled.add(mcid)


def add_plain_value(group_name, key, value, mcid, id_vars=None):
    """Adds a plain state value (no file) for blocks rendered as models."""
    group = blocks[group_name]
    if value not in group['states'][key]:
        group['states'][key].append(value)
    ids_dict(group)['minecraft:' + mcid] = id_vars or (key + '=' + value)
    lang['block/state/value/'][value] = title(value)
    handled.add(mcid)


def new_block(name, mcids, extra=None, variant_key='variant', variants=None, after=None):
    """Creates a Mine-imator block. mcids is a single Minecraft ID, or a list of (value, mcid) for variants."""
    b = OrderedDict([('name', name)])
    if extra and 'type' in extra:
        b['type'] = extra.pop('type')
    states = OrderedDict()
    if isinstance(mcids, str):
        assert exists(mcids), mcids
        b['file'] = mcids + '.json'
        p, default = props(mcids)
        states.update(p)
        idmap = 'minecraft:' + mcids
        handled.add(mcids)
        first = mcids
        default_vars = default
    else:
        states[variant_key] = []
        idmap = OrderedDict()
        for value, mcid in mcids:
            assert exists(mcid), mcid
            states[variant_key].append(OrderedDict([('value', value), ('file', mcid + '.json')]))
            idmap['minecraft:' + mcid] = variant_key + '=' + value
            handled.add(mcid)
            lang['block/state/value/'][value] = title(value)
        first = mcids[0][1]
        p, default = props(first)
        states.update(p)
        default_vars = OrderedDict([(variant_key, mcids[0][0])])
        default_vars.update(default)
    if states:
        b['states'] = states
        b['default_state'] = ','.join('%s=%s' % kv for kv in default_vars.items())
        for k in states:
            lang['block/state/'].setdefault(k, title(k))
    if extra:
        b.update(extra)
    b['id'] = idmap
    lang['block/'][name] = title(name)
    if after and after in blocks:
        items = list(blocks.items())
        pos = [k for k, _ in items].index(after) + 1
        items.insert(pos, (name, b))
        blocks.clear()
        blocks.update(items)
    else:
        blocks[name] = b
    return b


def to_variant_group(name, first_value, entries, after_ids=None):
    """Turns a single-file block into a variant group keeping the original as the first (default) value."""
    b = blocks[name]
    old_file = b.pop('file')
    old_ids = b.get('id')
    states = OrderedDict([('variant', [OrderedDict([('value', first_value), ('file', old_file)])])])
    states.update(b.get('states', OrderedDict()))
    b['states'] = states
    b['default_state'] = 'variant=' + first_value + ((',' + b['default_state']) if b.get('default_state') else '')
    idmap = OrderedDict()
    for k in ([old_ids] if isinstance(old_ids, str) else list(old_ids)):
        idmap[k] = 'variant=' + first_value
    b['id'] = idmap
    # Keep key order: name, (type), states, default_state, ..., id
    order = ['name', 'type', 'states', 'default_state']
    newb = OrderedDict((k, b[k]) for k in order if k in b)
    for k, v in b.items():
        if k not in newb:
            newb[k] = v
    blocks[name] = newb
    lang['block/state/value/'][first_value] = title(first_value)
    for value, mcid in entries:
        add_variant(name, value, mcid)


# --------------------------------------------------------------------------------------------------
# Renamed blocks (keep the old IDs for older worlds)

grass = blocks['grass']
for v in grass['states']['type']:
    if v['value'] == 'grass':
        v['file'] = 'short_grass.json'
ids_dict(grass)['minecraft:short_grass'] = 'type=grass'
handled.add('short_grass')

# --------------------------------------------------------------------------------------------------
# New wood types

for w in NEW_WOODS:
    add_variant('planks', w, w + '_planks')
    add_variant('log', w, w + '_log')
    add_variant('stripped_log', w, 'stripped_' + w + '_log')
    add_variant('wood', w, w + '_wood')
    add_variant('stripped_wood', w, 'stripped_' + w + '_wood')
    add_variant('sapling', w, w + '_sapling')
    add_variant('slab', w, w + '_slab')
    add_variant('stairs', w, w + '_stairs')
    add_variant('fence', w, w + '_fence')
    add_variant('fence_gate', w, w + '_fence_gate')
    add_variant('door', w, w + '_door')
    add_variant('trapdoor', w, w + '_trapdoor')
    add_variant('button', w, w + '_button')
    add_variant('pressure_plate', w, w + '_pressure_plate')
    add_variant('flower_pot', w + '_sapling', 'potted_' + w + '_sapling', key='contents')

    # Functional models for signs and fence gates
    add_plain_value('sign', 'wood', w, w + '_sign')
    add_plain_value('wall_sign', 'wood', w, w + '_wall_sign')
    add_plain_value('hanging_sign', 'wood', w, w + '_hanging_sign')
    add_plain_value('wall_hanging_sign', 'wood', w, w + '_wall_hanging_sign')
    blocks['sign']['timeline']['model_state']['wood=' + w] = 'wood=%s,variant=standing' % w
    blocks['wall_sign']['timeline']['model_state']['wood=' + w] = 'wood=%s,variant=wall' % w
    blocks['hanging_sign']['timeline']['model_state']['wood=%s,attached=false' % w] = 'wood=%s,variant=hanging' % w
    blocks['hanging_sign']['timeline']['model_state']['wood=%s,attached=true' % w] = 'wood=%s,variant=attached' % w
    blocks['wall_hanging_sign']['timeline']['model_state']['wood=' + w] = 'wood=%s,variant=wall' % w
    blocks['fence_gate']['timeline']['model_state']['variant=' + w] = 'variant=' + w
    special['sign']['states']['wood'].append(OrderedDict([('value', w), ('texture', 'entity/signs/' + w)]))
    special['hanging_sign']['states']['wood'].append(OrderedDict([('value', w), ('texture', 'entity/signs/hanging/' + w)]))
    special['fence_gate']['states']['variant'].append(OrderedDict([('value', w), ('texture', 'block/%s_planks' % w)]))
    d['model_textures'] += ['entity/signs/' + w, 'entity/signs/hanging/' + w]
    lang['model/state/value/'][w] = title(w)

add_variant('leaves', 'pale_oak', 'pale_oak_leaves')
for c in ['orange', 'red', 'yellow']:
    add_variant('leaves', c + '_poplar', c + '_poplar_leaves')

# Shelves
shelf_woods = ['oak', 'spruce', 'birch', 'jungle', 'acacia', 'dark_oak', 'mangrove', 'cherry', 'pale_oak', 'poplar', 'bamboo',
               'crimson', 'warped']
new_block('shelf', [(w, w + '_shelf') for w in shelf_woods], after='chiseled_bookshelf')

# --------------------------------------------------------------------------------------------------
# Wool and concrete slabs/stairs

for c in COLORS:
    for kind in ['wool', 'concrete']:
        add_variant('slab', c + '_' + kind, '%s_%s_slab' % (c, kind))
        add_variant('stairs', c + '_' + kind, '%s_%s_stairs' % (c, kind))

# --------------------------------------------------------------------------------------------------
# Stone families


def stone_family(name, block_values, shapes):
    """block_values: (value, mcid) for full blocks, shapes: (value, prefix) for slabs/stairs/walls."""
    if name in blocks:
        to_variant_group(name, block_values[0][0], block_values[1:])
    else:
        new_block(name, block_values)
    for value, prefix in shapes:
        add_variant('slab', value, prefix + '_slab')
        add_variant('stairs', value, prefix + '_stairs')
        add_variant('wall', value, prefix + '_wall')


stone_family('tuff', [('tuff', 'tuff'), ('polished_tuff', 'polished_tuff'), ('tuff_bricks', 'tuff_bricks'),
                      ('chiseled_tuff', 'chiseled_tuff'), ('chiseled_tuff_bricks', 'chiseled_tuff_bricks')],
             [('tuff', 'tuff'), ('polished_tuff', 'polished_tuff'), ('tuff_brick', 'tuff_brick')])
stone_family('resin_bricks', [('resin_bricks', 'resin_bricks'), ('chiseled_resin_bricks', 'chiseled_resin_bricks')],
             [('resin_brick', 'resin_brick')])
stone_family('cinnabar', [('cinnabar', 'cinnabar'), ('polished_cinnabar', 'polished_cinnabar'),
                          ('cinnabar_bricks', 'cinnabar_bricks'), ('chiseled_cinnabar', 'chiseled_cinnabar')],
             [('cinnabar', 'cinnabar'), ('polished_cinnabar', 'polished_cinnabar'), ('cinnabar_brick', 'cinnabar_brick')])
stone_family('sulfur', [('sulfur', 'sulfur'), ('polished_sulfur', 'polished_sulfur'), ('sulfur_bricks', 'sulfur_bricks'),
                        ('chiseled_sulfur', 'chiseled_sulfur')],
             [('sulfur', 'sulfur'), ('polished_sulfur', 'polished_sulfur'), ('sulfur_brick', 'sulfur_brick')])
new_block('resin_block', 'resin_block', after='resin_bricks')
new_block('resin_clump', 'resin_clump', after='resin_block')
new_block('potent_sulfur', 'potent_sulfur', after='sulfur')
new_block('sulfur_spike', 'sulfur_spike', after='potent_sulfur')

# --------------------------------------------------------------------------------------------------
# Copper


def copper_ids(fmt):
    """(value, mcid) for all oxidation and waxed versions, fmt has {o} for the oxidation prefix."""
    out = []
    for waxed in ['', 'waxed_']:
        for o in OXIDATION:
            mcid = waxed + fmt.format(o=o)
            out.append((mcid, mcid))
    return out


new_block('chiseled_copper', copper_ids('{o}chiseled_copper'), after='cut_copper')
new_block('copper_grate', copper_ids('{o}copper_grate'), after='chiseled_copper')
new_block('copper_bulb', copper_ids('{o}copper_bulb'), after='copper_grate')
blocks['copper_bulb']['states']['lit'] = [OrderedDict([('value', 'true'), ('emissive', 1)]), OrderedDict([('value', 'false')])]
new_block('copper_bars', copper_ids('{o}copper_bars'), after='iron_bars')
for value, mcid in copper_ids('{o}copper_door'):
    add_variant('door', value[:-5], mcid)
for value, mcid in copper_ids('{o}copper_trapdoor'):
    add_variant('trapdoor', value[:-9], mcid)
for value, mcid in copper_ids('{o}copper_lantern'):
    add_variant('lantern', value, mcid)
add_variant('torch', 'copper_torch', 'copper_torch')
add_variant('wall_torch', 'copper_torch', 'copper_wall_torch')

# Chains, the original block is now the iron chain
to_variant_group('chain', 'iron', [(v, m) for v, m in copper_ids('{o}copper_chain')])
blocks['chain']['states']['variant'][0]['file'] = 'iron_chain.json'
ids_dict(blocks['chain'])['minecraft:iron_chain'] = 'variant=iron'
handled.add('iron_chain')

# Lightning rods
to_variant_group('lightning_rod', 'lightning_rod',
                 [(v, m) for v, m in copper_ids('{o}lightning_rod') if m != 'lightning_rod'])

# Copper chests use the chest model with copper textures
chest_values = ['copper', 'exposed_copper', 'weathered_copper', 'oxidized_copper']
chest = copy.deepcopy(blocks['trapped_chest'])
chest['name'] = 'copper_chest'
chest['states'] = OrderedDict([('variant', chest_values)] + list(chest['states'].items()))
chest['default_state'] = 'variant=copper,' + chest['default_state']
chest['timeline']['model_state'] = OrderedDict()
idmap = OrderedDict()
for o, value in zip(OXIDATION, chest_values):
    tex = 'entity/chest/copper' + ('_' + o[:-1] if o else '')
    chest['timeline']['model_state']['variant=%s,double=false' % value] = 'variant=' + value
    chest['timeline']['model_state']['variant=%s,double=true' % value] = 'variant=%s_double' % value
    special['chest']['states']['variant'] += [
        OrderedDict([('value', value), ('file', 'chest.mimodel'), ('texture', tex)]),
        OrderedDict([('value', value + '_double'), ('file', 'chest_double.mimodel'),
                     ('shape_texture', OrderedDict([('left', tex + '_left'), ('right', tex + '_right')]))])]
    d['model_textures'] += [tex, tex + '_left', tex + '_right']
    for waxed in ['', 'waxed_']:
        idmap['minecraft:%s%scopper_chest' % (waxed, o)] = 'variant=' + value
        handled.add('%s%scopper_chest' % (waxed, o))
    lang['block/state/value/'][value] = title(value)
    lang['model/state/value/'][value] = title(value)
    lang['model/state/value/'][value + '_double'] = title(value) + ' (Double)'
chest['id'] = idmap
items = list(blocks.items())
pos = [k for k, _ in items].index('trapped_chest') + 1
items.insert(pos, ('copper_chest', chest))
blocks.clear()
blocks.update(items)
lang['block/']['copper_chest'] = 'Copper Chest'

# --------------------------------------------------------------------------------------------------
# Plants

for value, mcid in [('bush', 'bush'), ('firefly_bush', 'firefly_bush'), ('red_shrub', 'red_shrub')]:
    add_variant('grass', value, mcid, key='type')
for value, mcid in [('short_dry_grass', 'short_dry_grass'), ('tall_dry_grass', 'tall_dry_grass')]:
    add_variant('grass', value, mcid, key='type', extra={'random_offset': True})
for value in ['golden_dandelion', 'open_eyeblossom', 'closed_eyeblossom', 'cactus_flower']:
    add_variant('flower', value, value, key='type')
for value in ['golden_dandelion', 'open_eyeblossom', 'closed_eyeblossom']:
    add_variant('flower_pot', value, 'potted_' + value, key='contents')
new_block('wildflowers', 'wildflowers', after='pink_petals', extra={'subsurface': 1})
new_block('leaf_litter', 'leaf_litter', after='wildflowers')
new_block('pale_moss_block', 'pale_moss_block', after='moss_carpet')
new_block('pale_moss_carpet', 'pale_moss_carpet', after='pale_moss_block')
new_block('pale_hanging_moss', 'pale_hanging_moss', after='pale_moss_carpet', extra={'subsurface': 1})
new_block('shelf_mushroom', 'shelf_mushroom', after='brown_mushroom')
new_block('creaking_heart', 'creaking_heart', after='pale_hanging_moss')
blocks['creaking_heart']['states']['creaking_heart_state'] = [
    'uprooted', 'dormant', OrderedDict([('value', 'awake'), ('emissive', 0.5)])]

# --------------------------------------------------------------------------------------------------
# Other blocks

new_block('crafter', 'crafter', after='crafting_table')
new_block('trial_spawner', 'trial_spawner', after='spawner')
new_block('vault', 'vault', after='trial_spawner')
new_block('heavy_core', 'heavy_core', after='vault')
new_block('dried_ghast', 'dried_ghast', after='heavy_core')
new_block('straw_bed', 'straw_bed', after='bed')

# Not rendered as blocks
for mcid in ['air', 'cave_air', 'void_air', 'structure_void', 'moving_piston', 'piston_head', 'end_portal', 'end_gateway',
             'test_block', 'test_instance_block', 'item_frame', 'glow_item_frame', 'copper_golem_statue',
             'exposed_copper_golem_statue', 'weathered_copper_golem_statue', 'oxidized_copper_golem_statue',
             'waxed_copper_golem_statue', 'waxed_exposed_copper_golem_statue', 'waxed_weathered_copper_golem_statue',
             'waxed_oxidized_copper_golem_statue']:
    handled.add(mcid)

# Signs and beds are block models since 26.x, use them when no timelines are created for the scenery
for group, key, fmt in [('sign', 'wood', '%s_sign'), ('wall_sign', 'wood', '%s_wall_sign'), ('hanging_sign', 'wood', '%s_hanging_sign'),
                        ('wall_hanging_sign', 'wood', '%s_wall_hanging_sign'), ('bed', 'color', '%s_bed')]:
    values = blocks[group]['states'][key]
    for i, v in enumerate(values):
        entry = v if isinstance(v, dict) else OrderedDict([('value', v)])
        if exists(fmt % entry['value']):
            entry['file'] = fmt % entry['value'] + '.json'
        else:
            warnings.append('No block model for %s %s' % (group, entry['value']))
        values[i] = entry

d['blocks'] = list(blocks.values())

# --------------------------------------------------------------------------------------------------
# Coverage

mapped = set()
for b in d['blocks']:
    i = b.get('id', {})
    for k in ([i] if isinstance(i, str) else i):
        mapped.add(k.replace('minecraft:', ''))
unmapped = [f[:-5] for f in sorted(os.listdir(A + '/blockstates')) if f[:-5] not in mapped and f[:-5] not in handled]
if unmapped:
    warnings.append('Unmapped: ' + ' '.join(unmapped))

# --------------------------------------------------------------------------------------------------
# Textures used by the block models


def is_animated(tex):
    meta = A + '/textures/' + tex + '.png.mcmeta'
    return os.path.exists(meta) and 'animation' in json.load(open(meta))


used = []
seen = set()
for b in d['blocks']:
    files = []
    if 'file' in b:
        files.append(b['file'])
    for values in b.get('states', {}).values():
        for v in values:
            if isinstance(v, dict) and v.get('file', '').endswith('.json'):
                files.append(v['file'])
    for f in files:
        if not exists(f[:-5]):
            warnings.append('Missing blockstate ' + f)
            continue
        for mn in block_models(f[:-5]):
            m = load_model(mn)
            for e in (m['elements'] or []):
                for face in e.get('faces', {}).values():
                    t = resolve_tex(m, face['texture'])
                    if t and t not in seen:
                        seen.add(t)
                        used.append(t)

static = list(d['block_textures'])
animated = list(d['block_textures_animated'])
known = set(t.split(' ')[0] for t in static + animated)
added_static, added_animated = [], []
for t in used:
    if t in known:
        continue
    if not os.path.exists(A + '/textures/' + t + '.png'):
        warnings.append('Missing texture ' + t)
        continue
    (added_animated if is_animated(t) else added_static).append(t)
    known.add(t)
for leaves in ['pale_oak', 'orange_poplar', 'red_poplar', 'yellow_poplar']:
    added_static.append('block/%s_leaves opaque' % leaves)
d['block_textures'] = static + added_static
d['block_textures_animated'] = animated + added_animated

# Tints
col = d['block_textures_color']
col['block/short_grass'] = 'grass'
col['block/bush'] = 'grass'
col['block/wildflowers_stem'] = 'grass'
try:
    from PIL import Image
    im = Image.open(A + '/textures/colormap/dry_foliage.png').convert('RGB')
    r, g, b = im.getpixel((51, 173))  # Plains: temperature 0.8, downfall 0.4
    col['block/leaf_litter'] = '#%02X%02X%02X' % (r, g, b)
except Exception as e:
    warnings.append('Dry foliage color: %s' % e)

# Items
old_items = set(d['item_textures'])
for f in sorted(os.listdir(A + '/textures/item')):
    if f.endswith('.png'):
        t = 'item/' + f[:-4]
        if t not in old_items and not is_animated(t):
            d['item_textures'].append(t)

# Biomes
biomes = OrderedDict((b['name'], b) for b in d['biomes'])
biomes['dark_forest'].setdefault('variant', []).append(
    OrderedDict([('name', 'pale_garden'), ('grass', '#778272'), ('foliage', '#878D76'), ('water', '#76889D')]))
biomes['forest'].setdefault('variant', []).append(
    OrderedDict([('name', 'dappled_forest'), ('grass', '#DF6827'), ('foliage', '#E68E30'), ('water', '#375154')]))
biomes['caves'].setdefault('variant', []).append(
    OrderedDict([('name', 'sulfur_caves'), ('grass', '#ABA64F'), ('water', '#34BF89')]))

# Banner patterns added in 1.21 (no short codes exist since 1.20.5, these are only used internally)
for name, short in [('flow', 'flw'), ('guster', 'gus')]:
    if not any(p[0] == name for p in d['patterns']):
        d['patterns'].append([name, short])
        lang['patterneditor/patterns/'][name] = title(name)

d['version'] = '26.3'
d['patch'] = 0

with open(OUT, 'w') as f:
    json.dump(d, f, indent='\t', ensure_ascii=False)
    f.write('\n')
json.dump(lang, open(LANG_OUT, 'w'), indent='\t')

print('blocks', len(d['blocks']), 'static textures', len(d['block_textures']), '(+%d)' % len(added_static),
      'animated', len(d['block_textures_animated']), '(+%d)' % len(added_animated), 'items', len(d['item_textures']))
print('added animated', added_animated)
for w in warnings:
    print('WARNING', w)
