extends Node2D

signal game_finished(result)

var map_node

var build_mode = false
var build_valid = false
var build_tile
var build_location
var build_type

var current_wave = 0
var wave_tracker = 0
var enemies_in_wave = 0

var base_health = 100
var wave_over = false
var dmg_in_round = 0
var money = 150
var coords

var crab_moved
var crab_position
var camera_position

func _ready():
	map_node = get_node("Map1")
	crab_position = get_node("Map1/crab").global_transform.origin
	camera_position = get_node("Camera2D").global_transform.origin
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.pressed.connect(initiate_build_mode.bind(i.name))
	# fix num_placed not resetting on game over bug
	GameData.tower_data["GunT1"]["num_placed"] = 0
	GameData.tower_data["Gun2T1"]["num_placed"] = 0
	GameData.tower_data["Gun3T1"]["num_placed"] = 0
	GameData.tower_data["Gun4T1"]["num_placed"] = 0
	GameData.tower_data["Gun5T1"]["num_placed"] = 0
##
## Building Turrets
##

func _process(delta):
	get_node("UI/HUD/InfoBar/H/Money").text = str(money)
	
	coords = map_node.get_node("TowerExclusion").local_to_map(get_global_mouse_position())
	
	get_node("UI/HUD/InfoBar/H/coords").text = str(current_wave)
	
	if enemies_in_wave <= 0 && current_wave != 0 && wave_over == false:
		print("wave ended")
		wave_end()
		
	if build_mode:
		update_tower_preview()

func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode == true:
		verify_and_build()
		cancel_build_mode()

func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
	build_type  = tower_type + "T1"
	build_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())

func update_tower_preview():
	var mouse_position = get_local_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").local_to_map(mouse_position)
	var title_position = map_node.get_node("TowerExclusion").map_to_local(current_tile)
	if map_node.get_node("TowerExclusion").get_cell_source_id(current_tile) == -1:
		var location = 256*current_wave
		if location < 257:
			location = 0
		get_node("UI").update_tower_preview(title_position-Vector2(location,0), "adff4545")
		build_valid = true 
		build_location = title_position
		build_tile = current_tile
	
	else:
		var location = 256*current_wave
		if location < 257:
			location = 0
		get_node("UI").update_tower_preview(title_position-Vector2(location,0), "ad54ff3c")
		build_valid = false

func cancel_build_mode():
	build_mode = false 
	build_valid = false 
	get_node("UI/TowerPreview").free()

func verify_and_build():
	var base_cost = GameData.tower_data[build_type]["cost"]
	var type_count = GameData.tower_data[build_type]["num_placed"]
	var cur_cost = base_cost + ((base_cost/2) * type_count)
	print("costs ", cur_cost)
	if build_valid && money >= cur_cost:
		var new_tower = load("res://scenes/turrets/" + build_type + ".tscn").instantiate()
		new_tower.position = build_location
		new_tower.built = true
		new_tower.type = build_type
		new_tower.category = GameData.tower_data[build_type]["category"]
		map_node.get_node("Turrets").add_child(new_tower, true)
		map_node.get_node("TowerExclusion").set_cell(build_tile, 0, Vector2(1, 0))
		money -= cur_cost
		# increment num_placed for that turret type and update the price UI
		GameData.tower_data[build_type]["num_placed"] += 1
		type_count = GameData.tower_data[build_type]["num_placed"]
		print("You have placed " + str(type_count) + " of that kind of turret")
		var next_cost = base_cost + ((base_cost/2) * type_count)
		get_node("UI/HUD/BuildBar/Gun" + GameData.tower_data[build_type]["label"] + "/Label").text = str(next_cost)
		$TurretPlace.play()


##
## Wave Functions
##

func start_next_wave():
	var wave_data = retrieve_wave_data()
	await get_tree().create_timer(0.5).timeout
	spawn_enemies(wave_data)
	
