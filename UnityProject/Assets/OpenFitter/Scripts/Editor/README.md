# OpenFitter - Unity Editor ツール

## 概要

OpenFitterシステムのためのエディター専用コンポーネントで、UIとワークフローツールを提供。

## コンポーネント

### OpenFitterWindow.cs

バッチ変換ワークフロー用のメインエディタウィンドウ。

### RBFDeformerEditor.cs

RBFDeformerコンポーネント用カスタムインスペクター。

### BoneDeformerEditor.cs

BoneDeformerコンポーネント用カスタムインスペクター。

### BindPoseCorrectorEditor.cs

BindPoseCorrectorコンポーネント用カスタムインスペクター。

### OpenFitterControllerEditor.cs

OpenFitterControllerコンポーネント用カスタムインスペクター。

## 数学

Editorスクリプトには複雑な数学演算なし。数学はRuntimeコンポーネントに委譲。

## ロジック

### OpenFitterWindow ワークフロー

**ウィンドウパス**：`Window → OpenFitter → Converter`

**パイプラインロジック**：

1. **入力検証**

   ```
   IF source_object == null THEN エラー
   IF rbf_json == null THEN エラー
   IF pose_json == null THEN エラー
   ```

2. **コンポーネントセットアップ**

   ```
   ソースプレハブをクローン → temp_instance
   RBFDeformerをアタッチ → rbf_jsonを割当
   BoneDeformerをアタッチ → pose_jsonを割当
   ```

3. **実行**

   ```
   BoneDeformer.ApplyPose()
   RBFDeformer.RunDeformationInEditor()
   BindPoseCorrector.CorrectBindPose()
   ```

4. **アセット作成**

   ```
   FOR each deformed_mesh:
     .assetファイルとして保存
   プレハブバリアントを作成
   保存メッシュをプレハブにリンク
   ```

5. **クリーンアップ**

   ```
   temp_instanceを破棄
   作成プレハブを選択
   ```

**出力命名規則**：

```
元：  "Clothing.prefab"
出力： "Clothing_[Fitted].prefab"
メッシュ： "Clothing_mesh_0.asset", "Clothing_mesh_1.asset", ...
```

### カスタムインスペクターロジック

#### RBFDeformerEditor

**表示**：

- JSONファイルドラッグ＆ドロップフィールド
- ターゲットメッシュリスト（読取専用）
- "Run Deformation"ボタン

**ボタンロジック**：

```csharp
if (GUILayout.Button("Run Deformation"))
{
    target.RunDeformationInEditor();
    EditorUtility.SetDirty(target);
}
```

即座に変形をトリガー + シーンをダーティにマーク。

#### BoneDeformerEditor

**表示**：

- JSONファイルドラッグ＆ドロップフィールド
- ルート変換セレクター
- ボーン軸ドロップダウン
- "Apply Pose" / "Reset Pose"ボタン

**ボタンロジック**：

```csharp
Apply: target.ApplyPose() + SetDirty
Reset: target.ResetPose() + SetDirty
```

#### BindPoseCorrectorEditor

**表示**：

- ターゲットSkinnedMeshRendererフィールド
- "Correct Bind Pose"ボタン

**ロジック**：

```
現在のボーン変換をキャプチャ
mesh.bindposes配列を更新
mesh.boneWeightsを更新
```

#### OpenFitterControllerEditor

**表示**：

- 全コンポーネント参照
- "Run Full Pipeline"ボタン

**パイプライン**：

```
BoneDeformer → RBFDeformer → BindPoseCorrector
```

## 機能

### OpenFitterWindow

**特徴**：

- ドラッグ＆ドロップでプレハブ割当
- ドラッグ＆ドロップでJSON割当
- 出力フォルダ選択
- ワンクリック変換
- 自動クリーンアップ

**ワークフローステップ**：

1. **ユーザー入力**
   - ソースプレハブを割当
   - RBF JSONファイルを割当
   - Pose JSONファイルを割当
   - （オプション）出力フォルダを設定

