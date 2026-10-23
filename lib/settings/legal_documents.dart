import 'dart:ui';

/// In-app legal documents shown from Settings → About.
///
/// Kept as static Markdown so the text can be mirrored verbatim to a public
/// privacy-policy URL (App Store requires a reachable privacy policy link).
/// Only zh / en are authored here; every other locale falls back to English.
enum LegalDocument { privacyPolicy, termsOfService }

class LegalDocumentContent {
  const LegalDocumentContent._();

  static String title(LegalDocument document, Locale locale) {
    final useZh = locale.languageCode.toLowerCase().startsWith('zh');
    switch (document) {
      case LegalDocument.privacyPolicy:
        return useZh ? '隐私政策' : 'Privacy Policy';
      case LegalDocument.termsOfService:
        return useZh ? '服务条款' : 'Terms of Service';
    }
  }

  static String markdown(LegalDocument document, Locale locale) {
    final useZh = locale.languageCode.toLowerCase().startsWith('zh');
    switch (document) {
      case LegalDocument.privacyPolicy:
        return useZh ? _privacyZh : _privacyEn;
      case LegalDocument.termsOfService:
        return useZh ? _termsZh : _termsEn;
    }
  }

  /// Last revision date shown at the bottom of every document.
  static String revisionDateLabel(Locale locale) {
    final useZh = locale.languageCode.toLowerCase().startsWith('zh');
    return useZh ? '最近更新：2026-10-24' : 'Last updated: 2026-10-24';
  }

  /// Public, App Store-reachable URL for this document. Kept in sync with the
  /// GitHub Pages deployment (see `docs/legal/` and
  /// `.github/workflows/deploy-legal.yml`). Returns `null` for documents that
  /// have no public mirror.
  static String? publicUrl(LegalDocument document) {
    switch (document) {
      case LegalDocument.privacyPolicy:
        return 'https://gamesushi.github.io/anitrip/privacy_policy.html';
      case LegalDocument.termsOfService:
        return 'https://gamesushi.github.io/anitrip/terms_of_service.html';
    }
  }

  // ---------------------------------------------------------------- zh -----

  static const _privacyZh = '''
# 隐私政策

AniTrip（以下简称「本应用」）由独立开发者 BilyHurington 开发与维护。本政策说明本应用
如何处理你的信息。

## 一句话总结

**本应用没有账户、没有服务器、没有广告、没有第三方统计或崩溃上报。你的巡礼计划、
打卡记录与照片全部只保存在你自己的设备上。**

## 一、我们收集的信息

我们不收集任何信息。本应用不存在注册、登录或云同步功能，因此没有任何可用于识别你身份
的数据被发送至我们或任何第三方。

## 二、存储在你设备上的数据

以下内容保存在本应用在本机创建的本地数据库中（SQLite），删除应用即一并删除：

- 巡礼计划、作品与巡礼点数据（含你手动新增或修改的坐标）
- 打卡记录、你拍摄的对比照片与你写入的文字备注
- 应用偏好设置（语言、主题、地图源等）
- 坐标偏差反馈记录（你在「报告位置错误」中提交的内容）
- GPS 轨迹记录（你手动开始录制后采集的坐标采样点、时长与距离）

这些数据仅在以下情形离开你的设备：

1. 你主动使用**导出**功能（生成计划包文件、CSV 或分享对比图）；
2. 你主动使用系统分享 / 保存到相册。

## 三、设备权限

本应用仅在你需要时才请求权限，且全部用于对应功能：

| 权限 | 用途 | 是否必需 |
| --- | --- | --- |
| 位置（前台） | 显示你在地图上的位置、计算与附近巡礼点的距离、「报告位置错误」时读取当前坐标、记录巡礼轨迹（仅前台，切换到其他应用时自动暂停） | 否，可拒绝 |
| 相册（读取） | 挑选截图作为对比参考图、为坐标反馈选择照片 | 否，可拒绝 |
| 相册（写入） | 保存拍摄的对比照片与导出的巡礼卡片 | 否，可拒绝 |
| 相机 | 拍摄圣地实景对比照片 | 否，可拒绝 |

拒绝任一权限只会导致对应功能不可用，其余功能不受影响。任何时候你都可以在系统设置中
撤销权限。

## 四、联网时会访问哪些第三方服务

本应用的部分内容来自公开数据源，请求会携带你的 **IP 地址**（这是互联网通信的固有属性），
部分服务可能据此判断大致地区。除此之外我们不会向它们提供任何标识你的信息。

- **圣地巡礼数据 / 参考图**：依据 anitabi 公开数据集及其图片服务。
- **作品封面与元数据**：bangumi.tv 公开 API（仅在封面缺失时用于解析封面图）。
- **最近车站名称**：OpenStreetMap Overpass API（用于推断巡礼点最近车站）。
- **地图瓦片**：默认使用 OpenFreeMap / OpenStreetMap 系列瓦片源；你也可以在设置中
  切换为自定义 XYZ 或 MapLibre 样式源。

上述服务各自适用其自身的隐私政策与服务条款。切换地图源后，瓦片请求将发往你所配置的服务商。

> 提示：本应用本身**不含任何统计分析、崩溃上报或广告 SDK**。

## 五、儿童隐私

本应用不面向 13 岁以下儿童，也不会主动收集任何年龄段用户的个人信息。

## 六、数据保留与删除

所有数据在你的设备本地。你可以通过以下方式彻底清除：

- 在应用内删除对应计划 / 打卡记录；
- 卸载应用（会同时清除本地数据库与缓存的图片）。

卸载后我们侧不存在任何需要删除的数据，因为我们没有服务器。

## 七、政策更新

若未来新增需要联网的功能，我们会在新版中更新本政策并在应用内提示。继续使用即视为接受
更新后的政策。

## 八、联系我们

对本政策有疑问请发送邮件至 **bilyhurington@gmail.com**。
''';

