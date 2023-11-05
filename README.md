# Yandex-Games
* Yandex Games SDK for Godot 3.5
* Godot 4 - If JavaScript and JavaScriptObject work the same way as in 3, then try it, you will also need to solve the issue with the header files of version 4

__My Telegram [@Alexey_Pe](https://t.me/Alexey_Pe)__

### Demo
![Godot_v3 5 2-stable_win64_9DEAaFyNrE](https://github.com/AlexeyPe/Yandex-Games/assets/70694988/375a5ada-0400-4c00-b95d-00fae30b7520)


### How Install
1. Install and enable the addon in the settings
2. Add `<script src="https://yandex.ru/games/sdk/v2"></script>` to Head Include (Project -> Export -> HTML)

### How use
* When the game starts, the addon automatically calls `initGame()`, `getPlayer(false)`, `getPayments()`, `getLeaderboards()`
* For more understanding, you can read [YandexGames.gd](addons/YandexGamesSDK/YandexGames.gd) and sdk documentation
#### Ads
* After the release, commercial advertising will work after a few hours. Just wait
``` gdscript
# Interstitial Ads, signal on_showFullscreenAdv(wasShown:bool)
YandexGames.showFullscreenAdv()
YandexGames.connect("on_showFullscreenAdv", self, "on_showFullscreenAdv")

# Rewarded Ads, signal on_showRewardedVideo(success:bool, current_rewarded_ad_name:String)
YandexGames.showRewardedVideo(new_current_rewarded_ad_name) 
YandexGames.connect("on_showRewardedVideo", self, "on_showRewardedVideo")
# example use
# new_current_rewarded_ad_name - this argument is not passed to yandex. I added it for signal and match
func on_showRewardedVideo(success:bool, ad_name:String):
  if not success:
    print("on_showRewardedVideo(success:%s, ad_name:%s)"%[false, ad_name])
    return
  match ad_name:
    "increase mine production": pass
    "something else": pass
```
#### Save/Load
* authorization - getPlayer(bool) is called by default in YandexGames._ready() - getPlayer(false)
* getPlayer(true) - to get the player's avatar image, the authorization window will be shown. getPlayer(false) - will not show windows
<img src="https://github.com/AlexeyPe/Yandex-Games/assets/70694988/70b21fec-32b4-434d-b47f-5245911958bf" width="250" />
<img src="https://github.com/AlexeyPe/Yandex-Games/assets/70694988/51ccfecf-be80-4d66-966b-44a9cb54f011" width="250" />

``` gdscript
# setData(data:Dictionary) to save data on yandex, no signal
YandexGames.setData(data)

# getData() and getData_yield()->Dictionary, signal on_getData(data:Dictionary)
var load_save:Dictionary = yield(YandexGames.getData_yield(), "completed")
# choose the use case that you like best
getData()
YandexGames.connect("on_getData", self, "on_getData")
```
##### Save/Load - example
``` gdscript
# Create DataManager.gd signleton

var can_load_data:bool = false

func _ready():
  YandexGames.connect("on_getPlayer", self, "on_getPlayer")

func on_getPlayer(player): 
  can_load_data = true
  loadData()

# Example call: a player has entered the game and does not have data, you need to get the data
# loadData is a yield function, when you call it you want to write it like this: yield(DataManager.loadData_yield(self), "completed")
# Why do you need to write yield: this means that you stop executing the code until the Yandex server sends you the data
func loadData_yield(from:Object):
  if YandexGames.js_ysdk_player == null: print("DataManager.gd loadData(from:%s) js_ysdk_player == null"%[from]); return
  if can_load_data: print("DataManager.gd loadData(from:%s)"%[from]); return
  else: print("DataManager.gd loadData(from:%s) !can_load_data"%[from])
  var load_save:Dictionary = yield(YandexGames.getData_yield(), "completed")
  # here you use the downloaded data from load_save
  pass

# Example call: a player upgraded an item by spending currency, you want to save it
func saveData(from:Object):
  print("DataManager.gd saveData(from:%s)"%[from])
  if YandexGames.js_ysdk_player == null: print("DataManager.gd saveData(from:%s) js_ysdk_player == null"%[from]); return
  # setData - overwrites a variable on the yandex server
  # Create a dictionary in which you write down all the data that you need to save
  # The dictionary will be converted to json, check that your data does not contain classes, you need to convert classes into data that can be stored in json
  var data:Dictionary = {"gold":100, "inventory": "your_value", "etc":123}
  YandexGames.setData(data)
  pass
```
#### Purchases
For purchases, you need to create purchases in the draft and add your login - this is enough for tests. (when buying, it will be written that it is a test)

For the release, you will need to write to Yandex to enable purchases
``` gdscript
# In-game purchases, purchase(id:String, consume_purchase:bool)
# signals on_purchase_then(product_id:String) and on_purchase_catch(product_id:String)
# true = is consumed. Reusable purchase (not added to the list getPayments())
# false = is not consumed. One-time purchase (added to the list getPayments())
YandexGames.purchase("id", true)
YandexGames.connect("on_purchase_then", self, "on_purchase_then")
YandexGames.connect("on_purchase_catch", self, "on_purchase_catch")

# getPurchases(), signals on_getPurchases_then(purchases:Array[productID:String]),on_getPurchases_catch()
YandexGames.getPurchases()
YandexGames.connect("on_getPurchases_then", self, "on_getPurchases_then")
YandexGames.connect("on_getPurchases_catch", self, "on_getPurchases_catch")
```
#### Leaderboards
For a leaderboard, you should have a leaderboard (or several) created in your draft.

You can also select the main leaderboard in the settings ('default'(bool) in the response)

[Link to the leaderboard documentation](https://yandex.ru/dev/games/doc/en/sdk/sdk-leaderboard#response-format2)
``` gdscript
# setLeaderboardScore(Leaderboard_name:String, score:int) 
YandexGames.setLeaderboardScore("Leaderboard_name", 1000)

# getLeaderboardDescription(leaderboardName:String), signal on_getLeaderboardDescription(description:Dictionary)
# description:{appID:String, default:bool, invert_sort_order:bool, decimal_offset:int, type:String, name:String, title:{en:String, ru:String ..}}
YandexGames.getLeaderboardDescription("Leaderboard_name")

# getLeaderboardPlayerEntry(leaderboardName:String)
# signals on_getLeaderboardPlayerEntry_then(response:Dictionary), on_getLeaderboardPlayerEntry_catch(err_code:String)
# response { score:int, extraData:String, rank:int, getAvatarSrc:JavaScriptObject, getAvatarSrcSet:JavaScriptObject, lang:String, publicName:String, uniqueID:String, scopePermissions_avatar:String, scopePermissions_public_name:String, formattedScore:String}
# response, getAvatarSrc and getAvatarSrcSet - is JavaScriptObject(Function maybe?) return String. I didn't understand how to use it
YandexGames.getLeaderboardPlayerEntry("Leaderboard_name")
YandexGames.connect("on_getLeaderboardPlayerEntry_then", self, "on_getLeaderboardPlayerEntry_then")
YandexGames.connect("on_getLeaderboardPlayerEntry_catch", self, "on_getLeaderboardPlayerEntry_catch")

# getLeaderboardEntries(leaderboardName:String), signal on_getLeaderboardEntries(response:Dictionary)
# response { leaderboard:Dictionary, userRank:int, entries:Array}
# leaderboard - getLeaderboardDescription response
# entries - top 20 and 10-20(up/down) players around the player who requested. entries element - getLeaderboardPlayerEntry response
YandexGames.getLeaderboardEntries("Leaderboard_name")
YandexGames.connect("on_getLeaderboardEntries", self, "on_getLeaderboardEntries")

# example use
func on_getLeaderboardEntries(response:Dictionary):
  match response["leaderboard"]["name"]:
    "best_score": pass
    "best_speed": pass
    "aaa": pass
```
#### Review
``` gdscript
# canReview() and on_canReview_yield()->bool, signal on_canReview(can_review:bool)
var can_review = yield(YandexGames.on_canReview_yield(), "completed")
# choose the use case that you like best
YandexGames.canReview()
YandexGames.connect("on_canReview", self, "on_canReview")

# requestReview() automatically calls canReview(), signal on_requestReview(requestReview:bool)
YandexGames.requestReview()
YandexGames.connect("on_requestReview", self, "on_requestReview")
```
#### Desktop shortcut (Yandex Browser Panel)
``` gdscript
# canShowPrompt() and canShowPrompt_yield()->bool, signal on_canShowPrompt(canShowPrompt:bool)
var can_show_prompt = yield(YandexGames.canShowPrompt_yield(), "completed") 
# choose the use case that you like best
YandexGames.canShowPrompt()
YandexGames.connect("on_canShowPrompt", self, "on_canShowPrompt")

# showPrompt() automatically calls canShowPrompt(), signal on_showPrompt(accepted:bool)
YandexGames.on_showPrompt()
YandexGames.connect("on_showPrompt", self, "on_showPrompt")
```
#### Functions
``` gdscript
# getLang() -> String (ru/en/tr/...)
YandexGames.getLang()

# Device Info
match YandexGames.js_ysdk.deviceInfo["_type"]:
  "desktop": pass
  "mobile": pass
  "tablet": pass
  "tv": pass
```
