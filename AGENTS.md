# Repository Guidelines

## プロジェクト構成
- `UnityProject/Assets/OpenFitter/Scripts/Runtime`: RBF変形／ボーン転送／バインドポーズ補正の本体。数式メモは `Runtime/README.md`。
- `UnityProject/Assets/OpenFitter/Scripts/Editor`: コンバーターウィンドウ（`Window → OpenFitter → Converter`）とカスタムインスペクター。手順は `Editor/README.md`。
- `blender_addon`: `rbf_exporter.py` と `bone_exporter.py` を含むBlenderエクスポーター。使い方は `blender_addon/README.md`。
- `.gitignore` はUnity標準の生成物・IDEゴミのみ除外の最小構成。通常のソースやドキュメントはそのまま追跡対象。

## 本家（MochiFitter）との違いと公開情報
- 本家: Nine Gates がGPLv3で公開・販売する「もちふぃった～」(Booth)。Unity 2022.3.22f1想定、メニューは `Tools → MochiFitter`、VRChat向け衣装サイズ自動合わせを提供。
- 本プロジェクト: 本家のGPLコアをもとにしたオープン実装（Alpha）。ウィンドウは `Window → OpenFitter → Converter`、Blenderエクスポーター同梱、モデル資産は付属せず部分互換。Unity 2019.4+で動作確認、2022系でも検証推奨。
- 差分の意識点: 本家が同梱する公式アバター・サンプルは含めない／コピーしない。UIパス・出力命名（`[Fitted]`）・JSON入力2種（RBF/Pose）の運用は本プロジェクト特有。

## ビルド・テスト・開発コマンド
- **Unity (2019.4+; 本家互換検証は 2022.3.22f1 で)**: `UnityProject` を開き、Converterでプレハブを処理し `[Fitted]` 付きプレハブとメッシュ `.asset` が生成されることを確認。`Newtonsoft.Json` / `Burst` / `Collections` / `Mathematics` を導入済みにしておく。
- **スクリプト再読み込み確認**: `Assets → Reimport All` またはドメインリロードでコンパイルエラー・警告を潰す。
- **Blenderアドオン**: `blender_addon` をzip化するかフォルダ指定でインストール。`numpy` が無いとエクスポート時に落ちるので注意。
- **任意Lint**: `python -m pyflakes blender_addon/*.py` で静的チェック（設定ファイル不要、警告ゼロを維持）。

## コーディング規約
- **C# (Unity)**: インデント4スペース。クラス／メソッドはPascalCase、フィールドはcamelCase。シリアライズは `[SerializeField] private ...` を基本に。`var`は型が明確なときのみ。`NativeArray`等は `OnDisable`/`OnDestroy` で確実にDispose。
- **Python (Blender)**: PEP8、4スペース、snake_case。乱数シードは固定、オペレーターのツールチップやメッセージは既存の語調に合わせる。
- コメントは座標変換や多項式係数補正など読み解きに時間がかかる箇所だけに短く付与。

## テスト指針
- 自動テストは未整備。変更後は小さなメッシュでRBF/PoseをBlenderから書き出し、Unity Converterで実行し、生成プレハブが正しく表示されるか目視確認。
- 追加ロジックには軽量なEditModeテストを `UnityProject/Assets/Tests` (NUnit) に置くと良い。サンプルアセットは最小限・小容量で。
- Converterが使う `[Fitted]` 接尾辞と出力ディレクトリ規約を崩さないこと。

## コミット／PR ガイドライン
- コミットメッセージは既存の短い命令形＋Title Caseを踏襲（例: `Add OpenFitterWindow`, `Cleanup: Remove unused scripts`）。範囲を明確にし、不要に長文にしない。
- PRには変更点・目的・検証手順（Unity/Blenderのスクショ歓迎）・新規依存を記載し、関連Issueがあればリンク。
- C#ファイルのGPL-3ヘッダーは保持。プロプライエタリ資産や有償Unityパッケージはコミットしない。

## セキュリティと設定ヒント
- エクスポートJSONにボーン名等が含まれるので、個人名やクライアント固有名は避ける。
- Unityアセットは肥大しがち。可能なら手順を記載して再生成可能にし、どうしても必要なバイナリは un-ignore を明示して由来をコメントに残す。
