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
	"blue_slowerball" : Vector2i(3,1),
	"green_slowerball" : Vector2i(4,1),
	"yellow_slowerball" : Vector2i(5,1),
	"pink_slowerball" : Vector2i(6,1),
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
	"green_rc" : Vector2i(4,7),
	"black" : Vector2i(7,6)
}

var _atlas_brick : Vector2i = Vector2i(0,0)

@onready var _tile_map = self.get_node("TileMapWall")
@onready var _tilemap_brick = self.get_node("TileMapBricks")
@onready  var _cam = self.get_node("Camera2D")

signal ZoomKeyBoardShortCut


var _speed_horizontal = 0.00
var _speed_vertical = 0.00

const ACCEL = 0.20
const MAXIMUM_CAMERA_SPEED = 12
const DECCELERATION = 0.15


var _zoom_speed = 0.00

const ZOOM_ACCEL = 0.005
const CAM_MAXIMUM_SPEED_ZOOM = 0.30
const CAM_ZOOM_DECCEL = 0.15
const CAM_MINIMUM_ZOOM = 1
const CAM_MAXIMUM_ZOOM = 2


@onready var _lvlEditor = self.find_parent("LevelEditorUi")


func _ready():
	self.set_camera_limits()


func _process(delta):
	if not self._lvlEditor.get_textedit_focus():
		self.check_input()
	
	if self._speed_horizontal > 0:
		if self._cam.zoom.x > 0:
			self._speed_horizontal -= self._cam.zoom.x/100
	
	if self._speed_vertical > 0:
		if self._cam.zoom.y > 0:
			self._speed_vertical -= self._cam.zoom.y/100
		
	self._cam.global_position.x += self._speed_horizontal
	self._cam.global_position.y += self._speed_vertical
	


func check_input():
	if Input.is_action_pressed("lvl_editor_left"):
		self._speed_horizontal = max(self._speed_horizontal-self.ACCEL, -self.MAXIMUM_CAMERA_SPEED)
	elif Input.is_action_pressed("lvl_editor_right"):
		self._speed_horizontal = min(self._speed_horizontal+self.ACCEL, self.MAXIMUM_CAMERA_SPEED)
	else:
		self._speed_horizontal = lerpf(self._speed_horizontal, 0, self.DECCELERATION)
	
	if Input.is_action_pressed("lvl_editor_up"):
		self._speed_vertical = max(self._speed_vertical-self.ACCEL, -self.MAXIMUM_CAMERA_SPEED)
	elif Input.is_action_pressed("lvl_editor_down"):
		self._speed_vertical = min(self._speed_vertical+self.ACCEL, self.MAXIMUM_CAMERA_SPEED)
	else:
		self._speed_vertical = lerpf(self._speed_vertical, 0, self.DECCELERATION)
	
	var zoom = self._cam.zoom.x
	if Input.is_action_pressed("zoom_in"):
		self._zoom_speed = max(self._zoom_speed-self.ZOOM_ACCEL, -self.CAM_MAXIMUM_SPEED_ZOOM)
	elif Input.is_action_pressed("zoom_out"):
		self._zoom_speed = min(self._zoom_speed+self.ZOOM_ACCEL, self.CAM_MAXIMUM_SPEED_ZOOM)
	else:
		self._zoom_speed = lerpf(self._zoom_speed, 0, self.CAM_ZOOM_DECCEL)
	
	if self._cam.zoom.x != self._cam.zoom.y:
		self._cam.zoom.y = self._cam.zoom.x
	
	zoom += self._zoom_speed
	
	if zoom > self.CAM_MAXIMUM_ZOOM:
		zoom = self.CAM_MAXIMUM_ZOOM
	elif zoom < self.CAM_MINIMUM_ZOOM:
		zoom = self.CAM_MINIMUM_ZOOM
	
	if zoom != self._cam.zoom.x:
		self._cam.zoom.x = zoom
	
	if zoom != self._cam.zoom.y:
		self._cam.zoom.y = zoom
		emit_signal("ZoomKeyBoardShortCut", self._zoom_speed)


func set_camera_limits():

	var zone = self._tile_map.get_used_rect()
	var cells_size = self._tile_map.tile_set.tile_size
	
	self._cam.limit_top = zone.position.y * cells_size.y
	self._cam.limit_left = zone.position.x * cells_size.x
	
	self._cam.limit_right = (zone.position.x+zone.size.x) * cells_size.x
	
	self._cam.limit_bottom = (zone.position.y + zone.size.y) * cells_size.y


func is_click_on_tilemap_brick(mouse_global_position_2D_WORLD):
	var zone = self._tilemap_brick.get_used_rect()
	var cells_size = self._tilemap_brick.tile_set.tile_size
	
	var is_horizontal_ok = (mouse_global_position_2D_WORLD.x >  zone.position.x*cells_size.x && mouse_global_position_2D_WORLD.x < (zone.position.x+zone.size.x)*cells_size.x)
	var is_verticaly_ok = (mouse_global_position_2D_WORLD.y > zone.position.y*cells_size.y && mouse_global_position_2D_WORLD.y < (zone.size.y+zone.position.y)*cells_size.y)
	
	return (is_horizontal_ok && is_verticaly_ok)


func _input(InputEvent):
	var mouse_global_pos_2D_world = self.get_local_mouse_position()+Vector2(0,32)
	
	var ground_layer = 0
	
	if Input.is_action_just_pressed("left_click") && self.is_click_on_tilemap_brick(mouse_global_pos_2D_world):
		var tilemap_click_global_pos_2D_world = self._tilemap_brick.local_to_map(mouse_global_pos_2D_world)
		var source_id : int = 0
		
		self._tilemap_brick.set_cell(0, tilemap_click_global_pos_2D_world, source_id, self._atlas_brick) 
		
	elif Input.is_action_pressed("right_click"):
		self._cam.global_position = mouse_global_pos_2D_world
	elif Input.is_action_just_pressed("return_textedit"):
		if self._lvlEditor.get_textedit_focus():
			var obj = self._lvlEditor.get_textedit_has_focus()
			obj.release_focus()


func set_brick(brick_name:String):
	self._atlas_brick = self.dict_atlas_coord_for_bricks[brick_name]

func get_tileset_brick_index(index_brick:int):
	var list_keys = self.dict_atlas_coord_for_bricks.keys()
	
	return list_keys[index_brick-13]
