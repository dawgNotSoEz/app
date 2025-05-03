import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/windsurf_spot.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../services/weather_service.dart';
import '../services/review_service.dart';
import '../widgets/animated_gradient_button.dart';
import 'booking_screen.dart';
import 'login_screen.dart';
import 'review_screen.dart';

class SpotDetailsScreen extends StatefulWidget {
  final WindsurfSpot spot;

  const SpotDetailsScreen({
    super.key,
    required this.spot,
  });

  @override
  State<SpotDetailsScreen> createState() => _SpotDetailsScreenState();
}

class _SpotDetailsScreenState extends State<SpotDetailsScreen> {
  bool _isLoadingWeather = true;
  WeatherData? _weatherData;
  
  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }
  
  Future<void> _loadWeatherData() async {
    final weatherService = Provider.of<WeatherService>(context, listen: false);
    final weatherData = await weatherService.getWeatherForLocation(widget.spot.location);
    
    if (mounted) {
      setState(() {
        _weatherData = weatherData;
        _isLoadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'spot-image-${widget.spot.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.spot.imageUrl.startsWith('assets/')
                      ? Container(
                          color: Colors.blue.withOpacity(0.3),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sailing,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'About ${widget.spot.name}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.spot.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.blue.withOpacity(0.3),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sailing,
                                    size: 64,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    widget.spot.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    // Gradient overlay for better text visibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.7, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.only(right: 72),
                child: Text(
                  widget.spot.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black54,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Consumer2<AuthService, FavoritesService>(
                builder: (context, authService, favoritesService, _) {
                  final isAuthenticated = authService.isAuthenticated;
                  final isFavorite = isAuthenticated ? 
                      favoritesService.isFavorite(widget.spot.id) : false;
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: () {
                          if (isAuthenticated) {
                            favoritesService.toggleFavorite(widget.spot.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFavorite 
                                      ? 'Removed from favorites' 
                                      : 'Added to favorites!',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          } else {
                            _showLoginDialog();
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.spot.location,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),
                      
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.spot.rating}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: 0.2, end: 0),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Difficulty
                  Row(
                    children: [
                      Text(
                        'Difficulty:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(widget.spot.difficulty),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.spot.difficulty,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Conditions
                  Text(
                    'Conditions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Conditions cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildConditionCard(
                          context,
                          icon: Icons.air,
                          title: 'Wind',
                          value: widget.spot.conditions['wind'] as String,
                          delay: 400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildConditionCard(
                          context,
                          icon: Icons.waves,
                          title: 'Waves',
                          value: widget.spot.conditions['waves'] as String,
                          delay: 500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildConditionCard(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Best Season',
                    value: widget.spot.conditions['bestSeason'] as String,
                    delay: 600,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 700.ms),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    widget.spot.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Weather Section
                  if (_isLoadingWeather)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_weatherData != null)
                    _buildWeatherSection(context)
                  else
                    const SizedBox.shrink(),
                    
                  const SizedBox(height: 24),
                  
                  // Reviews Section
                  _buildReviewsSection(context),
                  
                  const SizedBox(height: 32),
                  
                  // Book Now button
                  Consumer<AuthService>(
                    builder: (context, authService, _) {
                      return AnimatedGradientButton(
                        text: 'Book a Session',
                        onPressed: () {
                          if (authService.isAuthenticated) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingScreen(spot: widget.spot),
                              ),
                            );
                          } else {
                            _showLoginDialog();
                          }
                        },
                        gradientColors: [
                          Colors.blue[700]!,
                          Colors.blue[400]!,
                        ],
                      ).animate().fadeIn(duration: 500.ms, delay: 900.ms);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required int delay,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: delay));
  }

  Widget _buildWeatherSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny,
                color: isDarkMode ? Colors.amber : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Weather',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherInfoItem(
                context,
                icon: _weatherData!.getWeatherIcon(),
                value: '${_weatherData!.temperature.round()}°C',
                label: _weatherData!.description,
              ),
              _buildWeatherInfoItem(
                context,
                icon: Icons.air,
                value: '${_weatherData!.windSpeed.round()} knots',
                label: 'Wind Speed',
              ),
              _buildWeatherInfoItem(
                context,
                icon: Icons.navigation,
                value: _weatherData!.windDirection,
                label: 'Direction',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 700.ms);
  }
  
  Widget _buildWeatherInfoItem(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildReviewsSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final reviewService = Provider.of<ReviewService>(context);
    final reviews = reviewService.getReviewsForSpot(widget.spot.id);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                final authService = Provider.of<AuthService>(context, listen: false);
                if (authService.isAuthenticated) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewScreen(spot: widget.spot),
                    ),
                  );
                } else {
                  _showLoginDialog();
                }
              },
              icon: const Icon(Icons.rate_review),
              label: const Text('Add Review'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'No reviews yet. Be the first to review!',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length > 3 ? 3 : reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  review.username.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                review.username,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < review.rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(review.comment),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(review.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms * index);
            },
          ),
        if (reviews.length > 3)
          Center(
            child: TextButton(
              onPressed: () {
                // Navigate to all reviews screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewScreen(
                      spot: widget.spot,
                      initialTab: 0, // View tab
                    ),
                  ),
                );
              },
              child: const Text('See all reviews'),
            ),
          ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 800.ms);
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign in required'),
        content: const Text('You need to sign in to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        if (difficulty.toLowerCase().contains('beginner')) {
          return Colors.green;
        } else if (difficulty.toLowerCase().contains('intermediate')) {
          return Colors.orange;
        } else if (difficulty.toLowerCase().contains('advanced')) {
          return Colors.red;
        } else if (difficulty.toLowerCase().contains('expert')) {
          return Colors.purple;
        }
        return Colors.blue;
    }
  }
}
