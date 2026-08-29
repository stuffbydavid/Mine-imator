Prompt:

*Find optimizations for minecraft_assets_load() which runs during startup and takes exceedingly long in Debug mode, either by employing new C++ datastructures (such as hash tables for string<->id mapping) or other redundancies. List the highest prio fixes.*

# `minecraft_assets_load()` startup performance

## Scope

This report covers the standalone C++/GameMaker startup path around `minecraft_assets_load()` and its blockstate, block-model, texture-atlas, and developer-validation helpers. It focuses on the unusually long unoptimized Debug build startup.

This was a read-only investigation: the application was not run and no implementation changes were made. Measurements below are static counts derived from the bundled `26.3-snapshot-9.midata` and `26.3-snapshot-9.zip` assets. Existing logs were used only to identify phase boundaries.

## Summary

The highest-priority fixes are:

1. Replace per-face texture list scans with a precomputed string-to-texture-info hash table.
2. Stop prepending every new object ID to the global per-type object registry.
3. Restrict variant-specific blockstate files to state IDs matching their fixed state values.
4. Eliminate recursively generated JSON type-map trees.
5. Cache resolved model inheritance and repeated render-model construction.
6. Explicitly use the typed integer and string hash maps already implemented in the C++ runtime.
7. Make expensive developer audits opt-in or implement them using hash sets.

The bundled assets currently produce:

- 311 logical block definitions.
- 29,088 expanded state slots.
- 1,141 blockstate-file load calls covering 1,140 unique files.
- 2,540 parsed block-model files, including parents.
- 9,441 block render-model objects.
- 20,802 block render-element objects.
- 97,158 rendered faces requiring texture resolution.

An existing full-load log finishes block/item/particle texture work at approximately `00:38:58` and reports `Loaded assets successfully` at `00:39:20`. This isolates a roughly 22-second gap in the block/model portion of startup rather than texture-atlas construction.

## P0: Replace face texture list scans

The hottest statically identifiable lookup is in `GmProject/scripts/block_load_render_model/block_load_render_model.gml`, around lines 397-424.

For each rendered face, the loader searches combinations such as:

- `name + " opaque"`
- `name + " noalpha"`
- `name + " nocull"`
- `name`
- Animated equivalents when the static lookup fails

The static texture list contains 1,238 names and the animated list contains 54. An ordinary untagged static texture commonly causes two full failed 1,238-entry scans for `noalpha` and `nocull` before the base-name search succeeds.

For the bundled pack, the current code performs approximately:

- 97,158 face texture resolutions.
- 292,737 `ds_list_find_index()` calls.
- 290,214,474 string-ID comparisons.
- 2,987 scanned entries per rendered face on average.

### Proposed fix

Build the lookup once after the texture lists and sheet-depth lists are finalized. Prefer two pre-resolved tables:

- Normal rendering: base texture name -> texture information.
- Forced-opaque leaf rendering: base texture name -> texture information.

A resolved entry should contain:

- Static or animated sheet.
- Slot index.
- Depth classification.
- `e_block_vbuffer` classification.
- Fixed color or biome-tint classification.

The lowest-risk GML-facing implementation is two `ds_string_map_create()` maps with packed integer values. The best C++ implementation is a native `QHash<StringType, BlockTextureInfo>` exposed through a narrow lookup function. Because `StringType` is interned and hashes by ID, this should be inexpensive even in Debug.

This changes approximately 290 million comparisons into about 97,000 hash lookups. Preserve the existing tag-priority behavior during the conversion. Also verify the repeated static `" noalpha"` search in the animated fallback; it appears redundant and may have intended to search the animated list.

## P0: Remove quadratic object-registry prepending

`CppProject/Asset/Object.cpp` currently registers every object with:

```cpp
objectIdsMap[subAssetId].insert(0, id);
```

Prepending to `QVector` shifts all existing IDs and is O(n) per construction. The loader creates large numbers of data-only GameMaker objects of the same types.

For major loader types alone:

| Type/count | IDs shifted by repeated prepend | Approximate bytes moved |
|---|---:|---:|
| 20,802 render elements | 216,351,201 | 1.73 GB |
| 9,441 render models | 44,561,520 | 356 MB |
| 8,033 block variants | 32,260,528 | 258 MB |
| 1,161 multipart cases | 673,380 | 5.4 MB |
| 1,141 state-file objects | 650,370 | 5.2 MB |

These known types alone shift about 294 million 64-bit IDs, or approximately 2.35 GB of memory. Other startup object types increase the actual total. This is particularly harmful under an unoptimized Debug build.

### Proposed fix

Use `append(id)` for amortized O(1) registration. If newest-first GameMaker iteration order must be preserved, update `Scope` iteration to walk the vector backward.

