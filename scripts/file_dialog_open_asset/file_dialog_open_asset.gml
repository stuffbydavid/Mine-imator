/// file_dialog_open_asset()

var formats = "*miobject; *.miframes; *.zip; *.schematic; *.miproject; *.miparticles;";
formats += "*.png; *.jpg;"
formats += "*.mp3; *.wav; *.ogg; *.flac; *.wma; *.m4a;"
formats += "*.object; *.keyframes; *.particles; *.mproj; *.mani; *.blocks";

return file_dialog_open(text_get("filedialogopenasset") + " (" + formats + ")|" + formats, "", "", text_get("filedialogopenassetcaption"))
