# MiriaGo → animap 风格界面改造方案

> 基于对 animap iPhone app（16 张截图）的完整分析，以及 MiriaGo 当前代码架构的审计。
> 状态：**方案阶段**，尚未实施。

---

## 关于 v2.0 的重要修订（先读这段）

v1.0 方案基于两个**错误前提**，v2.0 已纠正，并已就三个岔路口与产品方确认了决策：

1. **animap 没有「探索」这个独立 tab。** 底部导航自始至终只有 **3 个 tab（地图 / 收藏 / 我的）**。「探索」是在**地图 tab 上从底部上滑出来的半屏卡片**（见 `5338e4...jpg`：底单弹出时底部「地图」仍是高亮选中态，探索内容盖在地图之上）。
   → **决策：MiriaGo 仍把探索做成独立一级 tab**（产品方明确要求「最左 tab」）。这是对 animap 的**刻意偏离**，好处是实现独立、空间大；代价是 tab 数增加。

2. **animap 的「收藏」与 MiriaGo 的「记录」不是同一个功能。**
   - MiriaGo 的 `RecordsScreen`（`lib/records/records_screen.dart`，1072 行）＝**打卡记录**：相机拍照 + 参考图对比 + 对比图导出，是 MiriaGo 的核心资产，整条相机/调色/对比导出管线都在喂它。
   - animap 的「收藏」＝**书签式收藏地点**（收藏某个巡礼点），MiriaGo 代码里**没有这个数据模型**。
   → **决策：「打卡记录」移进「我的」tab**（不占独立 tab），功能不丢失、只换归属。
   → **决策：「收藏」本轮不做**（不建数据模型/CRUD/UI）。收藏是全新功能，留作后续里程碑；本轮「我的」里可选放一个「敬请期待」占位入口（与 animap 空态一致），或直接不放。
   → **协同红利**：animap「我的」里的 **足迹 / 作品 / 城市** 三个统计页，在 animap 中全是「敬请期待」空态；而 MiriaGo 的**打卡记录数据正好能喂满它们**（足迹=打卡时间线、作品=打卡过的作品、城市=去过的城市），比 animap 更充实。

3. **MiriaGo 的「计划」是操作中枢，animap 里没有对应概念。** `PlanScreen`（1756 行）挂着建计划 / 加点 / 管理点位 / 导入导出全部主流程。
   → **决策：计划保留为一级 tab。** MiriaGo 是「规划 + 打卡」型工具，不是 animap 的「浏览 + 收藏」型产品，不下沉计划中枢。

### 由此确定的目标 Tab 结构（4 个）

| 索引 | 名称 | 来源 | 说明 |
|------|------|------|------|
| 0 | **探索** ExploreScreen | **全新** | 最新作品 + 策展合集 + 搜索（对标 animap 探索底单的内容，但提升为独立 tab） |
| 1 | **计划** PlanScreen | 现有保留 | 操作中枢，不下沉 |
| 2 | **地图** PilgrimageMapScreen | 现有改造 | 加搜索栏 + 作品筛选芯片 + animap 风格标记 |
| 3 | **我的** ProfileScreen | 新建（合并 Records + Settings） | 个人资料 + **足迹/作品/城市（打卡记录数据）** + 设置入口（收藏本轮不做，可选占位） |

> **与 animap 的差异：** MiriaGo 用 4 个 tab（animap 3 个），仅多出「探索」这一独立 tab（产品方明确要求）。计划保留、记录+收藏+设置全归入「我的」，整体结构已高度贴近 animap。Material `NavigationBar` 支持 3–5 destination，4 个宽松无压力。

---

## 一、animap 界面分析总结

### 1.1 整体架构（3 Tab + 1 个上滑底单）

| Tab | 名称 | 图标 | 核心功能 |
|-----|------|------|----------|
| 0 | **地图** | 🗺️ 地图图标 | 全屏地图 + 动漫圣地标记 + 搜索栏 + 作品筛选芯片 + 点击弹出详情底单；**上滑弹出「探索」底单** |
| 1 | **收藏** | ❤️ 心形 | 按作品/按地区 双视图切换的收藏列表 |
| 2 | **我的** | 👤 人形 | 个人资料 + 足迹/作品/城市 三标签统计（当前全为空态）+ 右上角设置齿轮 |

### 1.2 "探索"界面（animap 中是地图上滑底单，MiriaGo 中提升为 tab）

**animap 触发方式**：在地图 tab 上从底部上滑（底部「地图」保持选中）。
**MiriaGo 做法**：作为独立 tab 的整页内容。

