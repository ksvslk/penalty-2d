extends VBoxContainer

var payment = null

const BALL := "ball"
const INTERMEDIATE_ADS := "intermediate_ads"
const TWO_BALLS_NO_ADS := "two_balls_and_remove_ads"

const SKUS: Array[String] = [
	BALL,
	INTERMEDIATE_ADS,
	TWO_BALLS_NO_ADS
]

var max_retries := 5
var retry := 0
var consume_retry := 0
var seconds: Array[int] = [10, 20, 40, 80, 160]

@onready var maximum_rew_reached: Control = $WatchRewarded/MaximumRewReached
@onready var watch_rewarded: Button = $WatchRewarded
@onready var maximum_reached_ads: Control = $TwoBallsNoAds/MaximumReachedAds
@onready var maximum_reached: Control = $Ball/MaximumReached
@onready var ball: Button = $Ball
@onready var intermediate_ads: Button = $IntermediateAds
@onready var two_balls_no_ads: Button = $TwoBallsNoAds

signal disable_intermediate_ads
signal add_2_balls_disable_ads
signal add_ball

func _ready() -> void:
	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment = load("res://addons/GodotGooglePlayBilling/BillingClient.gd").new()
		add_child(payment)
		# Godot 4 Signal Connections
		payment.connected.connect(_on_connected)
		payment.disconnected.connect(_on_disconnected)
		payment.connect_error.connect(_on_connect_error)
		payment.on_purchase_updated.connect(_on_purchases_updated)
		payment.query_product_details_response.connect(_on_sku_details_query_completed)
		payment.query_purchases_response.connect(_on_query_purchases_response)
		payment.start_connection()
	else:
		print("Android IAP support is not enabled. Make sure you have enabled 'Custom Build' and installed and enabled the GodotGooglePlayBilling plugin in your Android export settings! This application will not work.")
	
	if GPack.plugin:
		GPack.plugin.rewarded_ad_loaded.connect(_set_rewarded_ad_button_state)
		GPack.plugin.rewarded_ad_failed_to_load.connect(_rewarded_failed_to_load)

func _on_connect_error(response_code: int, debug_message: String) -> void:
	print("%s: %s" % [response_code, debug_message])
	if retry < max_retries:
		# Godot 4 uses 'await' instead of 'yield'
		await get_tree().create_timer(seconds[retry]).timeout
		print("Retrying to connect..")
		retry += 1
		payment.start_connection()
	else:
		print("Retries reached maximum.")
		retry = 0

func _rewarded_failed_to_load(error: String) -> void:
	print("_rewarded_failed_to_load: %s" % error)
	watch_rewarded.disabled = true
	maximum_rew_reached.visible = false

func _set_rewarded_ad_button_state(max_balls_count: int = -1) -> void:
	print("_set_rewarded_ad_button_state. Should be rewarded loaded here.")
	if max_balls_count == -1:
		max_balls_count = Data.get_max_balls_to_add_count()
	
	if max_balls_count > 0:
		watch_rewarded.disabled = false
		maximum_rew_reached.visible = false
	elif max_balls_count <= 0:
		watch_rewarded.disabled = true
		maximum_rew_reached.visible = true

func _set_rewarded_ad_button_state_on_load(max_balls_count: int = -1) -> void:
	if max_balls_count > 0 and GPack.is_rewarded_ad_loaded():
		watch_rewarded.disabled = false
		maximum_rew_reached.visible = false
	elif max_balls_count >= 0 and not GPack.is_rewarded_ad_loaded():
		watch_rewarded.disabled = true
		maximum_rew_reached.visible = false
	elif max_balls_count <= 0:
		watch_rewarded.disabled = true
		maximum_rew_reached.visible = true

func _set_intermediate_button_state() -> void:
	if not Data.is_intermediate_ads_enabled():
		intermediate_ads.visible = false
		two_balls_no_ads.visible = false

func _set_two_balls_button_state(max_balls_count: int) -> void:
	if max_balls_count < 2:
		two_balls_no_ads.disabled = true
		maximum_reached_ads.visible = true
	else:
		two_balls_no_ads.disabled = false
		maximum_reached_ads.visible = false
		
	if not Data.is_intermediate_ads_enabled():
		two_balls_no_ads.visible = false
		intermediate_ads.visible = false

func _set_eternal_ball_button_state(max_balls_count: int) -> void:
	if max_balls_count < 1:
		ball.disabled = true
		maximum_reached.visible = true
	else:
		ball.disabled = false
		maximum_reached.visible = false

# In Godot 4, use _notification to react to built-in property changes like 'visible'.
func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			var max_balls_count = Data.get_max_balls_to_add_count()
			_set_eternal_ball_button_state(max_balls_count)
			_set_rewarded_ad_button_state_on_load(max_balls_count)
			_set_two_balls_button_state(max_balls_count)
	
	if what == NOTIFICATION_APPLICATION_RESUMED and payment:
		payment.query_purchases(0)

func _on_connected() -> void:
	print("PurchaseManager connected")
	payment.query_purchases(0) # Use "subs" for subscriptions.
	payment.query_product_details(SKUS, 0)

func _on_query_purchases_response(query_result: Dictionary) -> void:
	print("_on_query_purchases_response: %s" % [query_result])
	if query_result.response_code == 0:
		for purchase in query_result.purchases:
			_handle_purchase(purchase)
	else:
		print("queryPurchases failed, response code: %s, debug message: %s" % [query_result.response_code, query_result.debug_message])

