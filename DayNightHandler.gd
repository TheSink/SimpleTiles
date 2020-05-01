extends Timer

var Increase = 0.5

func _on_Timer_timeout():
	Globals.Time += Increase
	if Globals.Time > 50:
		Increase = -0.5
	elif Globals.Time < 1:
		Increase = 0.5
