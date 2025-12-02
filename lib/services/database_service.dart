import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Service to manage local SQLite database for cart items.
/// Each cart item is associated with a specific user ID to ensure data isolation.
class DatabaseService {
  static Database? _database;
  static const String _tableName = 'cart_items';

  /// Get the database instance, creating it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database and create tables
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'nourish.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            food_id TEXT NOT NULL,
            food_name TEXT NOT NULL,
            food_price REAL NOT NULL,
            food_image TEXT,
            quantity INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            UNIQUE(user_id, food_id)
          )
        ''');
      },
    );
  }

  /// Add an item to the cart for a specific user
  /// If the item already exists, it updates the quantity
  Future<void> addToCart({
    required String userId,
    required String foodId,
    required String foodName,
    required double foodPrice,
    String? foodImage,
    int quantity = 1,
  }) async {
    final db = await database;
    
    // Check if item already exists in cart
    final existingItem = await db.query(
      _tableName,
      where: 'user_id = ? AND food_id = ?',
      whereArgs: [userId, foodId],
    );

    if (existingItem.isNotEmpty) {
      // Update quantity if item already exists
      final currentQuantity = existingItem.first['quantity'] as int;
      await db.update(
        _tableName,
        {'quantity': currentQuantity + quantity},
        where: 'user_id = ? AND food_id = ?',
        whereArgs: [userId, foodId],
      );
    } else {
      // Insert new item
      await db.insert(
        _tableName,
        {
          'user_id': userId,
          'food_id': foodId,
          'food_name': foodName,
          'food_price': foodPrice,
          'food_image': foodImage,
          'quantity': quantity,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Get all cart items for a specific user
  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    final db = await database;
    return await db.query(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  /// Update the quantity of a cart item
  Future<void> updateQuantity({
    required String userId,
    required String foodId,
    required int quantity,
  }) async {
    final db = await database;
    
    if (quantity <= 0) {
      // Remove item if quantity is 0 or less
      await removeFromCart(userId: userId, foodId: foodId);
    } else {
      await db.update(
        _tableName,
        {'quantity': quantity},
        where: 'user_id = ? AND food_id = ?',
        whereArgs: [userId, foodId],
      );
    }
  }

  /// Remove a specific item from the cart
  Future<void> removeFromCart({
    required String userId,
    required String foodId,
  }) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'user_id = ? AND food_id = ?',
      whereArgs: [userId, foodId],
    );
  }

  /// Clear all cart items for a specific user
  Future<void> clearCart(String userId) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Get the total number of items in cart for a user
  Future<int> getCartItemCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(quantity) as total FROM $_tableName WHERE user_id = ?',
      [userId],
    );
    
    return result.first['total'] as int? ?? 0;
  }

  /// Get the total price of all items in cart for a user
  Future<double> getCartTotal(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(food_price * quantity) as total FROM $_tableName WHERE user_id = ?',
      [userId],
    );
    
    return result.first['total'] as double? ?? 0.0;
  }

  /// Close the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
