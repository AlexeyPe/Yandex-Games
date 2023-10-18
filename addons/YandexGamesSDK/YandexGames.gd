extends Node
# autoload_singleton

signal on_initGame()
signal on_showFullscreenAdv(success) # success:bool
signal on_showRewardedVideo(success, ad_name) # success:bool, ad_name:String 
signal on_getData(data) # data:Dictionary
signal on_getPlayer(player) # player:JavaScriptObject
signal on_purchase_then(product_id) # product_id:String ("int")
signal on_purchase_catch(args)  
signal on_getPurchases_then(purchases) # purchases:Array [productID:String]
signal on_getPurchases_catch()
signal on_getLeaderboards()
signal on_isAvailableMethod(aviable, method_name) # aviable:bool, method_name:String
signal on_canReview(canReview) # canReview:bool
signal on_requestReview(requestReview) # requestReview:bool
signal on_canShowPrompt(canShowPrompt) # canShowPrompt:bool
signal on_showPrompt(accepted) # accepted:bool

const _print:String = "Addon:YandexGamesSDK, YandexGames.gd"
var _print_debug:bool = true

# Game start - initGame()
var js_callback_initGame = JavaScript.create_callback(self, "js_callback_initGame")
# Managing ads - showFullscreenAdv()
var js_callback_showFullscreenAdv_onClose = JavaScript.create_callback(self, "js_callback_showFullscreenAdv_onClose")
var js_callback_showFullscreenAdv_onError = JavaScript.create_callback(self, "js_callback_showFullscreenAdv_onError")
# Managing ads - showRewardedVideo()
var js_callback_showRewardedVideo_onClose = JavaScript.create_callback(self, "js_callback_showRewardedVideo_onClose")
var js_callback_showRewardedVideo_onError = JavaScript.create_callback(self, "js_callback_showRewardedVideo_onError")
var js_callback_showRewardedVideo_onRewarded = JavaScript.create_callback(self, "js_callback_showRewardedVideo_onRewarded")
# Player details - getPlayer()
var js_callback_getPlayer = JavaScript.create_callback(self, "js_callback_getPlayer")
# Player details - getData()
var js_callback_getData = JavaScript.create_callback(self, "js_callback_getData")
# In-game purchases - getPayments()
var js_callback_getPayments_then = JavaScript.create_callback(self, "js_callback_getPayments_then")
var js_callback_getPayments_catch = JavaScript.create_callback(self, "js_callback_getPayments_catch")
# In-game purchases - purchase()
var js_callback_purchases_then = JavaScript.create_callback(self, "js_callback_purchases_then")
var js_callback_purchases_catch = JavaScript.create_callback(self, "js_callback_purchases_catch")
# In-game purchases - getPurchases()
var js_callback_getPurchases_then = JavaScript.create_callback(self, "js_callback_getPurchases_then")
var js_callback_getPurchases_catch = JavaScript.create_callback(self, "js_callback_getPurchases_catch")
# Leaderboards - getLeaderboards()
var js_callback_getLeaderboards = JavaScript.create_callback(self, "js_callback_getLeaderboards")
# Game rating
var js_callback_canReview = JavaScript.create_callback(self, "js_callback_canReview")
var js_callback_requestReview = JavaScript.create_callback(self, "js_callback_requestReview")
# Desktop shortcut
var js_callback_canShowPrompt = JavaScript.create_callback(self, "js_callback_canShowPrompt")
var js_callback_showPrompt = JavaScript.create_callback(self, "js_callback_showPrompt")

var js_callback_isAvailableMethod = JavaScript.create_callback(self, "js_callback_isAvailableMethod")

var is_initGame:bool = false
var js_ysdk:JavaScriptObject
var js_ysdk_player
var js_ysdk_payments
var js_ysdk_lb
var current_rewarded_ad_name = ""

var _saved_data_json:String = "" # DO NOT USE! PRIVATE VARIABLE
var _get_data:Dictionary # DO NOT USE! PRIVATE VARIABLE
var _current_purchase_is_consume:bool # DO NOT USE! PRIVATE VARIABLE
var _current_purchase_produc_id:String = "" # DO NOT USE! PRIVATE VARIABLE
var _current_isAvailableMethod:String = "" # DO NOT USE! PRIVATE VARIABLE
var _current_isAvailableMethod_result:bool # DO NOT USE! PRIVATE VARIABLE
var _current_canReview:bool # DO NOT USE! PRIVATE VARIABLE
var _current_canShowPrompt:bool # DO NOT USE! PRIVATE VARIABLE

