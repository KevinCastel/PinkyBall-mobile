extends Node2D

var dict_atlas_coord_for_bricks = {
	"blue_plane" : Vector2i(1,0),
	"green_plane" : Vector2i(2,0),
	"yellow_plane" : Vector2i(3,0),
	"pink_plane" : Vector2i(4,0),
	"blue_coffee" : Vector2i(6,0),
	"green_coffee" : Vector2i(7,0),
	"yellow_coffee" : Vector2i(0,1),
	"pink_coffee" : Vector2i(1,1),
	"blue_slow_ball" : Vector2i(3,1),
	"green_slow_ball" : Vector2i(4,1),
	"yellow_slow_ball" : Vector2i(5,1),
	"pink_slow_ball" : Vector2i(6,1),
	"blue_deadhead" : Vector2i(0,2),
	"green_deadhead" : Vector2i(1,2),
	"yellow_deadhead" : Vector2i(2,2),
	"pink_deadhead" : Vector2i(3,2),
	"blue_bomb" : Vector2i(5,2),
	"green_bomb" : Vector2i(6,2),
	"yellow_bomb" : Vector2i(7,2),
	"pink_bomb" : Vector2i(0,3),
	"blue_alcohol" : Vector2i(2,3),
	"green_alcohol" : Vector2i(3,3),
	"yellow_alcohol" : Vector2i(4,3),
	"pink_alcohol" : Vector2i(5,3),
	"blue_ball" : Vector2i(7,3),
	"green_ball" : Vector2i(0,4),
	"yellow_ball" : Vector2i(1,4),
	"pink_ball" : Vector2i(2,4),
	"blue_rocket" : Vector2i(3,4),
	"green_rocket" : Vector2i(5,4),
	"yellow_rocket" : Vector2i(6,4),
	"pink_rocket" : Vector2i(7,4),
	"blue_bullet" : Vector2i(1,5),
	"yellow_bullet" : Vector2i(2,5), 
	"green_bullet" : Vector2i(3,5),
	"pink_bullet" : Vector2i(4,5),
	"blue_heart" : Vector2i(6,5),
	"green_heart" : Vector2i(7,5),
	"yellow_heart" : Vector2i(0,6),
	"pink_heart" : Vector2i(1,6),
	"blue" : Vector2i(3,6),
	"pink" : Vector2i(4,6),
	"yellow" : Vector2i(5,6), 
	"green" : Vector2(6,6),
	"pink_rc" : Vector2i(1,7),
	"yellow_rc" : Vector2i(2,7),
	"blue_rc" : Vector2i(3,7),
	"green_rc" : Vector2i(4,7)
}


@onready var _tile_map = self.get_node("TileMapWall")
@onready  var _cam = self.get_node("Camera2D")


func _ready():
	self.set_camera_limits()


func _process(delta):
	self.check_input()


func check_input():
	if Input.is_action_pressed("lvl_editor_left"):
		self._cam.global_position.x -= 12
	elif Input.is_action_pressed("lvl_editor_right"):
		self._cam.global_position.x += 32

func set_camera_limits():
	var cam = self.get_node("Camera2D")
	#var used_rect : Vector2 = to_global(self._tile_map.get_used_rect())
	
	
	cam.limit_left = self._tile_map.global_position.x
	print("used_rect:", used_rect)


func _input(InputEvent):
	if Input.is_action_just_pressed("left_click"):
		var mouse_global_pos_2D_world = get_viewport().get_mouse_position()
		var tilemap_click_global_pos_2D_world = self.get_node("TileMapBricks").local_to_map(mouse_global_pos_2D_world)
	
