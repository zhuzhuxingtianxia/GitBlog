# template

[SkillHub](https://skillhub.cn/)

开发发布自己的skill可以参考[ios-uiscene-migrator](https://skillhub.cn/skills/user_9919e3a2/ios-uiscene-migrator) 文件->README.md

## 目录结构
```
ios-uiscene-migrator/
├── SKILL.md              # 技能说明（WorkBuddy 必读，含触发词与 9 步流程）
├── manifest.yaml         # 元数据（用于 SkillHub 上架）
├── README.md             # 本文件
├── .gitignore            # 屏蔽 macOS 系统文件
└── assets/
    ├── icon-512.png      # 技能头像（512×512，摸鱼绿 #059 + 蜜蜂 IP）
    ├── checklist.md      # 12 项 Info.plist 合规清单
    └── example_diff.md   # 改造前后 diff 示例（Objective-C 风格）
```

## 上架到 SkillHub 流程

```
# 1. 准备 dist 目录
mkdir -p dist

# 2. 打包（zip 包含整个 skill 根目录）
zip -r dist/ios-uiscene-migrator-1.0.0.zip . -x "*.DS_Store" ".git/*" "dist/*"

# 3. 浏览器登 https://open.workbuddy.cn
#    → 我的技能 → 创建 → 上传 zip
#    → 按 assets/上架信息填写指南（来自 workbuddy-skills 索引仓库）填分类
# 4. 提交审核，等 7 个工作日
```

## 本地快速验证（不上架直接试触发词）

```
# 复制到 WorkBuddy 客户端扫描目录
cp -R . ~/.workbuddy/skills/ios-uiscene-migrator/

# 完全退出 + 重开 WorkBuddy 客户端
# 左下角「技能」面板里搜 "ios-uiscene-migrator"
# 在对话里说「帮我把 iOS 工程从 AppDelegate 迁到 UIScene」，看是否自动触发
```

## 商业模式
* 上架后建议设置：单次 0.5 元（人民币），按次扣费
* 平台分成：创作者 70-80%，详见 SkillHub 政策
* 个人版 PaySkill：手机号 + 支付宝实名即可收款，无需注册公司

## 维护与迭代
* 修改 `SKILL.md` 后，记得同步更新 `manifest.yaml` 的 `version` 字段
* 重新跑"中文引号扫描"自检
 ```
 grep -nE "[\"\xE2\x80\x9C]" manifest.yaml SKILL.md
 ```
 看到任何行说明有问题，必须改成英文引号
 
* 每次发布递增版本号（v1.0.0 → v1.0.1 → v1.1.0）





