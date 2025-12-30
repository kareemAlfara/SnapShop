import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void>sendPrivateNotification({
  required String title,
  required String body,
  String? receiverId,
}) async {
  const url =
      'https://kbshmetpchppzivoynly.supabase.co/functions/v1/send-notification';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $supabaseAnonKey',
    },
    body: jsonEncode({
      'title': title,
      'body': body,
     'receiverId': receiverId,
    }),
  );

  if (response.statusCode != 200) {
    print('❌ Failed: ${response.statusCode} ${response.body}');
  }
}

const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtic2htZXRwY2hwcHppdm95bmx5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTY5OTUxNCwiZXhwIjoyMDc1Mjc1NTE0fQ.gbzfyuoR21tUpj7lEJPUDEc_47QO5WTQ8Hg4NcLZ3NU'; // your anon/public API key
Future<void> sendGlobalNotification({
  required List<String> tokens,
  required String title,
  required String body,
}) async {
  const url =
      'https://euudvrftyscplhfwzxli.supabase.co/functions/v1/send-push'; // 👈 real URL

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      // include anon key if the function isn’t marked public
      'Authorization': 'Bearer $supabaseAnonKey',
    },
    body: jsonEncode({
      'tokens': tokens,
      'title': title,
      'body': body,
    }),
  );

  if (response.statusCode == 200) {
    print('✅ Notification sent successfully');
  } else {
    print('❌ Failed: ${response.statusCode}  ${response.body}');
  }
}
