import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';

class GuideMessagesScreen extends ConsumerStatefulWidget {
  const GuideMessagesScreen({super.key});

  @override
  ConsumerState<GuideMessagesScreen> createState() => _GuideMessagesScreenState();
}

class _GuideMessagesScreenState extends ConsumerState<GuideMessagesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mock data
    final conversations = List.generate(
      10,
      (index) => _ConversationData(
        id: 'conv-$index',
        visitorName: 'Visitor ${index + 1}',
        lastMessage: index % 3 == 0
            ? 'Yes, that sounds perfect!'
            : index % 3 == 1
            ? 'Can we meet at 3 PM instead?'
            : 'Thank you for the information!',
        timestamp: '${index + 1}h ago',
        unreadCount: index % 5 == 0 ? index + 1 : 0,
        isOnline: index % 4 == 0,
        avatarUrl: 'https://via.placeholder.com/50',
        hasBooking: index % 2 == 0,
        bookingStatus: index % 2 == 0 ? (index % 4 == 0 ? 'pending' : 'upcoming') : null,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Conversations List
          Expanded(
            child: conversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppDimensions.paddingL),
                        Text(
                          'No messages yet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: AppDimensions.paddingM),
                        Text(
                          'Messages from visitors will appear here',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      return _ConversationTile(
                        conversation: conversations[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Messages',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              ListTile(
                leading: const Icon(Icons.all_inbox, color: AppColors.accentTeal),
                title: const Text('All Messages'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.pending, color: AppColors.accentGolden),
                title: const Text('Pending Bookings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.event, color: AppColors.info),
                title: const Text('Upcoming Bookings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.mark_chat_unread, color: AppColors.error),
                title: const Text('Unread Only'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppDimensions.paddingL),
            ],
          ),
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final _ConversationData conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(conversation.avatarUrl),
                onBackgroundImageError: (_, __) {},
                child: conversation.avatarUrl.isEmpty
                    ? Text(
                        conversation.visitorName[0],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (conversation.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  conversation.visitorName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                ),
              ),
              Text(
                conversation.timestamp,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: conversation.unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                    ),
                  ),
                  if (conversation.unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentTeal,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                      ),
                      child: Text(
                        conversation.unreadCount.toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
              if (conversation.hasBooking) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 14,
                      color: _getBookingStatusColor(conversation.bookingStatus),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getBookingStatusLabel(conversation.bookingStatus),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _getBookingStatusColor(conversation.bookingStatus),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          onTap: () {
            // Navigate to chat screen
          },
        ),
        const Divider(height: 1),
      ],
    );
  }

  Color _getBookingStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return AppColors.accentGolden;
      case 'upcoming':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getBookingStatusLabel(String? status) {
    if (status == null) return '';
    return '${status[0].toUpperCase()}${status.substring(1)} Booking';
  }
}

class _ConversationData {
  final String id;
  final String visitorName;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isOnline;
  final String avatarUrl;
  final bool hasBooking;
  final String? bookingStatus;

  _ConversationData({
    required this.id,
    required this.visitorName,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isOnline,
    required this.avatarUrl,
    required this.hasBooking,
    this.bookingStatus,
  });
}
