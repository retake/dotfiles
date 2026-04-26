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

## Android 開発（2026-04-24 検証）

### セットアップ手順

1. **JDK 17**（Android Gradle Plugin 8.x / Flutter 3.41 が要求）
   ```bash
   sudo apt install -y openjdk-17-jdk
   # ~/.bashrc
   export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
   export PATH="$JAVA_HOME/bin:$PATH"
   export ANDROID_HOME=$HOME/android-sdk
   export ANDROID_SDK_ROOT=$HOME/android-sdk
   ```
2. **arm64 adb**（Google 公式の `/home/keita/android-sdk/platform-tools/adb` は x86_64 ELF で arm64 上で動かない）
   ```bash
   sudo apt install -y adb fastboot
   # /usr/bin/adb → /usr/lib/android-sdk/platform-tools/adb (ELF aarch64)
   ```
3. **x86_64 build-tools（aapt2 等）を qemu で透過実行**
   ```bash
   sudo apt install -y qemu-user-static binfmt-support
   sudo dpkg --add-architecture amd64
   # amd64 用の apt ソース追加（arm64 Ubuntu は ports.ubuntu.com のみ参照）
   sudo tee /etc/apt/sources.list.d/amd64.list <<'EOF'
   deb [arch=amd64] http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
   deb [arch=amd64] http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
   deb [arch=amd64] http://archive.ubuntu.com/ubuntu noble-security main restricted universe multiverse
   EOF
   sudo apt update
   sudo apt install -y libc6:amd64 libstdc++6:amd64 zlib1g:amd64
   ```
4. **Flutter 側設定**
   ```bash
   flutter config --android-sdk /home/keita/android-sdk
   yes | flutter doctor --android-licenses
   flutter doctor -v  # [✓] Android toolchain を確認
   ```

### 既知の制約

- **Google 配布の Android SDK バイナリは x86_64 のみ**。公式 arm64 Linux バイナリは未提供。build-tools は qemu-user-static 経由で動かす（aapt2 は 1〜数秒のオーバーヘッド、初回 APK ビルドは 5〜10 分）
- **`flutter build apk` は `build.gradle.kts` を自動書き換えする**ことがある（`Upgrading build.gradle.kts` メッセージ）。minSdk などをカスタム編集したい場合は `./gradlew assembleDebug` を直接叩くほうが安全
- **Flutter 3.41 系の minSdk は 24（Android 7.0）以上**。`shared_preferences_android`・`path_provider_android`・`wakelock_plus` 等、主要プラグインが全て API 24 を要求するため、override で下げると実行時にクラッシュする。Android 6.x 以下の端末では起動不可

### 実機接続

- USB 接続は **usbipd-win**（Windows）で WSL2 に passthrough
  ```powershell
  # Windows PowerShell（管理者）
  winget install --exact dorssel.usbipd-win
  usbipd list
  usbipd bind --busid <BUSID>
  usbipd attach --wsl --busid <BUSID>
  ```
- 端末側は「ファイル転送 / MTP」モード + USB デバッグ有効
- `usbipd-win` は `edevmon` フィルタ競合で警告を出すことがあるが、多くは無害
- 代替: Google Drive / Gmail 経由で APK を sideload、または `adb connect <ip>:<port>` のワイヤレスデバッグ

## 参考 retrospective

- `~/retrospectives/2026-04-alarm-6.md` — チェック音遅延対策の試行錯誤
