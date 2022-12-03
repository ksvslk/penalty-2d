extends Node

var plugin = null

func _ready():
	if Engine.has_singleton("GPack"):
		plugin = Engine.get_singleton("GPack")


func is_signed_in() -> bool:
	if plugin:
		return plugin.isSignedIn()
	return false
	
	
################
# ACHIEVEMENTS #
################

func unlock_achievement(id: String) -> void:
	if plugin:
		plugin.unlockAchievement(id)


func increment_achievement(id: String, num_steps: int) -> void:
	if plugin:
		plugin.incrementAchievement(id, num_steps)


func show_achievements() -> void:
	if plugin:
		plugin.showAchievements()


################
# LEADERBOARD  #
################

func submit_score(score: int, leaderboard: String) -> void:
	if plugin:
		plugin.submitScore(score, leaderboard)


func show_leaderboard(id: String) -> void:
	if plugin:
		plugin.showLeaderboard(id)


################
#   FIREBASE   #
################

func log_event(event_name: String, dictionary: Dictionary) -> void:
	if plugin:
		plugin.logEvent(event_name, dictionary)


################
#    ADMOB     #
################

func load_rewarded_ad() -> void:
	if plugin:
		plugin.loadRewardedAd()


func is_rewarded_ad_loaded() -> bool:
	if plugin:
		return plugin.isRewardedAdLoaded()
	return false


func show_rewarded_ad() -> void:
	if plugin:
		plugin.showRewardedAd()


func load_interstitial_ad() -> void:
	if plugin:
		plugin.loadInterstitialAd()


func is_interstitial_ad_loaded() -> bool:
	if plugin:
		return plugin.isInterstitialAdLoaded()
	return false


func show_interstitial_ad() -> void:
	if plugin:
		var is_loaded = is_interstitial_ad_loaded()
		if is_loaded:
			print("show")
			plugin.showInterstitialAd()
		else:
			print("load")
			plugin.loadInterstitialAd()
		
	
	
################
#  SAVE GAME   #
################

func save_game(data: Dictionary, progress: int) -> void:
	if plugin:
		plugin.saveGame(data, progress)


func load_game() -> void:
	if plugin:
		plugin.loadGame()



# Signals you can connect to in the Android plugin.
# Prefixed by "s" so they would be recognized more easily from various scripts.
const s_rewarded_ad_loaded = "rewarded_ad_loaded"
const s_rewarded_ad_failed_to_load = "rewarded_ad_failed_to_load"
const s_reward_earned = "reward_earned"
const s_rewarded_ad_was_not_ready_to_show = "rewarded_ad_was_not_ready_to_show"
const s_on_rewarded_ad_showed = "on_rewarded_ad_showed"
const s_on_rewarded_ad_failed_to_show = "on_rewarded_ad_failed_to_show"
const s_on_rewarded_ad_dismissed = "on_rewarded_ad_dismissed"

const s_on_start_loading_saved_game = "on_start_loading_saved_game"
const s_on_loading_saved_game_complete = "on_loading_saved_game_complete"
const s_on_start_saving_game = "on_start_saving_game"
const s_on_saving_game_complete = "on_saving_game_complete"

const s_on_signed_in_status_changed = "on_signed_in_status_changed"