**布局结构（两者内容一致）**：
```
┌─────────────────────────────┐
│ 🔍 搜索作品、地名、城市    [🔎] │ ← 全宽圆角搜索栏
├─────────────────────────────┤
│ 探索                        │ ← 大标题
├─────────────────────────────┤
│ 最新作品                    │ ← 区块标题
│ ┌───┐ ┌───┐ ┌───┐ ┌───┐   │ ← 横向滚动卡片
│ │海报│ │海报│ │海报│ │海报│   │   (封面图 + 标题 + N个地点)
│ │标题│ │标题│ │标题│ │标题│   │
│ │N地点│ │N地点│ │N地点│ │N地│   │
│ └───┘ └───┘ └───┘ └───┘   │
├─────────────────────────────┤
│ 京阿尼名作选                │ ← 主题合集区块（人工策展）
│ ...                        │
├─────────────────────────────┤
│ 新海诚剧场                  │ ← 更多主题合集...
└─────────────────────────────┘
```

> 截图实测的合集与「地点数」：上低音号 581 个地点、中二病也要谈恋爱！346、轻音少女 214、BanG Dream! YUME∞MITA 206、上伊那牡丹 220、能帮我弄干净吗？137。这些「地点数」来自 anitabi 的点位数据库，**不是** Bangumi 元数据。

### 1.3 设计系统

| 元素 | 规范 |
|------|------|
| **主色调** | 白色背景 `#FFFFFF` |
| **强调色** | 品红/玫红 `~#E91E63`（按钮、选中态、活跃标签、tab 下划线） |
| **文字色** | 主文本深灰 `#1A1A1A` / 辅助中灰 `#666666` |
| **搜索栏** | 圆角全宽输入框，左侧定位针 icon + 右侧搜索 icon |
| **卡片** | 圆角 ~12px、轻微阴影、竖版海报图(2:3) + 文字叠加 |
| **芯片/标签** | 胶囊形圆角、带头像/图标 + 文字 + 数字角标 |
| **底部导航** | 浮动胶囊容器（非贴底），等分 tab，icon+label |
| **地图标记** | **两级 LOD**：缩小时按作品聚合成「圆形角色头像 + 作品名」，放大时散成「点位级彩色圆点」 |
| **底部弹层** | 从底部上滑，含标题/操作行/图片预览/打卡按钮 |
| **设置页** | 卡片分组列表，每项左侧彩色 icon + 标题 + 右侧值 + 箭头（MiriaGo 现有设置页风格已接近） |

---

## 二、当前 MiriaGo 架构 vs 目标对比

### 2.1 当前 Tab 结构（4 个）

| 索引 | 当前 | 图标 | 处置 |
|------|------|------|------|
| 0 | **计划** PlanScreen | ✅ checklist | **保留**（移到索引 1） |
| 1 | **地图** PilgrimageMapScreen | 🗺️ map | **保留改造**（移到索引 2） |
| 2 | **记录** RecordsScreen | 📚 collections | **折叠进「我的」**（打卡记录成为 足迹/作品/城市 的数据源；功能不变） |
| 3 | **设置** SettingsScreen | ⚙️ settings | **折叠进「我的」**（作为子页入口） |

### 2.2 目标 Tab 结构（4 个）

见上文「由此确定的目标 Tab 结构」。核心变化：
- **新增** 探索（索引 0）
- 计划 / 地图 保留，索引后移
- 记录从一级 tab 降级为「我的」内的 足迹/作品/城市 统计（功能不变）
- 设置从一级 tab 降级为「我的」下的子页
- **新增** 我的（含个人资料 + 统计 + 设置入口）
- **收藏本轮不做**（后续里程碑；「我的」内可选放「敬请期待」占位入口）

---

## 三、分阶段实施计划

### Phase 1：新增「探索」Tab（最高优先级）

> **实现状态（2026-07-21）：核心已完成，analyzer 干净。** 采用增量做法——探索插入 index 0，其余现有 tab（计划/地图/记录/设置）暂时保留后移为临时 5 tab；「我的」重构（记录+设置折叠）留到 Phase 3。
> 已落地：`AnitabiClient.listWorks()` 暴露全量目录；`lib/explore/` 全套（screen + work_card/horizontal_work_list/explore_search_bar/work_section_header + explore_work_item + curated_collections）；app_shell 插入探索 tab 并修正硬编码索引；13 种语言 arb + gen-l10n。
> 卡片封面：已接 Bangumi 海报（`BangumiApiClient.fetchSubjectImageUrl` + `PosterResolver` 按 bangumiId 懒加载/缓存；`WorkCard` 用 `frameBuilder`/`errorBuilder` 在加载中与失败时回退首字渐变占位块，不闪白）。「热门作品」按 anitabi 点位数降序；策展合集按标题关键词匹配、命中才显示。
> **iOS 模拟器实测（2026-07-21）：海报正常加载**——「我的作品」吹响吧！上低音号显示真实 Bangumi 封面；「热门作品」anitabi 目录也正常填充（ゆるキャン△/ガールズバンドクライ 等真实海报），整页呈现 animap 式海报卡片。截图存档。
> Web 预览局限（仅 web，移动端不受影响）：anitabi 静态目录在 web 读本地资源 `/__anitabi_static__/g.json`（未打包→404，故 web 上「热门/合集」走失败态）；Bangumi 海报在 web+CanvasKit 受跨域画布限制未必渲染。已在原生 iOS 证实二者均为 web 环境限制。
> 搜索栏点击接现有 AddPoints 流程。

