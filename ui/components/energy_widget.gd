class_name EnergyWidget
extends Control

@export var energy_label: Label
@export var momentum_label: Label

var _tween: Tween

func _ready() -> void:
	visible = false
	modulate.a = 0.0

func _on_visibility_toggled() -> void:
	var now_visible = !visible
	
	if _tween:
		_tween.stop()
	
	_tween = create_tween()
	if now_visible:
		show()
		_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	else:
		_tween.tween_property(self, "modulate:a", 0.0, 0.2)
		_tween.tween_callback(hide)

func _on_energy_updated(kinetic: float, potential: float, linear_momentum: Vector2, angular_momentum: float) -> void:
	var total = kinetic + potential
	var energy_contents = "Total: " + _format_joules(total)
	energy_contents += "\nKinetic: " + _format_joules(kinetic)
	energy_contents += "\nPotential: " + _format_joules(potential)
	
	var momentum_contents = "Linear: %.1v N*s" % [round(linear_momentum * 10) / 10]
	momentum_contents += "\nAngular: " + _format_joules(angular_momentum)
	
	energy_label.text = energy_contents
	momentum_label.text = momentum_contents
	
func _format_joules(raw_amount: float) -> String:
	if abs(raw_amount) >= 1000000000000: # Terajoule
		return "%.1f TJ" % [raw_amount / 1000000000]
	if abs(raw_amount) >= 1000000000: # Gigajoule
		return "%.1f GJ" % [raw_amount / 1000000000]
	if abs(raw_amount) >= 1000000: # Megajoule
		return "%.1f MJ" % [raw_amount / 1000000]
	if abs(raw_amount) >= 1000: # Kilojoule
		return "%.1f KJ" % [raw_amount / 1000]
	return "%.1f J" % raw_amount # Joule
