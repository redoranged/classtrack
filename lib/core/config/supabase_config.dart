class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zcislfiduksfqwifkhrz.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpjaXNsZmlkdWtzZnF3aWZraHJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg3NDEwMzQsImV4cCI6MjA4NDMxNzAzNH0.MoXcoPkaynskRPBg7V8PjQGmX7BhuwfhT-ghqorPY1M',
  );
}
