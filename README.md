These files are the creation of self path finding zombies. 

=> use your player node 
@onready var player = get_tree().get_first_node_in_group('player')
# @onready var mesh = $mesh

=> use your meshInstance3D 
@onready var armature: Node3D = $Armature

=> You need to create Animation Tree or Animation Player 
@onready var move_machine = $AnimationTree.get('parameters/MoveMachine/playback')
@onready var animation_player: AnimationPlayer = $AnimationPlayer

=> Include the NavigationAgent3D node 
@onready var nav_agent = $NavigationAgent3D

=> Add two Timer Nodes 
@onready var patrol_timer=$Timers/patrol_timer
@onready var attack: Timer = $Timers/attack