func retrieve_wave_data():
	var wave_data = [[],[],[],[],[]]
	for i in wave_data:
		randomize()
		var rand_enemy = randi() %100
		match(current_wave):
			0:
				if rand_enemy <= 49:
					i.assign(["SeaUrchin", 1.0]) #49%
				elif rand_enemy <= 99:
					i.assign(["Snake", 1.0]) #50%
				else:
					i.assign(["GoldUrchin", 1.0]) #1%
			1: 
				if rand_enemy <= 53:
					i.assign(["SeaUrchin", 1.0]) #53%
				elif rand_enemy <= 88:
					i.assign(["Snake", 1.0]) #35%
				elif rand_enemy <= 98:
					i.assign(["Lizard", 1.0]) #10%
				else:
					i.assign(["GoldUrchin", 1.0]) #2%
			2: 
				if rand_enemy <= 47:
					i.assign(["SeaUrchin", 1.0]) #47%
				elif rand_enemy <= 80:
					i.assign(["Snake", 1.0]) #33%
				elif rand_enemy <= 97:
					i.assign(["Lizard", 1.0]) #17%
				else:
					i.assign(["GoldUrchin", 1.0]) #3%
			3:
				if rand_enemy <= 67:
					i.assign(["Snake", 1.0]) #67%
				else:
					i.assign(["Spider", 1.0]) #33%
			7:
				if rand_enemy <= 63:
					i.assign(["SeaUrchin", 1.0]) #63%
				elif rand_enemy <= 96:
					i.assign(["Spider", 1.0]) #33%
				else:
					i.assign(["GoldUrchin", 1.0]) #4%
			_:
				if rand_enemy <= 36:
					i.assign(["SeaUrchin", 1.0]) #36%
				elif rand_enemy <= 69:
					i.assign(["Snake", 1.0]) #33%
				elif rand_enemy <= 79:
					i.assign(["Spider", 1.0]) #10%
				elif rand_enemy <= 96:
					i.assign(["Lizard", 1.0]) #17%
				else:
					i.assign(["GoldUrchin", 1.0]) #4%
			
	enemies_in_wave = wave_data.size() * (current_wave+1)
	if current_wave == 14:
		enemies_in_wave += 1 #add 1 for BossLizard
	print("there are " + str(enemies_in_wave) + " enemies")
	return wave_data

func spawn_enemies(wave_data):
	current_wave += 1
	print("We are on wave ", current_wave)
	for j in current_wave:
		for i in wave_data:
			randomize()
			#make 5 paths
			var rand_path = (randi() %5) + 1
			var new_enemy = load("res://scenes/enemies/"+i[0]+".tscn").instantiate()
			new_enemy.base_damage.connect(on_base_damage)
			new_enemy.enemy_died.connect(on_enemy_died)
			
			map_node.get_node("path" + str(rand_path)).add_child(new_enemy, true)
			await get_tree().create_timer(i[1]).timeout
	if current_wave == 15:
		var boss_path = 3
		var boss_enemy = load("res://scenes/enemies/BossLizard.tscn").instantiate()
		boss_enemy.base_damage.connect(on_base_damage)
		boss_enemy.enemy_died.connect(on_enemy_died)
		map_node.get_node("path" + str(boss_path)).add_child(boss_enemy, true)

func wave_end():
	if current_wave == 15:
		$UI.get_node("HUD/win").visible = true
		await get_tree().create_timer(3).timeout
		if base_health == 100:
			game_finished.emit("Perfect!")
		else:
			game_finished.emit("You Won!")
	wave_over = true
	$UI.get_node("HUD/GameControls/PausePlay").set_pressed(false) #sets play button to standard
	
	get_node("Map1/Crab/CharacterBody2D/Sprite2D").visible = false
	get_node("Map1/Crab/CharacterBody2D/AnimatedSprite2D").visible = true
	get_node("Map1/Crab/CharacterBody2D/AnimatedSprite2D").play()
	var crab_tween = get_node("Map1/Crab").create_tween()
	crab_position += Vector2(256,0)
	crab_tween.tween_property(get_node("Map1/Crab"), "position", crab_position, 2)
	#add tweening for movement
	#get_node("Map1/Crab").global_position += Vector2(256,0) #moves crab
	get_node("Map1/Crab/CharacterBody2D/Sprite2D").visible = true
	get_node("Map1/Crab/CharacterBody2D/AnimatedSprite2D").visible = false
	
	for i in 5:
		get_node("Map1/path" + str(i + 1)).global_position += Vector2(256,0) #moves paths
	if get_node("Map1/Crab").global_position.x >= 200:
		var camera_tween = get_node("Camera2D").create_tween()
		camera_position += Vector2(256,0)
		crab_tween.tween_property(get_node("Camera2D"), "position", camera_position, 2)
		#get_node("Camera2D").global_position += Vector2(256,0) #moves camera
		crab_moved = true
	dmg_in_round = 0
	#await get_tree().create_timer(3).timeout
	#$UI._on_pause_play_pressed()
	

##
## Enemy Functions
##

func on_enemy_died(hit):
	enemies_in_wave -= 1
	if hit == false:
		#if i can get the enemy type here, i want to do money += enemytype.payout
		#that way each enemy can give a different amount of money, and we can implement the golden urchin
		money += 15

func on_base_damage(damage):
	base_health -= damage
	dmg_in_round += damage
	if base_health <= 0:
		game_finished.emit("You Lost...")
	else:
		$UI.update_health_bar(base_health)
		
