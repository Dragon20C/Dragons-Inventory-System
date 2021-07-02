extends KinematicBody

var speed = 15
var accel_type = {"default": 40, "air": 1}
onready var accel = accel_type["default"]
var gravity = 20
var jump = 10

var cam_accel = 40
var mouse_sense = 0.12
var snap

var menu_state : bool = false

var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

onready var head = get_node("Head")
onready var camera = get_node("Head/Camera")
onready var raycast = get_node("Head/Camera/RayCast")

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion and !menu_state:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-85), deg2rad(85))

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		camera.set_as_toplevel(false)
		camera.global_transform = head.global_transform
		
func _physics_process(delta):
		
	#get keyboard input
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	if !menu_state:
		var f_input = Input.get_action_strength("backward") - Input.get_action_strength("forward")
		var h_input = Input.get_action_strength("right") - Input.get_action_strength("left")
		direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = accel_type["default"]
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = accel_type["air"]
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor() and !menu_state:
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
	
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	
	move_and_slide_with_snap(movement, snap, Vector3.UP)

func ui_opened():
	menu_state = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	raycast.enabled = false
func ui_closed():
	menu_state = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	raycast.enabled = true
