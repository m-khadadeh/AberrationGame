class_name SplitOnClickLogic
extends ButtonLogic

var _label : RichTextLabel

func on_ready(button : SplittableButton):
	split_button_logic_next = self
	split_button_logic_replace = self
	button.set_label_text("[center]Slice[/center]")

func on_button_clicked(button : SplittableButton):
	game_container.queue_split()
	
func on_neighbor_clicked(button : SplittableButton):
	pass

func on_applied(button : SplittableButton):
	pass

func on_hovered(button : SplittableButton):
	pass