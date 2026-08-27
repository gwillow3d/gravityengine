class_name EnergyWidget
extends Label

func _on_energy_updated(kinetic: float, potential: float, linear_momentum: Vector2, angular_momentum: float) -> void:
	var total = kinetic + potential
	var contents = "~ Energy ~"
	contents += "\nTotal: " + _format_joules(total)
	contents += "\nKinetic: " + _format_joules(kinetic)
	contents += "\nPotential: " + _format_joules(potential)
	contents += "\n\n~ Momentum ~"
	contents += "\nLinear: %.1v N" % linear_momentum
	contents += "\nAngular: " + _format_joules(angular_momentum)
	
	text = contents
	
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
