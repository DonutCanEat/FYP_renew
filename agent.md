# agent.md ─ AI Agent 工作守則與驗證規範

> 專案：**Victor2 ── Enterprise Network Infrastructure and Architect**（HDTN 畢業專案／FYP）
> 情境：Vertex Peak Financial Technologies Limited（FinTech／InsurTech）｜標準：WorldSkills 2026・IT Network Systems Administration（Skill 2447）
> 對象：任何在本目錄工作的 AI agent（以及未來的自己）
> 語言：文件、註解、commit 訊息一律**繁體中文**；程式識別字（變數／函式／檔名）一律英文。

---

## 0. 兩條最高規矩（**違反即停止工作**）

> 使用者原話：**「有任何修改都要進行驗證並確保全部通過先可以繼續」**、
> **「每一次修改都要進行一次 commit」**。
> 這兩條不是建議，是**本目錄的唯一准入條件**。以下 §1、§2 把它們寫成可執行、可檢查的形式。

| 編號 | 規矩 | 通過定義 | 失敗時的動作 |
| --- | --- | --- | --- |
| **R1** | 任何修改都必須先驗證，**全部通過**才可繼續下一步 | `tools/verify.ps1` 退出碼為 `0`，且最後一行係 `RESULT: PASS` | 停止，唔准接落去做下一個修改，亦唔准 commit |
| **R2** | 每一次修改都要一個獨立 commit | 今次改動嘅檔案已 `git add` 並 `git commit`（`docs(agent)` 除外嘅任何檔案類型都適用） | 未 commit 就唔算完成，唔可以往上報告「做好」 |

**兩條規矩嘅關係**：R1 係閘門、R2 係收尾。一次修改嘅生命週期永遠係：

```
① 分類 → ② 最小改動 → ③ 跑驗證（Stage A/B/C）
   → ④ 驗證失敗：改到過為止（唔准 commit 失敗狀態）
   → ⑤ 驗證通過：寫驗證記錄 → ⑥ commit → ⑦ 才准開始下一個修改
```

**「繼續」嘅定義**：只有完成 ①～⑥ 全部步驟，先算「可以繼續」。中途跳過驗證、或者攞住失敗嘅測試結果照做下一個功能，都算違規。

---

## 1. R1：驗證流程（每次改動都跑）

### 1.1 一鍵驗證

```powershell
# 在本目錄（FYP）執行；會自動產生 _reports/ 驗證記錄
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/verify.ps1
```

- **必須用 `-ExecutionPolicy Bypass`**：本機（Windows）停用了指令碼執行，直接 `& tools/verify.ps1` 會失敗。
- 退出碼 `0` ＝ 全部通過；任何一項 FAIL ＝ 退出碼 `1`，並在 `_reports/verify-latest.txt` 列出失敗原因。
- 驗證記錄（`_reports/*.txt`、`_reports/*.json`）係**產生物，不入版控**。
- 本機只有 Windows PowerShell 5.1（冇 `pwsh`），所以一律用 `powershell.exe`。
- **`.ps1` 必須帶 UTF-8 BOM；`.md`／`.txt` 不准帶 BOM**（理由見 §8 疑難排解第一項）。呢條由 `tools/verify.ps1` 自動把關。

### 1.2 驗證階段（按改動類型選擇，唔可以跳級）

| 階段 | 幾時要跑 | 內容 | 未通過就… |
| --- | --- | --- | --- |
| **A** | 改任何檔案 | 檔案存在、UTF-8 可讀、無 tab、無不可見字元、Markdown 連結全部指得到、`agent.md`／`README.md` 兩條規矩齊全 | 唔准繼續 |
| **B** | 改文件／工具／規則 | A ＋ 文件聲明的一致性（規則檔存在、被引用嘅指令真係存在）、`manifest.json` 逐檔 SHA-256 對得上（防「偷偷改咗冇記錄」） | 唔准 commit |
| **C** | 改 IaC／自動化／AI 管理層（見 §4） | B ＋ 對應嘅實測（重建環境、二次執行零漂移、權限拒絕路徑、稽核鏈） | 唔准進入下一階段 |
| **D** | 每個里程碑（G0–G6） | 完整驗收：三族可達性、IaC 可重建、自動化幂等、AI 唯讀＋審批、評估套件、文件齊全 | 唔准報「階段完成」 |

