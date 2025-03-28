extends Node2D

var type
var category
var enemy_array = []
var built = false
var enemy
var readied = true
var enemy_offset = 0
var wave_number = 0


func _ready():
	if built:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.tower_data[type]["range"]

func _physics_process(delta):
	if enemy_array.size() != 0 and built:
		select_enemy()
		if not get_node("AnimationPlayer").is_playing():
			turn()
		if readied:
				fire()
	else:
		enemy = null

func turn():
	get_node("Turret").look_at(enemy.global_position)

func select_enemy():
	var enemy_progress_array = []
	for i in enemy_array:
		enemy_progress_array.append(i.progress)
	var max_offset = enemy_progress_array.max()
	var enemy_index = enemy_progress_array.find(max_offset)
	enemy = enemy_array[enemy_index]
		

func fire():
	readied = false
	if category == "projectile":
		fire_gun()
	elif category == "missile":
		fire_missile()
	enemy.on_hit(GameData.tower_data[type]["damage"])
	await get_tree().create_timer(GameData.tower_data[type]["rof"]).timeout
	readied = true

func fire_gun():
	get_node("AnimationPlayer").play("fire")
	$AudioStreamPlayer.play()
	

func fire_missile():
	pass

func _on_range_body_entered(body: Node2D):
	enemy_array.append(body.get_parent())


func _on_range_body_exited(body: Node2D):
	enemy_array.erase(body.get_parent())
