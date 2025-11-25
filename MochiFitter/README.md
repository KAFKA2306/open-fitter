# MochiFitter（上流リファレンス）

このディレクトリは、Nine Gates が GPLv3 で配布している Blender アドオン「MochiFitter」(ver. 2.5.0 / Blender 4.0 以降想定) のコードをそのまま保持したものです。OpenFitter 本体には組み込まず、挙動比較・フォーマット確認・再現テストのためのリファレンスとしてのみ利用します。公式アバターや BOOTH 配布プロファイルは同梱しません。

## 目的
- OpenFitter の実装と挙動差分を確認するための一次情報を残す。
- 上流が出力する RBF/ポーズ JSON 形式を確認し、互換性調査に使う。
- 公式配布に含まれていた外部 RBF 処理スクリプトを単体で再実行して結果を比較する。

## ディレクトリ構成
- `SaveAndApplyFieldAuto.py`  
  アドオン本体。Humanoid マッピング、シェイプキー差分からの RBF フィールド生成、ポーズ差分の保存/適用 UI（Sidebar > MochiFitter パネル）を提供。
- `rbf_multithread_processor.py`  
  RBF 補間をマルチプロセスで実行するスタンドアロン スクリプト。`temp_rbf_data.npz` を入力に、変形フィールドを計算して保存。
- `__init__.py`  
  Blender アドオン登録エントリ。`MochiFitter/deps` に配置したライブラリを動的にロードする。
- `LICENSE.txt`  
  GPLv3。既存のヘッダー・著作権表示は保持してください。

## RBF補間の数学的詳細

### Multi-Quadratic Biharmonic カーネル

実装で使用するRBFカーネル関数:

```math
\phi(r) = \sqrt{r^2 + \epsilon^2}
```

ここで `r` は制御点間の距離、`ε` はスケーリングパラメータ (デフォルト: 1.0)。

### 線形システムの構築

重み係数を求めるため、以下の拡大線形システムを解きます:

```math
\begin{bmatrix}
\Phi & P \\
P^T & 0
\end{bmatrix}
\begin{bmatrix}
w \\
a
\end{bmatrix}
=
\begin{bmatrix}
d \\
0
\end{bmatrix}
```

- `Φ`: RBFカーネル行列。実装では `scipy.spatial.distance.cdist` で二乗ユークリッド距離 `r²` を計算後、`φ = √(r² + ε²)` を適用
- `P`: 多項式基底行列。各行は `[1, c_x, c_y, c_z]` (制御点座標に定数項を追加)
- `w`: RBF重み係数ベクトル (制御点数 × 次元)
- `a`: 多項式係数ベクトル (4 × 次元)
- `d`: 制御点の変位ベクトル

計算手順 (`rbf_multithread_processor.py` 369-398行):

1. `dist_matrix = cdist(control_points, control_points, 'sqeuclidean')` で二乗距離行列を計算
2. `phi = np.sqrt(dist_matrix + epsilon**2)` でRBFカーネル行列を構築
3. 多項式項 `P` を制御点座標から生成
4. 拡大行列を構築して `np.linalg.solve` で解く

## 動作環境と依存

- 想定 Blender: 4.0 以降（Python 3.11 系）。古いバージョンは未検証
- 必須ライブラリ:
  - `numpy`: 数値計算
  - `scipy`: 距離計算 (`scipy.spatial.distance.cdist`) と最近接探索 (`scipy.spatial.KDTree`)
- オプショナルライブラリ:
  - `psutil`: メモリ使用量監視とCPU親和性設定。無い場合は保守的な設定で動作
- Blender 同梱 Python へのインストール例:

  ```bash
  <path_to_blender>/python/bin/python3.11 -m ensurepip --upgrade
  <path_to_blender>/python/bin/python3.11 -m pip install --target "$(pwd)/MochiFitter/deps" numpy scipy psutil
  ```

## アドオンの使い方（比較・検証用）
1. `MochiFitter` フォルダを ZIP 化し、Blender の「Preferences > Add-ons > Install」で選択して有効化。  
2. 3D ビュー Sidebar に追加される **MochiFitter** パネルから操作。`Save Deformation Data` でシェイプキー差分を保存し、`Apply Field Data` / `Apply Pose Difference` でターゲットへ適用する。ボタン名・挙動はスクリプト内実装に依存します。  
3. 生成された一時ファイル `temp_rbf_data.npz` をコマンドラインで再計算する場合:
   ```bash
   python rbf_multithread_processor.py temp_rbf_data.npz --max-workers 4 --batch-size 5000
   ```

   **主要オプション**:

   - `--max-workers N`: 最大ワーカー数 (デフォルト: 自動)
   - `--batch-size N`: バッチサイズ (デフォルト: 10000)
   - `--low-memory`: 低メモリモード
   - `--old-version`: 旧バージョン形式で保存
   出力を再インポートして結果を突き合わせることで、OpenFitter との数値差分を確認できます。

## 注意事項
- 本フォルダは上流コードのスナップショットです。大規模な改変は避け、必要な変更はパッチとして最小限に留めてください。
- Nine Gates 公式アバターや BOOTH 配布プロファイルをこのリポジトリに追加しないでください（ライセンス順守）。
- 配布・頒布する場合は GPLv3 に従い、ソース公開とライセンス表記を維持してください。
