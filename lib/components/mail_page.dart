import 'package:flutter/material.dart';

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

    try {
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        emails = [
          {
            'id': 1,
            'subject': 'Notice: Annual Meeting 2024',
            'from': 'noticeboard@meconlimited.co.in',
            'date': DateTime.now().subtract(const Duration(hours: 2)),
            'body': 'Dear Employees,\n\nWe are pleased to announce the Annual Meeting for 2024 will be held on December 15, 2024, at 10:00 AM in the main conference hall.\n\nAgenda:\n1. Annual Performance Review\n2. Budget Discussion for 2025\n3. New Policies Implementation\n4. Q&A Session\n\nPlease confirm your attendance by December 10, 2024.\n\nBest regards,\nHR Department',
          },
          {
            'id': 2,
            'subject': 'Safety Guidelines Update',
            'from': 'noticeboard@meconlimited.co.in',
            'date': DateTime.now().subtract(const Duration(days: 1)),
            'body': 'All Staff,\n\nUpdated safety guidelines have been implemented effective immediately. Please review the following:\n\n1. Hard hats are mandatory in construction areas\n2. Safety boots must be worn at all times on site\n3. Report any safety hazards immediately to your supervisor\n\nYour cooperation is essential for maintaining a safe work environment.\n\nSafety Department',
          },
          {
            'id': 3,
            'subject': 'Holiday Schedule - December 2024',
            'from': 'noticeboard@meconlimited.co.in',
            'date': DateTime.now().subtract(const Duration(days: 2)),
            'body': 'Holiday Schedule for December 2024:\n\nDecember 25: Christmas Day - Office Closed\nDecember 26: Boxing Day - Office Closed\nDecember 31: New Year Eve - Half Day\nJanuary 1: New Year Day - Office Closed\n\nPlease plan your work accordingly.\n\nAdmin Department',
          },
          {
            'id': 4,
            'subject': 'Training Program Registration',
            'from': 'noticeboard@meconlimited.co.in',
            'date': DateTime.now().subtract(const Duration(days: 3)),
            'body': 'Registration is now open for the Professional Development Training Program.\n\nProgram Details:\n- Duration: 3 weeks\n- Start Date: January 15, 2025\n- Topics: Leadership, Project Management, Technical Skills\n\nInterested employees should register by December 30, 2024.\n\nTraining Department',
          },
          {
            'id': 5,
            'subject': 'Parking Policy Changes',
            'from': 'noticeboard@meconlimited.co.in',
            'date': DateTime.now().subtract(const Duration(days: 5)),
            'body': 'Effective December 1, 2024, new parking arrangements:\n\n- Reserved spots for senior management\n- Designated areas for visitors\n- Two-wheeler parking in Block A\n- Car parking in Block B\n\nPlease follow the new guidelines to avoid any inconvenience.\n\nFacilities Management',
          },
        ];
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        error = 'Failed to connect to email server: ${e.toString()}';
        isLoading = false;

        emails = [
          {
            'id': 1,
            'subject': 'Notice: Annual Meeting 2024',
            'from': 'noticeboard@meconlimited.co.in',
            'date': DateTime.now().subtract(const Duration(hours: 2)),
            'body': 'Dear Employees,\n\nWe are pleased to announce the Annual Meeting for 2024 will be held on December 15, 2024, at 10:00 AM in the main conference hall.\n\nAgenda:\n1. Annual Performance Review\n2. Budget Discussion for 2025\n3. New Policies Implementation\n4. Q&A Session\n\nPlease confirm your attendance by December 10, 2024.\n\nBest regards,\nHR Department',
          },
          {
            'id': 2,
            'subject': 'Safety Guidelines Update',
            'from': 'noticeboard@meconlimited.co.in',
            'date': DateTime.now().subtract(const Duration(days: 1)),
            'body': 'All Staff,\n\nUpdated safety guidelines have been implemented effective immediately. Please review the following:\n\n1. Hard hats are mandatory in construction areas\n2. Safety boots must be worn at all times on site\n3. Report any safety hazards immediately to your supervisor\n\nYour cooperation is essential for maintaining a safe work environment.\n\nSafety Department',
          },
          {
            'id': 3,
            'subject': 'Holiday Schedule - December 2024',
            'from': 'noticeboard@meconlimited.co.in',
            'date': DateTime.now().subtract(const Duration(days: 2)),
            'body': 'Holiday Schedule for December 2024:\n\nDecember 25: Christmas Day - Office Closed\nDecember 26: Boxing Day - Office Closed\nDecember 31: New Year Eve - Half Day\nJanuary 1: New Year Day - Office Closed\n\nPlease plan your work accordingly.\n\nAdmin Department',
          },
        ];
      });

      debugPrint('IMAP connection failed: $e');
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
              Text(email['body']),
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