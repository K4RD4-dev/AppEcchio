/// Backend configuration for APPecchio.
///
/// Values are injected at build time via `--dart-define`:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///
/// When they are empty the app stays in "demo mode" (no backend, in-memory
/// data) so the public mockup keeps working without any configuration.
class BackendConfig {
  const BackendConfig._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// True when both the URL and the anon key have been provided.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
