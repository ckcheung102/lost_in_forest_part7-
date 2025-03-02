class_name FPS_Player
extends CharacterBody3D

@export_subgroup("Camera")
@export var sensitivity = 0.5
@export var min_angle = -60
@export var max_angle = 60

# use for global in future
var Health=50

@export_subgroup("Movement")
@export var SPEED = 5.0
@export var  FAST_SPEED= 12.0
const JUMP_VELOCITY = 7.0


@export_subgroup("Crouching")
@export var crouch_speed = 2.0
@export var crouch_height = 1.4
@export var crouch_transition = 8.0

# inventory 
@export_subgroup('Inventory')
@export var inventory_data : InventoryData
@export var equipRight_inventory:InventoryEquip
# @export var equipLeft_inventory:InventoryEquip

@export_subgroup('Interactive Objects')
@export var new_items_datas: Array[SlotData]
# 0 - torch 

@export_subgroup('Sound')
@export var walking_sound :AudioStreamPlayer3D 
@export var getting_object: AudioStreamPlayer3D


@onready var head = $head
@onready var UI = $ui
@onready var collision_shape = $CollisionShape3D
@onready var texture_rect: TextureRect = $ui/TextureRect


# objects in hand
@onready var torch: Node3D = $head/left_hand_throw/torch
@onready var equiped_petrol_bomb: Node3D = $head/right_hand_throw/equiped_petrol_bomb
@onready var petrol_icon: Sprite2D = $ui/petrol_icon

@onready var right_hand_throw: Marker3D = $head/right_hand_throw
@onready var sword: Node3D = $head/right_hand_throw/sword
@onready var color_rect: ColorRect = $UI/ColorRect



# preload objects 
@onready var petrol_bomb = preload('res://Scenes/Objects/petrol_bomb.tscn')

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_rot : Vector2
var mouse_visible:bool = false
var stand_height : float

var final_direction : Vector3
var move_speed :float

# bool 
var is_sprint: bool =false
var is_dead : bool = false

# controls 
var block_move: bool = false
var block_rotate_view:bool = false
var block_inventory:bool =false
var is_interacting:bool=false
var active_in_dialogue:bool = false
var can_shoot: bool =false

var power=100.0 

# signals 
signal toggle_inventory

func _ready()->void: 
	
	look_rot.y = rotation_degrees.y
	stand_height = collision_shape.shape.height
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	equiped_petrol_bomb.position=right_hand_throw.global_position
	
func _physics_process(delta: float) -> void:
	

	# movement 
	move_speed = SPEED 
	power+=delta*5
	if power>100: 
		power=100
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	elif not is_dead: 
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif Input.is_action_pressed("crouch"):
			move_speed = crouch_speed
			# crouching 
			crouch(delta)
		elif Input.is_action_pressed('run') and power>10 :
			move_speed= FAST_SPEED
			power-=delta*10
			print(power)
			if power<0: 
				power=0
			
		else:
			# not crouching
			move_speed = SPEED
			crouch(delta, true)
	
	if not block_move:
		# Get the input direction and handle the movement/deceleration.
		# movement direction 
		var input_dir := Input.get_vector("right", "left", "backward", "forward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction and not $head/head_cast.is_colliding():
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)

		handle_rotation(delta)
		
		
		move_and_slide()

		final_direction = direction
		
		# walking sound
		if is_on_floor() and input_dir: 
			if walking_sound.playing == false:
				walking_sound.playing=true
		else: 
			walking_sound.playing=false
	
	else : 
		walking_sound.playing=false
	
func _input(event)-> void:
	if event is InputEventMouseMotion :
		look_rot.y -= (event.relative.x * sensitivity)
		look_rot.x -= (event.relative.y * sensitivity)
		look_rot.x = clamp(look_rot.x, min_angle, max_angle)

func crouch(delta : float, reverse = false)->void:
	var target_height : float = crouch_height if not reverse else stand_height
	
	collision_shape.shape.height = lerp(collision_shape.shape.height, target_height, crouch_transition * delta)
	collision_shape.position.y = lerp(collision_shape.position.y, target_height * 0.5, crouch_transition * delta)
	head.position.y = lerp(head.position.y, target_height - 1, crouch_transition * delta)	
	
func _unhandled_input(_event: InputEvent) -> void:
	
		
	if Input.is_action_just_pressed('inventory') and not block_inventory:
		
		toggle_inventory.emit()
		
				 
	if mouse_visible : 
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else : 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	# throw objects 
	if can_shoot: 
		equiped_petrol_bomb.show()
		petrol_icon.show()
		if Input.is_action_just_pressed('throw') : 
			can_shoot=false
			equiped_petrol_bomb.hide()
			petrol_icon.hide()
			throw_object()
	else : 
		equiped_petrol_bomb.hide()
		petrol_icon.hide()
		

func handle_rotation(delta)->void: 
		
	# rotation
	if not mouse_visible and not block_rotate_view:
		var plat_rot = get_platform_angular_velocity()
		look_rot.y += rad_to_deg(plat_rot.y * delta)
		head.rotation_degrees.x = look_rot.x
		rotation_degrees.y = look_rot.y	

func block_movement()->void: 
	block_move=true
	
func release_movement()->void: 
	block_move=false
		
func is_inventory_full()->bool : 
	
# to check inventory is full or not 
	for slot_data in inventory_data.slot_datas: 
		if slot_data ==null: 
			return false 
	
	return true  

func throw_object()->void: 
	var instance : RigidBody3D = petrol_bomb.instantiate()
	var force:float = 8.0
	var up_vel: float= 0.5
	
	# position of drop
	instance.position =right_hand_throw.global_position  + Vector3(0,up_vel,0)
		
	get_tree().current_scene.add_child(instance)
	
	# direction of drop,  facing ahead 
	var throw_direction = head.global_transform.basis.z
	
	instance.apply_central_impulse(throw_direction*force)
	print("playerRot:", throw_direction)
	
	
func get_damage()->void: 
	Health-=1
	print("Health left : ", Health)
	self.color_rect.show() 
	await get_tree().create_timer(0.15).timeout
	self.color_rect.hide()
	
