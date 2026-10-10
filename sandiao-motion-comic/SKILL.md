---
name: sandiao-motion-comic
description: "Create, adapt, and review 虾仁风/沙雕动画-style AI motion comics: hooks, scripts, character/scene/prop bibles, storyboards, image/video/voice/audio prompts, continuity checks, and platform packaging. Use for 虾仁动画、沙雕动画、熊猫头漫剧、AI漫剧、AI短剧、动态漫、Seedance prompts, or requests to turn a premise/novel into a producible motion-comic package. Not for photoreal live-action drama or copying an existing creator's protected characters, scripts, or assets."
license: MIT
metadata:
  short-description: "虾仁风沙雕漫剧全流程提示词工作台"
---

# 虾仁风沙雕漫剧工坊

把一句话创意、短故事或小说章节，做成可执行的“虾仁风”沙雕漫剧生产包：钩子、剧本、角色/场景/道具资产、分镜、图片提示词、视频提示词、配音与音效、剪辑包装和审查。

“虾仁风”在这里指沙雕动画/熊猫头漫剧的**创作方向**：正经铺垫、荒诞转折、连环打脸、历史穿越、现代梗、夸张表情和快节奏反转。不要复制任何真实创作者的角色、剧情、台词、形象或素材；用原创角色和原创故事做同类风格。

## 适用场景

当用户想做以下事情时使用本 Skill：

- 虾仁动画、沙雕动画、熊猫头漫剧、动态漫、AI 漫剧、AI 短剧
- 把小说、段子、历史穿越梗或原创点子做成竖屏/横屏漫剧
- 生成角色设定、场景资产、分镜、图片提示词、视频提示词、配音和音效提示词
- 固定角色一致性、场景连续性、道具状态和跨镜动作
- 审查一集漫剧的节奏、爽点、反转、钩子和可生成性
- 适配 Seedance 2.0/2.5、Kling、Runway、Hailuo、Vidu、Wan、Pika、Midjourney、SD、Flux、ComfyUI 等工具

不要把它用于写实真人剧、纯插画、纯小说写作，或“模仿某位创作者本人”的请求。

## 硬约束

1. **原创优先**：可以借鉴类型、节奏和镜头语法，但不能复制受保护的 IP、角色、剧本、台词、标志性造型或具体作品片段。
2. **一镜一主动作**：每个镜头只承担一个主要戏剧变化；复杂动作拆镜，不用堆形容词硬塞。
3. **动作三段化**：动作镜头按“预备 → 主体 → 缓冲”写，三段时长相加等于镜头时长；不足 1.2 秒可省略分段，但仍要写清起止状态。
4. **情绪有梯度**：每镜记录 `emotionStart → emotionEnd`；下一镜的起始情绪承接上一镜终点，只有明显转折才跳变，并写清缓冲动作。
5. **所有情绪可见**：不能写“他很愤怒”，要写“拳头砸在桌沿、茶杯里的水震出一圈纹、下颌绷紧”。
6. **左右明确**：画面左右用“画面左/画面右”；人物自身左右必须写“他的左手/她的右肩”。多人同镜不能只写“他/她”。
7. **资产绑定每次重复**：角色、场景、道具一旦绑定 ID 或参考图，在同一提示词内每次提及都要带上同一绑定，不能只绑一次。
8. **视频不生成字幕文字**：对白通过声音和口型发生；字幕、标题、花字、封面字在剪辑阶段添加。只有上游明确要求 `exact-readable` 的屏幕内容才允许生成画内文字。
9. **默认不调用付费服务**：本 Skill 生成提示词、项目文件和审查结果。除非用户单独明确授权，不调用外部图片、视频、TTS 或音乐服务。
10. **输出可复制**：提示词代码块只放交付内容，不把内部备注、文件路径、规则编号、失败记录混进去。

## 默认参数

如果用户没有指定，按以下默认值工作，并在交付开头用一行说明：

| 参数 | 默认值 |
|---|---|
| 语言 | 中文 |
| 画幅 | 9:16（抖音/快手/视频号）；B站/YouTube 可用 16:9 |
| 单集时长 | 60–120 秒 |
| 视觉风格 | 熊猫头/表情包角色 + 简化身体 + 平涂色块 + 低细节背景 |
| 主视频模型 | Seedance 2.5；必要时回退 Seedance 2.0 |
| 图片参考 | 每个主要角色 1 张角色板，每个主场景 1 张场景板 |
| 台词长度 | 单句尽量不超过 15 字 |
| 节奏 | 前 3 秒钩子；每 10 秒至少一次信息/情绪转折；结尾留钩子 |
| 配乐 | 提示词可写 BGM 风格，但 BGM 默认后期添加，不写进视频生成提示词 |

## 默认工作流

### 1. 需求收集

最少确认：题材、主角、核心冲突、想模仿的风格方向、目标平台、画幅、时长、目标生成模型。

如果用户只给一句话，直接补齐合理默认值并开始；不要连续追问。只有缺失信息会实质性改变故事走向时才问一个最短问题。

### 2. 建立风格圣经

读取 [references/panda-head-style-guide.md](references/panda-head-style-guide.md)，锁定：

- 沙雕程度、时代背景、现代梗密度
- 角色视觉锚点、表情库、标志物
- 场景风格、色彩、镜头语法
- 每集节奏公式和结尾钩子形式

### 3. 故事引擎

先写：

