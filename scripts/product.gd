class_name Product
extends Resource

const RESOURCE_NAME : String = "Product"

# Core product attributes specified in requirements
@export var attractiveness : float = 0.0  # How appealing the product is to consumers (0-100)
@export var utility : float = 0.0          # How useful/functional the product is (0-100) 
@export var cost : float = 0.0             # Production cost per unit
@export var retail_price : float = 0.0     # Selling price to consumers
@export var value : float = 0.0            # Perceived value by consumers (0-100)

# Additional relevant business attributes
@export var quality : float = 0.0          # Build quality and reliability (0-100)
@export var brand_appeal : float = 0.0     # Brand recognition and reputation (0-100)
@export var market_fit : float = 0.0       # How well it fits target market needs (0-100)
@export var production_difficulty : float = 0.0  # Complexity to manufacture (0-100)
@export var innovation_level : float = 0.0 # How innovative/unique the product is (0-100)
@export var durability : float = 0.0       # How long the product lasts (0-100)
@export var environmental_impact : float = 0.0  # Sustainability rating (0-100, higher = more eco-friendly)

# Metadata
@export var product_name : String = ""
@export var category : String = ""
@export var development_time : float = 0.0  # Time taken to develop (in game time units)
@export var launch_date : String = ""

func _init(name: String = "New Product"):
	product_name = name
	# Set some reasonable defaults
	attractiveness = 50.0
	utility = 50.0
	quality = 50.0
	brand_appeal = 20.0
	market_fit = 30.0
	production_difficulty = 50.0
	innovation_level = 25.0
	durability = 50.0
	environmental_impact = 40.0

# Calculate profit margin
func get_profit_margin() -> float:
	if retail_price <= 0:
		return 0.0
	return ((retail_price - cost) / retail_price) * 100.0

# Calculate overall product score (weighted average of key metrics)
func get_overall_score() -> float:
	var score = (attractiveness * 0.2) + (utility * 0.2) + (quality * 0.15) + \
				(brand_appeal * 0.1) + (market_fit * 0.15) + (innovation_level * 0.1) + \
				(durability * 0.05) + (environmental_impact * 0.05)
	return score

# Estimate market demand based on product attributes
func estimate_market_demand() -> float:
	var demand_score = (attractiveness + utility + brand_appeal + market_fit) / 4.0
	# Apply price sensitivity - higher prices reduce demand
	if retail_price > 0 and value > 0:
		var price_to_value_ratio = retail_price / (value * 10.0)  # Normalize value
		demand_score *= max(0.1, 2.0 - price_to_value_ratio)  # Reduce demand if overpriced
	return max(0.0, min(100.0, demand_score))

# Check if product is viable for market launch
func is_market_ready() -> bool:
	return attractiveness > 30.0 and utility > 30.0 and quality > 40.0 and retail_price > cost

# Get development cost estimate based on complexity and innovation
func get_development_cost_estimate() -> float:
	var base_cost = 10000.0  # Base development cost
	var complexity_multiplier = 1.0 + (production_difficulty / 100.0)
	var innovation_multiplier = 1.0 + (innovation_level / 50.0)  # More innovative = more expensive
	return base_cost * complexity_multiplier * innovation_multiplier