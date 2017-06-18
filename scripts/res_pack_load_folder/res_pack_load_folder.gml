/// res_pack_load_folder(dir)
/// Loads a previously imported resource pack from a folder of images.

var dir=argument0+"\\";

log("Opening pack from folder",dir)

log("colormap_grass_texture")
colormap_grass_texture=texture_create(dir+"color_grass.png")

log("colormap_foliage_texture")
colormap_foliage_texture=texture_create(dir+"color_foliage.png")

log("item_texture")
item_texture=texture_create(dir+"items.png")

log("particles_texture")
particles_texture[0]=texture_create(dir+"particles_sheet1.png")
particles_texture[1]=texture_create(dir+"particles_sheet2.png")

log("block_preview_texture")
block_preview_texture=texture_create(dir+"pack.png")

log("sun_texture")
sun_texture=texture_create(dir+"sun.png")

log("moonphases_texture")
moonphases_texture=texture_create(dir+"moonphases.png")

log("moon_texture")
moon_texture=texture_split(moonphases_texture,4,2)

log("clouds_texture")
clouds_texture=texture_create(dir+"clouds.png")

log("Pack opened")
