class_name Marketing
extends Resource

const RESOURCE_NAME : String = "Marketing"

enum CampaignType {
	AWARENESS,     # Targets oblivious buyers to make them educated
	INTEREST,      # Targets educated buyers to make them interested
	MIXED          # Targets both oblivious and educated buyers
}

# Marketing campaign class
class Campaign extends Resource:
	@export var campaign_name : String = ""
	@export var campaign_type : CampaignType = CampaignType.AWARENESS
	@export var effectiveness : float = 50.0  # How effective this campaign is (0-100)
	@export var cost : float = 1000.0
	@export var target_audience_size : int = 100
	@export var duration : float = 60.0  # Duration in game time units
	@export var remaining_duration : float = 60.0
	@export var is_active : bool = false
	@export var targeted_products : Array[String] = []  # Products this campaign promotes
	
	func _init(name: String = ""):
		campaign_name = name if not name.is_empty() else "Campaign " + str(randi() % 1000)
		effectiveness = randf_range(30.0, 80.0)
		cost = randf_range(500.0, 3000.0)
		target_audience_size = randi_range(50, 200)

# Marketing department attributes
@export var marketing_budget : float = 10000.0
@export var team_skill_level : float = 50.0  # Overall marketing team effectiveness (0-100)
@export var brand_awareness : float = 20.0  # Overall brand recognition (0-100)
@export var content_quality : float = 50.0  # Quality of marketing content (0-100)

# Active campaigns and content
@export var active_campaigns : Array[Campaign] = []
@export var campaign_history : Array[Campaign] = []
@export var created_content_pieces : int = 0
@export var total_reach : int = 0

# Performance tracking
@export var buyers_reached : int = 0
@export var buyers_educated : int = 0
@export var buyers_interested : int = 0
@export var leads_generated : int = 0

func _init():
	team_skill_level = randf_range(30.0, 70.0)
	content_quality = randf_range(40.0, 80.0)

# Create a new marketing campaign
func create_campaign(campaign_name: String = "", type: CampaignType = CampaignType.AWARENESS, target_products: Array[String] = []) -> Campaign:
	if marketing_budget < 500.0:
		print("Insufficient marketing budget to create campaign")
		return null
	
	var campaign = Campaign.new(campaign_name if not campaign_name.is_empty() else "Campaign " + str(active_campaigns.size() + 1))
	campaign.campaign_type = type
	campaign.targeted_products = target_products.duplicate()
	
	# Adjust effectiveness based on team skill and content quality
	var skill_bonus = (team_skill_level - 50.0) * 0.3
	var quality_bonus = (content_quality - 50.0) * 0.2
	campaign.effectiveness = min(95.0, campaign.effectiveness + skill_bonus + quality_bonus)
	
	active_campaigns.append(campaign)
	marketing_budget -= campaign.cost
	created_content_pieces += 1
	
	print("Created marketing campaign: ", campaign.campaign_name)
	print("  - Type: ", get_campaign_type_string(campaign.campaign_type))
	print("  - Effectiveness: ", campaign.effectiveness)
	print("  - Cost: $", campaign.cost)
	print("  - Target Audience: ", campaign.target_audience_size)
	
	return campaign

func get_active_campaigns() -> Array:
	return active_campaigns

# Start a campaign
func launch_campaign(campaign: Campaign) -> bool:
	if campaign in active_campaigns and not campaign.is_active:
		campaign.is_active = true
		campaign.remaining_duration = campaign.duration
		print("Launched campaign: ", campaign.campaign_name)
		return true
	return false

# Start a campaign (alias for launch_campaign)
func start_campaign(campaign: Campaign) -> bool:
	return launch_campaign(campaign)

# Stop a campaign
func stop_campaign(campaign: Campaign) -> bool:
	if campaign in active_campaigns and campaign.is_active:
		campaign.is_active = false
		print("Stopped campaign: ", campaign.campaign_name)
		return true
	return false

# Process marketing campaigns and affect buyers
func run_marketing_cycle(buyers: Array[Buyer], products: Array[Product], delta_time: float = 1.0) -> Array[Lead]:
	var new_leads: Array[Lead] = []
	
	# Update active campaigns
	for campaign in active_campaigns:
		if campaign.is_active:
			campaign.remaining_duration -= delta_time
			
			if campaign.remaining_duration <= 0:
				campaign.is_active = false
				campaign_history.append(campaign)
				active_campaigns.erase(campaign)
				print("Campaign ", campaign.campaign_name, " has ended")
				continue
			
			# Apply campaign effects to buyers
			var affected_buyers = process_campaign_effects(campaign, buyers, products)
			buyers_reached += affected_buyers
			
			# Generate leads from interested buyers
			for buyer in buyers:
				if buyer.current_state == Buyer.BuyerState.INTERESTED:
					var lead = buyer.generate_lead()
					if lead != null:
						new_leads.append(lead)
						leads_generated += 1
	
	return new_leads

