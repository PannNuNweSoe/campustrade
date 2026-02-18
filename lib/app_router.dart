import 'package:go_router/go_router.dart';
import 'features/login/screen.dart';
import 'features/home/screen.dart';
import 'features/profile/screen.dart';
import 'features/chat/screen.dart';
import 'features/item_detail/screen.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
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
    
  ],
);