func _ready():
	if OS.has_feature("HTML5"):
		print("%s, _ready() OS.has_feature('HTML5') - addon works"%[_print])
		initGame()
		yield(self, "on_initGame")
		getPlayer(false)
		getPayments()
		getLeaderboards()
	else:
		print("%s, _ready() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])

# https://yandex.ru/dev/games/doc/en/sdk/sdk-gameready
# Game start - initGame()
# auto-call from _ready()
func initGame():
	if _print_debug: print("%s initGame()"%[_print])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, initGame() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return
	var js_window:JavaScriptObject = JavaScript.get_interface("window")
	var js_console:JavaScriptObject = JavaScript.get_interface("console")
#	var js_dictionary:JavaScriptObject = JavaScript.create_object("object")
	js_window.YaGames.init().then(js_callback_initGame)

func js_callback_initGame(args:Array):
	if _print_debug: print("%s js_callback_initGame(args:%s)"%[_print, args])
	js_ysdk = args[0]
	js_ysdk.features.LoadingAPI.ready()
	is_initGame = true
	emit_signal("on_initGame")
	if _print_debug: print("%s js_callback_initGame(args:%s) is_initGame = true"%[_print, args])

# https://yandex.ru/dev/games/doc/en/sdk/sdk-adv
# Managing ads
# Managing ads - showFullscreenAdv()
func showFullscreenAdv():
	if _print_debug: print("%s showFullscreenAdv()"%[_print])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, showFullscreenAdv() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return
	if !is_initGame: return
	var js_dictionary:JavaScriptObject = JavaScript.create_object("Object")
	var js_dictionary_2:JavaScriptObject = JavaScript.create_object("Object")
	var js_console:JavaScriptObject = JavaScript.get_interface("console")
	js_dictionary_2["onClose"] = js_callback_showFullscreenAdv_onClose
	js_dictionary_2["onError"] = js_callback_showFullscreenAdv_onError
	js_dictionary["callbacks"] = js_dictionary_2
	if _print_debug: js_console.log(js_dictionary)
	js_ysdk.adv.showFullscreenAdv(js_dictionary)

func js_callback_showFullscreenAdv_onClose(args:Array):
	if _print_debug: print("%s js_callback_showFullscreenAdv_onClose(args:%s)"%[_print, args])
	var wasShown:bool = args[0]
	emit_signal("on_showFullscreenAdv", wasShown)
func js_callback_showFullscreenAdv_onError(args:Array):
	if _print_debug: print("%s js_callback_showFullscreenAdv_onError(args:%s)"%[_print, args])
	emit_signal("on_showFullscreenAdv", false)

# Managing ads - showRewardedVideo()
func showRewardedVideo(new_current_rewarded_ad_name:String):
	if _print_debug: print("%s showRewardedVideo()"%[_print])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, showRewardedVideo() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return
	if !is_initGame: return
	
	current_rewarded_ad_name = new_current_rewarded_ad_name
	var js_dictionary:JavaScriptObject = JavaScript.create_object("Object")
	var js_dictionary_2:JavaScriptObject = JavaScript.create_object("Object")
	var js_console:JavaScriptObject = JavaScript.get_interface("console")
	js_dictionary_2["onClose"] = js_callback_showRewardedVideo_onClose
	js_dictionary_2["onError"] = js_callback_showRewardedVideo_onError
	js_dictionary_2["onRewarded"] = js_callback_showRewardedVideo_onRewarded
	js_dictionary["callbacks"] = js_dictionary_2
	if _print_debug: js_console.log(js_dictionary)
	js_ysdk.adv.showRewardedVideo(js_dictionary)

func js_callback_showRewardedVideo_onClose(args:Array):
	if _print_debug: print("%s js_callback_showRewardedVideo_onClose(args:%s)"%[_print, args])
	var ad_name = current_rewarded_ad_name
	current_rewarded_ad_name = ""
	emit_signal("on_showRewardedVideo", true, ad_name)
func js_callback_showRewardedVideo_onError(args:Array):
	if _print_debug: print("%s js_callback_showRewardedVideo_onError(args:%s)"%[_print, args])
	var ad_name = current_rewarded_ad_name
	current_rewarded_ad_name = ""
	emit_signal("on_showRewardedVideo", false, ad_name)
func js_callback_showRewardedVideo_onRewarded(args:Array):
	if _print_debug: print("%s js_callback_showRewardedVideo_onRewarded(args:%s)"%[_print, args])
	var ad_name = current_rewarded_ad_name
	current_rewarded_ad_name = ""
	emit_signal("on_showRewardedVideo", true, ad_name)

# https://yandex.ru/dev/games/doc/en/sdk/sdk-player#auth
# Player details
# Player details - getPlayer()
func getPlayer(scopes:bool):
	if _print_debug: print("%s getPlayer(scopes:%s)"%[_print, scopes])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, getPlayer() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return
	if !is_initGame: return
	var js_dictionary:JavaScriptObject = JavaScript.create_object("Object")
	js_dictionary["scopes"] = scopes
	js_ysdk.getPlayer(js_dictionary).then(js_callback_getPlayer)

func getPlayer_yield(scopes:bool):
	getPlayer(scopes)
	yield(self, "on_getPlayer")

func js_callback_getPlayer(args:Array):
	if _print_debug: 
		print("%s js_callback_getPlayer(args:%s)"%[_print, args])
		var js_console = JavaScript.get_interface("console")
		js_console.log(args[0])
	js_ysdk_player = args[0]
	emit_signal("on_getPlayer", js_ysdk_player)

# https://yandex.ru/dev/games/doc/en/sdk/sdk-player#ingame-data
# Player details
# Player details setData()
func setData(data:Dictionary):
	if _print_debug: print("%s setData(data:%s)"%[_print, data])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, setData() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return
	if !is_initGame: return
	if js_ysdk_player == null: 
		if _print_debug: print("%s setData(data) js_ysdk_player == null"%[_print])
		return
	var json_data:String = to_json(data)
	if _saved_data_json == json_data: return
	else: _saved_data_json = json_data
	var js_dictionary:JavaScriptObject = JavaScript.create_object("Object")
	var js_console = JavaScript.get_interface("console")
	js_dictionary["json_data"] = json_data
	js_ysdk_player.setData(js_dictionary).then(js_console.log("YandexGamesSDK setData success"))

# Player details - getData()
func getData():
	if _print_debug: print("%s getData()"%[_print])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, getData() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return
	if !is_initGame: return
	if js_ysdk_player == null: 
		if _print_debug: print("%s getData(data) js_ysdk_player == null"%[_print])
		return
	js_ysdk_player.getData().then(js_callback_getData)
	return

func getData_yield() -> Dictionary:
	var result:Dictionary
	getData()
	yield(self, "on_getData")
	result = _get_data
	_get_data = {}
	return result

func js_callback_getData(args:Array):
	if _print_debug: print("js_callback_getData(args:%s)"%[args])
	var js_console = JavaScript.get_interface("console")
	var data:Dictionary = JSON.parse(args[0]["json_data"]).result
	if _print_debug: print("js_callback_getData data: ", data)
	_get_data = data
	emit_signal("on_getData", data)

# https://yandex.ru/dev/games/doc/en/sdk/sdk-purchases#install
# In-game purchases
# In-game purchases - getPayments()
func getPayments():
	if _print_debug: print("%s getPayments()"%[_print])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, getPayments() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return
	if !is_initGame: return
	var js_dictionary:JavaScriptObject = JavaScript.create_object("Object")
	js_dictionary["signed"] = true
	js_ysdk.getPayments(js_dictionary).then(js_callback_getPayments_then).catch(js_callback_getPayments_catch)

func js_callback_getPayments_then(args:Array):
	if _print_debug: 
		print("js_callback_getPayments_then args: ", args)
		var js_console:JavaScriptObject = JavaScript.get_interface("console")
		js_console.log(args[0])
	js_ysdk_payments = args[0]

func js_callback_getPayments_catch(args:Array):
	if _print_debug: 
		print("js_callback_getPayments_catch args: ", args)
		var js_console:JavaScriptObject = JavaScript.get_interface("console")
		js_console.log(args[0])

# https://yandex.ru/dev/games/doc/en/sdk/sdk-purchases#payments-purchase
# In-game purchases - purchase()
func purchase(id:String, consume_purchase:bool):
	if _print_debug: print("%s purchase(id:%s)"%[_print, id])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, purchase(id:%s) !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print, id])
		return
	if !is_initGame: return
	if js_ysdk_payments == null:
		if _print_debug: print("%s purchase(id:%s) js_ysdk_payments == null"%[_print, id])
		return
	var js_dictionary:JavaScriptObject = JavaScript.create_object("Object")
