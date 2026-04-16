import re

with open("scripts/options_container.gd", "r") as f:
    text = f.read()

# Name the inner_box so we can systematically path to it from Master
text = text.replace('var inner_box = VBoxContainer.new()', 'var inner_box = VBoxContainer.new()\n\t\t\tinner_box.name = "InnerBox"')

with open("scripts/options_container.gd", "w") as f:
    f.write(text)

with open("Master.gd", "r") as f:
    master = f.read()

master = master.replace(
    '@onready var add_ball = $CanvasLayer/OptionsContainer/OptionsList/BallManagement/AddBall',
    '@onready var add_ball = $CanvasLayer/OptionsContainer/OptionsList/InnerBox/BallManagement/AddBall'
)
master = master.replace(
    '@onready var remove_ball = $CanvasLayer/OptionsContainer/OptionsList/BallManagement/RemoveBall',
    '@onready var remove_ball = $CanvasLayer/OptionsContainer/OptionsList/InnerBox/BallManagement/RemoveBall'
)

with open("Master.gd", "w") as f:
    f.write(master)

