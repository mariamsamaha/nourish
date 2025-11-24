import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _quantity1 = 1;
  int _quantity2 = 1;
  bool _donationAdded = false;
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  double get _subtotal => (4.99 * _quantity1) + (8.99 * _quantity2);
  double get _serviceFee => 0.99;
  double get _donation => _donationAdded ? 1.02 : 0.0;
  double get _total => _subtotal + _serviceFee + _donation;
  double get _savings => (15.00 * _quantity1) + (25.00 * _quantity2) - _subtotal;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.02),

              // Cart Item 1
              _buildCartItem(
                emoji: '🥐',
                title: 'Fresh Bakery Surprise Bag',
                restaurant: 'Artisan Bakery',
                price: 4.99,
                originalPrice: 15.00,
                pickupTime: 'Today, 7:00 - 9:00 PM',
                address: '123 Main Street, San Francisco',
                quantity: _quantity1,
                onDecrease: () {
                  if (_quantity1 > 1) {
                    setState(() => _quantity1--);
                  }
                },
                onIncrease: () {
                  setState(() => _quantity1++);
                },
              ),

              SizedBox(height: height * 0.02),

              // Cart Item 2
              _buildCartItem(
                emoji: '🍕',
                title: 'Gourmet Pizza Box',
                restaurant: 'Bella Italia',
                price: 8.99,
                originalPrice: 25.00,
                pickupTime: 'Today, 8:00 - 10:00 PM',
                address: '456 Oak Avenue, San Francisco',
                quantity: _quantity2,
                onDecrease: () {
                  if (_quantity2 > 1) {
                    setState(() => _quantity2--);
                  }
                },
                onIncrease: () {
                  setState(() => _quantity2++);
                },
              ),

              SizedBox(height: height * 0.03),

              // Promo Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFA5D6A7).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        decoration: InputDecoration(
                          hintText: 'Enter promo code',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Promo code applied!'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.02),

              // Donation Option
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFA5D6A7).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Color(0xFF4CAF50),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Donate to Charity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Round up your order to \$${(_subtotal + _serviceFee).toStringAsFixed(2)} and donate \$${_donation.toStringAsFixed(2)} to local food banks',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E7D32),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _donationAdded = !_donationAdded;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _donationAdded
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFA5D6A7),
                          ),
                          backgroundColor: _donationAdded
                              ? const Color(0xFFE8F5E9)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _donationAdded ? 'Remove Donation' : 'Add Donation',
                          style: TextStyle(
                            color: _donationAdded
                                ? const Color(0xFF1B5E20)
                                : const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.03),

              // Order Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFA5D6A7).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Service fee', '\$${_serviceFee.toStringAsFixed(2)}'),
                    if (_donationAdded) ...[
                      const SizedBox(height: 12),
                      _buildSummaryRow('Donation', '\$${_donation.toStringAsFixed(2)}'),
                    ],
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Total',
                      '\$${_total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.savings,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "You're saving \$${_savings.toStringAsFixed(2)}!",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.03),

              // Proceed to Checkout Button
              SizedBox(
                width: double.infinity,
                height: height * 0.065,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Proceeding to checkout...'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem({
    required String emoji,
    required String title,
    required String restaurant,
    required double price,
    required double originalPrice,
    required String pickupTime,
    required String address,
    required int quantity,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFA5D6A7).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji
              Text(
                emoji,
                style: const TextStyle(fontSize: 50),
              ),
              const SizedBox(width: 12),
              // Title and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurant,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${originalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pick up: $pickupTime',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quantity controls
          Row(
            children: [
              const Text(
                'Quantity',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFA5D6A7).withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      color: const Color(0xFF4CAF50),
                      onPressed: onDecrease,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      color: const Color(0xFF4CAF50),
                      onPressed: onIncrease,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF1B5E20),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }
}

