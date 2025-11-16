import 'package:flutter/material.dart';

import '../../../pantry_items/data/models/pantry_item_model.dart';

class RestockDialog extends StatefulWidget {
  const RestockDialog({
    super.key,
    required this.item,
    required this.onRestock,
  });

  final PantryItemModel item;
  final void Function(int newQuantity) onRestock;

  @override
  State<RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends State<RestockDialog> {
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: (widget.item.quantity + 1).toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restock Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How many ${widget.item.name} will you restock?'),
          const SizedBox(height: 12),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'New quantity',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final value = int.tryParse(_quantityController.text);
            if (value == null || value <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid quantity.')),
              );
              return;
            }
            widget.onRestock(value);
          },
          child: const Text('Restock'),
        ),
      ],
    );
  }
}
