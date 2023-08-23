extends Node

func export_map(tilemap_object:TileMap, map_name:String):
	"""
		Export map to file for being reloaded as level map for gameplay
		and eventuely level editor
		
		For exporting file, it's gonna be in json
		
		This is all informations for an brick cell
		that should be store:
			how much after impact break?
			where is it located in the atlas
		
	"""
	var i_brick = 0
	var str = "{\n\t\""+map_name+"\":{"
	for cell in tilemap_object.get_used_cells(0):
		var atlas = tilemap_object.get_cell_atlas_coords(0, cell)
		var data = "\n\t\t\"brick"+str(i_brick)+"\":{"+\
			"\n\t\t\t\"atlas\":{\n\t\t\t\t\"x\":"+str(atlas.x)+\
			",\n\t\t\t\t\"y\":"+str(atlas.y)+"\n\t\t\t\t},"+\
			"\n\t\t\t\t\"breakable_count\":1"
		
		data += "\n\t\t},"
		i_brick += 1
		
		str += "\n"+data
	
	str += "\n\t}\n}"
	
	var t = FileAccess.open("res://map_test.json", FileAccess.WRITE)
	t.store_string(str)
	t.close()