#	var js_console = JavaScript.get_interface("console")
	js_dictionary["id"] = id
	_current_purchase_is_consume = consume_purchase
	_current_purchase_produc_id = id
	js_ysdk_payments.purchase(js_dictionary).then(js_callback_purchases_then).catch(js_callback_purchases_catch)

func js_callback_purchases_then(args:Array):
	if _print_debug: 
		print("js_callback_purchases_then args: ", args)
		var js_console:JavaScriptObject = JavaScript.get_interface("console")
		js_console.log(args[0])
	var purchase = args[0]
	var purchase_productID:String = purchase.productID
	if _current_purchase_is_consume:
		js_ysdk_payments.consumePurchase(purchase.purchaseToken)
	emit_signal("on_purchase_then", purchase_productID)

func js_callback_purchases_catch(args:Array):
	if _print_debug: 
		print("js_callback_purchases_catch args: ", args)
		var js_console:JavaScriptObject = JavaScript.get_interface("console")
		js_console.log(args[0])
	var copy_current_purchase_produc_id = _current_purchase_produc_id
	_current_purchase_produc_id = ""
	emit_signal("on_purchase_catch", copy_current_purchase_produc_id)

func getPurchases():
	if _print_debug: print("%s getPurchases()"%[_print])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, getPurchases !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return
	if !is_initGame: return
	if js_ysdk_payments == null:
		if _print_debug: print("%s getPurchases js_ysdk_payments == null"%[_print])
		return
	js_ysdk_payments.getPurchases().then(js_callback_getPurchases_then).catch(js_callback_getPurchases_catch)