- 一句话故事
- 3 秒开场钩子
- 中段 3–5 个包袱或反转
- 结尾钩子
- 本集承诺（观众看完能得到什么）

沙雕漫剧默认节奏：**正经铺垫 → 荒诞转折 → 递进升级 → 终极打脸/反转 → 新钩子**。

### 4. 资产圣经

为每个角色、场景和反复出现的道具分配稳定 ID：

```text
CHAR-001 / SCENE-001 / PROP-001
```

每个资产必须有可原样复用的视觉锚点。角色至少包含：头像/脸型、身体比例、服装、配色、标志物、表情、声线、禁止漂移项。场景至少包含：空间锚点、光线、时间、材质、机位变体。

详细模板见 [references/panda-head-style-guide.md](references/panda-head-style-guide.md)。

### 5. 单集剧本

输出逐拍剧本，每个 beat 标注：

```text
时间 | 场景 | 角色 | 可见动作 | 台词/OS | 情绪变化 | 包袱/反转 | 镜头目的
```

规则：

- 台词短、口语化、有梗。
- 每句台词 4–5 字/秒估算时长；放不下就拆镜或删字。
- 心理描写必须转成可见动作。
- 场景变化拆新镜头；每句关键台词通常给一个镜头或一个反应镜。

### 6. 分镜

每条分镜必须包含：

```text
SHOT ID | 时长 | 画面目的 | 镜头焦段与景别 | 摄影机位置/运动 | 起始状态 | 动作三段 | 台词与声音 | 终点状态 | 与下一镜衔接
```

动作镜头使用：

```text
预备：蓄力/抬手/转头
主体：核心动作与接触点
缓冲：收回/落定/喘气/表情回弹
```

### 7. 图片提示词

按顺序生成：

1. 角色板（正面/三分之二/背面，同一身份）
2. 表情板（喜怒哀惊、得意、尴尬、害怕、思考、沙雕夸张）
3. 姿态板（站立、奔跑、跪地、抱头、指点、拍桌）
4. 场景板（空间锚点、光线、时间、镜头方向）
5. 道具板（关键道具状态变体）
6. 关键帧（每镜首帧）
7. 封面图

图片提示词配方见 [references/full-pipeline-prompt-library.md](references/full-pipeline-prompt-library.md)。

### 8. 视频提示词

每条视频提示词先写通用动作边界，再按目标模型改写：

- 起点状态
- 触发
- 有序动作与物理接触点
- 摄影机（固定或一次有动机的运动）
- 环境与光线变化
- 逐字台词、OS/VO、音效
- 明确终点状态
- 禁止字幕、花字、LOGO、水印

模型差异见 [references/model-adapters.md](references/model-adapters.md)。

### 9. 声音与配音

为每个角色写声线卡：音色、语速、口音、情绪范围、标志性语气。为每集写声音时间线：对白、OS、VO、环境底声、动作音效、点缀音效、BGM 起点与落点。

提示词模板见 [references/full-pipeline-prompt-library.md](references/full-pipeline-prompt-library.md)。

### 10. 剪辑与发布

输出剪辑单、字幕表、封面文案、标题、标签、前 3 秒钩子文案和下集预告。字幕与花字在剪辑阶段添加，不进入视频生成提示词。

### 11. 审查与返修

交付前读取 [references/review-rubric.md](references/review-rubric.md)，逐项检查钩子、节奏、包袱密度、角色一致性、场景连续性、道具接触、台词时长、音效层级和平台包装。

返修时一次只改一个变量，记录“问题 → 改动 → 结果”，不要凭感觉整条重写。

## 默认交付结构

优先创建或更新以下项目结构：

```text
projects/<slug>/
  00-project.json
  01-creative-brief.md
  02-asset-bible.md
  03-episode-01-screenplay.md
  04-storyboard.csv
  05-image-prompts.md
  06-video-prompts.md
  07-voice-and-sound.md
  08-publish-and-review.md
```

可以用 [scripts/init_project.py](scripts/init_project.py) 从 [assets/project-template](assets/project-template) 初始化：

```bash
python scripts/init_project.py projects/my-first-episode --name "我的第一集" --platform douyin --aspect 9:16
```

如果用户只要求某一个环节，不要强行生成全套文件；只输出该环节，并保持上述 ID 和连续性规则。

## 参考路由

- 风格、角色、场景、道具、沙雕节奏：读 [references/panda-head-style-guide.md](references/panda-head-style-guide.md)
- 全流程提示词模板：读 [references/full-pipeline-prompt-library.md](references/full-pipeline-prompt-library.md)
- 目标模型适配：读 [references/model-adapters.md](references/model-adapters.md)
- 交付前审查：读 [references/review-rubric.md](references/review-rubric.md)
- 开源来源与许可证：读 [references/sources-and-licenses.md](references/sources-and-licenses.md)
- 项目骨架：复制 [assets/project-template](assets/project-template)

## 完成标准

一个合格的交付至少满足：

- 前 3 秒有明确钩子
- 每 10 秒有一次信息、情绪或视觉转折
- 结尾有可继续的钩子
- 所有主要角色有视觉锚点和稳定 ID
- 跨镜角色、场景、道具和情绪可以追踪
- 每条视频提示词只含画面、动作、声音和限制条件
- 视频提示词不生成字幕、花字、LOGO 或水印
- 台词时长可执行，动作和口型能对上
- 来源和许可证已记录
