extends Button


func _ready():
	if GPack.plugin:
		GPack.plugin.connect(GPack.s_on_signed_in_status_changed, self, "set_access")


func set_access(b):
	disabled = !b
