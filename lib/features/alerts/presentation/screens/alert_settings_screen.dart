import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/alert_provider.dart';
import '../state/alert_state.dart';

class AlertSettingsScreen extends ConsumerStatefulWidget {
  const AlertSettingsScreen({super.key});

  @override
  ConsumerState<AlertSettingsScreen> createState() => _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends ConsumerState<AlertSettingsScreen> {
  late TextEditingController _lowStockThresholdController;
  late TextEditingController _expirationWarningController;
  bool _lowStockEnabled = true;
  bool _expirationEnabled = true;
  bool _initialized = false;

  @override
  void dispose() {
    _lowStockThresholdController.dispose();
    _expirationWarningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertState = ref.watch(alertControllerProvider);
    final controller = ref.read(alertControllerProvider.notifier);

    if (alertState is AlertInitial) {
      Future.microtask(() => controller.loadAlerts());
    }

    if (alertState is AlertLoading || !_initialized && alertState is! AlertLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (alertState is AlertError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Alert Settings')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(alertState.message),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.loadAlerts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (alertState is! AlertLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final settings = alertState.settings;

    if (!_initialized) {
      _lowStockThresholdController =
          TextEditingController(text: settings.lowStockThreshold.toString());
      _expirationWarningController =
          TextEditingController(text: settings.expirationWarningDays.toString());
      _lowStockEnabled = settings.enableLowStockAlerts;
      _expirationEnabled = settings.enableExpirationAlerts;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Settings'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              SwitchListTile(
                title: const Text('Enable Low Stock Alerts'),
                subtitle: const Text('Get notified when items fall below the threshold'),
                value: _lowStockEnabled,
                onChanged: (value) => setState(() => _lowStockEnabled = value),
              ),
              TextField(
                controller: _lowStockThresholdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Low stock threshold',
                  helperText: 'Alert when quantity is less than or equal to this value',
                ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Enable Expiration Alerts'),
                subtitle: const Text('Get notified before items expire'),
                value: _expirationEnabled,
                onChanged: (value) => setState(() => _expirationEnabled = value),
              ),
              TextField(
                controller: _expirationWarningController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Expiration warning days',
                  helperText: 'Number of days before expiration to warn you',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final lowStockThreshold = int.tryParse(_lowStockThresholdController.text) ??
                      settings.lowStockThreshold;
                  final expirationWarningDays =
                      int.tryParse(_expirationWarningController.text) ??
                          settings.expirationWarningDays;

                  final updated = settings.copyWith(
                    lowStockThreshold: lowStockThreshold,
                    expirationWarningDays: expirationWarningDays,
                    enableLowStockAlerts: _lowStockEnabled,
                    enableExpirationAlerts: _expirationEnabled,
                    updatedAt: DateTime.now(),
                  );

                  if (!mounted) return;
                  final messenger = ScaffoldMessenger.of(context);
                  await controller.updateSettings(updated);
                  if (!mounted) return;

                  messenger.showSnackBar(
                    const SnackBar(content: Text('Alert settings updated')),
                  );
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Save Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
