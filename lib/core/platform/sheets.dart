// lib/core/platform/sheets.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart';

class Sheets {
  static Future<T?> showActionSheet<T>(
      BuildContext context, {
        required String title,
        required List<SheetAction<T>> actions,
        T? cancelValue,
      }) async {
    if (PlatformUtils.isIOS) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (_) => CupertinoActionSheet(
          title: Text(title),
          actions: actions
              .map((a) => CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, a.value),
            isDestructiveAction: a.destructive,
            child: Text(a.label),
          ))
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, cancelValue),
            child: const Text('İptal'),
          ),
        ),
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              ...actions.map((a) => ListTile(
                title: Text(a.label, style: TextStyle(color: a.destructive ? Colors.red : null)),
                onTap: () => Navigator.pop(context, a.value),
              )),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    }
  }
}

class SheetAction<T> {
  final String label;
  final T value;
  final bool destructive;
  SheetAction(this.label, this.value, {this.destructive = false});
}