  static const _termsZh = '''
# 服务条款

欢迎使用 AniTrip。使用本应用即表示你同意以下条款。若你不同意，请停止使用。

## 一、应用性质

AniTrip 是一款**本地优先**的动漫圣地巡礼辅助工具，用于整理巡礼计划、记录打卡并管理
对比照片。我们**不提供任何形式的账户、云同步或在线服务**，因此也不对任何数据丢失承担责任——
请在卸载前自行导出重要数据。

## 二、数据来源与准确性

本应用的巡礼点信息整理自 **anitabi** 公开数据集与用户自行录入的内容。

- 巡礼点坐标、名称与参考图**可能存在偏差、过时或缺失**；
- 前往圣地前请自行核实现场情况与最新信息；
- 第三方地图瓦片、线路与车站数据同样由对应服务商提供，我们无法保证其准确性。

App 内提供「报告位置错误」入口供你提交修正建议。提交内容仅保存在你本地，是否采纳、
何时修正由维护者决定。

## 三、你的责任

1. 你需自行承担前往巡礼地点的全部风险，包括但不限于交通、天气、地形与安全风险。请遵守
   当地法律法规与现场管理规定。
2. **圣地巡礼请保持克制**：大量巡礼场所位于居民区、学校、神社、店铺等日常运营地点。
   请勿擅自进入私有领地、请勿打扰居民与营业、请勿拍摄他人肖像并公开传播。
3. 二次创作、截图与实拍图的版权归各自权利人所有。你是否可以在社交平台发布对比图，取决于
   原作品的权利人政策与你的使用场景，**请自行判断并自负其责**。
4. 你确认依据所在国家 / 地区法律已达到可独立接受本条款的年龄，或在监护人同意下使用。

## 四、知识产权

应用本身的代码以 [MIT License](https://opensource.org/licenses/MIT) 开源发布。
第三方数据、字体、瓦片与图片资源遵循各自的权利说明，已在应用「关于」页标注出处。

未经许可请勿去除或篡改上述归属声明。

## 五、免责声明

本应用按「现状」提供，不作任何明示或默示的担保，包括但不限于对特定用途的适用性、
准确性或不侵权的担保。我们不对以下情况负责：

- 因坐标偏差、路况、天气等导致的时间或金钱损失；
- 设备数据丢失（请自行导出备份）；
- 第三方服务（地图、图片、API）中断或变更导致的不可用；
- 你在巡礼过程中的任何人身或财产损害。

## 六、条款更新

我们可能修订本条款，更新后的版本将随应用新版发布。继续使用即视为接受更新后的条款。

## 七、联系我们

条款相关问题请发送邮件至 **bilyhurington@gmail.com**。
''';

  // ---------------------------------------------------------------- en -----

