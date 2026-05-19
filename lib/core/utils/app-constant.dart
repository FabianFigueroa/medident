class AppConstants {
  AppConstants._();

  // App Info
  static const String companyName = 'Medident';
  static const String MY_API_KEY = 'AIzaSyAHP5CQ5xF4ktBJF85f7b8CHtUUnbEdNM8';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Aplicaci�n multiplataforma dental y m�dica para IPS Medident';

  // Paddings
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Margins
  static const double marginXS = 4.0;
  static const double marginS = 8.0;
  static const double marginM = 16.0;
  static const double marginL = 24.0;
  static const double marginXL = 32.0;
  static const double marginXXL = 48.0;

  // Border Radius
  static const double radiusXXS = 4.0;
  static const double radiusXS = 8.0;
  static const double radiusS = 12.0;
  static const double radiusM = 16.0;
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 14.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Button Heights
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 48.0;
  static const double buttonHeightL = 56.0;

  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 16.0;

  // Animation Durations
  static const Duration animationDurationS = Duration(milliseconds: 150);
  static const Duration animationDurationM = Duration(milliseconds: 300);
  static const Duration animationDurationL = Duration(milliseconds: 500);

  // Product Grid
  static const int productGridColumns = 2;
  static const double productCardAspectRatio = 0.75;

  // Product Categories
  static const List<String> productCategories = [
    'Electronics',
    'Fashion',
    'Home & Garden',
    'Sports',
    'Books',
    'Beauty',
    'Automotive',
    'Toys',
    'Food',
    'Health',
  ];

  // Sort Options
  static const List<String> sortOptions = [
    'Popular',
    'Price: Low to High',
    'Price: High to Low',
    'Newest',
    'Best Rating',
    'Best Selling',
  ];

  // Filter Options
  static const List<String> priceRanges = [
    'Under \$',
    '\ - \$',
    '\ - \$',
    '\ - \$',
    'Over \$',
  ];

  static const List<String> ratings = [
    '4 Stars & Up',
    '3 Stars & Up',
    '2 Stars & Up',
    '1 Star & Up',
  ];

  // Error Messages
  static const String networkError = 'Please check your internet connection';
  static const String generalError = 'Something went wrong. Please try again';
  static const String emptyListError = 'No items found';
  static const String authError = 'Authentication failed';

  // Success Messages
  static const String addToCartSuccess = 'Item added to cart';
  static const String addToWishlistSuccess = 'Item added to wishlist';
  static const String removeFromWishlistSuccess = 'Item removed from wishlist';
  static const String orderPlacedSuccess = 'Order placed successfully';

  // Placeholder Images
  static const String placeholderImage = 'assets/images/post.png';
  static const String placeholderUserImage = 'assets/images/login.jpg';

  // API Endpoints (for future implementation)
  static const String baseUrl = 'https://api.medident.com';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String authEndpoint = '/auth';
  static const String ordersEndpoint = '/orders';
}
