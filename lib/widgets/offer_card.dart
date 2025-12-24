import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OfferCard extends StatelessWidget {
  final String title;
  final String storeName;
  final String distance;
  final String originalPrice;
  final String discountedPrice;
  final String pickupTime;
  final String quantityLeft;
  final Color imageColor;
  final IconData icon;
  final String discountPercent;
  final String? restaurantId;
  final String? restaurantName;
  final Map<String, dynamic>? foodItemData;

  const OfferCard({
    super.key,
    required this.title,
    required this.storeName,
    required this.distance,
    required this.originalPrice,
    required this.discountedPrice,
    required this.pickupTime,
    required this.quantityLeft,
    required this.imageColor,
    required this.icon,
    required this.discountPercent,
    this.restaurantId,
    this.restaurantName,
    this.foodItemData,
  });

  @override
  Widget build(BuildContext context) {
    return _InteractiveOfferCard(
      foodItemData: foodItemData,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image / Icon Section
            Hero(
              tag: 'food_image_${foodItemData?['id'] ?? title}',
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: imageColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      size: 50,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  // Discount Badge
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        discountPercent,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Details Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (No heart icon here as requested)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Store & Distance (Small font to prevent overflow)
                  Text(
                    "$storeName • $distance",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Price Row
                  Row(
                    children: [
                      Text(
                        discountedPrice,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00C853),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        originalPrice,
                        style: TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Time & Quantity Tags
                  Row(
                    children: [
                      _buildTag(
                        Icons.access_time,
                        pickupTime,
                        const Color(0xFFFFF3E0),
                        const Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 8),
                      _buildTag(
                        null,
                        quantityLeft,
                        const Color(0xFFE8F5E9),
                        const Color(0xFF4CAF50),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(
    IconData? icon,
    String text,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 2),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveOfferCard extends StatefulWidget {
  final Widget child;
  final Map<String, dynamic>? foodItemData;

  const _InteractiveOfferCard({required this.child, this.foodItemData});

  @override
  State<_InteractiveOfferCard> createState() => _InteractiveOfferCardState();
}

class _InteractiveOfferCardState extends State<_InteractiveOfferCard> {
  bool _isHovered = false;
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    Widget card = GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        if (widget.foodItemData != null) {
          Navigator.pushNamed(
            context,
            '/food_details',
            arguments: widget.foodItemData,
          );
        }
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );

    // Strictly guard MouseRegion for web only to avoid semantics errors
    if (kIsWeb) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? (Matrix4.identity()..scale(1.02, 1.02))
              : Matrix4.identity(),
          child: card,
        ),
      );
    }

    return card;
  }
}
