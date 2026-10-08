# article-video-publish

「文章转视频」项目的单条视频发布 SOP，做成 Claude Code skill：
用作者本人的克隆声音重新配音出片 → 压发布版 → 定发布标题 → 用 Codex 生成 B站 / 小红书 / 视频号 / 抖音 四个平台的封面 → 给出四个平台的话题 tag。

- `SKILL.md`：入口和流程总览
- `references/`：每一步的细节、命令和踩过的坑
- `scripts/`：Codex 生图、四平台封面导出、短字幕合并
- `CHANGELOG.md`：每次修改的记录

## 同步规则
- 本地位置：`文章转视频/.claude/skills/article-video-publish/`（本目录就是 git 仓库）。
- 远端：GitHub 公开仓库 `Stephen-creater/article-video-publish-skill`。
- **改了任何文件，都要在 CHANGELOG.md 记一笔，然后 commit 并 push，两端保持一致。**
- 这是公开仓库：只放流程和脚本，不放文章原文、录音、视频、API Key 等任何私有内容。