> **工作流改进（2026-07-21）：探索直接一键加作品。** 取代原版「搜作品 → 加作品 → 再逐个加点位」的繁琐流程：在探索点未加入的作品卡 → 弹确认底单（作品名 + 「将导入 N 个巡礼点」）→ 一键把作品及其全部 anitabi 点位加入当前计划，成功后 SnackBar 提示 +「在地图查看」。已在计划中的作品点击则直接进地图。
> 实现：`WorkImporter`（`lib/explore/work_importer.dart`，`fetchPoints` → `toPilgrimagePoint` → `addPointsToPlan` 自动 upsert 作品，去重已有点位）+ ExploreScreen 确认底单/进度/SnackBar；工作 id 沿用 `bangumi-<id>` 约定。
> 验证：`test/work_importer_test.dart` 3 条单测全过（一键加作品+点位、重复导入去重、无点位作品也加）；iOS 原生实测探索目录/海报正常渲染。交互式点按底单因沙箱无 idb/simctl tap、osascript 辅助访问被拒未能截图，逻辑由单测确定性覆盖。

#### 1.1 创建 `ExploreScreen`

**新文件**：`lib/explore/explore_screen.dart`

**UI 结构**：

```
Scaffold(
  body: CustomScrollView(
    slivers: [
      SliverToBoxAdapter(child: _ExploreSearchBar()),          // 搜索栏
      SliverToBoxAdapter(child: SectionTitle('探索')),          // 大标题
      SliverToBoxAdapter(child: _WorkCarousel('最新作品', ...)), // 最新作品
      SliverToBoxAdapter(child: _WorkCarousel('京阿尼名作选', ...)),// 策展合集
      SliverToBoxAdapter(child: _WorkCarousel('新海诚剧场', ...)),
      SliverPadding(padding: EdgeInsets.only(bottom: 88)),      // 底部留白
    ],
  ),
)
```

**核心组件**：

| 组件 | 文件 | 功能 |
|------|------|------|
| `_ExploreSearchBar` | widgets/explore_search_bar.dart | 全宽圆角搜索框，点击跳转搜索页（可复用给地图 tab） |
| `_WorkSectionHeader` | widgets/work_section_header.dart | 区块标题（可复用） |
| `_HorizontalWorkList` | widgets/horizontal_work_list.dart | 横向滚动作品卡片列表 |
| `_WorkCard` | widgets/work_card.dart | 单张作品卡片（海报 + 标题 + 地点数） |

#### 1.2 数据源策略 ⚠️（v1.0 严重低估，v2.0 重写）

**⚠️ v2.2 前置调研结论（推翻 v2.0 的悲观假设）**：
- **anitabi 的 `g.json` 静态索引本身就是全量目录**。`AnitabiClient._fetchStaticIndex()` 返回 `List<AnitabiMapWorkLite>`（全部作品），每条含 `title / subtitle / city / center` 和 `points` map，**`points.length` 就是「N 个地点」**。→ 「列作品 + 每作品点位数」**可行**（只需把私有的 index 暴露成 `listWorks()`）。
- **真正的缺口是「封面海报」**：`PilgrimageWork` 与 `AnitabiMapWorkLite` 都**无封面字段**；全 App 仅在「点位」层用 `referenceImageUrl`；`BangumiApiClient` 目前只做关键词搜索且忽略 `images`。→ 探索页卡片的大海报**无现成数据源**。
- **「最新」排序无直接数据**：anitabi 索引无播出日期。→ 用「点位数降序」当「热门」是诚实可行的替代；真「最新」需扩展 Bangumi。

**MVP 落地（据此定）**：
- **数据源＝anitabi 静态目录**（真实的 title/city/点位数）+ 本地已导入作品（`controller.plan`）。
- **区块**：「我的作品」（本地，离线）+「热门作品」（anitabi 目录按点位数降序）+ 可选策展合集（按标题关键词匹配目录，命中才显示）。
- **封面**：MVP 用「首字渐变占位块 + 作品类型角标」，`WorkCard` 预留 `imageUrl` 参数，后续接 Bangumi subject 海报即可，不返工。

因此探索页要么内容极稀疏，要么依赖网络目录。三条来源逐一评估：

