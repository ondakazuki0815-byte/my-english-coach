# Vercel 移行手順書 — My English Coach

**作成日**: 2026-05-16
**対象**: Puttyarin（ウェブ構築学習中）
**移行元**: Netlify（無料枠上限到達のため停止予定）
**移行先**: Vercel（無料 Hobby プラン）

> ✅ **2026-05-16 移行完了**
> - 新URL: **https://my-english-coach.vercel.app**
> - 設定ファイル7か所のURL更新済み
> - deploy.sh によるワンコマンドデプロイが運用中
> 以下は移行手順の記録（再現用 / 学習教材として保全）

このドキュメントは coach-ai（AI活用コーチ）視点の **ウェブ構築ノウハウ教材** も兼ねています。
手順を追うだけでも動きますが、「なぜそうするか」のコメントを各所に入れています。

---

## 1. なぜ Vercel か（判断の根拠）

| 観点 | Netlify（現状） | Vercel（移行先） | GitHub Pages（候補3） |
|---|---|---|---|
| 無料枠上限 | **到達済み（停止中）** | 100GB帯域 / 月、毎月リセット | 制限ほぼなし、ただし1GB/月のソフト目安 |
| GitHub連携 | あり | あり（より深い統合） | 同じ Github 内なので最強連携 |
| 自動デプロイ | main push で自動 | main push で自動 | main push で自動 |
| プレビューデプロイ | あり | あり（より使いやすい） | なし |
| 静的サイト対応 | ◎ | ◎ | ◎（静的のみ） |
| Webhook / Functions | あり（無料枠あり） | あり（Edge Functions 無料枠あり） | なし |
| CLI 体験 | netlify-cli | vercel CLI（よりシンプル） | gh CLI |
| ドメイン取得 | 内部購入可 | 内部購入可 | カスタムドメイン無料 |

**選択理由**:
- Netlify が使えない以上、選択肢は Vercel か GitHub Pages
- 将来 Edge Functions（サーバーレス）を入れる可能性が少しでもあるなら Vercel が有利
- GitHub Pages は静的のみで拡張余地がない
- Vercel CLI が手元から `vercel --prod` の1コマンドでデプロイできるので、deploy.sh と相性がよい

→ **Vercel 一択**。

---

## 2. 事前準備（5分）

### 2-1. Vercel アカウント作成

1. ブラウザで https://vercel.com にアクセス
2. 右上「**Sign Up**」をクリック
3. **「Continue with GitHub」を選択** ← これが最重要。GitHub と紐付けることで以降の連携が一発で済む
4. GitHub の認証画面が出たら「Authorize Vercel」をクリック
5. ユーザー名・プラン（Hobby = 無料）を選択して完了

✏️ **なぜ GitHub 連携？**
GitHub のリポジトリを「ここを公開して」と Vercel に指差すだけで済みます。手動でアップロードする必要なし。Netlify でやった連携と全く同じ仕組み。

---

## 3. デプロイ手順 — Web UI 経由（初心者推奨ルート）

### 3-1. プロジェクト作成

1. https://vercel.com/dashboard を開く
2. 右上「**Add New...**」→ 「**Project**」をクリック
3. 「Import Git Repository」のセクションで `ondakazuki0815-byte/my-english-coach` を探す
   - 出てこない場合: 「**Adjust GitHub App Permissions**」をクリックして、対象リポジトリへのアクセスを付与
4. リポジトリ横の「**Import**」をクリック

### 3-2. 設定（重要）

「Configure Project」画面で:

| 項目 | 設定値 | コメント |
|---|---|---|
| **Project Name** | `my-english-coach`（デフォルトのまま） | これがURLになる: `my-english-coach.vercel.app` |
| **Framework Preset** | **Other** を選択 | 静的HTML/CSS/JSサイトなのでフレームワーク不要 |
| **Root Directory** | `./`（デフォルト） | リポジトリのルートが公開対象 |
| **Build Command** | **空のまま** | ビルド不要（HTMLそのまま） |
| **Output Directory** | **空のまま** | ルートを直接配信 |
| **Install Command** | **空のまま** | 依存関係なし |
| **Environment Variables** | なし | 今回不要 |

✏️ **Framework Preset を「Other」にする理由**
このサイトは Next.js / React / Nuxt などのフレームワークを使っていない「素の HTML/CSS/JS」。`Other` を選ぶと Vercel は余計なビルドをせず、ファイルをそのまま配信します。間違えて Next.js などを選ぶとビルドエラーで失敗します。

3. 「**Deploy**」ボタンをクリック

### 3-3. デプロイ完了確認（約30秒〜2分）

- 画面に「🎉 Congratulations!」と花火アニメーションが出る
- プレビュー画面の下に発行URLが表示される: `https://my-english-coach-{random}.vercel.app`
- 「**Continue to Dashboard**」をクリック

### 3-4. 発行URLの確認

ダッシュボードのプロジェクト詳細画面に、Production URL が3種類表示される:

- `https://my-english-coach.vercel.app`（メインドメイン、推奨）
- `https://my-english-coach-{username}.vercel.app`（ユーザー名付き）
- `https://my-english-coach-{random}-{username}.vercel.app`（コミット別、毎回変わる）

iPhone のブックマークは **メインドメイン**（最も短いもの）にする。

---

## 4. デプロイ手順 — CLI 経由（参考、後で挑戦してもOK）

CLI が使えるようになると `vercel --prod` でターミナルから一発デプロイができる。

