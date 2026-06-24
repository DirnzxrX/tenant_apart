import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tenant_apart/main.dart';

void main() {
  testWidgets('TenantHub menampilkan splash lalu login screen', (tester) async {
    await tester.pumpWidget(const TenantHubApp());

    expect(find.byType(RichText), findsWidgets);
    expect(find.text('Smart Tenant Operations Platform'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang!'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
