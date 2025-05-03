import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart' as auth_serv;
import '../services/booking_service.dart' as booking_serv;
import '../services/review_service.dart' as review_serv;
import '../services/favorites_service.dart' as favorites_serv;
import '../services/theme_service.dart';
import '../models/booking.dart' as model_booking;
import '../models/review.dart' as model_review; // Using alias for consistency
import '../widgets/animated_gradient_button.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _settingsTabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _settingsTabController = TabController(length: 2, vsync: this);
    
    // Initialize controllers with user data
    final authService = Provider.of<auth_serv.AuthService>(context, listen: false);
    if (authService.isAuthenticated) {
      _nameController.text = authService.currentUsername ?? '';
      _bioController.text = authService.userBio ?? '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _settingsTabController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  // Non-async wrapper for the save profile function
  void _handleSaveProfile() {
    _saveProfile();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<auth_serv.AuthService>(context, listen: false);
      await authService.updateProfile(
        username: _nameController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authService = Provider.of<auth_serv.AuthService>(context);
    final bookingService = Provider.of<booking_serv.BookingService>(context);
    final reviewService = Provider.of<review_serv.ReviewService>(context);
    final favoritesService = Provider.of<favorites_serv.FavoritesService>(context);
    
    if (!authService.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                size: 100,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                'You need to sign in to view your profile',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    final userBookings = bookingService.getUserBookings(authService.currentUsername ?? '');
    print('Debug: Number of user bookings: ${userBookings.length}');
    final userReviews = reviewService.getUserReviews(authService.currentUsername ?? '');
    print('Debug: Number of user reviews: ${userReviews.length}');
    final userFavorites = favoritesService.getFavoriteSpots();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: 'Edit Profile',
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleEditMode,
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.blue[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _isEditing ? _buildProfileEditForm() : _buildProfileHeader(authService),
          ).animate().fadeIn(duration: 500.ms),
          
          // Stats Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context, 
                  Icons.favorite, 
                  userFavorites.length.toString(), 
                  'Favorites',
                  0,
                ),
                _buildStatItem(
                  context, 
                  Icons.calendar_today, 
                  userBookings.length.toString(), 
                  'Bookings',
                  100,
                ),
                _buildStatItem(
                  context, 
                  Icons.rate_review, 
                  userReviews.length.toString(), 
                  'Reviews',
                  200,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
          
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade200.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              tabs: const [
                Tab(text: 'Favorites'),
                Tab(text: 'Bookings'),
                Tab(text: 'Reviews'),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
          
          // Tab Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFavoritesTab(userFavorites),
                  _buildBookingsTab(userBookings),
                  _buildReviewsTab(userReviews),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
          
          // Settings Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                _showSettingsBottomSheet(context);
              },
              icon: const Icon(Icons.settings),
              label: const Text('Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50,
                foregroundColor: isDarkMode ? Colors.white : Colors.blue.shade700,
                elevation: 0,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(auth_serv.AuthService authService) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            (authService.currentUsername ?? '?').substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          authService.currentUsername ?? 'User',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (authService.userBio != null && authService.userBio!.isNotEmpty)
          Text(
            authService.userBio!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[300] 
                  : Colors.grey[700],
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Member since ${_formatDate(authService.userCreatedAt ?? DateTime.now())}',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey[400] 
                : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              (_nameController.text.isNotEmpty ? _nameController.text : '?')
                  .substring(0, 1)
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Display name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Bio',
              border: OutlineInputBorder(),
              hintText: 'Tell us about yourself',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AnimatedGradientButton(
              text: _isLoading ? 'Saving...' : 'Save Profile',
              onPressed: _isLoading ? null : _handleSaveProfile,
              gradientColors: [
                Theme.of(context).primaryColor,
                Colors.blue[300]!,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label, int delay) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.blue[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: delay));
  }

  Widget _buildFavoritesTab(List<dynamic> favorites) {
    if (favorites.isEmpty) {
      return _buildEmptyState(
        'No favorites yet',
        'Your favorite windsurf spots will appear here',
        Icons.favorite_border,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final spot = favorites[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: spot.imageUrl.startsWith('assets/')
                ? const CircleAvatar(child: Icon(Icons.sailing))
                : CircleAvatar(
                    backgroundImage: NetworkImage(spot.imageUrl),
                    onBackgroundImageError: (_, __) => const Icon(Icons.sailing),
                  ),
            title: Text(spot.name),
            subtitle: Text(spot.location),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('${spot.rating}'),
              ],
            ),
            onTap: () {
              // Navigate to spot details
              Navigator.pushNamed(
                context,
                '/spot-details',
                arguments: spot,
              );
            },
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 50.ms * index);
      },
    );
  }

  Widget _buildBookingsTab(List<model_booking.Booking> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        'No bookings yet',
        'Your windsurf session bookings will appear here',
        Icons.calendar_today,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.spotName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _getStatusChip(booking.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(_formatDate(booking.date)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 8),
                    Text('${booking.duration} minutes'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.category, size: 16),
                    const SizedBox(width: 8),
                    Text(booking.sessionType),
                  ],
                ),
                if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Notes:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(booking.notes!),
                ],
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 50.ms * index);
      },
    );
  }

  Widget _buildReviewsTab(List<model_review.Review> reviews) {
    if (reviews.isEmpty) {
      return _buildEmptyState(
        'No reviews yet',
        'Your windsurf spot reviews will appear here',
        Icons.rate_review,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.spotName ?? 'Unknown Spot',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                const SizedBox(height: 8),
                Text(
                  _formatDate(review.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 50.ms * index);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _getStatusChip(model_booking.BookingStatus status) {
    Color color;
    IconData icon;
    
    switch (status) {  
      case model_booking.BookingStatus.confirmed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case model_booking.BookingStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case model_booking.BookingStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toString().split('.').last,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
  
  void _showSettingsBottomSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeService = Provider.of<ThemeService>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            
            // Settings Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800.withOpacity(0.3) : Colors.grey.shade200.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _settingsTabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                ),
                tabs: const [
                  Tab(text: 'Appearance'),
                  Tab(text: 'Preferences'),
                ],
              ),
            ),
            
            // Settings Content
            Expanded(
              child: TabBarView(
                controller: _settingsTabController,
                children: [
                  _buildAppearanceSettings(themeService, isDarkMode),
                  _buildPreferencesSettings(isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppearanceSettings(ThemeService themeService, bool isDarkMode) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Theme Toggle
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dark Mode'),
                    Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        themeService.toggleTheme();
                        Navigator.pop(context);
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
        
        const SizedBox(height: 16),
        
        // Text Size
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Text Size',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: 1.0, // Default text scale
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label: 'Normal',
                  onChanged: (value) {
                    // Would implement text scaling in a real app
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Small', style: TextStyle(fontSize: 12)),
                    const Text('Normal', style: TextStyle(fontSize: 14)),
                    const Text('Large', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
      ],
    );
  }
  
  Widget _buildPreferencesSettings(bool isDarkMode) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Notifications
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Booking Updates'),
                  subtitle: const Text('Get notified about your booking status'),
                  value: true,
                  onChanged: (value) {
                    // Would implement notification settings in a real app
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Weather Alerts'),
                  subtitle: const Text('Get notified about ideal windsurf conditions'),
                  value: true,
                  onChanged: (value) {
                    // Would implement notification settings in a real app
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('New Reviews'),
                  subtitle: const Text('Get notified about new reviews on your favorite spots'),
                  value: false,
                  onChanged: (value) {
                    // Would implement notification settings in a real app
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
        
        const SizedBox(height: 16),
        
        // Units
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Units',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                RadioListTile<String>(
                  title: const Text('Metric (km/h, °C)'),
                  value: 'metric',
                  groupValue: 'metric',
                  onChanged: (value) {
                    // Would implement unit settings in a real app
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String>(
                  title: const Text('Imperial (mph, °F)'),
                  value: 'imperial',
                  groupValue: 'metric',
                  onChanged: (value) {
                    // Would implement unit settings in a real app
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
      ],
    );
  }
}