A better longer-term option is a generator/runtime annotation for data-only objects such as block render elements and temporary loader objects. Those objects are addressed directly and do not need to participate in global `with (obj_type)` enumeration, so they could skip `objectIdsMap` registration entirely.

Object destruction uses `removeOne(id)`, which is also linear. Append plus reverse iteration fixes construction, while an indexed/tombstoned registry or data-only opt-out can address destruction later.

## P0: Restrict multipart state expansion

`block_load_state_file(fname, block, state)` receives fixed state variables for files selected by a logical block variant, for example `variant=cobblestone`. Multipart handling nevertheless loops over and populates `state_id_map` for every state ID belonging to the logical block.

This is especially expensive for generic block families:

| Logical block | Expanded states | State files | Current multipart updates | Updates after fixed-state restriction |
|---|---:|---:|---:|---:|
| Wall | 5,184 | 32 | 525,312 | 16,416 |
| Stained glass pane | 256 | 16 | 20,480 | 1,280 |
| Shelf | 416 | 13 | 10,816 | 832 |
| Fence | 224 | 14 | 9,408 | 672 |
| Bars | 144 | 9 | 4,293 | 477 |

Across the pack, multipart processing performs approximately 583,067 map/array updates. Restricting each file to state IDs matching its supplied fixed state reduces this to approximately 32,190 updates, a 94.5% reduction.

The current multipart matching also performs approximately 1,728,445 full state-ID predicate passes, of which walls account for about 1,492,992.

### Proposed fix

1. Convert the fixed `state` pairs passed to `block_load_state_file()` into their value IDs and strides.
2. Enumerate only matching state IDs rather than scanning all IDs with `state_vars_match_state_id()`.
3. Populate unconditional multipart cases only for that subset.
4. Use an integer-keyed sparse table for the result.

The current expression pattern is effectively:

```gml
state_id_map[?i] = array_add(state_id_map[?i], id)
```

Add a small C++-separate helper that mutates an array stored at a map key in place, or introduce a dedicated `StateVariantTable` backed by `QHash<IntType, QVector<IntType>>`. This avoids return-value array copies and repeated generic `VarType` conversions.

## P1: Remove recursive JSON type maps

The C++ JSON loader in `CppProject/Gml/FileFunc.cpp` already converts every JSON object to a `StringHashMap`. When the caller supplies a type-map ID, it additionally creates another `StringHashMap` for every JSON object and records every field's type.

The startup path currently creates approximately:

- 3,746 duplicate object type maps for the master `.midata` file.
- 14,717 duplicate object type maps for loaded blockstate files.
- 11,562 duplicate object type maps for loaded model files.
- 30,025 duplicate string type-map objects in total.
- 3,685 root integer type maps.

These maps add allocations, hash insertions, asset registration, and recursive destruction. The callers only use them for a few checks that can be made directly:

- Array: `ds_list_valid(value)`.
- Object: `ds_map_valid(value)`.
- Boolean: `is_bool(value)`.
- String: `is_string(value)`.

### Affected call sites

- `minecraft_assets_load_startup_version()` creates `load_assets_type_map` for the full `.midata` tree.
- `block_load_state_file()` creates `jsontypemap` per blockstate file.
- `block_load_model_file()` creates `typemap` per block model.
- `block_load_timeline()` uses the master type map to distinguish strings, arrays, and objects.

Remove the optional type-map argument in these paths and replace each lookup with the appropriate runtime type/DS validity check. This is a relatively low-risk change with broad allocation savings.

## P1: Cache resolved block-model inheritance

Each call to `block_load_render_model()` currently:

1. Creates a temporary texture map.
2. Walks the block model's parent chain.
3. Merges each local texture map.
4. Locates the first ancestor containing elements.
5. Destroys the temporary map after constructing the render model.

This work is repeated for 9,441 render models although only 2,540 model files, including parents, are parsed.

### Proposed fix

After a model's parent is loaded, calculate and retain:

- `resolved_texture_map`.
- `resolved_element_model`.
- Optionally, each face's resolved final texture name.

Then `block_load_render_model()` can read those values directly. Ensure child texture definitions retain precedence over parent definitions.

A second cache for complete render-model construction can key on:

- Model file.
- X/Y/Z rotation.
- UV-lock flag.
- Opaque-leaf flag.
- Weight.
- State-file/preview override identity.

Including the state file and weight in the key still leaves approximately 1,795 duplicate constructions in the current pack, around 19% of all render models. It may be safer initially to cache only immutable geometry and resolved texture information while keeping preview and weight data per variant.

## P1: Explicitly use typed maps

The runtime already supplies:

