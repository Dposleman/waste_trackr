import 'package:shared_preferences/shared_preferences.dart';

import '../models/waste_entry.dart';

class WasteStorageService {
  static const String _entriesKey = 'waste_entries';

  static Future<List<WasteEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_entriesKey) ?? [];

    final entries = rawList
        .map(WasteEntry.fromJson)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return entries;
  }

  static Future<void> saveEntries(List<WasteEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = entries.map((entry) => entry.toJson()).toList();
    await prefs.setStringList(_entriesKey, rawList);
  }

  static Future<void> addEntry(WasteEntry entry) async {
    final entries = await getEntries();
    entries.add(entry);
    await saveEntries(entries);
  }

  static Future<void> deleteEntry(String id) async {
    final entries = await getEntries();
    entries.removeWhere((entry) => entry.id == id);
    await saveEntries(entries);
  }

  static Future<void> clearAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entriesKey);
  }

  static Future<void> updateEntry(WasteEntry updatedEntry) async {
    final entries = await getEntries();
    final index = entries.indexWhere((entry) => entry.id == updatedEntry.id);

    if (index == -1) {
      entries.add(updatedEntry);
    } else {
      entries[index] = updatedEntry;
    }

    await saveEntries(entries);
  }

  static Future<double> getTotalLoss() async {
    final entries = await getEntries();

    return entries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.totalLoss,
    );
  }
}