> 階段唔可以跳：**未過 C 就唔可以報 D**。純文件改動可以只跑 A／B，但只要改到 IaC／playbook／MCP 工具，就一定要跑到 C。

### 1.3 驗證記錄（必須留底，但唔入版控）

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/verify.ps1 -Note "改咗 README 目錄結構"
```

每次驗證都會寫一份帶時間戳嘅記錄到 `_reports/`，內容包括：時間、git HEAD、每個檔案嘅 SHA-256、逐項檢查結果、總結。
**Commit 訊息或交付報告必須引用該次驗證嘅結論**（最低要求：寫明「驗證：PASS（`_reports/verify-*.txt`）」）。冇記錄＝冇驗證過。

### 1.4 Manifest（防漂移）

`tools/manifest.json` 記錄每個入版控檔案嘅 SHA-256。跑 `tools/verify.ps1 -Stage B` 時會**逐個重算並比對**：

- 有檔案 hash 唔同 → FAIL（代表有人改咗檔案但冇更新 manifest／冇記錄）。
- 有入版控檔案唔在 manifest 內 → FAIL（代表有檔案未登記）。
- 確認改動無誤後，用以下指令更新 manifest（**之後必須同一次 commit 一齊交**）：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/verify.ps1 -WriteManifest
```

> Manifest 係本專案嘅「漂移偵測」基石，亦係 §7 交付要求「drift check」嘅本地體現。**唔准手改 `manifest.json`**，一律用 `-WriteManifest` 產生。

---

## 2. R2：Commit 規範（每次改動一個 commit）

### 2.1 鐵規

1. **一次修改＝一個 commit**。唔准把幾個唔相關嘅改動夾埋一個 commit（「順手改埋」都算違規）。
2. **未過 R1 驗證 → 唔准 commit**。禁止先 commit 再修（會污染歷史，令 `git bisect` 失效）。
3. **`git add` 一定要寫明路徑**：本目錄係 monorepo（`D:\File\Program Project`）嘅子目錄，內含 `TimeMate`、`Umapyoi` 等其他專案。
   **嚴禁** `git add -A`／`git add .`（會誤把其他專案嘅改動一齊 commit）。
4. **唔准** `git commit --amend`、`git push --force`、`git reset --hard`、`git clean -fd`、`git rebase`（除非使用者明確要求）。
5. **唔准** commit 機密或產生物：`_reports/`、`*.log`、`*.tmp`、`*.bak`、任何金鑰／憑證／密碼。
6. Commit message 用**繁體中文**，採 Conventional Commits 前綴：

   | 前綴 | 用於 |
   | --- | --- |
   | `docs:` | 文件（README／agent.md／圖表說明／手冊） |
   | `feat:` | 新增功能（playbook、script、MCP 工具、評估情境） |
   | `fix:` | 修正錯誤 |
   | `chore:` | 環境、設定、依賴、目錄整理 |
   | `test:` | 測試與驗證本身嘅改動 |
   | `refactor:` | 唔改行為嘅重構 |

### 2.2 標準流程（照抄即可）

```powershell
cd "D:\File\Program Project"          # monorepo 根目錄
git status --short FYP                # ① 先睇清楚今次到底改咗咩

# ② 跑驗證（在 FYP 目錄內）
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "FYP\tools\verify.ps1" -Note "簡述今次改動"

# ③ 驗證 PASS 之後：更新 manifest（如檔案有增刪或內容改動）
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "FYP\tools\verify.ps1" -WriteManifest
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "FYP\tools\verify.ps1"   # 再跑一次確認仍然 PASS

# ④ 只 add 今次改動嘅檔案（明確路徑，唔准 -A）
git add FYP/agent.md FYP/tools/manifest.json

# ⑤ 一個改動一個 commit
git commit -m "docs(agent): 補上驗證記錄要求與 manifest 更新流程"
```

