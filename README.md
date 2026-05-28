# Period App

A minimalist menstrual cycle tracking app built with SwiftUI for iOS 17+.

---

## Features

### 🔴 One-Tap Recording
Tap the large circular button on the Home screen to instantly record your period start. The button updates in real time to reflect whether you have an active period or are waiting for the next cycle.

### 🔔 Smart Notifications
- **Period start reminder** — scheduled 3 days before your predicted next period ("Has your period started?").
- **Period end reminder** — scheduled 5 days after each recorded start date ("Has your period stopped?").
- Notifications are rescheduled automatically whenever you add, edit, or delete a record, or change your cycle-length setting.

### 📋 Auto-Estimated End Dates
If you ignore the end reminder, the app automatically converts open records to **estimated** status at day 8 (end date = start + 7 days). This reconciliation runs on every app launch and every time the app returns to the foreground, because iOS cannot guarantee background execution at a precise moment.

### 🗂 History & Backfill
The History tab lists all records, clearly labelling estimated ones. Tap any row to open an editor where you can correct dates. Saving a real end date for an estimated record automatically upgrades its status to **real**.

### 📊 Statistics & Chart
A bar chart shows period duration and cycle length for each recorded cycle. Real data is rendered in solid pink; estimated bars use a semi-transparent fill with a dashed border so you can instantly spot records that need correction. Tap an estimated bar (or the "Needs Attention" list below the chart) to open the editor inline.

### ⚙️ Settings
Adjust your cycle length (20–45 days, default 28) and enable local notifications from the Settings tab.

---

## Architecture

| Layer | Pattern |
|-------|---------|
| State management | `@Observable` macro (Swift 5.9+) — no `ObservableObject` or `@Published` |
| Architecture | MVVM — views are declarative; all business logic lives in ViewModels/Stores |
| Dependency injection | `AppContainer` wires stores and view models; injected via SwiftUI `.environment()` |
| Persistence | JSON files in the app's Documents directory via generic `PersistenceService<T>` |
| Notifications | `UNUserNotificationCenter` — local only, no server required |
| Charts | Native `Charts` framework (iOS 16+) |

### Key files

```
PeriodApp/
├── Models/
│   ├── MenstrualRecord.swift     # Data model + RecordStatus enum (real/estimated)
│   └── UserSettings.swift        # Cycle length setting
├── Services/
│   ├── AppContainer.swift        # Dependency-injection container
│   ├── NotificationService.swift # Centralised notification scheduling
│   └── PersistenceService.swift  # Generic JSON persistence
├── Stores/
│   ├── RecordStore.swift         # CRUD + day-8 reconciliation logic
│   └── SettingsStore.swift       # Persisted user settings
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── HistoryViewModel.swift
│   ├── StatisticsViewModel.swift
│   └── SettingsViewModel.swift
└── Views/
    ├── HomeView.swift
    ├── HistoryView.swift
    ├── StatisticsView.swift
    ├── SettingsView.swift
    └── Components/
        ├── MainCircleButton.swift
        ├── RecordRowView.swift
        ├── EditRecordView.swift   # Backfill / edit sheet
        └── CycleBarChart.swift   # Bar chart with real vs estimated styling
```

---

## Requirements

- **Xcode 15+**
- **iOS 17+** deployment target
- **Swift 5.10+**

No external dependencies — the app uses only Apple frameworks (SwiftUI, Charts, UserNotifications).

---

## Getting Started

1. Clone the repository.
2. Open `PeriodApp.xcodeproj` in Xcode.
3. Select your target device or simulator (iOS 17+).
4. Build and run (`⌘R`).

On first launch the app will request notification permission. You can also grant it later via **Settings → Notifications → Enable Notifications**.

---

## Data & Privacy

All data is stored locally on device using JSON files in the app's sandboxed Documents directory. No data is ever sent to any server or third party.
月经记录 App 开发需求说明
项目目标
开发一个极简风格的月经记录 App，帮助用户以最低操作成本完成经期开始/结束记录、周期预测、来潮提醒、结束提醒，以及历史数据补录和周期可视化展示。

App 的核心理念是：

极简操作
低打扰提醒
允许用户忘记操作后的自动兜底
明确区分真实数据与系统预估数据
一、核心功能与业务逻辑
功能 1：一键记录（主界面）
目标
让用户进入 App 后只需一次点击即可记录“月经开始日”。

UI 要求
主界面保持极简。
视觉中心放置一个醒目的大型圆形按钮。
页面尽量减少复杂信息展示，突出“记录”这一核心动作。
交互逻辑
用户点击主按钮后：
立即获取当前系统时间；
创建一条新的经期记录；
将该时间记录为本次经期的 开始日（Start Date）。
记录成功后，主界面状态应立即更新，例如：
按钮文案或样式切换为“经期中”；
或展示“已记录开始时间”。
状态要求
主界面至少需要支持以下状态：

未开始记录
经期中
已结束/等待下一周期
功能 2：动态预测与来潮提醒
目标
根据用户的周期长度设置，预测下一次月经开始日期，并提前提醒用户确认是否来潮。

设置项
App 内必须提供一个设置项：生理周期长度
默认值为 28 天
用户可自行修改
预测逻辑
自第一次记录“开始日”后，系统根据：
上一次记录的开始时间
用户设置的周期长度
计算下一个周期的预计开始日期
公式示例：

