import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_action_buttons.dart';
import '../widgets/chat_input_bar.dart';
import 'package:clanship_mobile_tradesman/core/theme/app_colors.dart';
import 'package:clanship_mobile_tradesman/core/di/injection.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/messages/chat_messages_bloc.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/messages/chat_messages_event.dart';
import 'package:clanship_mobile_tradesman/features/chat/presentation/bloc/messages/chat_messages_state.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clanship_mobile_tradesman/features/auth/presentation/bloc/auth_state.dart';

class ChatPage extends StatelessWidget {
  final String roomId;

  const ChatPage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChatMessagesBloc>(),
      child: _ChatPageContent(roomId: roomId),
    );
  }
}

class _ChatPageContent extends StatefulWidget {
  final String roomId;

  const _ChatPageContent({required this.roomId});

  @override
  State<_ChatPageContent> createState() => _ChatPageContentState();
}

class _ChatPageContentState extends State<_ChatPageContent> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    final authState = context.read<AuthBloc>().state;
    int userId = 0; // Default or fallback
    if (authState is AuthAuthenticated) {
      userId = int.tryParse(authState.user.id) ?? 0;
    }
    context.read<ChatMessagesBloc>().add(
      LoadChatMessages(widget.roomId, userId),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onScheduleTap() async {
    // 1. Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es'),
    );

    if (pickedDate == null) return;

    // 2. Pick Time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    // 3. Pick Price
    final String? price = await _showPriceDialog();

    if (price == null || price.isEmpty) return;

    // 4. Create Appointment Message
    final String formattedDate = DateFormat(
      'EEE d MMM',
      'es',
    ).format(pickedDate);
    final String formattedTime = pickedTime.format(context);

    if (!mounted) return;

    // For now we don't send appointment through websocket, but we could if the backend supports it.
    // Or just send a text representation.
    final text =
        'Cita agendada: $formattedDate a las $formattedTime, por \$ $price';
    context.read<ChatMessagesBloc>().add(SendMessage(widget.roomId, text));
  }

  Future<String?> _showPriceDialog() async {
    final TextEditingController priceController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ingresa el valor del servicio'),
        content: TextField(
          controller: priceController,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
          ],
          decoration: const InputDecoration(
            hintText: 'Ej: 35.000',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, priceController.text),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.trueBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Chat en tiempo real',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
              builder: (context, state) {
                if (state is ChatMessagesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatMessagesError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is ChatMessagesLoaded) {
                  final messages = state.messages;

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text('No hay mensajes en esta sala.'),
                    );
                  }

                  return ListView.builder(
                    reverse: false,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ChatBubble(message: message);
                    },
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),

          // Action Buttons (Agendar, Regresar, Rechazar)
          ChatActionButtons(
            onSchedule: _onScheduleTap,
            onBack: () => Navigator.pop(context),
            onReject: () {},
          ),

          // Input Bar
          ChatInputBar(
            controller: _controller,
            onSend: () {
              if (_controller.text.isNotEmpty) {
                context.read<ChatMessagesBloc>().add(
                  SendMessage(widget.roomId, _controller.text),
                );
                // The optimistic UI or websocket return will update the list
                _controller.clear();
              }
            },
            onMic: () {},
          ),
        ],
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final int value = int.parse(
      newValue.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    final formatter = NumberFormat.decimalPattern('es');
    final String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
