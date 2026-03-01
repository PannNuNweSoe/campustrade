import 'dart:html' as html;

bool openGmailComposeOnWeb({
  required String email,
  required String subject,
}) {
  final gmailUri = Uri.https('mail.google.com', '/mail/', {
    'view': 'cm',
    'fs': '1',
    'to': email,
    'su': subject,
  });

  html.window.open(gmailUri.toString(), '_blank', 'noopener,noreferrer');
  return true;
}
