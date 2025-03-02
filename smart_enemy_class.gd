class_name Smart_Enemy
extends CharacterBody3D

enum State{patrol, chase, idle, attack}

# patrol waypoints
@export var waypoint1:Array[Marker3D]


@onready var player = get_tree().get_first_node_in_group('player')
# @onready var mesh = $mesh

@onready var armature: Node3D = $Armature


@onready var move_machine = $AnimationTree.get('parameters/MoveMachine/playback')
@onready var animation_player: AnimationPlayer = $AnimationPlayer


@onready var nav_agent = $NavigationAgent3D
@onready var patrol_timer=$Timers/patrol_timer
@onready var attack: Timer = $Timers/attack



var waypoint_index: int =0 
var current_state 
var waypoints_matrix=[]

var gravity =9.8

@export var run_speed :float =4.0 
@export var patrol_speed:float =1.5
@export var attack_speed:float=0.2

@export var detect_radius : float = 20.0
@export var attack_radius : float =5.0


func _ready() -> void:
	
	nav_agent.set_target_position(waypoint1[waypoint_index].global_position)
	monster_face(waypoint1[waypoint_index].global_position)
	
func monster_face(face_direction:Vector3):
	
	armature.look_at_from_position(position,face_direction,Vector3(0,1,0),true)
	
func look_for_player(delta: float) -> void:
	
	await get_tree().physics_frame
	
	#gravity
	if not is_on_floor(): 
		velocity.y -= gravity *delta

	get_state()
	
	match current_state: 
		
		State.patrol : 
			
			if nav_agent.is_navigation_finished():
				
				current_state=State.idle							
								
			move_machine.travel('walk')
			# animation_player.play('walk')
			var next_point=nav_agent.get_next_path_position()
			var direction = global_position.direction_to(next_point)
			velocity = direction * patrol_speed
			
			move_and_slide()
			
		State.idle : 
			move_machine.travel('idle')
			# animation_player.play('idle')
			
			velocity.x = move_toward(velocity.x, 0, delta)
			velocity.z = move_toward(velocity.z, 0, delta)
						
		State.attack: 
			move_machine.travel('run')
			
			# animation_player.play('attack1')
			# move_machine.travel('attack1')
			
			monster_face(player.global_position)
			velocity.x = move_toward(velocity.x, attack_speed, delta)
			velocity.z = move_toward(velocity.z, attack_speed, delta)
		
		State.chase: 
			#option 1 
			#var direction = (player.position - self.position).normalized()
			#monster_face(player.global_position)
			
			#option 2 	
				
			nav_agent.set_target_position(player.global_position)
			var next_point=nav_agent.get_next_path_position()
			var direction = global_position.direction_to(next_point)
			monster_face(next_point)
			velocity = direction * run_speed
			# animation_player.play('run')
			move_machine.travel('run')
			move_and_slide()
			
			#if nav_agent.is_navigation_finished():
			#	current_state=State.idle
			#	patrol_timer.start()
			#move_to_target_point(run_speed)
	
func _on_patrol_timer_timeout() -> void:
	current_state=State.patrol	
	print("patrolling...") 
	
	waypoint_index+=1
	# end of waypoint
	if waypoint_index > waypoint1.size()-1: 
		waypoint_index=0 
		
	var next_point = waypoint1[waypoint_index].global_position
	nav_agent.set_target_position(next_point)
	monster_face(next_point)

func move_to_target_point(speed):
	var next_point=nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_point)
	velocity =direction *speed 
	monster_face(next_point)
	move_and_slide()
		
# to return a state	
func get_state()->State: 
	
	if self.position.distance_to(player.position) < detect_radius:
		if self.position.distance_to(player.position)< attack_radius:
			current_state=State.attack
			
		else:
			current_state=State.chase
				
		return current_state		
	else : 
		return current_state


		 
		
