extends Smart_Enemy

var damage: int

@onready var attack_animation=$AnimationTree.get_tree_root().get_node('attack1')

func _ready() -> void:	
	
	current_state= State.idle
	
	
func _physics_process(delta: float) -> void:
	
	# gravity
	if not is_on_floor(): 
		velocity.y -= gravity *delta
	
	self.look_for_player(delta)	
	
	move_and_slide()
	
#
func damage_player()->void: 
	
	if self.position.distance_to(player.global_position) < attack_radius: 
		player.get_damage()
	

	
func attack_player()->void: 
	# timeout 
	if self.position.distance_to(player.global_position)<attack_radius: 
		print('attacking...')
		attack_animation.animation='attack1'
		$AnimationTree.set('parameters/OneShotAttack/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_attack_timeout() -> void:
	attack_player()