2. **"Convert & Save"をクリック**
   - ソースをインスタンス化
   - コンポーネントをアタッチ
   - 変形を実行
   - メッシュをアセットとして保存
   - プレハブを作成
   - 一時インスタンスを削除

3. **結果**
   - `[Fitted]`サフィックス付き新プレハブ作成
   - 変形メッシュを`.asset`ファイルとして保存
   - ProjectウィンドウでプレハブAuto選択

### カスタムインスペクター

**目的**：手動コンポーネントテスト用の使いやすいインターフェース提供。

**利点**：

- スクリプト不要
- 即座の視覚フィードバック
- Undo/Redoサポート
- ダーティフラグ管理

## 技術詳細

### アセット保存ロジック

**メッシュアセット**：

```csharp
string meshPath = AssetDatabase.GenerateUniqueAssetPath(basePath);
AssetDatabase.CreateAsset(mesh, meshPath);
```

プロジェクト内に永続メッシュアセットを作成。

**プレハブ作成**：

```csharp
GameObject prefabInstance = PrefabUtility.InstantiatePrefab(sourcePrefab);
// ... インスタンスを変更 ...
string prefabPath = outputFolder + "/" + name + "_[Fitted].prefab";
PrefabUtility.SaveAsPrefabAsset(prefabInstance, prefabPath);
```

カスタムメッシュ付きプレハブバリアントを作成。

### エディタユーティリティ

**SetDirty使用**：

```csharp
EditorUtility.SetDirty(target);
```

シーン/プレハブ変更が保存されることを保証。

**AssetDatabase更新**：

```csharp
AssetDatabase.SaveAssets();
AssetDatabase.Refresh();
```

アセット作成後にProjectウィンドウを更新。

### エラー処理

**入力検証**：

- 全必須フィールドのnullチェック
- ユーザー通知に`EditorUtility.DisplayDialog`使用

**プレビュークリーンアップ**：

- 一時GameObjectを破棄
- NativeArrayを破棄
- 未使用アセットをアンロード

## UIレイアウト

### OpenFitterWindow

```
┌─────────────────────────────────┐
│ OpenFitter Converter            │
├─────────────────────────────────┤
│ Source Object:   [___________]  │
│ RBF Data JSON:   [___________]  │
│ Pose Data JSON:  [___________]  │
│ Output Folder:   [___________]  │
│                                 │
│       [Convert & Save]          │
└─────────────────────────────────┘
```

### RBFDeformerEditor

```
┌─────────────────────────────────┐
│ RBF Deformer                    │
├─────────────────────────────────┤
│ Rbf Data Json:   [___________]  │
│                                 │
│ Targets: （自動入力）            │
│   └─ Body_Mesh                  │
│   └─ Accessories_Mesh           │
│                                 │
│     [Run Deformation]           │
└─────────────────────────────────┘
```

### BoneDeformerEditor

```
┌─────────────────────────────────┐
│ Bone Deformer                   │
├─────────────────────────────────┤
│ Pose Data Json:  [___________]  │
│ Root Transform:  [___________]  │
│ Bone Length Axis: [Y Axis ▼]   │
│                                 │
│  [Apply Pose]  [Reset Pose]     │
└─────────────────────────────────┘
```

## ワークフローパターン

### クイックテストワークフロー

```
1. GameObjectにRBFDeformerを追加
2. インスペクタでJSONを割当
3. "Run Deformation"をクリック
4. 即座に視覚プレビュー更新
```

### 本番ワークフロー

```
1. OpenFitterウィンドウを開く
2. プレハブ + JSONファイルをドラッグ
3. "Convert & Save"をクリック
4. 生成プレハブをシーンで使用
```

### 反復改良

```
1. Blenderデータを調整
2. JSONを再エクスポート
3. 変換を再実行
4. 結果を比較
```

## 依存関係

- UnityEditor名前空間（Editor専用）
- UnityEditor.AssetDatabase
- UnityEditor.EditorUtility
- UnityEditor.PrefabUtility