```
ExploreScreen 数据来源（现实情况）：
├── 本地已导入作品 → controller.plan.works
│     现实：只有用户自己导入的 1–N 个，撑不满一个「探索」页
├── Bangumi API → BangumiApiClient
│     可拿「最新/热门动画」列表 + 海报，但拿不到「地点数」
│     （地点数不是 Bangumi 数据）
└── anitabi → AnitabiClient / AnitabiStaticDataReader
      能提供「作品 → 巡礼点」，但需确认是否有「按作品列目录 + 每作品点位数」的批量接口
      （现有代码更多是「按作品 ID 拉点」，不是「列全部作品」）
```

**落地建议（务实降级）**：
- **MVP（Phase 1）**：探索页只做两个区块——「我的作品」（本地已导入，实时）+ 「最新动画」（Bangumi 热门/最新，卡片只显示海报+标题，**不显示地点数**或显示「—」）。搜索栏可用。
- **策展合集（京阿尼/新海诚）**：**用一份内置的策展白名单**（手写 `List<CuratedCollection>`，每条列出 Bangumi subject id / 作品名），而非纯 tag 自动分类——截图里的合集明显是人工挑选，tag 无法精准还原。白名单可随版本更新，或后续挪到远端配置。
- **「地点数」**：只有当某作品能通过 anitabi 拿到点位数时才显示；拿不到就省略该行文字。**先确认 `AnitabiClient` 是否支持「列作品 + 计数」**，这是 Phase 1 的前置调研项（见待办）。
- **缓存 + 降级**：Bangumi 限流/失败时回退到本地作品 + 缓存；网络图用 `cached_network_image`，无封面 fallback 到首字圆形头像。

> ⚠️ **产品方需知**：若坚持要做出 animap 那样「几百个作品、每个带地点数」的丰富探索页，需要一个动画×巡礼点的目录数据源（自建后端，或确认 anitabi 有可用的批量目录 API）。仅靠现有本地数据 + Bangumi，探索页会明显比 animap 单薄。

#### 1.3 注册到 AppShell

**修改文件**：`lib/app_shell.dart`

```dart
// IndexedStack children：探索插到最前，计划/地图后移，记录+设置移入「我的」
IndexedStack(
  index: _selectedIndex,
  children: [
    ExploreScreen(repository: widget.repository, onWorkTap: _openMapForWork), // 0 探索（新）
    PlanScreen(...),          // 1 计划（原 0）
    PilgrimageMapScreen(...), // 2 地图（原 1）
    ProfileScreen(...),       // 3 我的（新，内含 记录/设置；收藏本轮不做）
  ],
)

// destinations（4 个）
destinations: [
  NavigationDestination(icon: Icon(Icons.explore_outlined),  selectedIcon: Icon(Icons.explore),  label: l10n.tabExplore),  // 探索
  NavigationDestination(icon: Icon(Icons.checklist_outlined),selectedIcon: Icon(Icons.checklist),label: l10n.tabPlan),     // 计划
  NavigationDestination(icon: Icon(Icons.map_outlined),      selectedIcon: Icon(Icons.map),      label: l10n.tabMap),      // 地图
  NavigationDestination(icon: Icon(Icons.person_outline),    selectedIcon: Icon(Icons.person),   label: l10n.tabProfile),  // 我的
],
```

> 注：`RecordsScreen` 不再进 `IndexedStack`，而是被 `ProfileScreen` 内部复用（作为「足迹/作品/城市」页的内容），或从「我的」push 进入。

> ⚠️ `_selectedIndex` 目前多处硬编码（如导入成功后 `_selectedIndex = 0` 期望落到计划页、`_openMap()` 设为 `1`）。索引整体后移后，**必须同步修正 `app_shell.dart` 里所有硬编码索引**（`_openMap` → 2，导入回跳的目标页要重新确认是探索还是计划）。这是易漏的回归点。
>
> ⚠️ 现有从「记录」相关流程回跳到底部 tab 的逻辑（若有），需改为跳「我的」（索引 3）或在「我的」内切到对应统计页。

#### 1.4 WorkCard 卡片设计（对标 animap）

```
┌──────────────┐
│              │  ← 封面图（Bangumi poster / anitabi image），比例 2:3，圆角 8px
│   [海报图]    │
│              │
├──────────────┤
│ 作品标题      │  ← 单行省略，size 14, w600
│ 220 个地点    │  ← 辅助文字，灰色 size 12；无数据时省略此行
└──────────────┘

尺寸：宽 ~140px，高度自适应（约 200px），卡片间距 12px
```

---

### Phase 2：地图界面对标 animap 改版

