class_name Finance
extends Resource

const RESOURCE_NAME : String = "Finance"

# Current financial position
@export var cash_balance : float = 50000.0  # Starting cash for the business
@export var starting_capital : float = 50000.0

# Revenue tracking
@export var total_revenue : float = 0.0
@export var sales_revenue : float = 0.0
@export var other_revenue : float = 0.0

# Expense tracking
@export var total_expenses : float = 0.0
@export var product_development_expenses : float = 0.0
@export var marketing_expenses : float = 0.0
@export var operational_expenses : float = 0.0
@export var other_expenses : float = 0.0

# Assets (simplified balance sheet)
@export var assets_inventory_value : float = 0.0  # Value of products/inventory
@export var assets_equipment : float = 10000.0   # Fixed assets like equipment
@export var assets_intellectual_property : float = 0.0  # IP value from products

# Liabilities (simplified)
@export var liabilities_debt : float = 0.0
@export var liabilities_accounts_payable : float = 0.0

# Performance metrics
@export var net_profit : float = 0.0
@export var gross_margin : float = 0.0

func _init():
	update_financial_metrics()

# Record revenue from sales
func record_revenue(amount: float, source: String = "sales") -> void:
	cash_balance += amount
	total_revenue += amount
	
	match source:
		"sales":
			sales_revenue += amount
		_:
			other_revenue += amount
	
	update_financial_metrics()
	print("Revenue recorded: $", amount, " from ", source, ". New balance: $", cash_balance)

func get_total_revenue() ->float:
	return total_revenue

# Record expenses
func record_expense(amount: float, category: String = "other") -> bool:
	if cash_balance < amount:
		print("Insufficient funds for expense: $", amount, ". Current balance: $", cash_balance)
		return false
	
	cash_balance -= amount
	total_expenses += amount
	
	match category:
		"product_development":
			product_development_expenses += amount
		"marketing":
			marketing_expenses += amount
		"operations":
			operational_expenses += amount
		_:
			other_expenses += amount
	
	update_financial_metrics()
	print("Expense recorded: $", amount, " for ", category, ". New balance: $", cash_balance)
	return true

func get_total_expenses() ->float:
	return total_expenses

# Calculate and update financial metrics
func update_financial_metrics() -> void:
	net_profit = total_revenue - total_expenses
	
	if total_revenue > 0:
		gross_margin = (net_profit / total_revenue) * 100.0
	else:
		gross_margin = 0.0

# Get current cash balance
func get_cash_balance() -> float:
	return cash_balance

# Get profit and loss summary
func get_profit_loss_summary() -> Dictionary:
	return {
		"revenue": total_revenue,
		"sales_revenue": sales_revenue,
		"other_revenue": other_revenue,
		"total_expenses": total_expenses,
		"product_dev_expenses": product_development_expenses,
		"marketing_expenses": marketing_expenses,
		"operational_expenses": operational_expenses,
		"other_expenses": other_expenses,
		"net_profit": net_profit,
		"gross_margin": gross_margin
	}

# Get balance sheet summary
func get_balance_sheet_summary() -> Dictionary:
	var total_assets = cash_balance + assets_inventory_value + assets_equipment + assets_intellectual_property
	var total_liabilities = liabilities_debt + liabilities_accounts_payable
	var equity = total_assets - total_liabilities
	
	return {
		"cash": cash_balance,
		"inventory": assets_inventory_value,
		"equipment": assets_equipment,
		"intellectual_property": assets_intellectual_property,
		"total_assets": total_assets,
		"debt": liabilities_debt,
		"accounts_payable": liabilities_accounts_payable,
		"total_liabilities": total_liabilities,
		"equity": equity
	}

# Check if business can afford an expense
func can_afford(amount: float) -> bool:
	return cash_balance >= amount

# Add asset value (like completed products)
func add_asset_value(amount: float, asset_type: String = "inventory") -> void:
	match asset_type:
		"inventory":
			assets_inventory_value += amount
		"equipment":
			assets_equipment += amount
		"intellectual_property":
			assets_intellectual_property += amount
	
	print("Added $", amount, " to ", asset_type, " assets")

# Get financial health indicator
func get_financial_health() -> String:
	if cash_balance <= 0:
		return "Critical - No Cash"
	elif cash_balance < 5000:
		return "Poor - Low Cash"
	elif net_profit < 0:
		return "Concerning - Losing Money"
	elif net_profit > 10000:
		return "Excellent - Profitable"
	elif net_profit > 0:
		return "Good - Profitable"
	else:
		return "Fair - Breaking Even"

# Calculate product development cost based on complexity
func calculate_product_development_cost(base_cost: float = 10000.0) -> float:
	# This could be enhanced with more sophisticated costing models
	var random_factor = randf_range(0.8, 1.2)  # ±20% variation
	return base_cost * random_factor

# Reset finances (for testing or new game)
func reset_finances(starting_amount: float = 50000.0) -> void:
	cash_balance = starting_amount
	starting_capital = starting_amount
	total_revenue = 0.0
	sales_revenue = 0.0
	other_revenue = 0.0
	total_expenses = 0.0
	product_development_expenses = 0.0
	marketing_expenses = 0.0
	operational_expenses = 0.0
	other_expenses = 0.0
	assets_inventory_value = 0.0
	assets_equipment = 10000.0
	assets_intellectual_property = 0.0
	liabilities_debt = 0.0
	liabilities_accounts_payable = 0.0
	update_financial_metrics()
	print("Finances reset. Starting balance: $", cash_balance)