func js_callback_getPurchases_then(args:Array):
	if _print_debug:
		print("%s js_callback_getPurchases_then(args:%s)"%[_print, args])
		var js_console:JavaScriptObject = JavaScript.get_interface("console")
		js_console.log(args[0])
		js_console.log(args[0].length)
		js_console.log(args[0][0])
	var result:Array = []
	var arr_length = args[0].length
	for id in args[0].length:
		result.append(args[0][id].productID)
	emit_signal("on_getPurchases_then", result)

func js_callback_getPurchases_catch(args:Array):
	if _print_debug:
		print("%s js_callback_getPurchases_then(args:%s)"%[_print, args])
		var js_console:JavaScriptObject = JavaScript.get_interface("console")
		js_console.log(args[0])

# https://yandex.ru/dev/games/doc/en/sdk/sdk-leaderboard
# Leaderboards
# Leaderboards - getLeaderboards()
func getLeaderboards():
	if _print_debug: print("%s getLeaderboards()"%[_print])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, getLeaderboards() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return
	if !is_initGame: return
	js_ysdk_lb = js_ysdk.getLeaderboards().then(js_callback_getLeaderboards)

func js_callback_getLeaderboards(args:Array):
	if _print_debug: 
		print("%s js_callback_getLeaderboards(args:%s)"%[_print, args])
		var js_console:JavaScriptObject = JavaScript.get_interface("console")
		js_console.log(args[0])
	js_ysdk_lb = args[0]
	emit_signal("on_getLeaderboards")

# Leaderboards - New score - setLeaderboardScore()
func setLeaderboardScore_yield(leaderboardName:String, score:int):
	if _print_debug: print("%s setLeaderboardScore_yield()"%[_print])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, setLeaderboardScore_yield(leaderboardName:%s, score:%s) !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print, leaderboardName, score])
		return
	if !is_initGame: return
	if js_ysdk_lb == null:
		if _print_debug:
			print("%s setLeaderboardScore_yield(leaderboardName:%s, score:%s) js_ysdk_lb == null"%[_print, leaderboardName, score])
		return
	_current_isAvailableMethod = 'leaderboards.setLeaderboardScore'
	js_ysdk.isAvailableMethod('leaderboards.setLeaderboardScore').then(js_callback_isAvailableMethod)
	yield(self, "on_isAvailableMethod")
	if _current_isAvailableMethod_result == true:
		js_ysdk_lb.setLeaderboardScore(leaderboardName, score)
		if _print_debug:
			print("%s setLeaderboardScore_yield() js_ysdk_lb.setLeaderboardScore(leaderboardName:%s, score:%s) request"%[_print, leaderboardName, score])
	elif _print_debug:
		print("%s setLeaderboardScore_yield() setLeaderboardScore(leaderboardName:%s, score:%s) isAvailableMethod('leaderboards.setLeaderboardScore') == false"%[_print, leaderboardName, score])