> **实现状态（2026-07-21）：核心已完成，analyzer 干净。** 已加地图顶部搜索栏（复用 `ExploreSearchBar`，`padding` 参数化；点击接 AddPoints 搜索流程），与下方片区筛选条堆叠，浮动按钮下移避让。标记升级/底单改版按下述判断**从简/保留**：现有已具备缩略图圆形标记与功能完整的底单，重度改动风险高于收益，故仅做搜索栏这一 animap 标志性对齐；LOD 作品级聚合、底单结构重排仍列后续可选。

#### 2.1 顶部搜索栏集成

**修改文件**：`lib/map/pilgrimage_map_screen.dart`（现 1105 行）

- 地图上方固定搜索栏（复用 `_ExploreSearchBar`）
- 搜索结果以作品筛选芯片形式横向滚动展示在搜索栏下方
- 点击芯片 → 地图缩放到该作品点位范围

```dart
Stack(children: [
  FlutterMap(...),
  Positioned(
    top: MediaQuery.paddingOf(context).top + 8, left: 16, right: 16,
    child: Column(children: [
      _ExploreSearchBar(onResult: _zoomToWork),
      if (_filteredWorks.isNotEmpty)
        SizedBox(height: 44, child: _WorkFilterChips(works: _filteredWorks)),
    ]),
  ),
  // 定位/图层按钮保持不变
])
```

#### 2.2 地图标记样式升级 ⚠️（v1.0 低估：这是聚合工程，不是换皮）

animap 的标记是**两级 LOD**：
- **缩小**：按作品聚合，显示「圆形角色头像 + 作品名标签」（IMG_3456）。
- **放大**：散成点位级彩色圆点（IMG_3451）。

MiriaGo 现状是 **point 级** thumbnail marker（`lib/widgets/map_thumbnail_marker.dart`），没有「按作品聚合成一个代表头像」的层级。要还原 animap 需要：
1. 一套按缩放级别切换的聚合逻辑（zoom 阈值 → 显示作品聚合 or 点位散点）。
2. 每个作品的「代表图」（角色头像）。Bangumi/anitabi 封面可作 fallback，但 animap 用的是**角色**头像，未必有现成数据。

**建议**：Phase 2 先做「点位标记视觉对齐（圆形封面裁切 + fallback 首字圆）」这一档，**LOD 作品级聚合列为可选后续项**，因为工作量与现有 marker 架构改动较大。

#### 2.3 点位详情底单改版

**修改文件**：`lib/point_detail/point_detail_sheet.dart`（现 915 行）

对标 animap 底单（IMG_3454 / IMG_3457）：标题行(可关闭) → 场景描述 → 操作行(导航/分享) → 图片预览 → 打卡主按钮。

> ⚠️ **不要削弱现有能力**：animap 底单的「打卡」只是简单 check-in，而 MiriaGo 已有**更强**的打卡流程（相机拍照 → 参考图对比 → 生成 visit record → 对比图导出）。改造时只做**视觉对齐**（品红主按钮、操作行布局），**保留** MiriaGo 现有的相机对比打卡逻辑。
> **收藏本轮不做**：操作行里**先不放收藏按钮**（无数据模型可接）；等后续收藏里程碑再补。

---

### Phase 3：「我的」Tab（个人中心 + 记录 + 设置；收藏本轮不做）

> **实现状态（2026-07-21）：已完成并在浏览器实跑验证。** 最终 4 tab（探索/计划/地图/我的）已落地。`ProfileScreen` 展示资料 + 「15 打卡 · 1 作品 · 1 城市」实时统计（由打卡记录聚合，非空态）+ 「我的收藏 敬请期待」占位 + 足迹/作品/城市 分页；足迹页复用打卡记录（缩略图+点名+作品+时间，点按进详情），顶部「管理记录」按钮下钻完整 `RecordsScreen`；右上齿轮进 `SettingsScreen`。`RecordsScreen`/`SettingsScreen` 保持原样、改为 push 进入，未重构。
> 实跑验证：Flutter Web（sample 数据）四个 tab 全部渲染正常，截图存档；探索页在无网时优雅降级到「作品数据加载失败/重试」。

**决策：记录、设置归入「我的」；收藏本轮不做。** 这是本轮结构改造的重头，替代了 v2.0 里独立的「记录 tab 对齐」和「我的」两个 Phase。

#### 3.1 ProfileScreen 新建

**新文件**：`lib/profile/profile_screen.dart`

对标 animap IMG_3460/3461/3462：

```
┌──────────────────────────┐
│               ⚙️设置按钮  │ ← 右上角齿轮 → push 设置子页
│ ┌────┐ user_xxxx ✏️      │
│ │头像│ 12打卡 3作品 2城市 │ ← 统计（由本地打卡记录实时聚合，非空态）
│ └────┘ 个性签名           │
├────┬──────┬─────────────┤
│足迹│ 作品  │ 城市         │ ← 三个统计页（animap 是空态，MiriaGo 用记录数据填满）
├────┴──────┴─────────────┤
│  ❤️ 我的收藏（敬请期待）>  │ ← 可选占位（本轮不做收藏；也可先不放此入口）
└──────────────────────────┘
```

