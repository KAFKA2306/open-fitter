# OpenFitter - Unity Scripts ルート

## 概要

全てのOpenFitter Unityスクリプトのコンテナディレクトリ。

## 構成

```
Scripts/
├── Runtime/     - コア機能（RBF、ボーン変形）
└── Editor/      - Unity Editorツールとインスペクター
```

## 目的

このディレクトリはUnityスクリプトを以下のように整理：

- **Runtime**：ランタイムで動作するコンポーネント（ゲームにビルド可能）
- **Editor**：Unity Editorでのみ動作するツール（ビルドに含まれない）

## 数学

数学はRuntimeコンポーネントに実装。詳細は [Runtime/README.md](Runtime/README.md) を参照：

- RBF補間式
- ボーン変換数学
- 座標系変換

## ロジック

### Runtimeロジック

- RBFメッシュ変形
- ボーンポーズ転送
- バインドポーズ補正

### Editorロジック

- アセット作成ワークフロー
- カスタムインスペクターUI
- バッチ変換パイプライン

## 機能

### Runtimeコンポーネント

以下のタイミングでアバター衣装フィッティングを可能に：

- エディタ時（プレビュー）
- ビルド時（ベイクアセット）

### Editorツール

使いやすいワークフローを提供：

- ドラッグ＆ドロップインターフェース
- ワンクリック変換
- アセット管理

詳細なドキュメントはサブディレクトリREADMEを参照：

- [Runtime/README.md](Runtime/README.md) - コア実装
- [Editor/README.md](Editor/README.md) - Editorツール
