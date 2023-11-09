extends Control

export var score:int = 0
export var money:int = 1
export var path_score_label:NodePath
export var path_money_label:NodePath

func _ready():
	get_node(path_score_label).text = "Score: %s"%[score]
	get_node(path_money_label).text = "Money: %s"%[money]
	YandexGames.connect("on_initGame", self, "on_initGame")
	YandexGames.connect("on_showFullscreenAdv", self, "on_showFullscreenAdv")
	YandexGames.connect("on_showRewardedVideo", self, "on_showRewardedVideo")
	YandexGames.connect("on_purchase_then", self, "on_purchase_then")
	YandexGames.connect("on_purchase_catch", self, "on_purchase_catch")
	YandexGames.connect("on_getPurchases_then", self, "on_getPurchases_then")

func on_getPurchases_then(arr_product_id:Array):
	print("demo on_getPurchases_then(arr_product_id:%s)"%[arr_product_id])

func on_purchase_catch(product_id:String):
	print("demo on_purchase_catch product_id ", product_id)

func on_purchase_then(product_id:String):
	print("demo on_purchase_then(product_id:%s)"%[product_id])
	if product_id == "1":
		money += 1
		get_node(path_money_label).text = "Money: %s"%[money]

func on_initGame(): 
	print("demo on_initGame()")
#	YandexGames.getPlayer(false)

func on_showRewardedVideo(success:bool, ad_name:String):
	print("on_showRewardedVideo(success:%s, ad_name:%s)"%[success, ad_name])

func on_showFullscreenAdv(success:bool):
	print("demo on_showFullscreenAdv(success:%s)"%[success])

func _on_Button_Score_pressed():
	score += 1
	get_node(path_score_label).text = "Score: %s"%[score]

func _on_Button_showFullscreenAdv_pressed():
	YandexGames.showFullscreenAdv()

func _on_Button_showRewardedVideo_pressed():
	YandexGames.showRewardedVideo("test")

func _on_Button_getPlayer_scopes_false_pressed():
	YandexGames.getPlayer(false)

func _on_Button_getPlayer_scopes_true_pressed():
	YandexGames.getPlayer(true)

func _on_Button_getPlayer_setData_pressed():
	YandexGames.setData({
		"score": score,
		"money": money,
	})

func _on_Button_getPlayer_getData_pressed():
	var data:Dictionary = yield(YandexGames.getData_yield(), "completed")
	if data.empty():
		print("_on_Button_getPlayer_getData_pressed getData_yield return data.empty()")
		return
	if data.has("score"): 
		score = data["score"]
		get_node(path_score_label).text = "Score: %s"%[score]
	if data.has("money"):
		money = data["money"]
		get_node(path_money_label).text = "Money: %s"%[money]

func _on_Button_getPlayer_getPayments_pressed():
	YandexGames.getPayments()

func _on_Button_purchase_pressed():
	# true = is consumed. Reusable purchase (not added to the list getPayments())
	YandexGames.purchase("1", true)
	# false = is not consumed. One-time purchase (added to the list getPayments())
#	YandexGames.purchase("1", false)

func _on_Button_getPurchases_pressed():
	YandexGames.getPurchases()

func _on_Button_getLeaderboards_pressed():
	YandexGames.getLeaderboards()

func _on_Button_setLeaderboardScore_pressed():
	YandexGames.setLeaderboardScore("test", score)

func _on_Button_canReview_pressed():
	YandexGames.canReview()

func _on_Button_requestReview_pressed():
	YandexGames.requestReview()

func _on_Button_getLang_pressed():
	YandexGames.getLang()

func _on_Button_canShowPrompt_pressed():
	YandexGames.canShowPrompt()

func _on_Button_showPrompt_pressed():
	YandexGames.showPrompt()

func _on_Button_getLeaderboardDescription_pressed():
	YandexGames.getLeaderboardDescription("test")

func _on_Button_getLeaderboardPlayerEntry_pressed():
	YandexGames.getLeaderboardPlayerEntry("test")

func _on_Button_getLeaderboardEntries_pressed():
	YandexGames.getLeaderboardEntries("test")

