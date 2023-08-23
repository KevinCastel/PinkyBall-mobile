extends StaticBody2D

var _superpower = ""
var _color = ""

func spawn(global_position_2D_world):
  self.global_position = global_position_2D_world

func on_ball_impact():
  self.destroy()

func destroy():
  self.queue_free()