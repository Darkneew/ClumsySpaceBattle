extends CanvasLayer

enum State {Veil, Unveil, None}

var callback
var state: State = State.None
@onready var timer: Timer = $Timer
@onready var rect: TextureRect = $Rect

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if state == State.Veil:
		rect.modulate = Color(0,0,0,lerpf(1, 0, timer.time_left/timer.wait_time))
	elif state == State.Unveil:
		rect.modulate = Color(0,0,0,lerpf(0, 1, timer.time_left/timer.wait_time))

func veil(_callback = null):
	rect.modulate = Color(0,0,0,0)
	rect.visible = true
	state = State.Veil
	timer.start()
	callback = _callback
	
func unveil(_callback = null):
	rect.modulate = Color(0,0,0,1)
	rect.visible = true
	state = State.Unveil
	timer.start()
	callback = _callback

func _on_timer_timeout():
	if state == State.Veil:
		rect.modulate = Color(0,0,0,1)
	elif state == State.Unveil:
		rect.modulate = Color(0,0,0,0)
		rect.visible = false
	state = State.None
	if callback != null:
		callback.call()