  static const _privacyEn = '''
# Privacy Policy

AniTrip ("the App") is developed and maintained by an independent developer,
BilyHurington. This policy explains how the App handles your information.

## Short version

**The App has no accounts, no servers, no ads, and no third-party analytics or
crash reporting. Your pilgrimage plans, visit records and photos stay on your
own device.**

## 1. What we collect

Nothing. There is no sign-up, no login and no cloud sync, so no data that could
identify you is ever sent to us or to anyone else.

## 2. Data stored on your device

The following lives in a local database (SQLite) created by the App. Deleting
the App deletes it as well:

- Pilgrimage plans, works and spots (including coordinates you add or edit)
- Visit records, comparison photos you take and notes you write
- App preferences (language, theme, map tile source, etc.)
- Location reports you submit through "Report location error"
- GPS track recordings (coordinate samples, duration and distance collected
  after you start recording manually)

This data leaves your device **only** when you explicitly make it happen:

1. You use an **export** feature (plan package, CSV, comparison card);
2. You share or save something through the system share sheet.

## 3. Device permissions

Permissions are requested only when needed and only for the matching feature:

| Permission | Purpose | Required? |
| --- | --- | --- |
| Location (when in use) | Show your position on the map, compute distances to nearby spots, read your current coordinate for location reports, and record your pilgrimage route (foreground only; pauses automatically when the App moves to the background) | No |
| Photo library (read) | Pick a screenshot as a comparison reference, attach a photo to a location report | No |
| Photo library (add) | Save comparison photos and exported pilgrimage cards | No |
| Camera | Take on-site comparison photos | No |

Denying any permission only disables that feature. You can revoke permissions at
any time in your system settings.

## 4. Third-party services contacted over the network

Some content comes from public data sources. Requests necessarily carry your
**IP address** — that is how the internet works — and some providers may infer
your approximate region from it. Nothing else identifying you is sent.

- **Pilgrimage data / reference images**: the public anitabi dataset and its image service.
- **Cover art and metadata**: the public bangumi.tv API (only when a cover is missing).
- **Nearest station names**: the OpenStreetMap Overpass API.
- **Map tiles**: OpenFreeMap / OpenStreetMap tile sources by default; you can switch
  to a custom XYZ or MapLibre style URL in Settings.

Each service is governed by its own privacy policy and terms. Once you switch map
sources, tile requests go to the provider you configured.

> Note: the App contains **no analytics, crash reporting or advertising SDKs**.

## 5. Children's privacy

The App is not directed at children under 13, and it does not knowingly collect
personal information from anyone.

## 6. Retention and deletion

Everything is local. To erase your data you can either delete the relevant plan
or record inside the App, or uninstall the App (which removes the local database
and cached images). There is nothing to delete on our side — we have no servers.

## 7. Changes to this policy

If a future version introduces a networked feature, this policy will be updated
and surfaced in the App. Continued use means you accept the updated policy.

## 8. Contact

Questions? Email **bilyhurington@gmail.com**.
''';

  static const _termsEn = '''
# Terms of Service

Welcome to AniTrip. By using the App you agree to these terms. If you do not,
please stop using it.

## 1. Nature of the App

AniTrip is a **local-first** anime pilgrimage companion: it helps you organise
pilgrimage plans, record your visits and manage comparison photos. **We provide
no account, no cloud sync and no online service**, and therefore accept no
responsibility for data loss — export anything important before uninstalling.

## 2. Data sources and accuracy

Spot information is compiled from the public **anitabi** dataset and from what
you enter yourself.

- Coordinates, names and reference images **may be inaccurate, outdated or missing**.
- Always verify on-site conditions and the latest information before travelling.
- Third-party map tiles, routes and station data come from those providers and
  their accuracy is likewise not guaranteed.

The App includes a "Report location error" action for submitting corrections.
Submissions are stored locally; whether and when they are applied is up to the
maintainer.

## 3. Your responsibilities

1. You travel entirely at your own risk, including traffic, weather, terrain and
   personal safety. Follow local laws and on-site rules.
2. **Pilgrimage respectfully**: many locations are in residential areas, schools,
   shrines and shops. Do not trespass on private property, do not disturb
   residents or businesses, and do not publish photos that identify individuals.
3. Copyright in screenshots, reference images and your own photos belongs to the
   respective rightsholders. Whether you may post a comparison image publicly
   depends on that rightsholder's policies and your own use case — **judge it
   yourself and assume responsibility for it**.
4. You confirm you are old enough under your local law to accept these terms, or
   that you use the App with a guardian's consent.

## 4. Intellectual property

The App's source code is released under the
[MIT License](https://opensource.org/licenses/MIT). Third-party data, fonts, map
tiles and imagery follow their own rights notices, credited on the About screen.

Do not remove or alter those attributions.

## 5. Disclaimer

The App is provided "as is", without warranty of any kind, express or implied,
including fitness for a particular purpose, accuracy or non-infringement. We are
not liable for:

- Time or money lost due to coordinate drift, traffic or weather;
- Device data loss (please export your own backups);
- Interruptions or changes in third-party services (maps, images, APIs);
- Any personal or property damage incurred during your pilgrimage.

## 6. Changes

We may revise these terms; the updated version ships with a new App release.
Continued use means you accept the updated terms.

## 7. Contact

Questions? Email **bilyhurington@gmail.com**.
''';
}
