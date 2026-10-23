# anitrip 法律 / 支持页面托管说明

App Store 上架需要两个**外网可访问**的公开页面：

| 用途 | 文件 | 线上地址 |
| --- | --- | --- |
| 隐私政策（Privacy Policy URL） | `docs/legal/privacy_policy.html` | `https://gamesushi.github.io/anitrip/privacy_policy.html` |
| 服务条款（应用内也有，可选公开） | `docs/legal/terms_of_service.html` | `https://gamesushi.github.io/anitrip/terms_of_service.html` |
| 技术支持（Support URL） | `docs/legal/support.html` | `https://gamesushi.github.io/anitrip/support.html` |

## 唯一真源（重要）

页面内容必须与 App 内「设置 → 关于 → 隐私政策 / 服务条款」**逐字一致**。
App 内文案的唯一真源是：

```
lib/settings/legal_documents.dart  (LegalDocumentContent._privacyZh / _privacyEn / _termsZh / _termsEn)
```

修改政策时，**先改 `legal_documents.dart`，再同步 `docs/legal/*.html`**。
三个 HTML 文件头部都有 `MAINTAIN-ME` 注释提醒这一点。
`revisionDateLabel`（当前 `2026-10-23`）也要同步更新。

> 不要只改 HTML 然后忘记 dart —— 否则 App 内与网页会出现不一致，App Store 审核可能因此被拒。

## 发布方式：GitHub Pages（仅发布 docs/legal）

仓库已配置 `.github/workflows/deploy-legal.yml`，只把 `docs/legal/` 部署到 GitHub Pages，
不会把 `docs/` 下的截图、宣传文案等一并公开。

首次启用（只需一次）：

1. 打开 `https://github.com/gamesushi/anitrip` → **Settings → Pages**。
2. **Source** 选择 **GitHub Actions**（不是 "Deploy from a branch"）。
3. 把 `docs/legal/` 推到 `main`（或手动在 Actions 里跑 `Deploy Legal Pages`）。
4. 几分钟后页面上线于 `https://gamesushi.github.io/anitrip/...`。

后续只要 `docs/legal/**` 有改动，push 到 `main` 会自动重新部署。

## 填到 App Store Connect

- **Privacy Policy URL** 字段：
  `https://gamesushi.github.io/anitrip/privacy_policy.html`
- **Support URL** 字段：
  `https://gamesushi.github.io/anitrip/support.html`
- App 二进制 `ios/Runner/Info.plist` 也已写入 `NSPrivacyPolicyURL`（同上地址），
  App 内「隐私政策」页底部有「在网页查看最新版本」链接，跳转同一地址。

## 联系人

政策与邮件统一使用开发者邮箱 `bilyhurington@gmail.com`（与 App 内「关于」页一致）。
不要用 `gamesushi.example` 之类占位邮箱——Apple 会实际抓取验证，占位邮箱会导致提交被拒。
