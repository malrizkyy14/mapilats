import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ats/main.dart';

void main() {
  testWidgets('shows login and register switch', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Selamat datang kembali.'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    await tester.tap(find.text('Belum punya akun? Daftar'));
    await tester.pump();
    expect(find.text('Mulai menulis hari ini.'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
  });
}
