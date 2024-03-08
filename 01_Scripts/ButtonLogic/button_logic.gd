class_name ButtonLogic
extends Resource

@export var next_button_logic : ButtonLogic
@export var split_button_logic_replace : ButtonLogic
@export var split_button_logic_next : ButtonLogic

@export var color : Color

var game_container : GameContainer

func on_ready(button : SplittableButton):
	pass

func on_button_clicked(button : SplittableButton):
	# print("Super Button pressed")
	button.set_button_logic(next_button_logic)
	game_container.click_neighbors(button)
	
func on_neighbor_clicked(button : SplittableButton):
	# print("Super Button neighbor pressed")
	button.set_button_logic(next_button_logic)

func on_applied(button : SplittableButton):
	pass

func on_hovered(button : SplittableButton):
	pass
