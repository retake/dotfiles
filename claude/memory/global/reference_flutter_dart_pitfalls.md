---
name: Flutter/Dart の落とし穴（alarm プロジェクト由来）
description: alarm 開発で踏んだ Flutter/Dart 固有の地雷。Riverpod dispose、pumpAndSettle、Timer.periodic、ensureVisible、trailing commas、一時オーバーライドパターン
type: reference
originSessionId: 4f24d32d-4154-4f7a-9c77-25fb2d1d9491
---
## 状態管理（Riverpod）

- **`ConsumerStatefulWidget` の dispose で `ref` は使えない**。外部サービスへのクリーンアップ呼び出しは initState で参照をキャッシュ（例: `_service = ref.read(serviceProvider)`）し、dispose ではキャッシュ経由で呼ぶ。これを守らないと `Cannot use "ref" after the widget was disposed` で広範囲のテストが壊れる

## プラットフォーム差（Linux / Web / モバイル）

- **プラットフォーム依存パッケージ**（`wakelock_plus` 等）は `kIsWeb` / `Platform` チェックで未対応環境を明示的に弾く。パッケージ側の例外に依存しない
- **音声再生・ウィンドウアイコン・WakeLock などのプラットフォーム固有機能**は `domain/` に抽象インタフェースを置き、`infrastructure/` で実装を分ける

## Widget テスト（flutter_test）

- **Widget finder は位置依存を避ける**。`find.byType(X).first` は UI 拡張で壊れる。`find.widgetWithText(X, 'label')` でラベルによる一意特定を優先
- **`pumpAndSettle` は非同期ループを持つ副作用でタイムアウト**する。`pump()` + `pump(Duration(milliseconds: N))` で必要最小限だけ進める
- **Timer.periodic の実時間テストは不安定**。カウントダウン系は `CountdownTimer` インタフェースを Fake で差し替え、tick を手動注入して検証する
- **UI 並び替え / 再配置を行うときは `ensureVisible` を前提にした finder 戦略**: `tester.tap(find.text(...))` はスクロールしないため、`await tester.ensureVisible(...)` → `pumpAndSettle()` → `tap(...)` の順で書く

## Lint・フォーマット

- **`require_trailing_commas` は `dart format` では解消しない**（analyzer の lint ルール）。`flutter analyze` と `dart format` を両方回す
- **テストのラベルは仕様語で書く**。メソッド名型ではなく外から観測される振る舞いを書く

## SnackBar / ScaffoldMessenger

- **`hideCurrentSnackBar` は内部タイマーが発火しても非表示にならないケースがある**。SnackBar を確実に消すには `removeCurrentSnackBar` を使う（REQ-39 completeDeparture 修正で発覚）

## 設計パターン

- **一時オーバーライドパターン**: 永続データを汚さず進行中セッションでのみ変更を効かせたい場合、state に `overrideX: T?` を追加し `effectiveX` getter で合成。`DepartureScheduleState` の override フィールドが例
