# anitrip 法律/支持页面托管说明

本目录包含提交 App Store 所需的两个公开页面：

- `privacy_policy.html` — 隐私政策（填 App Store Connect 的 **Privacy Policy URL**）
- `support.html` — 技术支持页（填 App Store Connect 的 **Support URL**）

两个页面互相用相对链接引用，需放在同一公开目录下。

## 托管方式：GitHub Pages（最简单，免费）

1. 在 GitHub 新建仓库，例如 `anitrip-legal`。
2. 把本目录（`legal/`）下的两个 html 上传到仓库根目录。
3. 仓库 Settings → Pages → Source 选 `main` 分支 `/ (root)`，保存。
4. 几分钟后得到公开地址，例如：
   - 隐私政策：`https://<你的用户名>.github.io/anitrip-legal/privacy_policy.html`
   - 技术支持：`https://<你的用户名>.github.io/anitrip-legal/support.html`

把这俩地址分别填进 App Store Connect 对应字段即可。

## 提交前务必修改

- 两个 html 里的邮箱 `privacy@gamesushi.example` / `support@gamesushi.example` → 换成你真实可收信的邮箱。
- 确认页面能通过浏览器正常打开（Apple 会实际抓取验证，404 会导致提交被拒）。
