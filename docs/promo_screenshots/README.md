# anitrip 推广截图素材

本目录按推广轮播图的常见顺序整理了一组截图，可直接用于制作小红书 / Bilibili / 微博等渠道的推广图片。

## 截图清单

| 序号 | 文件名 | 内容说明 | 建议用途 |
|------|--------|----------|----------|
| 00 | `00-icon.jpg` | anitrip 应用图标 | 封面角标、品牌露出 |
| 01 | `01-explore.png` | **探索页**（iOS 模拟器原生截图）：搜索栏 +「我的作品」+「热门作品」+ 策展合集 | **首图/封面主图** |
| 02 | `02-plan.png` | **计划页**：当前目标、片区列表、打卡进度、自动分区 | 功能轮播第 1 张 |
| 03 | `03-map.png` | **地图页**：点位标记、自定义地图源、搜索栏 | 功能轮播第 2 张 |
| 04 | `04-profile.png` | **我的页**：打卡/作品/城市统计、足迹、设置入口 | 功能轮播第 3 张 |
| 05 | `05-anitabi-import.png` | Anitabi 点位导入：地图上框选/批量添加 | 功能轮播第 4 张 |
| 06 | `06-camera-overlay.jpg` | 叠层相机：实拍与参考图叠加对齐 | 功能轮播第 5 张 |
| 07 | `07-camera-split.jpg` | 上下相机：实拍与参考图上下对照 | 功能轮播第 6 张 |
| 08 | `08-color-grading.jpg` | 自动调色页面 | 功能轮播第 7 张 |
| 09 | `09-export-comparison.jpg` | 导出对比图页面 | 功能轮播第 8 张 |
| 10 | `10-records.png` | 巡礼记录页：按作品/时间归档 | 功能轮播第 9 张 |
| 11 | `11-plan-switch-export.jpg` | 计划切换与导出 | 结尾/数据管理说明 |

## 截取方式说明

- **`01-explore.png`（探索页）**：**真机 iOS 模拟器原生截图**（iPhone 13 Pro Max，1284×2778，中文 UI，带 iOS 状态栏）。通过预构建的 `build/ios/iphonesimulator/Runner.app` 安装到模拟器，修改应用 SQLite 设置将语言切为中文后启动截取。
- **`02-plan.png` / `03-map.png` / `04-profile.png`**：由于当前沙箱环境**无法运行 UI 自动化**（AppleScript / `cliclick` / `idb` 等点击注入工具均被禁止或缺失），无法在原生模拟器里自动切换底部 tab。这三个 tab 改用同一套 Flutter 代码编译的 **Web 运行时 + 浏览器自动化**截取，分辨率统一为 iPhone 13 Pro Max 的 1284×2778，内容仍为内置示例数据，UI 与原生端一致（仅缺少 iOS 状态栏）。
- **05–11（导入/相机/调色/导出/记录）**：来自项目 `docs/sample_images/` 中的真机/示例素材（v1.1），功能与当前版本一致；相机页依赖真实摄像头，模拟器/Web 无法呈现，故保留原素材。

> 如果你后续在本地 Xcode 环境重新编译，只需手动在模拟器里依次点「计划/地图/我的」三个 tab，并用 `xcrun simctl io <device> screenshot <文件名.png>` 即可把 02–04 也换成纯原生截图。

## 使用建议

### 小红书 9 图组合
1. `01-explore.png`（封面感首图）
2. `02-plan.png`
3. `03-map.png`
4. `05-anitabi-import.png`
5. `06-camera-overlay.jpg`
6. `07-camera-split.jpg`
7. `08-color-grading.jpg`
8. `09-export-comparison.jpg`
9. `10-records.png` 或 `11-plan-switch-export.jpg`

### Bilibili 动态 / 微博
可拼图做成 4 宫格或 6 宫格：
- 上排：`01-explore.png` + `03-map.png` + `06-camera-overlay.jpg`
- 下排：`02-plan.png` + `08-color-grading.jpg` + `09-export-comparison.jpg`

### 封面模板元素
- 大标题：「这个夏日，一起去巡礼吧」或「终于有人把圣地巡礼做成完整工具链了」
- 副标题：anitrip · 计划 / 拍摄 / 调色 / 出图
- 手机 mockup 框住 `01-explore.png`
- 底部 tag：#圣地巡礼 #anitrip #日本旅行

## 注意事项

- 所有图片中的第三方作品封面、参考图版权归原平台或权利方所有，仅用于功能展示。
- 01 已为原生 iOS 模拟器截图；02–04 受自动化限制暂为同分辨率 Web 截图，后续可替换为原生截图以获得完全一致的状态栏和系统字体。

---

*生成时间：2026-08-14*