> **沙箱注意**：`git add`／`git commit` 會寫 monorepo 根目錄嘅 `.git`（在本工作區以外）。
> 受限沙箱下可能出現 `index.lock: Permission denied`。此時**唔要**改用其他寫法繞過，
> 而係將該次 git 指令升級權限重試一次（本專案先例：Umapyoi 同樣做法）。

### 2.3 建議嘅 commit 顆粒度（示例）

| 改動 | 應該拆成 |
| --- | --- |
| 新增一個 MCP 工具 ＋ 更新文件 | `feat(...)` 一個、`docs(...)` 一個（**兩個 commit**） |
| 同一份 playbook 修正兩個唔相關參數 | `fix(...)` 兩個（如果驗證唔互相影響） |
| 改 README 同時加驗證腳本 | `docs(...)` ＋ `test(...)`／`chore(...)` 分開 |

---

## 3. AI 安全護欄（本專案嘅技術立場，Agent 必須遵守）

本專案核心命題係「網絡由 AI／MCP／LLM 管理」，所以**呢節同時係產品需求同 agent 行為規範**。

- **唯讀為預設（Read-Only Default）**：AI 對 Windows／Linux／Cisco／監控只做觀察、關聯、解釋、提案。**任何變更都要人手批准**。
- **變更五步鏈（缺一不可）**：`6 欄位提案 → 人手批准 → 一次性 token → 執行 → 稽核記錄`。
- **一次性 token**：同一個批准只能用一次、綁定單一目標同單一命令、有效期短、用完即失效。
- **雜湊鏈稽核（hash-chained audit log）**：每筆記錄含前一筆雜湊；`100%` 覆蓋率，可驗證未被篡改。
- **最小權限身分**：每個 MCP server 一個專用服務身分；**LLM 本身永遠唔持有任何憑證**。
- **護欄清單**：主機允許清單（allow-list）、命令枚舉（只用白名單命令）、爆炸半徑聲明、逾時、呼叫預算、資料脫敏、prompt injection 防禦。
- **絕對禁止**：
  - 未經批准嘅自動變更（automated mutation）；
  - 聲稱 AI／自動化「管理」Packet Tracer（Packet Tracer 只准做設計工具）；
  - 觸碰生產資料、公網 IP、商業授權；
  - 微調模型、建 digital twin、自癒（self-healing）——三者明確在範圍外。

### 3.1 檔案／工具層硬規則

1. **`agent.md` 同 `README.md` 係專案入口**：任何新增目錄、工具、驗證方式，**必須同時更新呢兩份文件**，並在 `tools/manifest.json` 登記。
2. **`tools/` 係唯一驗證入口**：不准在校外另建一套「臨時驗證腳本」當交差。要新檢查項目，就加入 `tools/verify.ps1`。
3. **IaC／playbook 不准出現明文密碼**：一律用環境變數或 Ansible Vault；`git status` 見到疑似機密就停手。
4. **`_reports/`、暫存腳本、匯出檔唔准入版控**（見 §2.1-5）。
5. **唔准為咗令驗證 PASS 而刪走檢查項目或放寬規則**。要改標準，必須在 commit 訊息寫明理由，並由使用者確認。
6. **編碼硬規則**：`.ps1` 一律存成 **UTF-8 with BOM**；`.md`／`.txt` 一律 **UTF-8 without BOM**。
   本機 Windows PowerShell 5.1 會以 ANSI 讀冇 BOM 嘅 `.ps1`，中文註解會被誤讀並令整個腳本解析失敗；
   而 `edit` 類工具改檔後會**清走 BOM**，所以**每次編輯過 `.ps1` 之後，都要先補回 BOM，再跑驗證**（見 §8）。

---

## 4. 專案事實（改任何嘢之前先讀呢節）

### 4.1 規模與分流

