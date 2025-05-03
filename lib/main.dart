import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';
import 'services/favorites_service.dart';
import 'services/booking_service.dart';
import 'services/review_service.dart';
import 'services/weather_service.dart';
import 'services/windsurf_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize services
  final authService = AuthService();
  final favoritesService = FavoritesService();
  final bookingService = BookingService();
  final reviewService = ReviewService();
  final themeService = ThemeService();
  final windsurfService = WindsurfService();
  
  // Wait for auth service to initialize
  await Future.delayed(const Duration(milliseconds: 500));
  
  runApp(MyApp(
    authService: authService,
    favoritesService: favoritesService,
    bookingService: bookingService,
    reviewService: reviewService,
    themeService: themeService,
    windsurfService: windsurfService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final FavoritesService favoritesService;
  final BookingService bookingService;
  final ReviewService reviewService;
  final ThemeService themeService;
  final WindsurfService windsurfService;

  const MyApp({
    super.key,
    required this.authService,
    required this.favoritesService,
    required this.bookingService,
    required this.reviewService,
    required this.themeService,
    required this.windsurfService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: favoritesService),
        ChangeNotifierProvider.value(value: bookingService),
        ChangeNotifierProvider.value(value: reviewService),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: windsurfService),
        Provider(create: (_) => WeatherService()),
      ],
      child: Consumer2<ThemeService, AuthService>(
        builder: (context, themeService, authService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Windsurf App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
              textTheme: GoogleFonts.poppinsTextTheme(
                Theme.of(context).textTheme,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              textTheme: GoogleFonts.poppinsTextTheme(
                ThemeData.dark().textTheme,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: const Color(0xFF1E1E1E),
              ),
            ),
            themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: authService.isLoading
                ? const SplashScreen()
                : authService.isAuthenticated
                    ? const MainNavigationScreen()
                    : const LoginScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sailing,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Windsurf App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [Colors.lightBlue, Colors.purple]
                        : [Colors.blue, Colors.indigo],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
