extends Node2D

"""
This script serve as gameplay script
"""

enum GAMEPLAY_MODES {PLATFORM, CHARACTER, PLANE}
var GAMEPLAY_MODE

enum PLATFORMS_ID {PLATFORM1, PLATFORM2, PLATFORM3}
var PLATFORM_ID

@onready var dict_platforms = {
	"platofrm1" : preload("res://datas/scene/platform/Platform1.tscn")
}

@onready var _tile_map_bricks = self.get_node("TileMapBricks")


func _ready():
	var player_spawn_global_pos = get_global_position_2D_world_spawn_player()
	
	self.load_map()
	
	self.set_player_platform("platform1")
	self.set_gameplay_mode("platform")
	self.spawn_player(player_spawn_global_pos)


func set_gameplay_mode(gameplay_mode):
	match gameplay_mode:
		"platform":
			GAMEPLAY_MODE = PLATFORMS_ID.PLATFORM1


func get_global_position_2D_world_spawn_player():
	"""
		Set the player global position to the 2D map
	"""
	var used_rect = self._tile_map_bricks.get_used_rect()
	var spawn_position = to_global(used_rect.size)
	spawn_position.y = 560
	spawn_position.x += to_global(self._tile_map_bricks.global_position).x / 1.701
	
	return spawn_position


func set_player_platform(platform_id):
	"""
		Set the player platform for getting proper platform while runnning
		this script
	"""
	match platform_id:
		"platform1":
			PLATFORM_ID = PLATFORMS_ID.PLATFORM1
		

func spawn_player(global_position_world_2D:Vector2):
	"""
		Calls for spawning player,
		
		TAKE ARGS AS:
			player_type (string) is the type of the player it could be:
				platform, character, plane
			
			global_position_world_2D (Vector2)
	"""
	var player_object
	match GAMEPLAY_MODE:
		GAMEPLAY_MODES.PLATFORM:
			match PLATFORM_ID:
				PLATFORMS_ID.PLATFORM1:
					player_object = dict_platforms["platofrm1"].instantiate()
	
	if player_object:
		self.add_child(player_object)
		player_object.spawn(global_position_world_2D)


func load_map():
	for cell in self._tile_map_bricks.get_used_cells(0):
		var tile_data = self._tile_map_bricks.get_cell_tile_data(0, cell)
		if tile_data:
			var brick_name = tile_data.get_custom_data("type")
			if brick_name:
				print("brick_name:", brick_name)
