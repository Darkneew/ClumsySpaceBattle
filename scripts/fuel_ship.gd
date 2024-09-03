extends CharacterBody2D

@export var player: int 

const ROTATE_SPEED : float = 7
const STRENGTH : float = 1000
const MAX_SPEED : float = 300
const MIN_SPEED_SQUARED : float = 2
const FREIN : float = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Movement
	rotation += delta * Input.get_axis(str(player) + "_left", str(player) + "_right") * ROTATE_SPEED
	if Input.is_action_pressed(str(player) + "_up"):
		velocity += Vector2.UP.rotated(rotation) * delta * STRENGTH
		if velocity.length_squared() > MAX_SPEED * MAX_SPEED:
			velocity = velocity.normalized() * MAX_SPEED
	else:
		velocity *= 1 - FREIN * delta
		if velocity.length_squared() < MIN_SPEED_SQUARED:
			velocity = Vector2.ZERO
		velocity 
	move_and_slide()
	pass
