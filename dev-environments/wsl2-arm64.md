# 環境: wsl2-arm64（mobile）

## ハードウェア / OS

- Hostname: mobile
- OS: Ubuntu 24.04.4 LTS（Noble）
- Kernel: Linux 6.6.87.2-microsoft-standard-WSL2
- Arch: aarch64 (arm64)
- 実体: WSL2 上の Ubuntu。WSLg 経由で GUI / 音声利用可

## 主要ツール

- Flutter: tarball 直 install（`~/dev/tools/flutter`、stable 3.41.x 系）
  - **snap Flutter は使わない**。snap 同梱の sysroot が Ubuntu 20.04 相当で、Ubuntu 24.04 system lib（GLIBC 2.34/2.38）とリンク不整合を起こす（gstreamer / dw 系 plugin で undefined reference）
- Dart: Flutter 同梱
- Python: system 3.12 系
- LLVM/Clang: system 18（`lld` 必須）

## 音声まわり

- `libpulse0` あり、`libasound2t64` あり、`gstreamer1.0-pulseaudio` あり
- WSLg の PulseAudio 経由で出力されるので CLI `paplay` は動く
- 既知の制約:
  - **flutter_soloud（FFI）**: bundled .so（FLAC/Opus/Vorbis/Ogg）が x86_64 専用で arm64 リンク不可。`NO_XIPH_LIBS=1` で WAV のみ運用は可能。さらに miniaudio が `MA_NO_PULSEAUDIO` で意図的に PA を無効化しており、ALSA 直叩きも /dev/snd 不在で機能せず無音化する
  - **audioplayers**: GStreamer playbin 経由。snap Flutter とは GLIBC 不整合でビルド失敗。直 install Flutter なら build は通るが、`AudioPool.start` 経由のチェック音再生でアプリがフリーズする現象あり（再現性あり、原因未特定）
  - **paplay (process_sound_player)**: クリーンに鳴る。各起動に ~50-100ms かかる
  - **結論**: WSL2 では paplay 維持が現状のベスト。低レイテンシ音声は別環境で再評価する

## ライブラリ追加時のチェックリスト

1. `pubspec.yaml` 追加前に `~/.pub-cache/hosted/pub.dev/<lib>-*/{linux,src}/` に bundled binary があるか確認、`file` で arch 確認
2. ネイティブプラグインなら `linker error` の可能性を見越して `-DSOLOUD_BACKEND_*` のような compile-time マクロが切替られるか CMakeLists を確認
3. オーディオ系なら autoaudiosink → pulsesink の link が成立するか実機確認

## 参考 retrospective

- `~/retrospectives/2026-04-alarm-6.md` — チェック音遅延対策の試行錯誤
