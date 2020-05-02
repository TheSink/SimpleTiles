extends KinematicBody2D


const BASE_SPEED = 175
var speed = 175
var selected_block = 2
var targetMap = Globals.Maps.Surface.Layers.S0
var saved_msg = ""
var GroundLayerForCollision = false
var isSprinting = false
var lastSong = -1
var lastFootstep = -1
var stepIncrement = 0
var SavedTime = 0
var sprinting = false
var StateBeforePause
var RequestFootstep = false
var ManualLayerSwitch = false
var lastCoordinate = Vector2()
var footstepElements = []
onready var FPSText = $Camera2D/UILayer/UIContainer/FPS

func _check_speed():
	if weakref(targetMap).get_ref() != null:
		var current_tile = targetMap.get_cellv(targetMap.world_to_map(global_position))
		if (current_tile == 0): # Deep Water
			speed = BASE_SPEED * 0.5
		if (current_tile == 1): # Shallow Water
			speed = BASE_SPEED * 0.75
		if (current_tile == 2): # Grass
			speed = BASE_SPEED
		if (current_tile == 3): # Mountain
			speed = BASE_SPEED * 0.4
		if (current_tile == 4): # Snow
			speed = BASE_SPEED * 0.2
		if (current_tile == 5): # Wood/Tree
			speed = BASE_SPEED
		if (current_tile == 7): # Sand
			speed = BASE_SPEED * 0.85
		if (current_tile == 9):
			speed = BASE_SPEED
		if sprinting == true:
			speed += 65
		if Globals.MovementEnabled == false:
			speed = 0
	else:
		print("WARNING: Attempted to call invalid map to modify player speed.")
		Globals.DisplayErrorPopup($Camera2D/UILayer/UIContainer, "Attempted to call invalid target map to modify player speed.")

func _assign_target_block(block_id):
	var target = block_id
	print("Path: " + Globals.BlockTextures.values()[target][0])
	print("Name: " + Globals.BlockTextures.keys()[target])
	selected_block = target
	$Camera2D/UILayer/UIContainer/Block.set_texture(load(Globals.BlockTextures.values()[target][0]))
	$Camera2D/UILayer/UIContainer/BlockName.text = Globals.BlockTextures.keys()[target]

func _check_light_placements(vectorToCheckFor):
	if Globals.CurrentLayer == 1:
		for vector in Globals.LightPlacements.Surface:
			if vector == vectorToCheckFor:
				return true
	else:
		for vector in Globals.LightPlacements.Cave:
			if vector == vectorToCheckFor:
				return true
	return false

func _build():
	if Globals.MovementEnabled == false:
		return
	if get_global_mouse_position().distance_to(global_position) < 160:
		var buildTargetMap
		if Globals.CurrentLayer == 0:
			buildTargetMap = Globals.Maps.Underground.Root.get_node("U"+str(Globals.BuildTarget))
		elif Globals.CurrentLayer == 1:
			buildTargetMap = Globals.Maps.Surface.Root.get_node("S"+str(Globals.BuildTarget))
		print(buildTargetMap.name)
		var old_tile = buildTargetMap.get_cellv(buildTargetMap.world_to_map(get_global_mouse_position()))
		buildTargetMap.set_cellv(buildTargetMap.world_to_map(get_global_mouse_position()), selected_block)
		var lightCoordinate = buildTargetMap.map_to_world(buildTargetMap.world_to_map(get_global_mouse_position()))+Vector2(16,16)
		if selected_block == 8 and _check_light_placements(lightCoordinate) == false:
			var light = Light2D.new()
			get_node("../").add_child(light)
			light.texture = load("res://torchlight.png")
			light.global_position = lightCoordinate
			light.color = Color.orange
			light.energy = 1
			light.texture_scale = 1.5
			light.mode = Light2D.MODE_ADD
			Globals.LightReferences.values()[Globals.CurrentLayer].append(light)
			if Globals.CurrentLayer == 1:
				Globals.LightPlacements.Surface.append(lightCoordinate)
			else:
				Globals.LightPlacements.Cave.append(lightCoordinate)
		if old_tile == 5 and not selected_block == 5:
			Globals.BlockChecks.TreeLeaves.append(buildTargetMap.world_to_map(get_global_mouse_position()))
		if old_tile == 8 and not selected_block == 8:
			if Globals.CurrentLayer == 0:
				for light in Globals.LightReferences.Cave:
					if Globals.Maps.Surface.Layers.S0.world_to_map(light.global_position) == Globals.Maps.Surface.Layers.S0.world_to_map(get_global_mouse_position()):
						Globals.LightReferences.Cave.erase(light)
						light.queue_free()
			else:
				for light in Globals.LightReferences.Surface:
					if Globals.Maps.Surface.Layers.S0.world_to_map(light.global_position) == Globals.Maps.Surface.Layers.S0.world_to_map(get_global_mouse_position()):
						Globals.LightReferences.Surface.erase(light)
						light.queue_free()

