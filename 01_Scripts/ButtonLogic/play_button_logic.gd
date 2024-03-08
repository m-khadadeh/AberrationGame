class_name PlayButtonLogic
extends ButtonLogic

var _label : RichTextLabel

func on_ready(button : SplittableButton):
	next_button_logic = load("res://03_Resources/ButtonLogic/settings_button_logic.tres")
	split_button_logic_next = self
	split_button_logic_replace = self
	button.set_label_text("[center]Play[/center]")

func on_button_clicked(button : SplittableButton):
	print("Play pressed")
	super(button)
	
func on_neighbor_clicked(button : SplittableButton):
	print("Play's Neighbor pressed")
	super(button)

func on_applied(button : SplittableButton):
	print("You win!")

func on_hovered(button : SplittableButton):
	pass
