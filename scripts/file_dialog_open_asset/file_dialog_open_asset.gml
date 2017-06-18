/// file_dialog_open_asset()

var formats = "*.object; *.keyframes; *.particles; *.mproj; *.mani; *.schematic; *.blocks; *.mp3; *.wav; *.ogg; *.flac; *.wma; *.m4a; *.png; *.jpg; *.zip";
return file_dialog_open(text_get("filedialogopenasset") + " (" + formats + ")|" + formats, "", "", text_get("filedialogopenassetcaption"))
