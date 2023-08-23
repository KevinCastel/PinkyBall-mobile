extends BodyCharacter2D

var _vel = Vector2.ZERO

var _speed = 0

const MAXIMUM_SPEED = 1.50
const INCREASE_SPEED = 0.0015


func spawn(vel:Vector2, global_pos_2D_world:Vector2):
  self.global_position = global_pos_2D_world


func _physics_process(delta):
  var coll = move_and_collide(self._vel * delta)
  if coll:
    self._vel = self._vel.bounce(coll.get_normal())
    
    if "brick" in coll.name:
      self.collide_with_brick(coll)
 
  self.increase_speed()
  self._vel = Vector2(self._speed, self._speed)


func collide_with_brick(brick_obj):
  var superpower = brick_obj.superpower
  self.on_ball_impact()

func increase_speed():
  self._speed = maxf(self._speed-self.INCREASE_SPEED, -self.MAXIMUM_SPEED)