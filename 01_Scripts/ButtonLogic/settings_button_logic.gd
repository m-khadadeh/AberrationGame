class_name SettingsButtonLogic
extends ButtonLogic

var _label : RichTextLabel

func on_ready(button : SplittableButton):
	next_button_logic = load("res://03_Resources/ButtonLogic/credits_button_logic.tres")
	split_button_logic_next = self
	split_button_logic_replace = self
	button.set_label_text("[center]Settings[/center]")

func on_button_clicked(button : SplittableButton):
	print("Settings pressed")
	super(button)
	
func on_neighbor_clicked(button : SplittableButton):
	print("Settings' Neighbor pressed")
	super(button)

func on_applied(button : SplittableButton):
	pass

func on_hovered(button : SplittableButton):
	pass