**足迹/作品/城市 三页的数据来源（复用现有打卡记录）**：
- **足迹**：所有打卡记录的时间线（对标 RecordsScreen 现有的记录列表 + 照片；可直接复用 `RecordsScreen` 内容或其组件）。
- **作品**：按 `workId` 聚合出「打卡过的作品」列表 + 每作品打卡数。
- **城市**：按 `PilgrimageWork.city` 聚合出「去过的城市」列表 + 每城市打卡数。
- 顶部统计数字（打卡/作品/城市）= 上述三者的计数，实时算出。

> animap 这三页当前都是「敬请期待」空态，MiriaGo 直接用打卡记录填满，是**优于 animap 的差异化**。

#### 3.2 记录功能的归属（不丢失、只换位置）

**修改文件**：`lib/records/records_screen.dart`

- `RecordsScreen`（1072 行）**功能与语义完全不变**（打卡记录 + 对比导出），不再是一级 tab。
- 落地方式二选一（实现时定）：
  - **A（复用）**：把 `RecordsScreen` 的记录列表作为「我的 → 足迹」页的内容直接嵌入。
  - **B（下钻）**：「我的」的统计页只显示概览，点进去 `Navigator.push` 到现有 `RecordsScreen`。
- 可选 animap 风格视觉对齐（纯换皮，不改数据）：粉色下划线分段 tab、列表项「左缩略图 + 右文字 + 箭头」。

> 提醒：**不要**把记录改名成「收藏」——是两个功能。记录 = 打卡历史；收藏 = 书签。

#### 3.3 收藏功能（本轮不做，留作后续里程碑）

**决策：本轮不做收藏。** 「我的」里可选放一个「敬请期待」占位入口（与 animap 空态一致），也可先完全不放。下方内容作为**后续里程碑**的实现备忘，本轮不排期：

- **数据模型**：`FavoritePoint`（收藏的巡礼点，关联 work + point + 收藏时间；可选备注）。
- **存储**：接入 `PilgrimageRepository`（新增 CRUD + 持久化）。
- **UI**：收藏列表页（按作品/按地区双视图）+ 点位底单收藏按钮 + 地图「收藏地点」图层。
- **入口**：「我的」tab → 我的收藏。

> 因本轮不做，`lib/favorites/` 相关文件、repository 收藏 CRUD、底单收藏按钮、地图收藏图层**均不在本轮范围**。

#### 3.4 设置页降级

- `SettingsScreen`（3773 行）不再是一级 tab，改为从 ProfileScreen 右上角齿轮 `Navigator.push` 进入的全屏子页。
- MiriaGo 现有设置页视觉已接近 animap（卡片分组 + 彩色 icon，见 IMG_3463），**基本无需重做**，只需把入口从底部 tab 挪到「我的」。

---

## 四、文件清单（新增 + 修改）

### 新增文件

| 文件路径 | 用途 |
|----------|------|
| `lib/explore/explore_screen.dart` | 探索主页（Phase 1 核心） |
| `lib/explore/curated_collections.dart` | 内置策展合集白名单（京阿尼/新海诚…） |
| `lib/explore/widgets/horizontal_work_list.dart` | 横向滚动作品列表组件 |
| `lib/explore/widgets/work_card.dart` | 单个作品卡片组件 |
| `lib/explore/widgets/explore_search_bar.dart` | 探索/地图共用搜索栏 |
| `lib/profile/profile_screen.dart` | 个人中心：资料 + 足迹/作品/城市（Phase 3.1；收藏入口可选占位） |

> 本轮不含：`lib/favorites/favorite_models.dart`、`lib/favorites/favorites_screen.dart`（收藏留作后续里程碑）。

### 修改文件

| 文件路径 | 改动内容 |
|----------|----------|
| `lib/app_shell.dart` | **核心改动**：Tab 4→4（探索替入索引 0，记录+设置移入「我的」）；**修正所有硬编码 `_selectedIndex`** |
| `lib/map/pilgrimage_map_screen.dart` | 顶部搜索栏 + 作品筛选芯片（Phase 2.1）；标记视觉对齐（2.2） |
| `lib/point_detail/point_detail_sheet.dart` | 底单视觉对齐，**保留现有相机对比打卡逻辑**（本轮不加收藏按钮，Phase 2.3） |
| `lib/records/records_screen.dart` | 复用进「我的→足迹」，**功能/语义不变**；可选视觉对齐（Phase 3.2） |
| `lib/settings/settings_screen.dart` | 不再作为 tab，改为「我的」子页（入口迁移，页面基本不动） |
| `lib/l10n/*.arb` | 新增 key：`tabExplore`、`tabProfile`、`explore`、`latestWorks`、`footprints`/`worksVisited`/`citiesVisited` 等（收藏文案本轮不加）；**移除或保留** `tabRecords`（记录不再是 tab，但「足迹」等文案可能复用）；同步 zh/en/ja/ko/fr/zh_Hant |
| `lib/app_theme.dart` | 如需新增 animap 品红 token（现有 `AppColors.accent` 可能已够用，先复用） |