```bash
# 1. Vercel CLI をインストール（Node.js 必要）
npm install -g vercel

# 2. ログイン
vercel login
# → ブラウザが開いて GitHub 認証

# 3. プロジェクトにリンク（初回のみ）
cd ~/Documents/my-english-coach
vercel link
# → 対話形式で「既存プロジェクトに紐付け」を選ぶ

# 4. 本番デプロイ
vercel --prod
```

✏️ **deploy.sh との関係**
本リポジトリの `deploy.sh` は `git push origin main` するスクリプト。Vercel は GitHub 連携経由でこれを検知して自動デプロイするので、**CLI を直接叩く必要はない**。`./deploy.sh "Day 9 added"` だけで全部動く。

---

## 5. デプロイ確認（必須）

1. **Mac の Safari/Chrome で開く**
   - `https://my-english-coach.vercel.app` を開く
   - index.html がランディングとして表示される
2. **8本のHTMLアプリをすべてクリックして開く**
   - Lesson_Studio / Phrase_Master / Speaking_Coach / Question_Master / Preposition_Visual / Idiom_Master / Phrasal_Verb_Master
3. **localStorage が動くか確認**
   - Phrase_Master を開く → 過去のフレーズが見える（localStorageはブラウザ単位なので、初めて開くと空。それでOK）
4. **iPhone Safari で開く**
   - 同じURLを iPhone から開く
   - Speaking_Coach で録音テスト（マイク許可が出る）
   - iPhoneのブックマークに登録

⚠️ **localStorageの注意**
localStorage はドメイン単位で保持されます。`netlify.app` に貯めたデータは `vercel.app` には引き継がれません。
過去のフレーズ・採点履歴を保全したい場合は、**Netlify を停止する前に**:
- Phrase_Master で「📥 Export」機能（あれば）でデータ出力
- なければ DevTools (F12) → Application → Local Storage → コピペで保存

---

## 6. カスタムドメイン（任意・後でOK）

`my-english-coach.vercel.app` で十分なら飛ばしてOK。
独自ドメイン（例: `english.kazuki.com` のような）を当てたい場合:

1. Vercel ダッシュボード → プロジェクト → Settings → Domains
2. ドメイン入力 → DNS 設定の指示が出る
3. ドメイン取得元（お名前.com / Google Domains / Cloudflare 等）で DNS レコードを設定
4. 数分〜数十分で反映

参考: `~/Documents/Claude/Projects/WEB coach/10_独自ドメインの繋ぎ方.md`

---

## 7. Netlify 側の停止

新URLが動作確認できたら、Netlify を停止する:

1. https://app.netlify.com にログイン
2. `t-myenglishcoach-20260506` プロジェクトを選択
3. **「Site settings」→ 「General」→ 「Status」**
4. **「Stop auto publishing」** をクリック（即削除ではなく一時停止）
   - 完全削除する場合は最下部の「Delete this site」だが、しばらくは Pause 推奨

✏️ **なぜ Pause 推奨か**
万一 Vercel 側で問題があったときに切り戻せる保険。1ヶ月くらい問題なく動いたら Delete してOK。

---

## 8. トラブル時のフォールバック

### 8-1. Vercel デプロイが失敗する

- Build settings を確認（Framework Preset が `Other` か）
- リポジトリ内に `vercel.json` がないか確認（あれば中身を確認、なければ気にしない）
- Vercel ダッシュボード → Deployments → 失敗したデプロイをクリック → ログ確認

### 8-2. iPhone で開けない

- メインドメイン以外のURL（`*-{random}.vercel.app`）は数日で失効する。ブックマークはメインドメインを使う
- HTTPS 強制になっているので、`http://` でなく `https://` で開く

### 8-3. 緊急時の Netlify 復帰

1. https://app.netlify.com → 該当サイト → 「Resume auto publishing」
2. Netlify URL（旧URL）が即座に復活
3. このタイミングで再度時間をとって Vercel 側を修正

---

## 9. 次のステップ（Vercel デプロイ完了後）

このドキュメント通りにデプロイが終わったら、以下を Puttyarin から Claude Code に伝える:

> 「Vercel のURLは `https://my-english-coach.vercel.app` です。各設定ファイルのURL更新お願いします」

Claude Code 側で以下を自動実行する（Plan の Step 3-4）:

1. CLAUDE.md / README.md / deploy.sh / agent定義 / memory のURLを一括置換
2. coach-english agent にデプロイ実行手順を追記
3. 動作確認（dry-run）

その後は `./deploy.sh "メッセージ"` で1コマンドデプロイ運用に切り替わる。

---

## 10. 学習ポイント（coach-ai 視点）

このページの中に登場した重要な概念:

| 概念 | 1行説明 |
|---|---|
| **静的サイト** | サーバー側で動的処理がなく、HTMLファイルをそのまま配信する形式。My English Coach はこれ |
| **GitHub 連携デプロイ** | リポジトリへの push を検知してホスティングサービスが自動ビルド・公開する仕組み |
| **Framework Preset** | Vercel/Netlify がプロジェクトの種類を判定して適切なビルド方法を選ぶ設定 |
| **CDN** | コンテンツを世界中のサーバーにキャッシュ配信して高速化する仕組み。Vercel/Netlify はデフォルトで使う |
| **DNS** | ドメイン名（example.com）を IP アドレスに変換する仕組み。カスタムドメイン設定で関わる |
| **localStorage** | ブラウザ内に保存されるデータ領域。**ドメインが変わると引き継がれない**点に注意 |
| **本番デプロイ vs プレビューデプロイ** | main ブランチ＝本番、他ブランチ＝プレビューURL（一時公開）。Vercel/Netlify 共通 |

各概念の詳細は coach-ai に聞けば深掘りできる。