| 層 | 數量 | 角色 |
| --- | --- | --- |
| Hypervisor | 1 | ESXi／Proxmox VE |
| Windows Server | 4 VM ＋ 1 Client | AD 服務、管理、CLI、GUI、客戶端工作站 |
| Linux Server | 3 VM | 核心服務（DHCP／OCI 容器／Nginx／nftables／VPN／LDAP／Mail）、備援（Keepalived＋k8s）、監控引擎 |
| Cisco | 4 Router ＋ 2 Switch | OSPF＋EIGRP／DMVPN／eBGP＋iBGP、HSRP／RSTP／DHCP |
| AI／MCP | 1～2 VM | 本地 LLM ＋ MCP server ＋ agent 工作站 |

- **整體流程（順序不可顛倒）**：`Manual deploy → IaC → Infra → Automations → AI Monitoring/Management`。
- **最低可行（Stage B）**：至少 **1 台實體 Cisco 設備**被 AI 以唯讀模式管理。
- **目標（Stage C）**：Cisco 4 路由器 ＋ 2 交換器全部接入 AI 管理層。

### 4.2 五階段與關卡（G0–G6）

| 階段 | 做咩 | 產出 | 關卡 |
| --- | --- | --- | --- |
| 1 手動部署 | 最小可行環境：1 Win AD、1 Linux、1 Cisco、1 監控 | 可達、SSH／ping 通、SNMP 開好、metrics 睇得到 | 全設備 transcript；至少 1 Cisco 可用 SSH＋SNMPv3（G1） |
| 2 IaC | 把手動步驟變成 Git＋Ansible＋PowerShell 模板 | 可重用 playbook／腳本／模板 | 空環境可重建；**第二次執行零漂移** |
| 3 Infra | 擴到目標規模 | 完整混合網絡、AD 網域、路由交換、監控 | 跨族互通；**Prometheus 全部 target healthy** |
| 4 Automations | 自動設定、合規、備份、報告 | 幂等腳本＋稽核記錄 | 重跑不變；review／commit 記錄乾淨 |
| 5 AI Mgmt | 本地 LLM＋MCP＋Prometheus／Grafana，唯讀診斷、審批式變更 | AI 管理層、MCP servers、稽核鏈 | 用例全過：跨族診斷、漂移檢查、問答、已批准變更 |

**三個「先後鐵則」**：可達性先於寫 IaC｜IaC 穩定先於擴規模｜監控先於餵資料畀 AI。

### 4.3 評估套件（改動 AI 相關嘢時嘅必過項）

- **12 個固定情境** × 每次 3 跑（驗證操作穩定性）。
- **5 個注入故障**，對照已知 ground truth 驗診斷準確度。
- **9 個權限邊界測試**，專測未授權呼叫嘅拒絕路徑。
- **幻覺檢查**：對唔存在嘅主機／服務／網段提問，AI 必須承認唔存在。
- **漂移與稽核完整性**：漂移誤報檢查 ＋ 稽核記錄 `100%` 覆蓋。

### 4.4 12 週路線圖

| 週 | 重點 | 關卡 |
| --- | --- | --- |
| W1 | 平台選型、Git 設定、基線模板、手動最小環境 | G0：Base Setup Passed |
| W2–W3 | 首台 Cisco 可達、Win AD 部署、初步監控 | G1：Device Reachability |
| W4–W6 | 完整 IaC、Infra 擴容、Prometheus／Grafana、本地 LLM spike | G2-H：Automation & Model Spike |
| W7–W8 | 開發 5 個 MCP server、Ansible／PowerShell 整合、唯讀 AI 平面 | G3：AI Read-Only Plane |
| W9–W10 | AI 診斷、漂移檢查、問答、已批准變更、跑評估套件 | G4：Evaluation & Guardrails |
| W11–W12 | 全面驗證、報告定稿、executive summary、最終示範 | G5／G6：Final Project Acceptance |

> **W9 技術凍結（Technical Freeze）**：W9 之後唔再加新功能，只做測試與文件。**Agent 在 W9 後不得新增功能程式碼**，除非使用者明確解除凍結。

