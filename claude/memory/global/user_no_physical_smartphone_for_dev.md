---
name: user-no-physical-smartphone-for-dev
description: ユーザーは開発検証に使える実機スマホを所有していない。モバイル検証は device-mode / emulator 代替が前提
type: user
originSessionId: 85a17199-ce6d-487d-9f3c-18a7c711f172
---

ユーザーは開発検証に使える実機スマートフォンを所有していない（2026-06-12、alarm HO-169 の実機確認依頼で判明）。

**How to apply:** モバイル対応タスクで「実機確認」を Human に依頼する計画を立てない。Web mobile は browser device-mode（DevTools mobile emulation）＋スクリーンショット、Android は emulator を検証手段のデフォルトにする。handoff の Acceptance Criteria に「実機手動確認」を完了条件として入れない。
