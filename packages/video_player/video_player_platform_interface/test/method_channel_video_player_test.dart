// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:video_player_platform_interface/method_channel_video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$VideoPlayerPlatform', () {
    test('$MethodChannelVideoPlayer() is the default instance', () {
      expect(VideoPlayerPlatform.instance,
          isInstanceOf<MethodChannelVideoPlayer>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        VideoPlayerPlatform.instance = ImplementsVideoPlayerPlatform();
      }, throwsA(isInstanceOf<AssertionError>()));
    });

    test('Can be mocked with `implements`', () {
      final ImplementsVideoPlayerPlatform mock =
          ImplementsVideoPlayerPlatform();
      when(mock.isMock).thenReturn(true);
      VideoPlayerPlatform.instance = mock;
    });

    test('Can be extended', () {
      VideoPlayerPlatform.instance = ExtendsVideoPlayerPlatform();
    });
  });

  group('$MethodChannelVideoPlayer', () {
    const MethodChannel channel = MethodChannel('flutter.io/videoPlayer');
    final List<MethodCall> log = <MethodCall>[];
    final MethodChannelVideoPlayer player = MethodChannelVideoPlayer();

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
      });
    });

    tearDown(() {
      log.clear();
    });

    test('init', () async {
      await player.init();
      expect(
        log,
        <Matcher>[isMethodCall('init', arguments: null)],
      );
    });

    test('dispose', () async {
      await player.dispose(1);
      expect(
        log,
        <Matcher>[
          isMethodCall('dispose', arguments: <String, Object>{
            'textureId': 1,
          })
        ],
      );
    });

    test('create with asset', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return <String, dynamic>{'textureId': 3};
      });
      final int textureId = await player.create(<String, dynamic>{
        'asset': 'someAsset',
        'package': 'somePacket',
      });
      expect(
        log,
        <Matcher>[
          isMethodCall('create', arguments: <String, Object>{
            'asset': 'someAsset',
            'package': 'somePacket'
          })
        ],
      );
      expect(textureId, 3);
    });

    test('create with network', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return <String, dynamic>{'textureId': 3};
      });
      final int textureId = await player.create(<String, dynamic>{
        'uri': 'someUri',
        'formatHint': 'dash',
      });
      expect(
        log,
        <Matcher>[
          isMethodCall('create', arguments: <String, Object>{
            'uri': 'someUri',
            'formatHint': 'dash'
          })
        ],
      );
      expect(textureId, 3);
    });

    test('create with file', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return <String, dynamic>{'textureId': 3};
      });
      final int textureId = await player.create(<String, dynamic>{
        'uri': 'someUri',
      });
      expect(
        log,
        <Matcher>[
          isMethodCall('create', arguments: <String, Object>{
            'uri': 'someUri',
          })
        ],
      );
      expect(textureId, 3);
    });

    test('setLooping', () async {
      await player.setLooping(1, true);
      expect(
        log,
        <Matcher>[
          isMethodCall('setLooping', arguments: <String, Object>{
            'textureId': 1,
            'looping': true,
          })
        ],
      );
    });

    test('play', () async {
      await player.play(1);
      expect(
        log,
        <Matcher>[
          isMethodCall('play', arguments: <String, Object>{
            'textureId': 1,
          })
        ],
      );
    });

    test('pause', () async {
      await player.pause(1);
      expect(
        log,
        <Matcher>[
          isMethodCall('pause', arguments: <String, Object>{
            'textureId': 1,
          })
        ],
      );
    });

    test('setVolume', () async {
      await player.setVolume(1, 0.7);
      expect(
        log,
        <Matcher>[
          isMethodCall('setVolume', arguments: <String, Object>{
            'textureId': 1,
            'volume': 0.7,
          })
        ],
      );
    });

    test('seekTo', () async {
      await player.seekTo(1, 12345);
      expect(
        log,
        <Matcher>[
          isMethodCall('seekTo', arguments: <String, Object>{
            'textureId': 1,
            'location': 12345,
          })
        ],
      );
    });

    test('getPosition', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return 234;
      });

      final Duration position = await player.getPosition(1);
      expect(
        log,
        <Matcher>[
          isMethodCall('position', arguments: <String, Object>{
            'textureId': 1,
          })
        ],
      );
      expect(position, Duration(milliseconds: 234));
    });
  });
}

class ImplementsVideoPlayerPlatform extends Mock
    implements VideoPlayerPlatform {}

class ExtendsVideoPlayerPlatform extends VideoPlayerPlatform {}