class_name ButtonLogic
extends Resource

@export var next_button_logic : ButtonLogic
@export var split_button_logic_replace : ButtonLogic
@export var split_button_logic_next : ButtonLogic

@export var color : Color

@export var tooltip_scene : PackedScene

var game_container : GameContainer

func on_ready(button : SplittableButton):
	pass

func on_button_clicked(button : SplittableButton):
	# print("Super Button pressed")
	if not button.is_locked():
		button.set_button_logic(next_button_logic)
		game_container.click_neighbors(button)
		game_container.queue_apply()
	
func on_neighbor_clicked(button : SplittableButton):
	#print("Super Button neighbor pressed")
	if not button.is_locked():
		button.set_button_logic(next_button_logic)
		game_container.queue_apply()

func on_applied(button : SplittableButton):
	pass

func on_hovered(button : SplittableButton):
	game_container.create_tooltip(tooltip_scene)

func create_control_tree() -> Node:
	return Node.new()