- `ds_string_map_create()` -> `StringHashMap` -> `QHash<StringType, MapValue>`.
- `ds_int_map_create()` -> `IntHashMap` -> `QHash<IntType, MapValue>`.

Generated C++ still shows generic `ds_map_create()` for several hot structures because type inference does not identify their key type reliably.

Use string maps for:

- `load_assets_model_file_map`.
- Model local and resolved texture maps.
- Block `states_map`.
- State `value_map`.
- Other filename/name lookup tables.

Use integer maps for:

- `state_id_map`.
- Other state-ID-indexed sparse maps.

Generic maps are backed by `QMap<VarType, MapValue>`, adding tree traversal and generic comparison overhead. Typed maps avoid that and also make intent explicit. Review any code depending on sorted iteration before converting a map, although these hot lookup tables generally do not require ordering.

## P1 quick win: Make Debug audits opt-in

`debug_startup()` currently enables both `dev_mode_debug_names` and `dev_mode_debug_unused` by default in Debug builds.

Unused texture detection builds a list of all files and repeatedly invokes `ds_list_delete_value()`, which itself performs a linear `ds_list_find_index()` followed by vector deletion and shifting. Similar checks enumerate all blockstate and block-model files after loading.

The existing staged `!dev_mode_skip_blocks` guards prevent these audits during shortened benchmark startup, but do not improve a normal full Debug load.

Recommended approaches:

- Default these validations to false and enable them explicitly with the existing command-line flags when maintaining asset packages.
- Or use a `ds_string_map_create()`/native string hash set of discovered paths and delete used paths in O(1).
- Run translation validation as an asset-maintenance test rather than on every application startup.

Logging amplifies error-heavy cases because `Printer::Line()` opens and closes the log file for every message and flushes stdout through `std::endl` in Debug. Clean packs generate few messages, so logging is not a primary normal-case bottleneck, but buffering it would prevent missing-asset floods from dominating startup.

## P2: Preprocessed asset cache

After the in-memory algorithmic fixes, add a versioned preprocessed cache for repeated startups. The loader currently opens and converts more than 3,600 JSON files even though the bundled asset version is immutable between application updates.

A cache can contain:

- Parsed model-parent relationships.
- Resolved texture bindings.
- Element geometry templates.
- State-condition tables.
- Render-model construction descriptors.

Key the cache by Minecraft asset version, patch number, cache format, and a content fingerprint. Prefer an explicit portable binary schema rather than serializing raw C++ object memory. Invalid or missing caches must fall back to the normal JSON path.

This has high potential for subsequent startups but should follow the P0 changes. Otherwise the cache load will still instantiate thousands of objects through the quadratic registry and rebuild redundant state tables.

## Lower-priority cleanup

- Avoid repeated `file_exists_lib()` checks for the same texture path; several loops test the normal path before legacy fallback and then test it again.
- Share immutable default material and normal textures rather than duplicating them for almost every model texture, if later code never mutates those textures.
- Free temporary preview surfaces after `buffer_get_surface()` where ownership permits; the relevant `surface_free()` calls are currently commented out.
- Cache `asset_get_index("block_set_" + type)` and `asset_get_index("block_generate_" + type)` by the small set of block types. This is minor compared with the P0 work.
- Do not attempt broad parallel block construction first. The current path mutates global object registries, string tables, maps, and object arrays. Parallel JSON-to-native-POD parsing may become useful after separating parsing from object construction.

## Recommended implementation order

1. Add precomputed texture lookup tables and remove all face-level texture-list scans.
2. Change object registration from prepend to append and preserve iteration order by iterating backward.
3. Restrict variant-specific multipart state tables and add an in-place/native state-table append operation.
4. Remove master, blockstate, and model JSON type maps.
5. Cache resolved model inheritance.
6. Convert remaining hot maps to explicit string/int hash maps.
7. Make developer audits opt-in or hash-set based.
8. Add a versioned preprocessed asset cache if startup is still too slow.

## Verification plan

Instrument these phases independently before and after each change:

- Master `.midata` parse.
- Texture packing.
- Character/special-model loading.
- Block definition parsing.
- Blockstate JSON parsing.
- Block-model JSON parsing.
- Multipart state-table construction.
- Render-model/render-element construction.
- Developer audits.
- Temporary loader-object destruction.

Record counters alongside timings:

- JSON files and JSON/type maps created.
- Render models, elements, and faces created.
- Texture lookup calls and candidates checked.
- Multipart predicate evaluations and state-map appends.
- Object-registry insertions and removals.

Benchmark a full 311-block startup with `dev_mode_skip_blocks=false`. Run one baseline with validation audits disabled to measure the loader itself, and a second validation-enabled run to measure audit overhead separately. Compare Debug builds first; Release results are useful for regression checks but will hide the pathologies that motivated this work.
