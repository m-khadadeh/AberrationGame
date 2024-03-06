class_name ButtonLogic
extends Resource

@export var next_button_logic : ButtonLogic
@export var split_button_logic_replace : ButtonLogic
@export var split_button_logic_next : ButtonLogic

var game_container : GameContainer

func on_ready(button_control_parent : Control, tooltip_parent : Control):
	pass

func on_button_clicked(button_control_parent : Control, tooltip_parent : Control):
	pass
	
func on_neighbor_clicked(button_control_parent : Control, tooltip_parent : Control):
	pass

func on_applied(button_control_parent : Control, tooltip_parent : Control):
	pass

func on_hovered(button_control_parent : Control, tooltip_parent : Control):
	pass
