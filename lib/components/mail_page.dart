import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';

class MailPage extends StatefulWidget {
  const MailPage({super.key});

  @override
  State<MailPage> createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  List<Map<String, dynamic>> emails = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchEmails();
  }

  Future<void> fetchEmails() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    ImapClient? client;
    try {
      debugPrint('🔥🔥 RELOAD: Starting IMAP connection to fetch real noticeboard emails...');
      client = ImapClient(isLogEnabled: true);

      debugPrint('Connecting to IMAP server...');
      await client.connectToServer('imap.mgovcloud.in', 993, isSecure: true);
      debugPrint('Connected to IMAP server');

      debugPrint('Logging in...');
      await client.login('manish@meconlimited.co.in', 'fTkTySejGn0Z');
      debugPrint('Logged in successfully');

      debugPrint('Looking for E-Notice Board folder...');

      try {
        await client.selectMailboxByPath('noticeboard@meconlimited.co.in/E-Notice Board');
        debugPrint('Successfully selected E-Notice Board folder');
      } catch (e) {
        debugPrint('E-Notice Board folder not found, listing all mailboxes...');
        final mailboxes = await client.listMailboxes();
        debugPrint('Found ${mailboxes.length} mailboxes');

        Mailbox? targetMailbox;
        for (final mailbox in mailboxes) {
          debugPrint('Mailbox: ${mailbox.name}, Path: ${mailbox.path}');
          if (mailbox.name.toLowerCase().contains('notice') ||
              mailbox.path.toLowerCase().contains('notice') ||
              mailbox.name.toLowerCase().contains('noticeboard') ||
              mailbox.path.toLowerCase().contains('noticeboard')) {
            targetMailbox = mailbox;
            debugPrint('Found notice-related mailbox: ${mailbox.name}');
            break;
          }
        }

        if (targetMailbox != null) {
          debugPrint('Selecting mailbox: ${targetMailbox.name}');
          await client.selectMailbox(targetMailbox);
        } else {
          debugPrint('No notice mailbox found, using INBOX as fallback');
          await client.selectInbox();
        }
      }

      debugPrint('Searching for messages...');
      final searchResult = await client.searchMessages();
      debugPrint('Search completed');

      List<Map<String, dynamic>> fetchedEmails = [];

      debugPrint('Fetching recent messages from E-Notice Board...');

      // Get the most recent messages from the folder (assume 175 total as mentioned)
      const totalMessages = 175; // Based on your folder info
      debugPrint('Targeting E-Notice Board folder with ~$totalMessages messages');

      // Calculate range to get the latest 20 messages
      // final startMessage = totalMessages > 20 ? totalMessages - 19 : 1;
      final startMessage = totalMessages > 10 ? totalMessages - 9 : 1;
      final endMessage = totalMessages;

      debugPrint('Fetching messages from $startMessage to $endMessage');

      for (int i = endMessage; i >= startMessage; i--) {
        try {
          debugPrint('Fetching message $i');
          final message = await client.fetchMessage(i, '(ENVELOPE BODY[TEXT])');

          if (message.messages.isNotEmpty) {
            final mimeMessage = message.messages.first;

            String bodyText = 'No content available';
            try {
              // First try to get decoded content from the library
              String? plainText = mimeMessage.decodeTextPlainPart();
              String? htmlText = mimeMessage.decodeTextHtmlPart();

              if (plainText != null && plainText.isNotEmpty && !plainText.contains('Content-Type:')) {
                bodyText = plainText;
              } else if (htmlText != null && htmlText.isNotEmpty && !htmlText.contains('Content-Type:')) {
                // Parse HTML and extract clean text
                bodyText = htmlText
                    .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
                    .replaceAll(RegExp(r'<div[^>]*>', caseSensitive: false), '\n')
                    .replaceAll(RegExp(r'</div>', caseSensitive: false), '')
                    .replaceAll(RegExp(r'<[^>]*>'), '')
                    .replaceAll('&nbsp;', ' ')
                    .replaceAll('&amp;', '&')
                    .replaceAll('&lt;', '<')
                    .replaceAll('&gt;', '>');
              } else {
                // Manual parsing for multipart content
                debugPrint('Manual parsing required for message');
                String rawContent = (message.messages.first.body ?? '').toString();

                // Look for plain text content
                RegExp plainTextRegex = RegExp(r'Content-Type: text/plain.*?\n\n(.*?)(?=--|\Z)', dotAll: true);
                Match? plainMatch = plainTextRegex.firstMatch(rawContent);

                if (plainMatch != null) {
                  bodyText = plainMatch.group(1)?.trim() ?? '';
                } else {
                  // Look for HTML content and extract
                  RegExp htmlRegex = RegExp(r'Content-Type: text/html.*?\n\n(.*?)(?=--|\Z)', dotAll: true);
                  Match? htmlMatch = htmlRegex.firstMatch(rawContent);

                  if (htmlMatch != null) {
                    String htmlContent = htmlMatch.group(1)?.trim() ?? '';
                    bodyText = htmlContent
                        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
                        .replaceAll(RegExp(r'<div[^>]*>', caseSensitive: false), '\n')
                        .replaceAll(RegExp(r'</div>', caseSensitive: false), '')
                        .replaceAll(RegExp(r'<[^>]*>'), '')
                        .replaceAll('&nbsp;', ' ')
                        .replaceAll('&amp;', '&')
                        .replaceAll('&lt;', '<')
                        .replaceAll('&gt;', '>');
                  }
                }
              }

              // Clean up quoted-printable encoding
              bodyText = bodyText
                  .replaceAll('=C2=A0', ' ')
                  .replaceAll('=E2=80=99', "'")
                  .replaceAll('=E2=80=98', "'")
                  .replaceAll('=E2=80=9C', '"')
                  .replaceAll('=E2=80=9D', '"')
                  .replaceAll('=20', ' ')
                  .replaceAll('=\r\n', '')
                  .replaceAll('=\n', '')
                  .replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n') // Clean up multiple line breaks
                  .trim();

              if (bodyText.isEmpty || bodyText == 'No content available') {
                bodyText = 'Email content could not be decoded properly.';
              }
            } catch (e) {
              debugPrint('Error decoding message body: $e');
              bodyText = 'Error loading email content.';
            }

            fetchedEmails.add({
              'id': i,
              'subject': mimeMessage.decodeSubject() ?? 'No Subject',
              'from': mimeMessage.from?.first.email ?? 'noticeboard@meconlimited.co.in',
              'date': mimeMessage.decodeDate() ?? DateTime.now(),
              'body': bodyText,
            });

            debugPrint('Processed message $i: ${mimeMessage.decodeSubject()}');
          }
        } catch (e) {
          debugPrint('Error fetching message $i: $e');
        }
      }

      debugPrint('Disconnecting...');
      await client.disconnect();
      debugPrint('Disconnected successfully');

      setState(() {
        emails = fetchedEmails;
        isLoading = false;
        error = null;
      });

      debugPrint('Successfully loaded ${fetchedEmails.length} emails');

    } catch (e) {
      debugPrint('IMAP Error: $e');

      if (client != null) {
        try {
          await client.disconnect();
        } catch (disconnectError) {
          debugPrint('Error during disconnect: $disconnectError');
        }
      }

      setState(() {
        error = 'Failed to fetch emails: ${e.toString()}';
        isLoading = false;
        emails = [
          {
            'id': 1,
            'subject': 'Connection Error - Mock Data',
            'from': 'system@meconlimited.co.in',
            'date': DateTime.now(),
            'body': 'Could not connect to email server. This is mock data.\n\nError: ${e.toString()}',
          },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading emails',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchEmails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (emails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No emails found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchEmails,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchEmails,
      child: ListView.builder(
        itemCount: emails.length,
        itemBuilder: (context, index) {
          final email = emails[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  email['subject'].toString().isNotEmpty
                      ? email['subject'].toString()[0].toUpperCase()
                      : 'N',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                email['subject'],
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From: ${email['from']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(email['date']),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
              onTap: () => _showEmailDetail(context, email),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showEmailDetail(BuildContext context, Map<String, dynamic> email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          email['subject'],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'From: ${email['from']}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Date: ${_formatDate(email['date'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  email['body'],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}