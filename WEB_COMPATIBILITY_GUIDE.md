# 🌐 Web Compatibility Implementation Guide

## Overview

This guide explains how the database layer was refactored to support both **Mobile (Android/iOS)** and **Web** platforms using conditional imports and platform-specific implementations.

---

## 🏗️ Architecture

### Database Abstraction Layer

The app now uses a **DatabaseInterface** abstraction that works on all platforms:

```
┌─────────────────────────────────────┐
│     DatabaseInterface (Abstract)     │
│  - insert()                         │
│  - query()                          │
│  - update()                         │
│  - delete()                         │
│  - execute()                        │
└──────────────┬──────────────────────┘
               │
       ┌───────┴────────┐
       │                 │
       ▼                 ▼
┌─────────────┐   ┌─────────────┐
│   Mobile     │   │    Web      │
│ (sqflite)    │   │  (sembast)  │
│              │   │             │
│ SQLite DB    │   │  IndexedDB  │
└─────────────┘   └─────────────┘
```

### How It Works

1. **DatabaseInterface**: Defines the contract for all database operations
2. **Mobile Implementation**: Uses `sqflite` (SQLite) for Android/iOS
3. **Web Implementation**: Uses `sembast` (IndexedDB) for web browsers
4. **Conditional Imports**: Automatically selects the correct implementation

---

## 📁 File Structure

```
lib/data/local/
├── database_interface.dart      # Abstract interface
├── database_helper.dart         # Singleton with conditional imports
├── database_mobile.dart          # Mobile implementation (sqflite)
└── database_web.dart            # Web implementation (sembast)
```

---

## 🔧 Implementation Details

### 1. Database Interface (`database_interface.dart`)

Defines the abstract methods that all implementations must provide:

```dart
abstract class DatabaseInterface {
  Future<void> execute(String sql, [List<Object?>? arguments]);
  Future<int> insert(String table, Map<String, dynamic> values, {...});
  Future<List<Map<String, dynamic>>> query(String table, {...});
  Future<int> update(String table, Map<String, dynamic> values, {...});
  Future<int> delete(String table, {...});
  Future<void> close();
}
```

### 2. Mobile Implementation (`database_mobile.dart`)

- Uses `sqflite` package
- Wraps SQLite `Database` in `MobileDatabase` class
- Implements all `DatabaseInterface` methods
- Handles SQL operations natively
- Creates tables using SQL `CREATE TABLE` statements

**Key Features:**
- ✅ Full SQL support
- ✅ Foreign keys
- ✅ Indexes
- ✅ Transactions (via sqflite)

### 3. Web Implementation (`database_web.dart`)

- Uses `sembast` package with `sembast_web`
- Stores data in browser's IndexedDB
- Simulates SQL operations using NoSQL stores
- Each table becomes a sembast store

**Key Features:**
- ✅ Works in browsers (IndexedDB)
- ✅ NoSQL storage (simulates SQL)
- ✅ Automatic key management
- ✅ Query filtering and sorting

**Limitations:**
- ⚠️ No true SQL (simulated)
- ⚠️ Foreign keys handled in application logic
- ⚠️ Indexes handled by sembast automatically

### 4. Database Helper (`database_helper.dart`)

Uses **conditional imports** to select the correct implementation:

```dart
import 'database_mobile.dart' if (dart.library.html) 'database_web.dart';
```

**How it works:**
- On **mobile**: Imports `database_mobile.dart`
- On **web**: Imports `database_web.dart` (when `dart.library.html` exists)

---

## 🔄 How DAOs Work Unchanged

DAOs (Data Access Objects) use `DatabaseHelper.instance.database` which returns `DatabaseInterface`. Since both implementations provide the same interface, **DAOs don't need any changes**!

**Example:**
```dart
// This works on both mobile and web!
final db = await _dbHelper.database;
await db.insert('food_items', {...});
final results = await db.query('food_items', where: 'user_id = ?', whereArgs: [userId]);
```

---

## 📦 Dependencies

### Mobile (Android/iOS)
- `sqflite: ^2.3.0` - SQLite database
- `path: ^1.9.0` - Path manipulation

