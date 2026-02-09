extends CharacterBody3D

@export var LOOK_HORIZONTAL_SPEED : float = 2.0
@export var LOOK_VERTICLE_SPEED : float = 1.5
@export var SPEED : float = 10

@onready var camera_mount := $CameraMount
@onready var camera := $CameraMount/SpringArm3D/Camera3D
@onready var camera_cast := $CameraMount/SpringArm3D/Camera3D/CameraCast
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var anim_tree : AnimationTree = $AnimationTree

var rot_x : float = 0
var rot_y : float = 0
var is_playing_forward : bool = false
var mouse_position : Vector2

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func  _process(_delta: float) -> void:
	if Input.is_action_pressed("quit"):
		get_tree().quit()
	mouse_position = get_viewport().get_mouse_position()
	camera_cast.target_position = camera.project_local_ray_normal(mouse_position) * 100.0
	camera_cast.force_raycast_update()
	var camera_look : Vector2 = Vector2(Input.get_action_strength("right_look") - Input.get_action_strength("left_look"),
										Input.get_action_strength("up_look") - Input.get_action_strength("down_look"))
	rotate_y(deg_to_rad(-camera_look.x * LOOK_HORIZONTAL_SPEED))
	camera_mount.rotate_x(deg_to_rad(camera_look.y * LOOK_VERTICLE_SPEED))
	animation_update()

func _physics_process(_delta: float) -> void:
	
	var input_dir : Vector2 = Input.get_vector("mleft", "mright", "mforward", "mbackward")
	var direction : Vector3
	direction = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * LOOK_HORIZONTAL_SPEED))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * LOOK_VERTICLE_SPEED))
		# modify accumulated mouse rotation
		rot_x += event.relative.x * LOOK_HORIZONTAL_SPEED
		rot_y += event.relative.y * LOOK_VERTICLE_SPEED

func animation_update() -> void:
	if (velocity.x != 0 or velocity.z != 0):
		anim_tree["parameters/conditions/is_run_forward"] = true
		anim_tree["parameters/conditions/forward_run_stop"] = false
	else:
		anim_tree["parameters/conditions/is_run_forward"] = false
		anim_tree["parameters/conditions/forward_run_stop"] = true