#func _assign_collision_mask(under,surface):
#	print("Changing collision mask to value: u=" + str(under) + " s=" + str(surface))
#	$UpCast.set_collision_mask_bit(0, under)
#	$UpCast.set_collision_mask_bit(1, surface)
#	$DownCast.set_collision_mask_bit(0, under)
#	$DownCast.set_collision_mask_bit(1, surface)
#	$LeftCast.set_collision_mask_bit(0, under)
#	$LeftCast.set_collision_mask_bit(1, surface)
#	$RightCast.set_collision_mask_bit(0, under)
#	$RightCast.set_collision_mask_bit(1, surface)

func doFootstep():
	if weakref(targetMap).get_ref() != null:
		var delta = lastCoordinate.distance_to(global_position)
		lastCoordinate = global_position
		if abs(delta) < 1:
			return
		for sound in footstepElements:
			var wr = weakref(sound)
			if wr.get_ref():
				if sound.playing == false:
					sound.queue_free()
		var current_tile = targetMap.get_cellv(targetMap.world_to_map(global_position))
		var soundNumber = round(rand_range(1,5))
		while soundNumber == lastFootstep: soundNumber = round(rand_range(1,5))
		soundNumber = "0"+str(soundNumber)
		var path = "res://Sounds/Footsteps/"
		if current_tile == 3 or current_tile == 9: # mountain/cave floor
			path += "stone"
		elif current_tile == 2:
			path += "grass"
		elif current_tile == 0:
			path += "deep"
		elif current_tile == 1:
			path += "shallow"
		elif current_tile == 4:
			path += "snow"
		else:
			return
		path += soundNumber + ".ogg"
		var player = AudioStreamPlayer2D.new()
		add_child(player)
		player.stream = load(path)
		player.set_bus("Footsteps")
		player.volume_db = -14
		player.play()
		footstepElements.append(player)
	else:
		print("WARNING: Attempted to call invalid map to play footstep sound.")
		Globals.DisplayErrorPopup($Camera2D/UILayer/UIContainer, "Attempted to call invalid target map for footstep sounds.")

func DayNightCalculate(override=false):
	if Globals.Time != SavedTime or override == true:
		SavedTime = Globals.Time
		if Globals.Time < 15:
			$LightMask.energy = 0
		elif Globals.Time > 35:
			$LightMask.energy = 1
		else:
			$LightMask.energy = float(Globals.Time-15)/20

func check_collision(casts):
	if weakref(targetMap).get_ref() != null:
		var collision = false
		for cast in casts:
			if cast.is_colliding():
				if cast.get_collider() == targetMap:
					collision = true
		return collision
	else:
		print("WARNING: Attempted to call invalid map to check for collisions.")
		Globals.DisplayErrorPopup($Camera2D/UILayer/UIContainer, "Attempted to call invalid target map for collision checks.")

