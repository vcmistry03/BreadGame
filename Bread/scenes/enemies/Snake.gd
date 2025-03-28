extends PathFollow2D


signal base_damage(damage)
signal enemy_died

var speed = 75
var hp = 200
var dead = false
var payout = 20

@onready var health_bar = get_node("HealthBar")
@onready var impact_area = get_node("Impact")
var projectile_impact = preload("res://scenes/supportScenes/projectile_impact.tscn")

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	get_node("HealthBar").set_as_top_level(true) #disabled because health bars were not working
	get_node("CharacterBody2D/AnimatedSprite2D").play()

func _physics_process(delta):
	if progress_ratio == 1.0:
		emit_signal("base_damage", 15)
		enemy_died.emit(true)
		queue_free()
	move(delta)

func move(delta):
	set_progress(get_progress() + speed * delta)
	health_bar.set_position(global_position + Vector2(-30, -40))
		
	
func on_hit(damage):
	impact()
	hp -= damage
	health_bar.value = hp
	if hp <= 0 && dead == false:
		set_progress(get_progress())
		dead = true
		on_destroy()

func impact():
	randomize()
	var x_pos = randi() %100
	var y_pos = randi() %16
	var impact_location = Vector2(x_pos, y_pos)
	var new_impact = projectile_impact.instantiate()
	new_impact.position = impact_location
	impact_area.add_child(new_impact)

func on_destroy():
	get_node("CharacterBody2D").queue_free()
	get_node("HealthBar").visible = false
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.5).timeout
	enemy_died.emit(false)
	self.queue_free()