func js_callback_isAvailableMethod(args:Array):
	if _print_debug: print("%s js_callback_isAvailableMethod(args:%s)"%[_print, args])
	_current_isAvailableMethod_result = args[0]
	emit_signal("on_isAvailableMethod", _current_isAvailableMethod_result, _current_isAvailableMethod)


# https://yandex.ru/dev/games/doc/en/sdk/sdk-review
# Game rating
# Game rating - canReview()
func canReview():
	if _print_debug: print("%s canReview()"%[_print])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, canReview() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return
	if !is_initGame: return
	js_ysdk.feedback.canReview().then(js_callback_canReview)

func js_callback_canReview(args:Array):
	if _print_debug: 
		print("%s js_callback_canReview(args:%s)"%[_print, args])
		var js_console:JavaScriptObject = JavaScript.get_interface("console")
		js_console.log(args[0])
	if args[0]["value"]:
		if _print_debug: 
			print("%s js_callback_canReview(args:%s) canReview == true"%[_print, args])
		_current_canReview = true
		emit_signal("on_canReview")
	else:
		if _print_debug: 
			print("%s js_callback_canReview(args:%s) canReview == false"%[_print, args])
			var js_console:JavaScriptObject = JavaScript.get_interface("console")
			js_console.log(args[0]["reason"])

# Game rating - requestReview()
func requestReview():
	if _print_debug: print("%s requestReview()"%[_print])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, requestReview() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return
	if !is_initGame: return
	canReview()
	yield(self, "on_canReview")
	if _current_canReview:
		js_ysdk.feedback.requestReview().then(js_callback_requestReview)
	elif _print_debug: print("%s requestReview() _current_canReview = false"%[_print])

func js_callback_requestReview(args:Array):
	if _print_debug: 
		print("%s js_callback_requestReview(args:%s)"%[_print, args])
		var js_console:JavaScriptObject = JavaScript.get_interface("console")
		js_console.log(args[0])
	emit_signal("on_requestReview", args[0])

# My cusom func
# return user lang - en/ru/tr/...
func getLang() -> String:
	var result:String
	if _print_debug: print("%s getLang()"%[_print])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, getLang() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return result
	if !is_initGame: return result
	if js_ysdk_player == null:
		if _print_debug: print("%s getLang() js_ysdk_player == null, result = null"%[_print])
		return result
	else:
		result = js_ysdk_player._personalInfo.lang
		if _print_debug: print("%s getLang() result: %s"%[_print, result])
	return result

# https://yandex.ru/dev/games/doc/en/sdk/sdk-shortcut
# Desktop shortcut
# Desktop shortcut - canShowPrompt()
func canShowPrompt():
	if _print_debug: print("%s canShowPrompt()"%[_print])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, canShowPrompt() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return
	if !is_initGame: return
	js_ysdk.shortcut.canShowPrompt().then(js_callback_canShowPrompt)

func js_callback_canShowPrompt(args:Array):
	if _print_debug: 
		print("%s js_callback_canShowPrompt(args:%s)"%[_print, args])
		var js_console:JavaScriptObject = JavaScript.get_interface("console")
		js_console.log(args[0].canShow)
	_current_canShowPrompt = args[0].canShow
	emit_signal("on_canShowPrompt", _current_canShowPrompt)

# Desktop shortcut - showPrompt()
func showPrompt():
	if _print_debug: print("%s showPrompt()"%[_print])
	if !OS.has_feature("HTML5"):
		if _print_debug: print("%s, showPrompt() !OS.has_feature('HTML5') - addon doesn't work, platform is not html"%[_print])
		return
	if !is_initGame: return
	canShowPrompt()
	yield(self, "on_canShowPrompt")
	if _current_canShowPrompt:
		js_ysdk.shortcut.showPrompt().then(js_callback_showPrompt)
		pass
	elif _print_debug: print("%s showPrompt() _current_canShowPrompt = false"%[_print])

func js_callback_showPrompt(args:Array):
	if _print_debug: 
		print("%s js_callback_showPrompt(args:%s)"%[_print, args])
		var js_console:JavaScriptObject = JavaScript.get_interface("console")
		js_console.log(args[0].outcome)
	emit_signal("on_showPrompt", args[0].outcome == 'accepted')