func _physics_process(delta):
	if Globals.MovementEnabled == true:
		if Input.is_action_pressed("move_up"):
			_check_speed()
			var _movement = move_and_collide(-Vector2(0,1)*speed*delta)
			selection()
			var fsDelay = clamp(1.5-(1 * ((speed/175)*1.175)),0.35,1.5)
			if fsDelay > 0:
				$FootstepTimer.wait_time = fsDelay
				RequestFootstep = true
		if Input.is_action_pressed("move_down"):
			_check_speed()
			var _movement = move_and_collide(Vector2(0,1)*speed*delta)
			selection()
			var fsDelay = clamp(1.5-(1 * ((speed/175)*1.175)),0.35,1.5)
			if fsDelay > 0:
				$FootstepTimer.wait_time = fsDelay
				RequestFootstep = true
		if Input.is_action_pressed("move_left"):
			_check_speed()
			var _movement = move_and_collide(-Vector2(1,0)*speed*delta)
			selection()
			var fsDelay = clamp(1.5-(1 * ((speed/175)*1.175)),0.35,1.5)
			if fsDelay > 0:
				$FootstepTimer.wait_time = fsDelay
				RequestFootstep = true
		if Input.is_action_pressed("move_right"):
			_check_speed()
			var _movement = move_and_collide(Vector2(1,0)*speed*delta)
			selection()
			var fsDelay = clamp(1.5-(1 * ((speed/175)*1.175)),0.35,1.5)
			if fsDelay > 0:
				$FootstepTimer.wait_time = fsDelay
				RequestFootstep = true
	if Input.is_action_pressed("build"):
		_build()
	if Input.is_action_just_pressed("SwitchLayers") or ManualLayerSwitch == true:
		if Globals.CurrentGameState == Definitions.GameState.INGAME:
			ManualLayerSwitch = false
#			Globals.Maps.Surface.Layers.S0.visible = not Globals.Maps.Surface.Layers.S0.visible
#			Globals.Maps.Surface.Layers.S2.visible = not Globals.Maps.Surface.Layers.S2.visible
#			Globals.Maps.Surface.Layers.U0.visible = not Globals.Maps.Surface.Layers.U0.visible
			$Light2D.enabled = not $Light2D.enabled
			for light in Globals.LightReferences.values()[Globals.CurrentLayer]:
				light.enabled = false
			if Globals.CurrentLayer == 0:
				Globals.CurrentLayer = 1
				Globals.Maps.Surface.Root.position -= Vector2(100000,0)
				Globals.Maps.Underground.Root.position += Vector2(100000,0)
				targetMap = Globals.Maps.Surface.Layers.S0
				if Globals.MapData.Flags.day_night == true:
					if $LightMask.enabled == false:
						$LightMask.enabled = true
					DayNightCalculate(true)
				else:
					$LightMask.enabled = false
			else:
				Globals.CurrentLayer = 0
				targetMap = Globals.Maps.Surface.Layers.U0
				Globals.Maps.Surface.Root.position += Vector2(100000,0)
				Globals.Maps.Underground.Root.position -= Vector2(100000,0)
				if $LightMask.enabled == false:
					$LightMask.enabled = true
				$LightMask.energy = 1
			for light in Globals.LightReferences.values()[Globals.CurrentLayer]:
				light.enabled = true
	if Globals.MapData.Flags.day_night == true and Globals.CurrentLayer == 1:
		DayNightCalculate()
		
	FPSText.text = str(Engine.get_frames_per_second())
	if Globals.UIMsg != saved_msg:
		saved_msg = Globals.UIMsg
		$Camera2D/UILayer/UIContainer/Message.text = saved_msg
		if saved_msg == "":
			$Camera2D/UILayer/UIContainer/Message.visible = false
		else:
			$Camera2D/UILayer/UIContainer/Message.visible = true
	if Globals.UIPercentage > -1:
		$Camera2D/UILayer/UIContainer/Message/ProgressBar.visible = true
		$Camera2D/UILayer/UIContainer/Message/ProgressBar.value = Globals.UIPercentage
	else:
		$Camera2D/UILayer/UIContainer/Message/ProgressBar.visible = false

func music():
	while Globals.CurrentGameState == Definitions.GameState.INGAME:
		randomize()
		var Required = 0
		if targetMap == Globals.Maps.Surface.Layers.S0:
			Required = 1
		var selectedSong = round(rand_range(0,5))
		while selectedSong == lastSong or Globals.Music.values()[selectedSong][1] != Required:
			selectedSong = round(rand_range(0,5))
		lastSong = selectedSong
		selectedSong = Globals.Music.values()[selectedSong]
		$InGameMusic.stream = load(selectedSong[0])
		$InGameMusic.play()
		yield(get_tree().create_timer(selectedSong[2]*2.5), "timeout")

