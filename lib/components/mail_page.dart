import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';

class MailPage extends StatefulWidget {
  const MailPage({super.key});

  @override
  State<MailPage> createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> with AutomaticKeepAliveClientMixin {
  // Static cache to persist data across widget rebuilds
  static List<Map<String, dynamic>>? _cachedEmails;
  static bool _hasInitiallyLoaded = false;

  List<Map<String, dynamic>> emails = [];
  bool isLoading = true;
  bool isRefreshing = false;
  String? error;
  static const int maxEmails = 50; // Cap at 50 emails
  static const int emailsPerFetch = 10; // Fetch 10 at a time

  // Boolean to enable/disable full body viewing
  static const bool enableFullBodyView = false;

  @override
  bool get wantKeepAlive => true; // Keep state alive when navigating away

  @override
  void initState() {
    super.initState();

    // Check if we have cached data
    if (_hasInitiallyLoaded && _cachedEmails != null) {
      // Use cached data immediately
      setState(() {
        emails = _cachedEmails!;
        isLoading = false;
      });
      debugPrint('📦 Loaded ${emails.length} cached emails');
    } else {
      // First time load
      fetchEmails(isInitialLoad: true);
    }
  }

  Future<void> fetchEmails({bool isInitialLoad = false}) async {
    // If it's a refresh (not initial load), keep existing content visible
    setState(() {
      if (isInitialLoad) {
        isLoading = true;
      } else {
        isRefreshing = true;
      }
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
      await client.searchMessages();
      debugPrint('Search completed');

      List<Map<String, dynamic>> fetchedEmails = [];

      debugPrint('Fetching recent messages from E-Notice Board (subjects only for performance)...');

      // Get the most recent messages from the folder (assume 175 total as mentioned)
      const totalMessages = 175; // Based on your folder info
      debugPrint('Targeting E-Notice Board folder with ~$totalMessages messages');

      // Determine how many emails to fetch
      final emailsToFetch = isInitialLoad ? 10 : emailsPerFetch;
      final startMessage = totalMessages > emailsToFetch ? totalMessages - (emailsToFetch - 1) : 1;
      final endMessage = totalMessages;

      debugPrint('Fetching latest $emailsToFetch messages (subjects only) from $startMessage to $endMessage');

      // Get existing email IDs to avoid duplicates
      final existingEmailIds = emails.map((e) => e['id'] as int).toSet();

      for (int i = endMessage; i >= startMessage; i--) {
        // Skip if already exists
        if (existingEmailIds.contains(i)) {
          debugPrint('Skipping message $i (already fetched)');
          continue;
        }

        try {
          debugPrint('Fetching message $i (subject only)');
          // Fetch only ENVELOPE for faster loading (subject, from, date)
          final message = await client.fetchMessage(i, '(ENVELOPE)');

          if (message.messages.isNotEmpty) {
            final mimeMessage = message.messages.first;

            fetchedEmails.add({
              'id': i,
              'subject': mimeMessage.decodeSubject() ?? 'No Subject',
              'from': mimeMessage.from?.first.email ?? 'noticeboard@meconlimited.co.in',
              'date': mimeMessage.decodeDate() ?? DateTime.now(),
              'body': 'Click to view full content', // Placeholder, will load on demand
              'bodyLoaded': false, // Flag to indicate body needs to be loaded
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
        if (isInitialLoad) {
          // On initial load, just set the emails
          emails = fetchedEmails;
        } else {
          // On refresh, add new emails at the top and maintain cap
          emails = [...fetchedEmails, ...emails];

          // Cap at maxEmails (50)
          if (emails.length > maxEmails) {
            emails = emails.sublist(0, maxEmails);
            debugPrint('Capped emails list at $maxEmails');
          }
        }

        isLoading = false;
        isRefreshing = false;
        error = null;

        // Update static cache
        _cachedEmails = List.from(emails);
        _hasInitiallyLoaded = true;
      });

      debugPrint('Successfully loaded ${fetchedEmails.length} new emails, total: ${emails.length}');

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
        isRefreshing = false;

        // Only set mock data on initial load failure
        if (isInitialLoad && !_hasInitiallyLoaded) {
          emails = [
            {
              'id': 1,
              'subject': 'Connection Error - Mock Data',
              'from': 'system@meconlimited.co.in',
              'date': DateTime.now(),
              'body': 'Could not connect to email server. This is mock data.\n\nError: ${e.toString()}',
            },
          ];

          // Cache the error state
          _cachedEmails = List.from(emails);
          _hasInitiallyLoaded = true;
        }
        // On refresh failure, keep existing emails
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Show full-screen loading only on initial load
    if (isLoading && !isRefreshing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error only if it occurred on initial load and no emails exist
    if (error != null && emails.isEmpty) {
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
              onPressed: () => fetchEmails(isInitialLoad: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (emails.isEmpty && !isRefreshing) {
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
              onPressed: () => fetchEmails(isInitialLoad: true),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => fetchEmails(isInitialLoad: false),
      child: Stack(
        children: [
          ListView.builder(
            itemCount: emails.length,
            itemBuilder: (context, index) {
              final email = emails[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      email['subject'].toString().isNotEmpty
                          ? email['subject'].toString()[0].toUpperCase()
                          : 'N',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  title: Text(
                    _truncateSubject(email['subject']),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(email['date']),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  trailing: enableFullBodyView
                      ? Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey[400],
                        )
                      : null,
                  onTap: enableFullBodyView
                      ? () => _showEmailDetail(context, email)
                      : null,
                ),
              );
            },
          ),
          // Show compact loading indicator at top during refresh
          if (isRefreshing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 3,
                child: LinearProgressIndicator(),
              ),
            ),
        ],
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

  String _truncateSubject(String subject) {
    final words = subject.split(' ');
    if (words.length <= 30) {
      return subject;
    }
    return '${words.take(30).join(' ')}...';
  }

  Future<void> _loadEmailBody(Map<String, dynamic> email) async {
    // If body is already loaded, skip
    if (email['bodyLoaded'] == true) return;

    ImapClient? client;
    try {
      debugPrint('Loading full body for message ${email['id']}...');
      client = ImapClient(isLogEnabled: false);

      await client.connectToServer('imap.mgovcloud.in', 993, isSecure: true);
      await client.login('manish@meconlimited.co.in', 'fTkTySejGn0Z');

      // Select the mailbox
      try {
        await client.selectMailboxByPath('noticeboard@meconlimited.co.in/E-Notice Board');
      } catch (e) {
        await client.selectInbox();
      }

      // Fetch full message with body
      final message = await client.fetchMessage(email['id'], '(BODY[TEXT])');

      if (message.messages.isNotEmpty) {
        final mimeMessage = message.messages.first;
        String bodyText = 'No content available';

        try {
          String? plainText = mimeMessage.decodeTextPlainPart();
          String? htmlText = mimeMessage.decodeTextHtmlPart();

          if (plainText != null && plainText.isNotEmpty) {
            bodyText = plainText;
          } else if (htmlText != null && htmlText.isNotEmpty) {
            bodyText = htmlText
                .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
                .replaceAll(RegExp(r'<[^>]*>'), '')
                .replaceAll('&nbsp;', ' ')
                .replaceAll('&amp;', '&')
                .replaceAll('&lt;', '<')
                .replaceAll('&gt;', '>')
                .trim();
          }

          bodyText = bodyText
              .replaceAll('=C2=A0', ' ')
              .replaceAll('=E2=80=99', "'")
              .replaceAll('=20', ' ')
              .replaceAll('=\r\n', '')
              .replaceAll('=\n', '')
              .trim();
        } catch (e) {
          debugPrint('Error decoding body: $e');
        }

        email['body'] = bodyText;
        email['bodyLoaded'] = true;
      }

      await client.disconnect();
    } catch (e) {
      debugPrint('Error loading email body: $e');
      email['body'] = 'Error loading content. Please try again.';
    }
  }

  void _showEmailDetail(BuildContext context, Map<String, dynamic> email) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
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
                    child: email['bodyLoaded'] == false
                        ? Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 12),
                              const Text('Loading email content...'),
                              FutureBuilder(
                                future: _loadEmailBody(email),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done) {
                                    // Trigger rebuild after loading
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (context.mounted) {
                                        setState(() {});
                                      }
                                    });
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          )
                        : Text(
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
          );
        },
      ),
    );
  }
}