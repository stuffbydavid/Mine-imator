# Minecraft assets tools

Scripts used to generate `GmProject/datafiles/Data/Minecraft/26.3.midata` and `26.3.zip` from the
1.20.2 data and the vanilla Minecraft 26.3 assets. They require Python 3 with Pillow and NumPy.

1. Get the vanilla assets and block summary of the target version, for example from the
   [misode/mcmeta](https://github.com/misode/mcmeta) mirror:
   - `git clone --depth 1 --branch 26.3-assets https://github.com/misode/mcmeta.git assets-26.3`
   - `https://raw.githubusercontent.com/misode/mcmeta/26.3-summary/blocks/data.min.json`
2. Generate the block data and the translations of new blocks:
   `MC_ASSETS=assets-26.3/assets/minecraft python3 gen_midata.py 1.20.2.midata data.min.json 26.3.midata lang.json`
3. Merge the translations: `python3 merge_lang.py ../../GmProject/datafiles/Data/Languages/english.milanguage lang.json`
4. Build the archive: `python3 build_zip.py 1.20.2.zip assets-26.3 26.3.zip`

`gen_midata.py` maps new Minecraft blocks to Mine-imator blocks (new variants of existing blocks, or new
blocks), adds the textures used by their models to the block sheet lists, and prints a warning for
blocks that are not mapped. `build_zip.py` takes vanilla files from the new version, keeps Mine-imator's
own models and textures, keeps old entity textures whose layout changed (character models are made for
them), and generates sign textures in the entity layout for new wood types.
