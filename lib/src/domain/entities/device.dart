// lib/src/domain/entities/device.dart

class Device {
  final String id;
  final String name;
  final bool isActive;

  Device({required this.id, required this.name, required this.isActive});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Dispositivo Desconhecido',
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}
