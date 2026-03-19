import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/login/screen.dart';
import 'features/home/screen.dart';
import 'features/profile/screen.dart';
import 'features/chat/screen.dart';
import 'features/item_detail/screen.dart';
import 'features/post_item/screen.dart';
import 'features/signup/screen.dart';
import 'features/notifications/screen.dart';
import 'features/wishlist/screen.dart';
import 'features/landing/screen.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/landing',
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final location = state.matchedLocation;
    final isAuthRoute = location == '/' || location == '/signup';
    final isPublicRoute = isAuthRoute || location == '/landing';

    if (!isLoggedIn && !isPublicRoute) {
      return '/landing';
    }

    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        return ChatScreen(params: args ?? {});
      },
    ),
    GoRoute(
      path: '/item/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return ItemDetailScreen(itemId: id);
      },
    ),
    
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/post',
      builder: (context, state) => const PostItemScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
  ],
);