### 4.5 角色與交付

| 角色 | 範圍 |
| --- | --- |
| S1 | Cisco 與網絡基建（路由、交換、可達性） |
| S2 | Windows／AD／身分管理 |
| S3 | Linux／服務／監控（Prometheus／Grafana、服務備援） |
| S4 | AI／MCP／自動化／文件 |

交付項：`D1` 環境、`D2` 服務、`D3` AI 管理層、`D4` 評估、`D5` 變更提案、`D6` 設計圖、`D7` 手冊、`D8` 測試報告、`D9` 稽核證據、`D10` 參考架構、`D11` 簡報、`D12` 執行摘要。

### 4.6 風險（Agent 要主動提示）

| 風險 | 緩解 |
| --- | --- |
| Cisco 平台不可達 | W3 前證明 1 台實體設備 SSH＋SNMPv3 可達；失敗就轉 hybrid／備案 |
| 模型 tool calling 弱 | 先用 malformed-call rate 前測選模型；必要時縮小用例 |
| 硬件不足 | CPU fallback；LLM **唔可以**同被管基建放埋一齊 |
| 範圍蔓延 | W9 技術凍結；之後只做測試與文件 |
| Packet Tracer 假報告 | 只當設計工具；禁止聲稱對 PT 有 AI／自動化管理 |

---

## 5. 目錄與檔案職責

| 路徑 | 職責 | 可否手改 |
| --- | --- | --- |
| `README.md` | 專案入口：目標、規模、五階段、評估、路線圖、驗證方式 | ✅（改完要跑驗證） |
| `agent.md` | 本檔：Agent 工作守則、R1／R2、護欄、驗證階段 | ✅（同上） |
| `tools/verify.ps1` | **唯一驗證入口**（Stage A／B／D） | ✅（改完即刻用新舊結果對照） |
| `tools/manifest.json` | 入版控檔案嘅 SHA-256 清單（漂移偵測） | ❌ 只准 `-WriteManifest` 產生 |
| `_reports/` | 驗證記錄（產生物） | ❌ 不入版控 |
| `Victor2_Enterprise_Network_Infrastructure_4Pages_EN.docx` | 官方 4 頁計劃書（需求來源，**唯讀基準**） | ❌ 只讀 |
| `With in AIMCPLLM.txt` | 原始需求草稿（範圍來源） | ❌ 只讀 |

> 未來嘅 IaC／playbook／MCP 目錄（例如 `iac/`、`ansible/`、`mcp/`、`docs/`）加入時，
> **必須**同時更新本表、`README.md` 嘅目錄結構、以及 `tools/verify.ps1` 嘅檢查範圍。

---

## 6. Agent 快速路徑

| 我想… | 點做 |
| --- | --- |
| 改文件（README／agent.md） | ① 改 → ② `verify.ps1`（A＋B）→ ③ 重跑確認 PASS → ④ `git add FYP/... FYP/tools/manifest.json` → ⑤ `git commit` |
| 加驗證檢查項目 | ① 改 `tools/verify.ps1` → ② 用 `-WriteManifest` 更新 → ③ 全跑一次確認 PASS → ④ `test(...)` commit |
| 加 IaC／playbook | ① 先確認對應設備**可達**（§4.2 鐵則）→ ② 寫模板 → ③ 空環境重建 ＋ 二次執行零漂移 → ④ `feat(...)` commit |
| 加 MCP 工具 | ① 先寫權限邊界測試（9 類）同拒絕路徑 → ② 實作（唯讀優先）→ ③ 跑評估套件 → ④ `feat(...)` commit |
| 改 AI 嘅變更流程 | ① 確認五步鏈完整（提案→批准→一次性 token→執行→稽核）→ ② 驗雜湊鏈完整性 → ③ 跑 9 個邊界測試 → ④ commit |
| 懷疑有人未經記錄改嘢 | `verify.ps1 -Stage B`（hash 對唔上就係漂移）→ 查 `git log --oneline -- FYP` |
| 交報告／示範 | `verify.ps1 -Stage D`，並引用 `_reports/` 嘅記錄；`D8` 測試報告要貼失敗→修正→通過嘅完整過程 |