# Apply campaign effects to buyers
func process_campaign_effects(campaign: Campaign, buyers: Array[Buyer], products: Array[Product]) -> int:
	var affected_count = 0
	var targets_reached = 0
	
	# Determine product appeal for this campaign
	var avg_product_appeal = 50.0
	if not campaign.targeted_products.is_empty() and not products.is_empty():
		var total_appeal = 0.0
		var product_count = 0
		
		for product in products:
			if product.product_name in campaign.targeted_products:
				total_appeal += product.attractiveness
				product_count += 1
		
		if product_count > 0:
			avg_product_appeal = total_appeal / product_count
	
	# Apply campaign to appropriate buyers
	for buyer in buyers:
		if targets_reached >= campaign.target_audience_size:
			break
			
		if buyer.can_be_marketed_to():
			targets_reached += 1
			
			match campaign.campaign_type:
				CampaignType.AWARENESS:
					if buyer.current_state == Buyer.BuyerState.OBLIVIOUS:
						if buyer.expose_to_marketing(campaign.effectiveness):
							buyers_educated += 1
							affected_count += 1
				
				CampaignType.INTEREST:
					if buyer.current_state == Buyer.BuyerState.EDUCATED:
						if buyer.build_interest(avg_product_appeal, campaign.effectiveness):
							buyers_interested += 1
							affected_count += 1
				
				CampaignType.MIXED:
					if buyer.current_state == Buyer.BuyerState.OBLIVIOUS:
						if buyer.expose_to_marketing(campaign.effectiveness * 0.8):  # Slightly less effective
							buyers_educated += 1
							affected_count += 1
					elif buyer.current_state == Buyer.BuyerState.EDUCATED:
						if buyer.build_interest(avg_product_appeal, campaign.effectiveness * 0.8):
							buyers_interested += 1
							affected_count += 1
	
	total_reach += targets_reached
	return affected_count

# Create content to improve marketing effectiveness
func create_content(content_type: String = "general", budget_allocated: float = 500.0) -> bool:
	if marketing_budget < budget_allocated:
		print("Insufficient budget for content creation")
		return false
	
	marketing_budget -= budget_allocated
	created_content_pieces += 1
	
	# Content creation improves content quality and team skill
	var quality_improvement = budget_allocated / 1000.0 * 5.0  # Up to 5 point improvement per $1000
	var skill_improvement = budget_allocated / 2000.0 * 2.0   # Up to 2 point improvement per $2000
	
	content_quality = min(95.0, content_quality + quality_improvement)
	team_skill_level = min(95.0, team_skill_level + skill_improvement)
	
	print("Created ", content_type, " content for $", budget_allocated)
	print("  - Content Quality now: ", content_quality)
	print("  - Team Skill now: ", team_skill_level)
	
	return true

# Improve brand awareness through marketing activities
func build_brand_awareness(investment: float = 1000.0) -> bool:
	if marketing_budget < investment:
		print("Insufficient budget for brand awareness building")
		return false
	
	marketing_budget -= investment
	var awareness_gain = investment / 1000.0 * 3.0  # 3 points per $1000
	brand_awareness = min(100.0, brand_awareness + awareness_gain)
	
	print("Invested $", investment, " in brand awareness")
	print("  - Brand Awareness now: ", brand_awareness)
	
	return true

# Get campaign type as string
func get_campaign_type_string(type: CampaignType) -> String:
	match type:
		CampaignType.AWARENESS:
			return "Awareness"
		CampaignType.INTEREST:
			return "Interest Building"
		CampaignType.MIXED:
			return "Mixed Campaign"
		_:
			return "Unknown"

# Get marketing performance summary
func get_performance_summary() -> Dictionary:
	return {
		"total_campaigns": active_campaigns.size() + campaign_history.size(),
		"active_campaigns": active_campaigns.size(),
		"buyers_reached": buyers_reached,
		"buyers_educated": buyers_educated,
		"buyers_interested": buyers_interested,
		"leads_generated": leads_generated,
		"total_reach": total_reach,
		"content_pieces": created_content_pieces,
		"brand_awareness": brand_awareness,
		"budget_remaining": marketing_budget
	}

# Process customer reviews to improve marketing effectiveness
func process_customer_reviews(reviews: Array) -> void:
	if reviews.is_empty():
		return
	
	var total_rating = 0.0
	var review_count = 0
	
	for review in reviews:
		if review.helps_marketing:
			total_rating += review.rating
			review_count += 1
	
	if review_count > 0:
		var average_rating = total_rating / review_count
		
		# Improve brand awareness based on positive reviews
		if average_rating >= 4.0:
			var brand_improvement = review_count * 2.0  # 2 points per good review
			brand_awareness = min(100.0, brand_awareness + brand_improvement)
			print("Customer reviews improved brand awareness by ", brand_improvement, " points to ", brand_awareness)
		
		# Improve content quality based on feedback
		if average_rating >= 3.5:
			var quality_improvement = review_count * 1.0  # 1 point per decent review
			content_quality = min(95.0, content_quality + quality_improvement)
			print("Customer feedback improved content quality by ", quality_improvement, " points to ", content_quality)

# Add budget to marketing department
func add_budget(amount: float):
	marketing_budget += amount
	print("Added $", amount, " to marketing budget. New total: $", marketing_budget)
