# OpenFitter - Unity パッケージ

## 概要

RBFメッシュ変形とボーンポーズ転送によるアバター衣装フィッティングのためのUnityパッケージ。

## 構成

```
OpenFitter/
└── Scripts/
    ├── Runtime/    - コアコンポーネント（RBF、ボーン、バインドポーズ）
    └── Editor/     - エディタツールとインスペクター
```

## インストール

この`OpenFitter`フォルダ全体をUnityプロジェクトの`Assets`ディレクトリにコピー。

## クイックスタート

1. **Blenderからエクスポート**：
   - OpenFitter BlenderアドオンでRBFとPoseのJSONファイルをエクスポート

2. **Unityにインポート**：
   - JSONファイルをUnityプロジェクトにインポート
   - `Window → OpenFitter → Converter`を開く
   - ソースプレハブとJSONファイルを割当
   - "Convert & Save"をクリック

3. **結果**：
   - `[Fitted]`サフィックス付き新プレハブが作成される

## コンポーネント

詳細なドキュメントは [Scripts/README.md](Scripts/README.md) を参照。

## 依存関係

- Unity >= 2019.4
- Newtonsoft.Json
- Unity.Burst
- Unity.Mathematics
- Unity.Collections
