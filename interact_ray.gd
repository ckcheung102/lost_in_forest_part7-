extends RayCast3D

@onready var prompt = $prompt
@onready var player = get_tree().get_first_node_in_group('player')


func _process(_delta: float) -> void:
	prompt.text =""
	
	if is_colliding():
		var collider = get_collider()
		
		if collider is InteractClass: 
			
			prompt.text=collider.get_prompt()
			player.is_interacting=true
			
			if Input.is_action_just_pressed('interact'): 
					player.is_interacting=false
					collider.interact(owner)
					
					
		elif collider is InteractRigidBody: 
			prompt.text=collider.get_prompt()
			player.is_interacting=true
			
			if Input.is_action_just_pressed('interact'): 
					player.is_interacting=false
					collider.interact(owner)
					
		else : 
			player.is_interacting=false
			
	else : 
		player.is_interacting=false
		
