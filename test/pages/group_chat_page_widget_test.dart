import 'package:coordimate/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coordimate/pages/group_chat_page.dart';
import 'package:mockito/mockito.dart';
import 'package:coordimate/components/avatar.dart';
import '../test.mocks.dart';

void main() {
  late MockWebSocketChannel mockWebSocketChannel;
  late MockWebSocketSink mockSink;

  setUp(() {
    mockWebSocketChannel = MockWebSocketChannel();
    mockSink = MockWebSocketSink();
  });

  Widget createGroupChatPage() {
    return const MaterialApp(
      home: GroupChatPage(
        title: 'Group Chat',
        userId: 'user1',
        groupId: 'group1',
        memberAvatars: {
          'user1': Avatar(userId: 'user1', size: 30),
          'user2': Avatar(userId: 'user2', size: 30),
        },
        memberUsernames: {
          'user1': 'User One',
          'user2': 'User Two',
        },
        chatMessages: [],
      ),
    );
  }

  testWidgets('renders the GroupChatPage correctly', (WidgetTester tester) async {
    // Assign mock to AppState
    AppState.webSocketChannel = mockWebSocketChannel;
    AppState.testMode = true;

    // Stub the WebSocketChannel's sink and stream
    when(AppState.webSocketChannel!.sink).thenReturn(mockSink);
    when(AppState.webSocketChannel!.stream).thenAnswer((_) => const Stream.empty());

    // when(mockSink.add(any)).thenReturn(null);  // For adding messages
    when(mockSink.close(any, any)).thenAnswer((_) => Future.value());

    await tester.pumpWidget(createGroupChatPage());

    // Verify the title of the page is rendered
    expect(find.text('Group Chat'), findsOneWidget);

    // Verify the TextField for message input is present
    expect(find.byType(TextField), findsOneWidget);

    // Verify the send button is present
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

}