---

## 五、技术风险 & 注意事项

| 风险 | 影响 | 应对 |
|------|------|------|
| **探索页数据源不足** ⚠️ | 无全量目录，探索页比 animap 单薄 | MVP 只做「我的作品 + Bangumi 最新」；策展用内置白名单；地点数拿不到就省略。长期需目录数据源。 |
| **anitabi 是否支持「列作品 + 计数」** | 决定卡片能否显示地点数 | **Phase 1 前置调研**：确认 `AnitabiClient` 能力，不能则地点数留空 |
| **app_shell 索引硬编码** | tab 后移导致跳转错页 | 全量排查并修正 `_selectedIndex` 赋值点（`_openMap`、导入回跳、记录相关回跳等） |
| **「我的」承载过重** | 记录+统计+设置塞进一个 tab，页面复杂 | 分区清晰：统计页 + 设置齿轮；记录用下钻或分页，避免单页过长 |
| **收藏功能（本轮不做）** | 后续里程碑，工作量大 | 本轮跳过；未来做时拆独立里程碑，先「点位收藏 + 列表」，地图图层/备注后置 |
| **地图标记 LOD 聚合** ⚠️ | animap 作品级聚合是聚合工程 | Phase 2 先做点位视觉对齐；作品级聚合列为可选后续 |
| **Bangumi API 限流** | 探索页加载慢/失败 | 本地优先 + 缓存 + 降级提示 |
| **封面图加载** | WorkCard 需网络图 | `cached_network_image`；fallback 首字圆形头像 |
| **IndexedStack 4 页常驻内存** | 探索页大量网络图可能 OOM | 探索页用 `AutomaticKeepAliveClientMixin` 懒加载，或首帧后再拉图 |
| **i18n 多语言** | 新增 tab/合集名需翻译 | 同步 6 种 arb；合集专有名（京阿尼/新海诚）可保留原名 |

---

## 六、实施顺序建议

```
前置调研（0.5 天）
  └── 确认 AnitabiClient 能否「列作品 + 每作品点位数」→ 决定探索页地点数是否可显示

Phase 1（探索 Tab）          ← 产品方明确要求的「探索做成独立 tab」
  ├── 1.1 ExploreScreen + 子组件
  ├── 1.2 数据源：本地作品 + Bangumi 最新（务实 MVP）
  ├── 1.3 注册 AppShell（Tab 4→4：探索入 0，记录+设置移入「我的」）+ 修正硬编码索引 ⚠️
  └── 1.4 WorkCard 样式 + 策展白名单

Phase 2（地图改版）           ← 视觉一致性
  ├── 2.1 搜索栏 + 作品筛选芯片
  ├── 2.2 标记视觉对齐（LOD 聚合可选后置）
  └── 2.3 底单视觉对齐（保留现有打卡逻辑）

Phase 3（我的 Tab：记录+设置归入）  ← 结构重头
  ├── 3.1 ProfileScreen：资料 + 足迹/作品/城市（打卡记录聚合，真实非空态）
  ├── 3.2 记录复用进「我的」（功能不变，可选视觉对齐）
  ├── 3.3 收藏：本轮不做（可选放「敬请期待」占位入口）
  └── 3.4 设置降级为「我的」子页

后续里程碑（本轮范围外）
  └── 收藏功能：FavoritePoint 模型 + repository CRUD + 收藏列表页 + 底单收藏按钮 + 地图收藏图层
```

---

## 七、待产品方进一步确认的开放问题

1. **探索页地点数**：若 anitabi 无「列作品 + 计数」能力，卡片是否接受「只显示海报+标题、不显示地点数」？（Phase 1 前置调研会给出答案）
2. **探索页丰富度**：是否接受 MVP 阶段探索页明显比 animap 单薄（只有本地作品 + Bangumi 最新）？还是要投入做目录数据源？
3. **地图作品级 LOD 聚合**：是否必须还原 animap 的「缩小看作品头像」效果，还是点位视觉对齐即可？
4. **收藏占位入口**：「我的」里要不要放一个「敬请期待」的收藏占位入口（与 animap 空态一致），还是本轮完全不出现收藏？

> 已决策：收藏功能本轮不做（后续里程碑）。

---

## 附：计划设置优化（2026-07-21，P1+P0 已完成）

