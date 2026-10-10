# 开源来源与许可证

本 Skill 是对公开资料的**综合、改写和重新组织**，不是对任何来源的逐字复制。以下来源用于研究流程、提示词结构、连续性方法和沙雕动画工具设计。

## 直接借鉴并改写的工作流

| 项目 | 许可证 | 本 Skill 借鉴的内容 |
|---|---|---|
| [zenstory-ai/drama-skills](https://github.com/zenstory-ai/drama-skills) | MIT | 原著分析、分集剧本、视觉设定、图片/视频提示词、剪辑、审查的全流程分层；文件即事实；先预览后生产 |
| [djyy1031/ai-comic-drama-director-skills](https://github.com/djyy1031/ai-comic-drama-director-skills) | MIT | 分镜组、动作/表演、资产绑定、连续性检查、声音设计、Seedance 适配、质量标准 |
| [snailzsh/manga-script-master](https://github.com/snailzsh/manga-script-master) | MIT | 漫剧赛道节奏模型、完播率公式、角色设定卡、AI 分镜提示词表、Seedance 2.0 格式 |
| [busdigua/SandAnim](https://github.com/busdigua/SandAnim) | MIT | 沙雕动画六阶段生产流程、AI 拆剧本的结构化 JSON、三段动作（预备-主体-缓冲）、情绪梯度、规则引擎思路 |

以上四个项目的 MIT 许可证允许使用、修改、合并、发布和再许可，条件是保留版权与许可声明。本 Skill 在 [LICENSE](../LICENSE) 以外，在本文件中额外保留来源说明。

## 参考但未复制内容的项目

| 项目 | 许可证 | 参考内容 |
|---|---|---|
| [alibaba/lumenx](https://github.com/alibaba/lumenx) | MIT | 小说到动态视频的一站式生产链路 |
| [HBAI-Ltd/Toonflow-app](https://github.com/HBAI-Ltd/Toonflow-app) | MIT | 无限画布、Agent、剧本/分镜/资产/图像/视频工作台 |
| [Tencent/workrally](https://github.com/Tencent/workrally) | 未声明 | AIGC 漫剧视频创作工具集 |
| [xeronsh/openOii](https://github.com/xeronsh/openOii) | 未声明 | 多智能体协作、LangGraph 漫剧生成 |
| [kingdoja/ai-comic-drama-platform](https://github.com/kingdoja/ai-comic-drama-platform) | 未声明 | 7 阶段 agent pipeline、状态机、一致性检查 |
| [XiakeMan777/xiakeman-ai-short-drama](https://github.com/XiakeMan777/xiakeman-ai-short-drama) | 未声明 | Seedance 2.0 创作工具、图片资产与视频提示词 |
| [yy18570728781/AI-Comic-Director](https://github.com/yy18570728781/AI-Comic-Director) | 未声明 | AI 漫剧创作工作台 |
| [MR-TianYuSun/ai-comic-drama-producer](https://github.com/MR-TianYuSun/ai-comic-drama-producer) | MIT | 漫剧统筹与规划 |

对于“未声明”许可证的项目，本 Skill 只把它们作为生态调研和产品形态参考，不复制其代码、提示词或文档内容。

## “虾仁动画”类型研究

“虾仁动画”是中文互联网上沙雕动画/熊猫头漫剧的一个具体创作者及作品风格标签。公开搜索可见其常见特征：

- 熊猫头/表情包角色
- 历史穿越、师爷、暴君、算命、宫廷等题材
- 正经铺垫 + 荒诞转折的喜剧结构
- 抖音、Bilibili 等平台的短剧式发布

类型研究参考：

- Bing 中文搜索：`虾仁动画`
- 百度百科：`虾仁大动画`
- 抖音、Bilibili、AcFun 上的公开作品标签与合集页面

本 Skill **不复制**“虾仁动画”创作者的角色、剧情、台词、形象、封面、音效或具体作品内容。Skill 中的“虾仁风”只表示沙雕动画/熊猫头漫剧这一大类风格方向。

## 引用格式建议

如果你在教程、文章或视频里介绍这个 Skill，建议写：

```text
本工作流改编自 sandiao-motion-comic（MIT），并综合了
zenstory-ai/drama-skills、djyy1031/ai-comic-drama-director-skills、
snailzsh/manga-script-master、busdigua/SandAnim 等开源项目。
```

## 合规提醒

- 保留本仓库的 [LICENSE](../LICENSE) 和本来源说明。
- 不要移除第三方项目的版权声明。
- 如果你再发布衍生版本，建议在 README 中继续列出这些来源。
- 不要用本 Skill 生成或传播侵犯他人版权、商标权、肖像权或名誉权的内容。
- 不要把真实创作者的名字、角色或作品包装成你自己的原创。
