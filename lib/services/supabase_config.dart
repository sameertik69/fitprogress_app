const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://lsiawhyxrhimzkofgjah.supabase.co',
);

const supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_h-drGMP5P8SpeaHp_HdSmg_Ue892DMG',
);

bool get hasSupabaseConfig {
  return supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
