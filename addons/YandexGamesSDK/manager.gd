tool
extends EditorPlugin

const _print:String = "Addon:YandexGamesSDK, manager.gd"

func _enter_tree():
	print("%s, _enter_tree() add_autoload_singleton('YandexGames')"%[_print])
	add_autoload_singleton("YandexGames", "res://addons/YandexGamesSDK/YandexGames.gd")


func _exit_tree():
	print("%s, _exit_tree() remove_autoload_singleton('YandexGames')"%[_print])
	remove_autoload_singleton("YandexGames")