在探索一键加作品之后，进一步压缩「导入 → 分区」链路（详见 `miriago_plan_optimization_plan.md`）：

- **P1 锚点可选**（`nearest_group_assign_screen.dart`）：`_centerOf(group)=锚点??组内点位质心`，「最近分配」不再要求先设关键点，对所有有中心的片区可分配；空态文案改为引导「智能分区」。
- **P0 一键智能分区**：
  - `plan_partition.dart`（纯函数）：单连通聚类（union-find，阈值默认 800m）+ k-means（按组数），质心输出；小计划(<6点)不拆分。
  - `applyPlanPartition`（repository 接口 + sqlite 原子事务 + sample/localized/desktop）：一次提交建组(带质心锚点)+移点。
  - `smart_partition_screen.dart`：地图实时预览（各簇凸包着色 + 质心旗标）、按距离/按组数切换 + 滑块、「生成片区」。
  - 入口：`point_manager_screen`（未分组视图主按钮）+ `anitabi_map_import_screen`（导入后整理引导的首选项）。
- **验证**：`flutter analyze` 零错误；12 条单测全过（聚类 8 + 一键加作品 3 + applyPlanPartition 1）；**iOS 模拟器实测 SmartPartitionScreen 渲染正常**（15 点→3 片区，凸包分色 + 质心旗标 + 「将分成 3 个片区 · 共 15 个点位」，截图存档）。UI 点按流程因沙箱无法驱动模拟器，逻辑由单测覆盖。
- **增强（2026-07-21）：添加作品后自动分区 + 车站命名**。探索一键加作品成功后，`WorkImporter` 自动对新导入点位跑 `partitionByDistance` 并 `applyPlanPartition`，片区名取**最近公共交通枢纽**（OSM Overpass `railway=station` → 如「宇治附近」，贴合原有「宇治站附近」惯例），查不到回退「片区 N」。SnackBar 提示「已导入 N 个巡礼点 · M 个片区」。
  - `station_name_resolver.dart`：Overpass 查最近车站，并行、按坐标缓存、9s 超时优雅回退；**关键坑**：Overpass 拒绝 Dart 默认头(406)，必须带 `User-Agent` + `Accept: */*`（已修，live 实测返回「宇治」）。
  - 验证：14 条单测全过（新增 autoPartition 分区+命名 1 条）；Overpass live 实测返回真实车站名；analyze 零错误 + iOS 构建通过。
- **增强 2（2026-07-21）：添加作品＝新建独立计划**。探索一键加作品不再加进当前计划，而是 `createPlan(name: "作品名 巡礼")`（`createPlan` 自动置为活动计划）→ 导入点位 + 自动分区 + 车站命名 → AppShell 重载并切到「计划」tab。SnackBar 保持「已导入 N 点 · M 片区」。
- **菜单简化**：计划页右上角菜单去掉「添加点位」（旧搜索加点流程，已被探索一键取代）与「导入导出」，保留 **切换计划 / 管理计划 / 计划备忘录**。
- **分区质量修正（2026-07-21）：超大簇二次 k-means 拆分**。单连通聚类会「链式合并」（实测 97 点里 91 点并入一片）。现对「超过 `maxAreaSize=30` 或超过总点数 40%」的簇自动用 k-means 拆成 `ceil(size/targetAreaSize=20)` 个片区，既保留自然距离聚类、又避免巨型片区（91 点 → 约 5 片）。16 条单测覆盖（含超大簇拆分、不过度拆分两条）。
- **车站命名改后台重试（2026-07-21）**：导入不再阻塞等 Overpass——先用「片区 N」秒建片区，随后后台并行解析车站名并 `renamePlanGroup` 重命名，Overpass 失败(504/超时)的片区按 5s/12s 退避重试至多 3 次，成功即 `onPlanUpdated` 刷新（不切 tab），始终失败则保留「片区 N」。`StationNameResolver` 改为**只缓存成功**（null 不缓存，保证重试真的重查——live 实测 ocean 两次都重查、宇治正常返回）。新增 `ExploreScreen.onPlanUpdated` + `ImportedArea`。
- **后续（未做）**：P2 地图圈选建片区、P3 地区自动带出 + 小计划免分组。

---

*方案版本：v2.2（基于 16 张 animap 截图逐张分析 + MiriaGo 代码审计 + 产品决策）*
*决策记录：探索＝独立一级 tab｜计划保留一级 tab｜记录 + 设置归入「我的」｜**收藏本轮不做**（后续里程碑）。最终 4 个 tab：探索/计划/地图/我的*
*版本沿革：v1.0（探索误做成 tab、记录/收藏语义混淆）→ v2.0（纠正，5 tab）→ v2.1（记录移入「我的」，4 tab）→ v2.2（收藏本轮不做）*
