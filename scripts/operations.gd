class_name Operations
extends Resource

const RESOURCE_NAME : String = "Operations"

# Production order class
class ProductionOrder extends Resource:
	@export var order_id : String = ""
	@export var product_name : String = ""
	@export var quantity : int = 1
	@export var production_cost : float = 0.0
	@export var production_time : float = 30.0  # Time to produce in game seconds
	@export var remaining_time : float = 30.0
	@export var status : String = "queued"  # queued, in_progress, completed
	@export var sale_id : String = ""  # Reference to the sale that triggered this
	@export var buyer_name : String = ""
	
	func _init(id: String = ""):
		order_id = id if not id.is_empty() else "order_" + str(randi() % 100000)
		production_time = randf_range(15.0, 45.0)  # Random production time
		remaining_time = production_time

# Delivery order class
class DeliveryOrder extends Resource:
	@export var delivery_id : String = ""
	@export var order_id : String = ""  # Reference to production order
	@export var product_name : String = ""
	@export var delivery_cost : float = 0.0
	@export var delivery_time : float = 15.0  # Time to deliver in game seconds
	@export var remaining_time : float = 15.0
	@export var status : String = "pending"  # pending, in_transit, delivered
	@export var buyer_name : String = ""
	@export var delivery_address : String = ""
	
	func _init(id: String = ""):
		delivery_id = id if not id.is_empty() else "delivery_" + str(randi() % 100000)
		delivery_time = randf_range(10.0, 25.0)  # Random delivery time
		remaining_time = delivery_time
		delivery_cost = randf_range(50.0, 200.0)  # Random delivery cost

# Customer review class
class CustomerReview extends Resource:
	@export var review_id : String = ""
	@export var buyer_name : String = ""
	@export var product_name : String = ""
	@export var rating : float = 5.0  # 1-5 star rating
	@export var review_text : String = ""
	@export var created_date : String = ""
	@export var helps_marketing : bool = true
	
	func _init():
		review_id = "review_" + str(randi() % 100000)
		rating = randf_range(3.0, 5.0)  # Generally positive reviews
		created_date = Time.get_datetime_string_from_system()
		
		# Generate random review text based on rating
		if rating >= 4.5:
			review_text = "Excellent product! Highly recommend!"
		elif rating >= 4.0:
			review_text = "Very good product, happy with purchase."
		elif rating >= 3.5:
			review_text = "Good product, meets expectations."
		else:
			review_text = "Decent product, some room for improvement."

# Operations department attributes
@export var production_capacity : int = 3  # Max simultaneous production orders
@export var delivery_capacity : int = 5   # Max simultaneous deliveries
@export var production_efficiency : float = 1.0  # Multiplier for production speed
@export var delivery_efficiency : float = 1.0    # Multiplier for delivery speed

# Queues and active processes
@export var sales_queue : Array[Dictionary] = []  # Sales waiting for production
@export var production_queue : Array[ProductionOrder] = []
@export var active_production : Array[ProductionOrder] = []
@export var delivery_queue : Array[DeliveryOrder] = []
@export var active_deliveries : Array[DeliveryOrder] = []
@export var completed_deliveries : Array[DeliveryOrder] = []
@export var customer_reviews : Array[CustomerReview] = []

# Performance tracking
@export var total_production_orders : int = 0
@export var total_deliveries : int = 0
@export var total_production_cost : float = 0.0
@export var total_delivery_cost : float = 0.0
@export var average_production_time : float = 30.0
@export var average_delivery_time : float = 15.0

func _init():
	pass

# Process a new sale - add to sales queue for production
func process_new_sale(sale_data: Dictionary) -> void:
	sales_queue.append(sale_data)
	print("New sale added to operations queue: ", sale_data.get("buyer_name", "Unknown"), " for ", sale_data.get("product_name", "Unknown Product"))

# Start production for queued sales
func start_production(finance_dept: Finance) -> int:
	var started_count = 0
	
	# Process sales queue if we have production capacity
	while sales_queue.size() > 0 and active_production.size() < production_capacity:
		var sale_data = sales_queue.pop_front()
		var order = create_production_order(sale_data)
		
		# Check if we can afford the production cost
		if finance_dept.can_afford(order.production_cost):
			# Record production expense
			finance_dept.record_expense(order.production_cost, "operations")
			
			# Start production
			order.status = "in_progress"
			active_production.append(order)
			total_production_orders += 1
			total_production_cost += order.production_cost
			started_count += 1
			
			print("Started production for order: ", order.order_id, " (Cost: $", order.production_cost, ")")
		else:
			# Can't afford, put back in queue
			sales_queue.push_front(sale_data)
			print("Cannot afford production cost of $", order.production_cost, " for order ", order.order_id)
			break
	
	return started_count

# Create production order from sale data
func create_production_order(sale_data: Dictionary) -> ProductionOrder:
	var order = ProductionOrder.new()
	order.product_name = sale_data.get("product_name", "Unknown Product")
	order.buyer_name = sale_data.get("buyer_name", "Unknown Buyer")
	order.sale_id = sale_data.get("sale_id", "")
	
	# Calculate production cost based on product complexity
	order.production_cost = randf_range(100.0, 500.0)  # Base production cost
	
	return order

