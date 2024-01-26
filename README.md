# Yandex-Games
[![Godot](https://img.shields.io/badge/Godot%20Engine-3.5.2-blue.svg)](https://github.com/godotengine/godot/)
![GitHub License](https://img.shields.io/github/license/AlexeyPe/Yandex-Games)
![GitHub Repo stars](https://img.shields.io/github/stars/AlexeyPe/Yandex-Games)

__If you have ideas for improvement, write me to [telegram](https://t.me/Alexey_Pe) / Issues / pull, I’ll read everything__

__My Telegram [@Alexey_Pe](https://t.me/Alexey_Pe)__


The game in which I used this addon: [Match 3 puzzle](https://yandex.ru/games/app/254609?lang=ru), the game has `saving/loading`, `rewarded/fullscreen advertising`, `purchases`, `call for feedback`

## Demo
Demo in folder [addons/YandexGamesSDK/Demo](addons/YandexGamesSDK/Demo)

Contains simple code with comments

![Godot_v3 5 2-stable_win64_9DEAaFyNrE](https://github.com/AlexeyPe/Yandex-Games/assets/70694988/375a5ada-0400-4c00-b95d-00fae30b7520)

## Table of developers who use this addon
This addon is used by many developers, I added those who don’t mind ([write to me to add you](https://t.me/Alexey_Pe))

№ | Developer | Players |
-- | -- | -- |
1 | [RA Games](https://yandex.ru/games/developer?name=RA%20Games) | 1 500 000 + |
2 | [Magikelle Studio Yandex](https://yandex.ru/games/developer?name=Magikelle%20Studio%20Yandex) | 1000+ |
3 | [Legatum Studio](https://yandex.ru/games/developer?name=Legatum%20Studio) | 1000+ |

## How use
* When the game starts, the addon automatically calls `initGame()`, `getPlayer(false)`, `getPayments()`, `getLeaderboards()`
* For more understanding, you can read [YandexGames.gd](addons/YandexGamesSDK/YandexGames.gd) and sdk documentation
* Add `<script src="https://yandex.ru/games/sdk/v2"></script>` to Project/export/html5/head include.

> [!IMPORTANT]
> When the game is ready to be shown to the player, call `YandexGames.ready()` - for example, after loading the save `getData()`, you can call this function.

### Ads
* After the release, commercial advertising will work after a few hours. Just wait
* When calling an advertisement, check whether the advertisement is currently called. [link to video(bug)](https://disk.yandex.ru/i/sYeNKd5tYS4nEw)
``` gdscript
# Interstitial Ads, signal on_showFullscreenAdv(wasShown:bool, ad_name:String)

# ad_name - this argument is not passed to yandex. I added it for signal and match
if YandexGames.current_fullscreen_ad_name == "":
    YandexGames.showFullscreenAdv("ad_name")
YandexGames.connect("on_showFullscreenAdv", self, "on_showFullscreenAdv")

# example use signal
func on_showFullscreenAdv(success:bool, ad_name:String):
    match ad_name:
        "advertising after loading the game": 
            #your some code when the player closed this ad 
            if success: pass
            else: pass
```
``` gdscript
# Rewarded Ads, signal on_showRewardedVideo(success:bool, current_rewarded_ad_name:String)

# ad_name - this argument is not passed to yandex. I added it for signal and match
if YandexGames.current_rewarded_ad_name == "":
    YandexGames.showRewardedVideo(ad_name) 
YandexGames.connect("on_showRewardedVideo", self, "on_showRewardedVideo")

# example use signal
func on_showRewardedVideo(success:bool, ad_name:String):
    match ad_name:
        "open chest for advertising": 
            #your some code when the player closed this ad 
            if success: pass
            else: pass
```
### Save/Load
* [link yandex documentation](https://yandex.ru/dev/games/doc/en/sdk/sdk-player). For save/load need Player object from getPlayer(bool)
* getPlayer(bool) is called by default in YandexGames._ready() - getPlayer(false)
* getPlayer(true) - to get the player's avatar image, the window will be shown. getPlayer(false) - will not show windows

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
### Save/Load - example
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
  if load_save.empty(): pass # player logged in for the first time / there were no saves
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
### [Remote Config](https://yandex.ru/dev/games/doc/en/sdk/sdk-config)
![img](https://i.imgur.com/uboXtk8.png)
![img](https://i.imgur.com/536qgW1.png)
``` gdscript
# example 1
var flags = yield(YandexGames.getFlags_yield(), "completed")
if flags is Dictionary: pass # you code here

# example 2
var flags = yield(YandexGames.getFlags_yield([
	{"name":"var_1", "value":"20"},
	{"name":"var_2", "value":"33"},
]), "completed")
if flags is Dictionary: pass # you code here

# getFlags_yield() uses the on_getFlags signal
YandexGames.connect("on_getFlags", self, "on_getFlags")
func on_getFlags(response):
    if response is Dictionary: pass # flags
	else: pass # js error (the error will be printed in the browser console)
```

### Purchases
* For purchases, you need to create purchases in the draft and add your login - this is enough for tests. 
(when buying, it will be written that it is a test)
* Before submitting the game for moderation, you need to write a letter to Yandex Games to enable purchases. 
(You don't need to do this for tests.)
* Yandex calls `on_purchase_then()` only when the player closes the window, keep this in mind. Links to [video 1](https://disk.yandex.ru/i/SYNSas6u8zj7nA) and [video 2](https://disk.yandex.ru/i/BtGWp7sw5PbEbA) (bugs)
* How to solve problem with `on_purchase_then()` - you need to use `getPurchases()` when starting the game.
``` gdscript
# In-game purchase, signals on_purchase_then(), on_purchase_catch()

YandexGames.purchase("id")
YandexGames.connect("on_purchase_then", self, "on_purchase_then")
YandexGames.connect("on_purchase_catch", self, "on_purchase_catch")

# example use signals
func on_purchase_then(purchase:YandexGames.Purchase):
	  match purchase.product_id:
		    "id which you specified in the console":
            # your code
            
            # purchase.consume() - delete a purchase from the getPurchases array
            # In short, when a player buys, he must close the window to call on_purchase_then
            # Moderators make a purchase without closing the window and refresh the page, which is why on_purchase_then is not called
            purchase.consume()

func on_purchase_then(product_id:String):
    match product_id:
        "1": pass
```
``` gdscript
# Getting the purchases array [YandexGames.Purchase], signals on_getPurchases()

# The array contains only those Purchases for which consume() was not called

YandexGames.getPurchases()
YandexGames.connect("on_getPurchases", self, "on_getPurchases")

# example use signals
# purchases = Array [YandexGames.Purchase] or null
func on_getPurchases(purchases):
    if purchases == null: pass # your variant
    for purchase in purchases:
        match purchase.product_id:
            "id which you specified in the console":
                  # your code

                  # check the comment on_purchase_then()
                  purchase.consume()
```
``` gdscript
# YandexGames.gd
class Purchase:
    # product_id from Yandex Console (You specify it yourself)
	  var product_id:String
	  var _js_purchase:JavaScriptObject
	  func _init(__js_purchase:JavaScriptObject):
		    product_id = __js_purchase.productID
		    _js_purchase = __js_purchase
    # consume() for to remove from array YandexGames.getPurchases() (on the Yandex side)
    func consume():
		    YandexGames.js_ysdk_payments.consumePurchase(_js_purchase.purchaseToken)
```
### Leaderboards
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
### Review
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
### Desktop shortcut (Yandex Browser Panel)
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
### Functions
``` gdscript
# getLang() -> String (ru/en/tr/...)
YandexGames.getLang()

# Notifies Yandex that the game is ready
YandexGames.ready()

# Device Info
match YandexGames.js_ysdk.deviceInfo["_type"]:
  "desktop": pass
  "mobile": pass
  "tablet": pass
  "tv": pass
```
