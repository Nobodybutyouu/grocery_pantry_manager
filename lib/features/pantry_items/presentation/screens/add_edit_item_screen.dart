import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

import '../../data/models/pantry_item_model.dart';
import '../providers/pantry_item_provider.dart';

class AddEditItemScreen extends ConsumerStatefulWidget {
  final PantryItemModel? item;

  const AddEditItemScreen({super.key, this.item});

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends ConsumerState<AddEditItemScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  // Predefined categories
  final List<String> _categories = const [
    'Dairy',
    'Vegetables',
    'Fruits',
    'Meat',
    'Seafood',
    'Grains',
    'Canned Goods',
    'Snacks',
    'Beverages',
    'Condiments',
    'Frozen',
    'Bakery',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Item' : 'Add Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          initialValue: {
            'name': widget.item?.name ?? '',
            'quantity': widget.item?.quantity.toString() ?? '1',
            'category': widget.item?.category ?? _categories.first,
            'expirationDate': widget.item?.expirationDate,
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g., Milk, Eggs, Rice',
                  prefixIcon: Icon(Icons.shopping_basket),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(2),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'quantity',
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter quantity',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(0),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderDropdown<String>(
                name: 'category',
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                validator: FormBuilderValidators.required(),
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              FormBuilderDateTimePicker(
                name: 'expirationDate',
                inputType: InputType.date,
                format: DateFormat('MMM dd, yyyy'),
                decoration: const InputDecoration(
                  labelText: 'Expiration Date (Optional)',
                  hintText: 'Select expiration date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveItem,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEdit ? 'Update Item' : 'Add Item',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final formData = _formKey.currentState!.value;
    final controller = ref.read(pantryItemControllerProvider.notifier);

    final item = PantryItemModel(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: formData['name'] as String,
      quantity: int.parse(formData['quantity'] as String),
      category: formData['category'] as String,
      expirationDate: formData['expirationDate'] as DateTime?,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.item != null) {
        await controller.updateItem(item);
      } else {
        await controller.addItem(item);
      }

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.item != null
                ? 'Item updated successfully'
                : 'Item added successfully',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
