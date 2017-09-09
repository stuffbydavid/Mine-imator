/// file_dialog_open_asset()

var formats = "*miobj; *.zip; *.schematic; *.miproj; *.mipart;";
formats += "*.mp3; *.wav; *.ogg; *.flac; *.wma; *.m4a;"
formats += "*.png; *.jpg;"
formats += "*.object; *.keyframes; *.particles; *.mproj; *.mani; *.blocks";

return file_dialog_open(text_get("filedialogopenasset") + " (" + formats + ")|" + formats, "", "", text_get("filedialogopenassetcaption"))
