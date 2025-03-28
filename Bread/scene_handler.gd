extends Node

var menu_state = "main_menu"
var win_loss = ""

func _ready():
	load_main_menu()
	
func load_main_menu():
	print("in main menu")
	get_node("MainMenu/M/VB/NewGame").connect("pressed", on_new_game_pressed)
	get_node("MainMenu/M/VB/Quit").connect("pressed", on_quit_pressed)
	if win_loss != "":
		get_node("MainMenu/GameOver").text = "Game Over"
		get_node("MainMenu/win_loss").text = str(win_loss)
	menu_state = "main_menu"

#func load_restart_menu():
	#print("in restart menu")
	#get_node("RestartMenu/win_loss").text = str(win_loss)
	#get_node("RestartMenu/M/VB/NewGame").connect("pressed", on_new_game_pressed)
	#get_node("RestartMenu/M/VB/Quit").connect("pressed", on_quit_pressed)
	#menu_state = "restart_menu"

func on_new_game_pressed():
	#if menu_state == "main_menu":
	$"MainMenu".queue_free()
	#else:
		#$"RestartMenu".queue_free()
	var game_scene: Node2D = load("res://scenes/mainScenes/GameScene.tscn").instantiate()
	game_scene.connect("game_finished", unload_game)
	call_deferred('add_child', game_scene)
	
func on_quit_pressed():
	get_tree().quit()

func unload_game(result):
	$GameScene.queue_free()
	var main_menu = load("res://scenes/uiScenes/main_menu.tscn").instantiate()
	win_loss = result
	add_child(main_menu)
	load_main_menu()
