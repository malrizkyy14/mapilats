import 'package:flutter/material.dart';

import 'pages/auth_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'services/api_client.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;
  String? userName;
  String? userEmail;
  int selectedPage = 0;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Ruang Kata',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xfff3eee8),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff6f4632),
        primary: const Color(0xff2b211d),
        secondary: const Color(0xff9a6a4d),
        tertiary: const Color(0xffc08a63),
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xff211a17),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Color(0xffe3d7cd)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xfffaf7f3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffded1c6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffded1c6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff6f4632), width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xff8e7e74)),
      ),
      textTheme: ThemeData.light().textTheme.copyWith(
        headlineMedium: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Color(0xff211a17),
        ),
        titleLarge: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xff211a17),
        ),
        bodyLarge: const TextStyle(color: Color(0xff584840)),
      ),
    ),
    home: token == null
        ? AuthPage(
            onAuthenticated: (newToken, name, email) => setState(() {
              token = newToken;
              userName = name;
              userEmail = email;
              selectedPage = 0;
            }),
          )
        : Scaffold(
            body: IndexedStack(
              index: selectedPage,
              children: [
                HomePage(
                  api: ApiClient(token: token),
                  userName: userName ?? 'Penulis',
                  onLogout: _logout,
                ),
                ProfilePage(
                  userName: userName ?? 'Penulis',
                  email: userEmail ?? '',
                  onLogout: _logout,
                ),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedPage,
              onDestinationSelected: (index) =>
                  setState(() => selectedPage = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Homepage',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
              ],
            ),
          ),
  );

  void _logout() => setState(() {
    token = null;
    userName = null;
    userEmail = null;
    selectedPage = 0;
  });
}
