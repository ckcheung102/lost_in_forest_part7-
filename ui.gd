extends CanvasLayer

@onready var control = $Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	control.hide()


	
		
func display_message(message:String)-> void : 
	control.show()
	$Control/Label.text = message
	$message_timer.start()


func _on_message_timer_timeout() -> void:
	control.hide()
