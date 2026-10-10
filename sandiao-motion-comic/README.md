# 虾仁风沙雕漫剧工坊

一个面向 Codex、Claude Code 和其他 Agent Skill 运行环境的开源 Skill：把一句话创意、短故事或小说章节，做成可执行的“虾仁风 / 沙雕动画 / 熊猫头漫剧”生产包。

它覆盖：

- 故事钩子与分集设计
- 角色、场景、道具资产圣经
- 逐拍剧本与分镜
- 图片提示词：角色板、表情板、姿态板、场景板、关键帧、封面
- 视频提示词：Seedance 2.0/2.5、Kling、Runway、Hailuo、Vidu、Wan、Pika 等
- 配音、OS/VO、环境音、动作音效与 BGM 提示
- 剪辑单、字幕、标题、标签和封面文案
- 角色一致性、场景连续性、道具状态与交付审查
- 开源来源和许可证说明

## 安装

把整个 `sandiao-motion-comic` 文件夹复制到你的 Agent skills 目录。对 Codex 来说通常是：

```text
%CODEX_HOME%\skills\sandiao-motion-comic
```

如果没有设置 `CODEX_HOME`，默认是：

```text
%USERPROFILE%\.codex\skills\sandiao-motion-comic
```

也可以尝试通过 skills CLI 安装：

```bash
npx skills add <your-github-user>/sandiao-motion-comic
```

## 快速开始

创建一个项目骨架：

```bash
python scripts/init_project.py projects/my-first-episode --name "我的第一集" --platform douyin --aspect 9:16
```

然后在 Agent 里说：

```text
用 $sandiao-motion-comic 把我的创意做成第一集。

创意：
一个现代外卖员穿越到古代，靠外卖评价系统在朝堂上乱杀。

要求：
- 9:16，抖音
- 90 秒
- 熊猫头沙雕风
- 历史穿越 + 现代梗
- 前 3 秒必须有钩子
- 结尾留悬念
```

## 目录

```text
sandiao-motion-comic/
├── SKILL.md
├── agents/openai.yaml
├── references/
│   ├── panda-head-style-guide.md
│   ├── full-pipeline-prompt-library.md
│   ├── model-adapters.md
│   ├── review-rubric.md
│   └── sources-and-licenses.md
├── assets/project-template/
└── scripts/init_project.py
```

## 开源来源

本 Skill 综合、改写和重新组织了以下开源项目的公开工作流与提示词工程思路：

- [zenstory-ai/drama-skills](https://github.com/zenstory-ai/drama-skills)（MIT）
- [djyy1031/ai-comic-drama-director-skills](https://github.com/djyy1031/ai-comic-drama-director-skills)（MIT）
- [snailzsh/manga-script-master](https://github.com/snailzsh/manga-script-master)（MIT）
- [busdigua/SandAnim](https://github.com/busdigua/SandAnim)（MIT）

另有若干只作参考、未直接复制内容的开源项目，详见 [references/sources-and-licenses.md](references/sources-and-licenses.md)。

## 使用边界

- 这是“虾仁风”类型方向的工作流，不是对任何真实创作者、角色或作品的授权。
- 不要用本 Skill 复制受保护的 IP、角色、剧情、台词、形象或素材。
- 默认只生成提示词和项目文件，不自动调用付费生成服务。

## 许可证

MIT