预计开始日期 = 上一次开始日 + 周期长度
提醒逻辑
在预计开始日期的前 3 天，触发本地通知。
通知文案
是否来姨妈了？
用户交互
通知提供两个操作：

否
直接关闭提示
是
跳转至 App 主界面
引导用户点击记录按钮，记录新的开始日
说明
本功能依赖本地通知能力实现
提醒应基于最新周期数据动态更新
功能 3：结束提醒、自动生成虚拟记录与补录机制
目标
在用户记录开始日后，提醒其记录结束日；若用户长期未响应，则系统自动补全一条“预估结束时间”，并允许后续补录为真实数据。

结束提醒触发条件
每次记录“开始日”后的 第 5 天，触发本地通知：
通知文案：

月经是否已经停止？
正常交互流程
用户点击 是
跳转至 App 主界面
引导点击“停止”按钮
将当天记录为本次经期的 结束日（End Date）
超时自动关闭与虚拟数据逻辑
这是本需求的关键点：

如果用户持续未处理该提示：
在开始日后的 第 8 天，该提示彻底关闭
系统在底层自动为本次经期补全结束时间：
结束日 = 开始日 + 7 天
同时将该条记录标记为：
虚拟状态 / 预估状态
数据状态要求
每条经期记录至少应包含：

开始时间
结束时间
记录状态
记录状态建议包括：

真实记录（real）
虚拟/预估记录（estimated）
历史补录与修改机制
App 必须提供一个补录/修改历史数据入口。

用户可在后续手动补录真实的结束日期。补录后系统需要：

更新该条记录的结束日期
将该记录状态从：
虚拟/预估状态
改为 真实状态
补录后的系统行为
当虚拟记录被真实数据覆盖后，后续统计与图表应使用最新真实数据重新计算。

功能 4：周期数据可视化（区别显示虚拟数据）
目标
帮助用户在数据统计页面查看周期变化趋势，并清楚识别哪些数据是系统预估的。

UI 要求
提供独立的数据统计页面
使用柱状图（Bar Chart）展示周期曲线
图表内容至少包括：
经期天数
周期长度
可视化要求
对于不同来源的数据，必须做明显视觉区分：

真实记录
使用正常品牌主色调展示
例如：
实心粉色
实心红色
虚拟/预估记录
必须与真实记录显著不同，例如可采用以下任一方案：

虚线边框
半透明浅色
斜纹/阴影填充
灰化样式 + 提示标识
设计目标
让用户一眼识别：

哪些数据是自己真实记录的
哪些数据是系统自动推测的
哪些记录建议进一步补录修正
交互建议
点击虚拟/预估柱体时，可跳转到对应历史记录详情
引导用户补录真实结束日期
二、推荐的数据模型
建议至少包含如下数据结构：

MenstrualRecord
id
startDate
endDate
status
real
estimated
createdAt
updatedAt
UserSettings
cycleLengthDays，默认 28
三、通知规则汇总
1. 来潮预测提醒
计算依据：上次开始日 + 周期长度
触发时间：预计开始日前 3 天
文案：是否来姨妈了？
操作：

否：关闭
是：打开 App 主界面，引导记录开始日
2. 结束提醒
触发时间：开始日后第 5 天
文案：月经是否已经停止？
操作：

是：打开 App，引导记录结束日
3. 自动兜底逻辑
若用户一直未响应结束提醒：
第 8 天关闭该提醒流程
自动生成：
endDate = startDate + 7 天
status = estimated
四、关键业务规则
开始日记录优先使用当前系统时间
结束日默认由用户手动确认
若用户未确认结束日，系统自动生成预估结束日
所有预估记录必须带有明确状态标记
用户后续补录真实结束日后，必须覆盖预估数据
统计图表中必须区分真实数据与预估数据
周期预测基于最近一次开始日和用户设置的周期长度
通知调度应在新增记录、修改记录、补录记录、修改周期设置后重新计算
五、建议页面结构
1. 主界面
大圆形记录按钮
当前状态展示
如处于经期中，可显示“停止”按钮或结束操作入口
2. 历史记录页
查看过往每次经期记录
支持修改开始日、结束日
对虚拟/预估记录显示特殊标记
提供补录入口
3. 数据统计页
柱状图展示经期天数、周期长度
区分真实记录与预估记录
4. 设置页
周期长度设置
通知权限说明
提醒开关（可选）
六、验收标准
产品至少应满足以下验收条件：

记录功能
用户点击主按钮后，能够成功记录开始日
主界面状态正确切换
周期预测
用户修改周期长度后，预测日期正确变化
预计开始日前 3 天能触发提醒
结束提醒与自动兜底
开始日后第 5 天触发结束提醒
若用户未响应，到第 8 天自动写入预估结束日
该记录状态正确标记为 estimated
补录能力
用户能在历史记录中修改预估结束日
修改后状态从 estimated 正确变为 real
图表展示
统计页能展示周期数据
真实数据与预估数据视觉上明显不同
七、给开发 Agent 的实现要求建议
如果这是写给代码 Agent 的任务说明，可以附加下面这些实现要求：

技术要求建议
优先保证本地数据持久化
通知使用本地通知，不依赖服务端
所有时间计算要考虑本地时区
图表组件需支持自定义柱体样式
数据更新后自动刷新主界面、历史页、统计页和通知计划
实现重点
设计清晰的数据状态机：
未开始
经期中
已结束
预估待修正
封装统一的周期计算与通知调度逻辑
将“真实记录”和“预估记录”在数据层明确区分，而不是只在 UI 层区分
---

