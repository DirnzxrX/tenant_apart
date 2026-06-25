import 'package:apk_tenant/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Tenant menampilkan splash lalu login screen', (tester) async {
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