func _on_sku_details_query_completed(query_result: Dictionary) -> void:
	print("_on_sku_details_query_completed: %s" % [query_result])
	if query_result.response_code == 0:
		for available_sku in query_result.get("product_details", []):
			var price = available_sku.get("price", "")
			var sku_id = available_sku.get("product_id", "")
			var title = available_sku.get("title", "").get_slice("(", 0)
		
			match sku_id:
				BALL:
					ball.text = title + " - " + price
					ball.disabled = false
				INTERMEDIATE_ADS:
					intermediate_ads.text = title + " - " + price
					intermediate_ads.disabled = false
				TWO_BALLS_NO_ADS:
					two_balls_no_ads.text = title + " - " + price
					two_balls_no_ads.disabled = false

func _handle_purchase(purchase: Dictionary) -> void:
	var products = purchase.get("product_ids", [])
	var sku = products[0] if not products.is_empty() else ""
	var state = purchase.get("purchase_state", 1) # Default to 1 (PURCHASED) if missing
	
	if state == 1: # PURCHASED
		if not purchase.get("is_acknowledged", false):
			print("Purchase '%s' giving content!" % sku)
			_give_content(sku, purchase.get("purchase_token", ""))
			payment.acknowledge_purchase(purchase.get("purchase_token", ""))
			print("Purchase '%s' has not been acknowledged. Acknowledging..." % sku)
			if sku == BALL:
				_consume(purchase.get("purchase_token", ""))
				print("Purchase '%s' set to be consumed." % sku)
		elif purchase.is_acknowledged and sku == BALL:
			print("Purchase '%s' is acknowledged, so giving content and consuming." % sku)
			_consume(purchase.get("purchase_token", ""))
			_give_content(sku, purchase.get("purchase_token", ""))
		else:
			print("Purchase '%s' was already acknowledged. Giving content if needed." % sku)
			_give_content(sku, purchase.get("purchase_token", ""))

func _give_content(sku: String, token: String) -> void:
	match sku:
		BALL:
			if not Data.has_purchase_token(token):
				Data.add_purchase_token(token)
				add_ball.emit()
		INTERMEDIATE_ADS:
			if Data.is_intermediate_ads_enabled():
				intermediate_ads.visible = false
				two_balls_no_ads.visible = false
				disable_intermediate_ads.emit()
		TWO_BALLS_NO_ADS:
			if not Data.is_two_balls_purchased():
				two_balls_no_ads.visible = false
				intermediate_ads.visible = false
				add_2_balls_disable_ads.emit()

func _on_purchases_updated(purchases: Array) -> void:
	# Godot 4 uses JSON.stringify() instead of to_json()
	print("Purchases updated (on resume and startup): %s" % JSON.stringify(purchases))
	for purchase in purchases:
		_handle_purchase(purchase)

func _on_purchase_acknowledged(purchase_token: String) -> void:
	print("Purchase acknowledged: %s" % purchase_token)

func _on_purchase_consumed(purchase_token: String) -> void:
	print("Purchase consumed successfully: %s" % purchase_token)
	
func _on_purchase_error(code: int, message: String) -> void:
	print("Purchase error %d: %s" % [code, message])

func _on_purchase_acknowledgement_error(code: int, message: String, token: String) -> void:
	print("Purchase acknowledgement error %d: %s, token: %s" % [code, message, token])
	
func _on_purchase_consumption_error(code: int, message: String, purchase_token: String) -> void:
	print("Purchase consumption error %d: %s, purchase token: %s" % [code, message, purchase_token])
	if consume_retry < max_retries:
		await get_tree().create_timer(seconds[retry]).timeout
		print("Trying again to consume...")
		consume_retry += 1
		_consume(purchase_token)
	else:
		print("Consume retries reached maximum.")
		consume_retry = 0

func _on_sku_details_query_error(code: int, message: String, skus: Array[String]) -> void:
	print("SKU details query error %d: %s for SKUs: %s" % [code, message, skus])

func _on_disconnected() -> void:
	print("GodotGooglePlayBilling disconnected. Will try to reconnect in 10s...")
	await get_tree().create_timer(10).timeout
	payment.start_connection()

func _purchase(sku: String) -> void:
	if payment:
		var response: Dictionary = payment.purchase(sku)
		if response.response_code != 0:
			print("Purchase error %s: %s" % [response.response_code, response.get("debug_message", "")])

func _consume(sku_token: String) -> void:
	if payment:
		if sku_token == null:
			print("You need to set 'test_item_purchase_token' first! (either by hand or in code)")
			return
		payment.consume_purchase(sku_token)

#region GUI Callbacks
func _on_Ball_pressed() -> void:
	get_parent()._on_BackButton_pressed()
	_purchase(BALL)

func _on_IntermediateAds_pressed() -> void:
	get_parent()._on_BackButton_pressed()
	_purchase(INTERMEDIATE_ADS)

func _on_TwoBallsNoAds_pressed() -> void:
	get_parent()._on_BackButton_pressed()
	_purchase(TWO_BALLS_NO_ADS)

func _on_WatchRewarded_pressed() -> void:
	get_parent()._on_BackButton_pressed()
	if GPack.is_rewarded_ad_loaded():
		GPack.show_rewarded_ad()
#endregion