### Web
- `sembast: ^3.4.0` - NoSQL database
- `sembast_web: ^3.0.0` - Web-specific implementation (IndexedDB)

### Both
- All other dependencies remain the same

---

## 🚀 Usage

### No Changes Required!

The refactoring is **completely transparent** to the rest of the app:

```dart
// This works on mobile AND web!
final foodItemDao = FoodItemDao();
await foodItemDao.insert(foodItem, userId);
final meals = await foodItemDao.getByDate(userId, DateTime.now());
```

### Running on Different Platforms

**Mobile (Android/iOS):**
```bash
flutter run
# Automatically uses sqflite
```

**Web:**
```bash
flutter run -d chrome
# Automatically uses sembast (IndexedDB)
```

---

## 🔍 Key Differences: Mobile vs Web

### Mobile (sqflite)
- ✅ True SQL database
- ✅ Foreign key constraints
- ✅ SQL indexes
- ✅ File-based storage
- ✅ Full SQL query support

### Web (sembast)
- ✅ NoSQL database (simulates SQL)
- ✅ IndexedDB storage (browser)
- ✅ Automatic key management
- ✅ Filter-based queries
- ⚠️ No foreign keys (handled in app logic)
- ⚠️ No SQL indexes (sembast handles indexing)

---

## 🐛 Troubleshooting

### Issue: "Database not found on web"

**Solution:** Check that `sembast_web` is properly imported. The web implementation uses IndexedDB which is automatically available in browsers.

### Issue: "Query not working on web"

**Solution:** Web implementation uses filter-based queries. Make sure WHERE clauses use supported operators (`=`, `>=`, `<`, `<=`).

### Issue: "Auto-increment not working"

**Solution:** Web implementation handles auto-increment for `user_data` table by finding the max key and incrementing. This is automatic.

### Issue: "Foreign keys not enforced on web"

**Solution:** This is expected. sembast doesn't support foreign keys. The app logic handles cascading deletes if needed.

---

## ✅ Testing Checklist

Before deploying, test on both platforms:

### Mobile Testing
- [ ] Create user account
- [ ] Add food items
- [ ] Query by date
- [ ] Update food items
- [ ] Delete food items
- [ ] User data CRUD operations

### Web Testing
- [ ] Create user account
- [ ] Add food items
- [ ] Query by date
- [ ] Update food items
- [ ] Delete food items
- [ ] User data CRUD operations
- [ ] Refresh page (data persists in IndexedDB)
- [ ] Clear browser data (data is cleared)

---

## 📝 Migration Notes

### What Changed
1. ✅ `DatabaseHelper` now returns `DatabaseInterface` instead of `Database`
2. ✅ DAOs updated to use `DatabaseInterface` (minimal changes)
3. ✅ Platform-specific implementations added
4. ✅ Conditional imports added

### What Stayed the Same
1. ✅ Repository layer (no changes)
2. ✅ Business logic (no changes)
3. ✅ UI screens (no changes)
4. ✅ Authentication (no changes)
5. ✅ DAO method signatures (no changes)

---

## 🎯 Benefits

1. **Cross-Platform**: App works on mobile AND web
2. **No Code Duplication**: Same DAOs work everywhere
3. **Type Safety**: Interface ensures consistency
4. **Easy Testing**: Can test database logic independently
5. **Future-Proof**: Easy to add more platforms

---

## 🔮 Future Enhancements

Possible improvements:
- Add Windows/macOS/Linux support
- Implement database migrations for web
- Add database backup/restore
- Implement sync between platforms
- Add database encryption

---

## 📚 Resources

- [sqflite Documentation](https://pub.dev/packages/sqflite)
- [sembast Documentation](https://pub.dev/packages/sembast)
- [sembast_web Documentation](https://pub.dev/packages/sembast_web)
- [Flutter Conditional Imports](https://dart.dev/guides/libraries/create-library-packages#conditionally-importing-and-exporting-library-files)

---

**Status**: ✅ Complete - App works on Mobile and Web!

