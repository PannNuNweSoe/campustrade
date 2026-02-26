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


final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isAuthRoute = state.matchedLocation == '/' || state.matchedLocation == '/signup';

    if (!isLoggedIn && !isAuthRoute) {
      return '/';
    }

    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
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
    
  ],
);

