import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/login_screen.dart';
import '../../presentation/home/favorites_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/home/profile_screen.dart';
import '../../presentation/recipe/recipe_detail_screen.dart';
import '../../presentation/recipe/add_recipe_screen.dart';
import '../../presentation/home/main_layout.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/recipe_service.dart';
import '../../data/models/recipe_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home', // default
  refreshListenable: AuthService.instance,
  redirect: (context, state) {
    final isAuthenticated = AuthService.instance.isAuthenticated;
    final isGoingToLogin = state.fullPath == '/login';
    final isRestrictedRoute = state.fullPath == '/favorites' || state.fullPath == '/profile' || state.fullPath == '/add-recipe';

    if (!isAuthenticated && isRestrictedRoute) {
      return '/login';
    }
    if (isAuthenticated && isGoingToLogin) {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        // Branch 1: Home (Tarifler)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Branch 2: Favorites
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        // Branch 3: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/recipe/:id',
      builder: (context, state) {
        if (state.extra != null) {
          final recipe = state.extra as Recipe;
          return RecipeDetailScreen(recipe: recipe);
        }
        
        final id = state.pathParameters['id']!;
        return FutureBuilder<Recipe>(
          future: RecipeService.getRecipe(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Scaffold(body: Center(child: Text('Tarif bulunamadı veya bir hata oluştu.')));
            }
            return RecipeDetailScreen(recipe: snapshot.data!);
          },
        );
      },
    ),
    GoRoute(
       path: '/tarifler/:id', // Handle deep link scheme specifically
       redirect: (context, state) => '/recipe/${state.pathParameters['id']}',
    ),
    GoRoute(
      path: '/add-recipe',
      builder: (context, state) => const AddRecipeScreen(),
    ),
  ],
);
