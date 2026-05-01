import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:splukk/core/router/app_router.gr.dart';

@RoutePage()
class ChatPage extends StatefulWidget {
  final String listingId;
  final String farmerName;
  final String? farmerUid;

  const ChatPage({
    super.key,
    @PathParam('listingId') required this.listingId,
    @QueryParam('farmerName') this.farmerName = 'Çiftçi',
    @QueryParam('farmerUid') this.farmerUid,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'text': 'Merhaba! Çiftliğimizle ilgilendiğiniz için teşekkürler. Size nasıl yardımcı olabilirim?',
      'time': '10:00',
    },
    {
      'isMe': true,
      'text': 'Merhaba, bu hafta sonu için meyve toplamaya gelmek istiyoruz. Hangi saatler arası açıksınız?',
      'time': '10:05',
    },
    {
      'isMe': false,
      'text': 'Cumartesi ve Pazar günleri 09:00 - 18:00 arası açığız. Bekleriz!',
      'time': '10:07',
    },
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'isMe': true,
        'text': _controller.text.trim(),
        'time': TimeOfDay.now().format(context),
      });
      _controller.clear();
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: LucideIcons.image,
                  label: 'Fotoğraf',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Galeri açılıyor...')),
                    );
                  },
                ),
                _buildAttachmentOption(
                  icon: LucideIcons.video,
                  label: 'Video',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Video seçimi açılıyor...')),
                    );
                  },
                ),
                _buildAttachmentOption(
                  icon: LucideIcons.fileText,
                  label: 'Belge',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dosya seçimi açılıyor...')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF1A1A1A)),
          onPressed: () => context.router.maybePop(),
        ),
        title: GestureDetector(
          onTap: () {
            if (widget.farmerUid != null) {
              context.router.push(FarmerPublicProfileRoute(farmerUid: widget.farmerUid!));
            }
          },
          child: Row(
            children: [
              CircleAvatar(
              backgroundColor: const Color(0xFF2B8C5F).withOpacity(0.1),
              child: Text(
                widget.farmerName.isNotEmpty ? widget.farmerName.substring(0, 1).toUpperCase() : '?',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF2B8C5F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.farmerName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'Çevrimiçi',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF2B8C5F),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical, color: Color(0xFF1A1A1A)),
            onSelected: (value) {
              if (value == 'clear') {
                setState(() => _messages.clear());
              } else if (value == 'block') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kullanıcı engellendi.')),
                );
              } else if (value == 'report') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kullanıcı şikayet edildi.')),
                );
              } else if (value == 'profile' && widget.farmerUid != null) {
                context.router.push(FarmerPublicProfileRoute(farmerUid: widget.farmerUid!));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(LucideIcons.user, size: 18),
                    const SizedBox(width: 8),
                    Text('Profili Görüntüle', style: GoogleFonts.inter()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(LucideIcons.trash2, size: 18),
                    const SizedBox(width: 8),
                    Text('Sohbeti Temizle', style: GoogleFonts.inter()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle, size: 18),
                    const SizedBox(width: 8),
                    Text('Şikayet Et', style: GoogleFonts.inter()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    const Icon(LucideIcons.ban, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Kullanıcıyı Engelle',
                      style: GoogleFonts.inter(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF2B8C5F) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: isMe ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.plus, color: Color(0xFF2B8C5F)),
                    onPressed: _showAttachmentOptions,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Mesaj yazın...',
                          hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2B8C5F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
