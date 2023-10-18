# Yandex-Games
Yandex Games SDK for Godot 3.5
* Godot 4 - If JavaScript and JavaScriptObject work the same way as in 3, then try it, you will also need to solve the issue with the header files of version 4

### Demo
![Godot_v3 5 2-stable_win64_iYw5XCuTVk](https://github.com/AlexeyPe/Yandex-Games/assets/70694988/8d705e45-7ada-4072-a396-e015131b8fb7)

### How Install
1. Install and enable the addon in the settings
2. Add `<script src="https://yandex.ru/games/sdk/v2"></script>` to Head Include (Project -> Export -> HTML)

### How use
* When the game starts, the addon automatically calls `initGame()`, `getPlayer(false)`, `getPayments()`, `getLeaderboards()`
* For more understanding, you can read [YandexGames.gd](addons/YandexGamesSDK/YandexGames.gd) and sdk documentation
#### Ads
``` gdscript
# Interstitial Ads, signal on_showFullscreenAdv(wasShown:bool)
YandexGames.showFullscreenAdv()
YandexGames.connect("on_showFullscreenAdv", self, "on_showFullscreenAdv")

# Rewarded Ads, signal on_showRewardedVideo(success:bool, current_rewarded_ad_name:String)
YandexGames.showRewardedVideo(new_current_rewarded_ad_name) 
YandexGames.connect("on_showRewardedVideo", self, "on_showRewardedVideo")
```
#### Save/Load
``` gdscript
# setData(data:Dictionary) to save data on yandex, no signal
YandexGames.setData(data)

# getData() and getData_yield()->Dictionary, signal on_getData(data:Dictionary)
var load_save:Dictionary = yield(YandexGames.getData_yield(), "completed")
# choose the use case that you like best
getData()
YandexGames.connect("on_getData", self, "on_getData")
```
#### Purchases
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
``` gdscript
# Leaderboards - setLeaderboardScore(Leaderboard_name:String, score:int) 
YandexGames.setLeaderboardScore("Leaderboard_name", 1000)
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
#### User Language
``` gdscript
# getLang() -> String (ru/en/tr/...)
YandexGames.getLang()
```