---

## 7. 完成定義（Definition of Done）

一個改動只有**全部**滿足以下條件，先可以報「完成」：

- [ ] 屬今次改動嘅檔案已改動，且**未有**超出範圍嘅順手改動。
- [ ] `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/verify.ps1` 退出碼 `0`（`RESULT: PASS`）。
- [ ] `tools/manifest.json` 已更新並在**同一個 commit** 內（如適用）。
- [ ] 文件（`README.md`／`agent.md`）同實作一致；新增目錄／工具已登記。
- [ ] 已執行 `git commit`，訊息符合 §2.1-6 格式，且只包含今次改動嘅檔案。
- [ ] `_reports/` 驗證記錄存在，並在報告／commit 訊息被引用。
- [ ] 若屬 Stage C／D：實測證據（transcript、測試報告、稽核記錄）已附上。

**未滿足任何一項 → 未完成 → 唔准開始下一個改動。**

---

## 8. 疑難排解

| 症狀 | 原因 | 處理 |
| --- | --- | --- |
| `Missing closing '}'`／`Missing type name after '['`／錯誤訊息出現亂碼（例：`嚗?`） | `.ps1` 被 Windows PowerShell 5.1 當成 ANSI 讀（**冇 UTF-8 BOM**），中文註解令解析爆掉 | 補回 BOM：`[System.IO.File]::WriteAllText($p, $text, (New-Object System.Text.UTF8Encoding($true)))`；再跑 `verify.ps1` 確認 `UTF-8 BOM（.ps1 必須有）` PASS |
| 編輯 `tools/verify.ps1` 之後立即 FAIL：`UTF-8 BOM（.ps1 必須有）` | `edit`／`write` 工具會清走 BOM | 同上：先補 BOM，再重跑；**唔准**為咗方便而豁免呢項檢查 |
| `因為這個系統上已停用指令碼執行…` | 本機執行原則禁止 `.ps1` | 一律用 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/verify.ps1` |
| `pwsh: 無法辨識 'pwsh' 詞彙` | 本機冇 PowerShell 7 | 改用 `powershell.exe`（見上一行） |
| `verify.ps1` FAIL：`manifest hash 不符` | 檔案改咗但 manifest 未更新 | 跑 `-WriteManifest`，再全跑一次，然後同一次 commit 交 |
| `verify.ps1` FAIL：`未登記檔案` | 新增檔案未入 manifest | 同上；若係產生物，應改成唔入版控 |
| `verify.ps1` FAIL：`Markdown 連結指唔到` | 連結目標檔名／路徑錯 | 修好連結；唔准刪走該檢查 |
| `index.lock: Permission denied` | 沙箱限制，`git` 要寫 workspace 以外嘅 `.git` | 該次 git 指令**升級權限重試一次**，唔要另找繞路 |
| `git add -A` 見到其他專案檔案 | monorepo 特性 | 取消，改用明確路徑（見 §2.2-④） |
| 驗證 PASS 但功能唔正常 | 檢查項目不足 | **加檢查項目**（唔准入版控例外），再重跑；呢個係改善驗證，唔係放寬驗證 |

---

## 9. 規則修訂

`agent.md` 同 `tools/verify.ps1` 係本專案嘅憲法級檔案。修訂流程：

1. 使用者提出或同意修訂。
2. 改 `agent.md`／`tools/verify.ps1`（**條文要具體、可檢查**，唔准寫「盡量」、「建議」當規矩）。
3. 跑 `verify.ps1`（A＋B）→ 更新 manifest → 重跑確認 PASS。
4. 一個獨立 commit（`docs(agent): …` 或 `test(verify): …`），訊息要寫明**為何修訂**同**影響範圍**。

> 現行版本：`v1.0.0`（2026）｜對應驗證入口：`tools/verify.ps1`｜Manifest：`tools/manifest.json`
