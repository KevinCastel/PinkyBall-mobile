extends CharacterBody2D

var _vel = Vector2.ZERO

var _speed = 0.00

var _last_time_before_static

const ACCEL = 0.60
const DECCELERATION = 0.032
const MAXIMUM_SPEED = 200
const SECOND_COLLISION_SPEED_CORRECTOR = 0.30

func spawn(global_position_map_2D:Vector2):
	self.global_position = global_position_map_2D

func _physics_process(delta):
	self.correct_speed_on_collsion()
	
	self.check_input()
	
	self._vel.x = self._speed
	self.velocity = self._vel
	move_and_slide()


func check_input():
	"""
		Check player inputs
	"""
	if Input.is_action_pressed("move_right"):
		self._speed = min(self._speed+self.ACCEL, self.MAXIMUM_SPEED)
	elif Input.is_action_pressed("move_left"):
		self._speed = max(self._speed-self.ACCEL, -self.MAXIMUM_SPEED)
	else:
		self._speed = lerp(float(self._speed), 0.00, float(self.DECCELERATION))


func correct_speed_on_collsion():
	"""
		For example if this platform collided against a wall or something else,
		The speed will keep slow down but this function will set the speed at
		0 if the speed is higher than 0 and that the platform hasn't moved since
		some seconds ago 
	"""
	var actual_unix_time = Time.get_unix_time_from_system()
	if self.velocity.x == 0:
		if self._speed > 0.10 or self._speed < -0.10:
			if actual_unix_time > self._last_time_before_static + self.SECOND_COLLISION_SPEED_CORRECTOR:
				self._speed = 0.00
				self._vel = self.velocity
	else:
		self._last_time_before_static = actual_unix_time