# Update production processes
func update_production(delta_time: float) -> int:
	var completed_count = 0
	var completed_orders: Array[ProductionOrder] = []
	
	for order in active_production:
		order.remaining_time -= delta_time * production_efficiency
		
		if order.remaining_time <= 0:
			order.status = "completed"
			completed_orders.append(order)
			completed_count += 1
			print("Production completed for order: ", order.order_id)
			
			# Move to delivery queue
			queue_for_delivery(order)
	
	# Remove completed orders from active production
	for order in completed_orders:
		active_production.erase(order)
	
	return completed_count

# Queue completed production for delivery
func queue_for_delivery(production_order: ProductionOrder) -> void:
	var delivery = DeliveryOrder.new()
	delivery.order_id = production_order.order_id
	delivery.product_name = production_order.product_name
	delivery.buyer_name = production_order.buyer_name
	delivery.delivery_address = "Customer Address"  # Could be enhanced
	
	delivery_queue.append(delivery)
	print("Order ", production_order.order_id, " queued for delivery")

# Start deliveries for completed products
func start_deliveries(finance_dept: Finance) -> int:
	var started_count = 0
	
	while delivery_queue.size() > 0 and active_deliveries.size() < delivery_capacity:
		var delivery = delivery_queue.pop_front()
		
		# Check if we can afford delivery cost
		if finance_dept.can_afford(delivery.delivery_cost):
			# Record delivery expense
			finance_dept.record_expense(delivery.delivery_cost, "operations")
			
			# Start delivery
			delivery.status = "in_transit"
			active_deliveries.append(delivery)
			total_deliveries += 1
			total_delivery_cost += delivery.delivery_cost
			started_count += 1
			
			print("Started delivery: ", delivery.delivery_id, " (Cost: $", delivery.delivery_cost, ")")
		else:
			# Can't afford, put back in queue
			delivery_queue.push_front(delivery)
			print("Cannot afford delivery cost of $", delivery.delivery_cost)
			break
	
	return started_count

# Update delivery processes
func update_deliveries(delta_time: float, finance_dept: Finance) -> int:
	var completed_count = 0
	var completed_deliveries_list: Array[DeliveryOrder] = []
	
	for delivery in active_deliveries:
		delivery.remaining_time -= delta_time * delivery_efficiency
		
		if delivery.remaining_time <= 0:
			delivery.status = "delivered"
			completed_deliveries_list.append(delivery)
			completed_count += 1
			print("Delivery completed: ", delivery.delivery_id)
			
			# Process customer payment and review
			process_delivery_completion(delivery, finance_dept)
	
	# Move completed deliveries
	for delivery in completed_deliveries_list:
		active_deliveries.erase(delivery)
		completed_deliveries.append(delivery)
	
	return completed_count

# Process delivery completion - customer pays and may leave review
func process_delivery_completion(delivery: DeliveryOrder, finance_dept: Finance) -> void:
	# Customer pays for the product (simulate payment)
	var payment_amount = randf_range(200.0, 1000.0)  # Random payment amount
	finance_dept.record_revenue(payment_amount, "sales")
	print("Customer ", delivery.buyer_name, " paid $", payment_amount, " for ", delivery.product_name)
	
	# Chance for customer to leave a review
	if randf() < 0.7:  # 70% chance of review
		var review = CustomerReview.new()
		review.buyer_name = delivery.buyer_name
		review.product_name = delivery.product_name
		customer_reviews.append(review)
		print("Customer ", delivery.buyer_name, " left a review: ", review.rating, " stars - ", review.review_text)

# Run complete operations cycle
func run_operations_cycle(delta_time: float, finance_dept: Finance) -> Dictionary:
	var results = {
		"production_started": start_production(finance_dept),
		"production_completed": update_production(delta_time),
		"deliveries_started": start_deliveries(finance_dept),
		"deliveries_completed": update_deliveries(delta_time, finance_dept)
	}
	
	return results

# Get operations performance summary
func get_operations_summary() -> Dictionary:
	return {
		"sales_in_queue": sales_queue.size(),
		"production_queue": production_queue.size(),
		"active_production": active_production.size(),
		"delivery_queue": delivery_queue.size(),
		"active_deliveries": active_deliveries.size(),
		"completed_deliveries": completed_deliveries.size(),
		"total_production_orders": total_production_orders,
		"total_deliveries": total_deliveries,
		"customer_reviews": customer_reviews.size(),
		"total_production_cost": total_production_cost,
		"total_delivery_cost": total_delivery_cost,
		"production_capacity": production_capacity,
		"delivery_capacity": delivery_capacity
	}

# Get customer reviews for marketing feedback
func get_customer_reviews_for_marketing() -> Array[CustomerReview]:
	var marketing_reviews: Array[CustomerReview] = []
	
	for review in customer_reviews:
		if review.helps_marketing:
			marketing_reviews.append(review)
	
	return marketing_reviews

# Upgrade production capacity
func upgrade_production_capacity(finance_dept: Finance, cost: float = 5000.0) -> bool:
	if finance_dept.can_afford(cost):
		finance_dept.record_expense(cost, "operations")
		production_capacity += 1
		print("Production capacity upgraded to: ", production_capacity)
		return true
	else:
		print("Cannot afford production capacity upgrade: $", cost)
		return false

# Upgrade delivery capacity
func upgrade_delivery_capacity(finance_dept: Finance, cost: float = 3000.0) -> bool:
	if finance_dept.can_afford(cost):
		finance_dept.record_expense(cost, "operations")
		delivery_capacity += 1
		print("Delivery capacity upgraded to: ", delivery_capacity)
		return true
	else:
		print("Cannot afford delivery capacity upgrade: $", cost)
		return false