func _ready():
	$Camera2D/UILayer/UIContainer/LoadCover.visible = true
	$Camera2D/UILayer/UIContainer/LoadCover.modulate = Color(1,1,1,1)
	targetMap = Globals.Maps.Surface.Layers.S0
	Globals.PlayerBody = self
	while Globals.CurrentGameState != Definitions.GameState.INGAME:
		yield(get_tree().create_timer(2), "timeout")
	yield(get_tree().create_timer(0.5), "timeout")
	targetMap = Globals.Maps.Surface.Layers.S0
	if Globals.Player.Map == 0:
		ManualLayerSwitch = true
	var equipped = Globals.Player.Equipped[0]
	_assign_target_block(equipped)
	selected_block = equipped
	if Globals.Player.Position == Vector2(-1,-1):
		Globals.Player.Position = Vector2(Globals.MapData.Size/2,Globals.MapData.Size/2)
	global_position = Globals.Player.Position
	$Camera2D/UILayer/UIContainer/Animations.play("Fade")
	music()
	
func selection():
	var mousePosition = get_global_mouse_position()
	if mousePosition.distance_to(global_position) < 160 and Globals.MovementEnabled == true:
		Globals.SelectionMap.clear()
		var tile_pos = Globals.SelectionMap.world_to_map(mousePosition)
		Globals.SelectionMap.set_cellv(tile_pos, 0)
	else:
		Globals.SelectionMap.clear()
	
func _input(event):
	if event.is_action_pressed("zoom_in"):
		if $Camera2D.zoom.x < 2.5:
			$Camera2D.zoom += Vector2(.2,.2)
	elif event.is_action_pressed("zoom_out"):
		if $Camera2D.zoom.x > 0.25:
			$Camera2D.zoom -= Vector2(.2,.2)
	if event.is_action_pressed("pause_menu"):
		$Camera2D/UILayer/UIContainer/MenuBox.visible = not $Camera2D/UILayer/UIContainer/MenuBox.visible
		if $Camera2D/UILayer/UIContainer/MenuBox.visible == true:
			Globals.MovementEnabled = false
			StateBeforePause = Globals.CurrentGameState
		else:
			Globals.MovementEnabled = true
	if event.is_action_pressed("developer_mode"):
		if ProjectSettings.get_setting("debug/settings/development/developer_mode") == true:
			$Camera2D/UILayer/UIContainer/DevModeMenu.show()
	if event.is_action_pressed("sprint"):
		sprinting = true
	if event.is_action_released("sprint"):
		sprinting = false
	if event.is_action_pressed("layer_up"):
		if Globals.BuildTarget < 2:
			Globals.BuildTarget += 1
	if event.is_action_pressed("layer_down"):
		if Globals.BuildTarget > 0:
			Globals.BuildTarget -= 1
	for i in range(0,10):
		if event.is_action_pressed("Block" + str(i)):
			_assign_target_block(i)
			selected_block = i
			Globals.Player.Equipped[0] = i
	if event is InputEventMouseMotion:
		selection()
	


func _on_Return_pressed():
	Globals.MovementEnabled = not Globals.MovementEnabled
	$Camera2D/UILayer/UIContainer/MenuBox.visible = not $Camera2D/UILayer/UIContainer/MenuBox.visible


func _on_Save_pressed():
	yield(get_tree().create_timer(0.001), "timeout")
	Globals.Player.Position = global_position
	Globals.Player.Map = Globals.CurrentLayer
	SaveLoad.SaveGame(Globals.SaveMetadata.Name)
	Globals.MovementEnabled = not Globals.MovementEnabled
	$Camera2D/UILayer/UIContainer/MenuBox.visible = not $Camera2D/UILayer/UIContainer/MenuBox.visible


func _on_Exit_pressed():
	Globals.LightReferences.Surface = []
	Globals.LightReferences.Cave = []
	Globals.LightPlacements.Surface = []
	Globals.LightPlacements.Cave = []
	Globals.Maps.Surface.Layers.S0.position = Vector2(0,0)
	Globals.Maps.Surface.Layers.U0.position = Vector2(0,0)
	var _new_scene = get_tree().change_scene("res://MenuRoot.tscn")


func _on_Settings_pressed():
	if Globals.SettingsOpen == false:
		Globals.SettingsOpen = true
		$Camera2D/UILayer/UIContainer.add_child(load("res://UI/SettingsMenu.tscn").instance())


func _on_FootstepTimer_timeout():
	if RequestFootstep == true:
		RequestFootstep = false
		doFootstep()
