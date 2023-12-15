extends Control

# Demo scene YandexGamesSDK
# Contains simple code for using the addon
# Contains comments for understanding
# Contact of the addon author for communication https://t.me/Alexey_Pe

# (!) For advertising check: on_showFullscreenAdv, on_showRewardedVideo, showFullscreenAdv, showRewardedVideo

# (!) For purchases check: purchase, getPurchases, on_purchase_then, on_purchase_catch, on_getPurchases

export var score:int = 0
export var money:int = 1
export var path_score_label:NodePath
export var path_money_label:NodePath

func _ready():
	get_node(path_score_label).text = "Score: %s"%[score]
	get_node(path_money_label).text = "Money: %s"%[money]
	# Called after the SDK is initialized. It is called before initializing player, payments, leaderboard
	YandexGames.connect("on_initGame", self, "on_initGame") 
	# Called after YandexGames.showFullscreenAdv(ad_name:String)
	YandexGames.connect("on_showFullscreenAdv", self, "on_showFullscreenAdv")
	# Called after YandexGames.showRewardedVideo(ad_name:String)
	YandexGames.connect("on_showRewardedVideo", self, "on_showRewardedVideo")
	# Called after YandexGames.purchase(id:String), after the window closes when the purchase is made
	# (!) IMPORTANT! If the window is not closed, there will be no event (this is how Yandex works)
	YandexGames.connect("on_purchase_then", self, "on_purchase_then")
	# Called after YandexGames.purchase(id:String), if the purchase is canceled or something else
	YandexGames.connect("on_purchase_catch", self, "on_purchase_catch")
	# Called after YandexGames.getPurchases()
	# (!) IMPORTANT! This is a very important feature for games with purchases, you will not pass moderation without it
	YandexGames.connect("on_getPurchases", self, "on_getPurchases")

# purchases: catch Null / then Array [YandexGames.Purchase]
# How I work with this function: when the game starts, I check for purchases, if there is a purchase, I complete it
# (!) In this demo I did not call this function at startup
func on_getPurchases(purchases):
	print("demo on_getPurchases(purchases:%s)"%[purchases])
	for purchase in purchases:
		match purchase.product_id:
			"id which you specified in the console": pass
			"1":
				money += 10
				# check the comment on_purchase_then()
				purchase.consume()

func on_purchase_catch(product_id:String):
	print("demo on_purchase_catch product_id ", product_id)

func on_purchase_then(purchase:YandexGames.Purchase):
	print("demo on_purchase_then(purchase:%s)"%[purchase])
	match purchase.product_id:
		"id which you specified in the console": pass
		"1": 
			money += 10
			# purchase.consume() - delete a purchase from the getPurchases array
			# What is it - look at the attached video in the addon documentation
			# In short, when a player buys, he must close the window to call on_purchase_then
			# Moderators make a purchase without closing the window and refresh the page, which is why on_purchase_then is not called
			purchase.consume()

func on_initGame(): 
	print("demo on_initGame()")
#	YandexGames.getPlayer(false)
#	Usually you will want to call ready() (without _) when you load the player data using getData()
#	I called this in on_initGame to simplify the demo
	YandexGames.ready() 

func on_showRewardedVideo(success:bool, ad_name:String):
	print("on_showRewardedVideo(success:%s, ad_name:%s)"%[success, ad_name])
	match ad_name:
		"variant 1": pass
		"variant 2": pass
		"variant 3": pass
		"variant ...": pass

func on_showFullscreenAdv(success:bool, ad_name:String):
	print("demo on_showFullscreenAdv(success:%s)"%[success])
	match ad_name:
		"variant 1": pass
		"variant 2": pass
		"variant 3": pass
		"variant ...": pass

func _on_Button_Score_pressed():
	score += 1
	get_node(path_score_label).text = "Score: %s"%[score]

func _on_Button_showFullscreenAdv_pressed():
	YandexGames.showFullscreenAdv("test_adv")

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
	# by default it is called in YandexGanes._ready()
	YandexGames.getPayments()

func _on_Button_purchase_pressed():
	# Before calling the function, make sure that getPayments was called, by default it is called in YandexGanes._ready()
	YandexGames.purchase("1")

func _on_Button_getPurchases_pressed():
	# Before calling the function, make sure that getPayments was called, by default it is called in YandexGanes._ready()
	YandexGames.getPurchases()

func _on_Button_getLeaderboards_pressed():
	# by default it is called in YandexGanes._ready()
	YandexGames.getLeaderboards()

func _on_Button_setLeaderboardScore_pressed():
	# Before calling the function, make sure that getLeaderboards was called, by default it is called in YandexGanes._ready()
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
	# Before calling the function, make sure that getLeaderboards was called, by default it is called in YandexGanes._ready()
	YandexGames.getLeaderboardDescription("test")

func _on_Button_getLeaderboardPlayerEntry_pressed():
	# Before calling the function, make sure that getLeaderboards was called, by default it is called in YandexGanes._ready()
	YandexGames.getLeaderboardPlayerEntry("test")

func _on_Button_getLeaderboardEntries_pressed():
	# Before calling the function, make sure that getLeaderboards was called, by default it is called in YandexGanes._ready()
	YandexGames.getLeaderboardEntries("test")

func _on_Button_getFlags_pressed():
	var flags = yield(YandexGames.getFlags_yield(), "completed")
	if flags is Dictionary: pass # you code here 
	print("_on_Button_getFlags_pressed(), flags:", flags)


func _on_Button_getFlags2_pressed():
	var flags = yield(YandexGames.getFlags_yield([
		{"name":"var_1", "value":"20"},
		{"name":"var_2", "value":"33"},
	]), "completed")
	if flags is Dictionary: pass # you code here
	print("_on_Button_getFlags2_pressed(), flags:", flags)
