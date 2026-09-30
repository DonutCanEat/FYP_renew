# Victor2 ── Enterprise Network Infrastructure and Architect

**HDTN 畢業專案（FYP）｜4 位學生｜12 週｜Vertex Peak Financial Technologies Limited（FinTech／InsurTech）情境｜對標 WorldSkills 2026・IT Network Systems Administration（Skill 2447）**

用一座 **Windows／Linux／Cisco 混合網絡**，示範「**人手部署 ➜ IaC ➜ 基建 ➜ 自動化 ➜ 由 AI／MCP／LLM 監控與管理**」呢條完整演進路線。
專案嘅賣點唔係「砌到一個網絡」，而係**砌到一個可以被 AI 安全地管理、而且每一步都有證據嘅網絡**。

> **本目錄現況**：目前只有專案定義（計劃書）、需求草稿同治理規則，基建實作由 Stage 1 開始。
> 想睇「改嘢之前要注意咩」→ 讀 [agent.md](agent.md)；想睇「點驗證、點 commit」→ 本檔 §8。

---

## 1. 一句話講清楚

| 問題 | 答案 |
| --- | --- |
| 做咩？ | 建構並管理一個跨 Windows／Linux／Cisco 嘅企業混合網絡 |
| 點管理？ | **AI／MCP／LLM** 做觀察、關聯、解釋、提案；**變更一定要人手批准** |
| 點保證質素？ | IaC 可重建、自動化幂等、監控先於 AI、稽核 100% 覆蓋 |
| 點算成功？ | 見 §5 成功準則（三族可達、可重建、零漂移、唯讀診斷、審批式變更、文件齊全） |
| 明確唔做咩？ | 見 §6 範圍外（Packet Tracer 當受管設備、自動變更、生產資料、微調模型、自癒） |

---

## 2. 目標架構與規模

```
                    ┌─────────────────────────────────────────────┐
                    │  AI Management Plane（1～2 VM）              │
                    │  本地 LLM ＋ MCP Server ＋ Agent 工作站       │
                    │  唯讀診斷 ／ 漂移檢查 ／ 審批式變更           │
                    └───────────────┬─────────────────────────────┘
                     MCP（唯讀工具呼叫）│
        ┌───────────────┬───────────┴────────┬───────────────┐
        ▼               ▼                    ▼               ▼
  ┌───────────┐  ┌───────────┐      ┌─────────────┐  ┌──────────────┐
  │ Windows   │  │ Linux     │      │ Cisco       │  │ Monitoring   │
  │ 4 VM＋1    │  │ 3 VM      │      │ 4 Router    │  │ Prometheus   │
  │ Client    │  │           │      │ ＋2 Switch  │  │ ＋Grafana    │
  │ AD 網域    │  │ 服務／備援 │      │ 路由／交換  │  │              │
  └───────────┘  └───────────┘      └─────────────┘  └──────────────┘
        └────────────── 1 × Hypervisor（ESXi／Proxmox VE）──────────────┘
```

| 層 | 數量 | 角色與功能範圍 |
| --- | --- | --- |
| Hypervisor | 1 | ESXi／Proxmox VE 虛擬化平台 |
| Windows Server | 4 VM ＋ 1 Client | AD 服務、管理、CLI、GUI、客戶端工作站 |
| Linux Server | 3 VM | 核心服務（DHCP／OCI 容器／Nginx／nftables／VPN（WireGuard／OpenVPN）／LDAP／Mail）、備援（Keepalived＋k8s）、監控引擎 |
| Cisco 網絡 | 4 Router ＋ 2 Switch | 路由、交換、周邊基建。協定：OSPF＋EIGRP／DMVPN／eBGP＋iBGP、HSRP／RSTP／DHCP |
| AI／MCP | 1～2 VM | 本地 LLM ＋ MCP server ＋ agent 工作站 |

**階段目標**

- **最低可行（Stage B）**：至少 **1 台實體 Cisco 設備**被 AI 以**唯讀模式**管理。
- **目標（Stage C）**：Cisco **4 路由器 ＋ 2 交換器**全部接入 AI 管理層。

---

## 3. 五階段實作流程（順序不可顛倒）

```
Manual deploy ──▶ IaC ──▶ Infra ──▶ Automations ──▶ AI Monitoring / Management
  手動最小環境     模板化    擴到規模     自動化冪等        AI 唯讀＋審批式變更
```

| 階段 | 做咩 | 產出 | 關卡驗收 |
| --- | --- | --- | --- |
| **1. Manual deploy** | 手動部署最小可行環境：1 Win AD、1 Linux、1 Cisco、1 監控 | 網絡可達、SSH／ping 正常、SNMP 已開、metrics 睇得到 | 全設備 transcript；至少 1 台 Cisco 可用 SSH＋SNMPv3 存取 |
| **2. IaC** | 把手動步驟轉成 Git＋Ansible＋PowerShell 模板 | 可重用 playbook、腳本、設定模板 | **空環境可重建**；第二次執行**零漂移** |
| **3. Infra** | 擴到目標規模：Win 4＋1、Linux 3、Cisco 4R＋2S、AI／監控 VM | 完整混合網絡、AD 網域、路由交換、監控 | 跨族互通；**Prometheus 全部 target healthy** |
| **4. Automations** | Ansible／PowerShell 做自動設定、合規、備份、報告 | 幂等自動化腳本與稽核記錄 | 重跑不變（re-run invariant）；review 與 commit 記錄乾淨 |
| **5. AI Mgmt** | 本地 LLM＋MCP＋Prometheus／Grafana，唯讀診斷、審批式變更 | AI 管理層、MCP servers、稽核日誌鏈 | 用例全過：跨族診斷、漂移檢查、問答、已批准變更 |

### 3.1 三個「先後鐵則」

1. **可達性先於 IaC**：設備要先網絡可達，才寫 IaC 模板。
2. **IaC 穩定先於擴規模**：IaC 要穩定並驗證過，才擴基建。
3. **監控先於餵 AI**：基建要先經 Prometheus 監控，才把資料餵畀 AI。

### 3.2 AI 變更嘅唯一合法路徑（五步鏈）

```
6 欄位提案 ──▶ 人手批准 ──▶ 一次性 token ──▶ 執行 ──▶ 稽核記錄
```

任何一步缺失都唔算「已批准變更」。**預設係唯讀**：AI 只做觀察、關聯、解釋、提案。

---

## 4. AI／MCP 管理層規格

| 構面 | 規格 |
| --- | --- |
| **本地 LLM** | 離線模型，針對 tool calling 最佳化；**先做前測**（malformed-call rate）；無 GPU 時 CPU fallback |
| **MCP servers** | 5 個專用 server：Windows、Linux、Cisco、Monitoring、Documentation／Inventory |
| **工具分類** | 每個工具嚴格定型（strictly typed）；**預設唯讀**；最小量嘅變更工具必須人手批准 |
| **監控** | Prometheus＋Grafana；AI 經 MCP 介面查 metrics、alerts、logs |
| **自動化整合** | Ansible＋PowerShell＋Bash＋Git；**IaC 同自動化共用同一個 Git repo** |
| **身分與安全** | 每個 MCP server 用最低權限服務身分；**LLM 永不持有憑證** |
| **治理** | 主機允許清單、命令枚舉、一次性批准 token、雜湊鏈稽核日誌 |
| **護欄** | 資料脫敏、prompt injection 防禦、呼叫預算、逾時、爆炸半徑聲明 |
| **AI 操作邊界** | 觀察、關聯、解釋、提案，並在批准後執行**單一可逆變更**；**冇自主操作** |

### 4.1 五個 MCP Server

| # | MCP Server | 職責（全部唯讀優先） |
| --- | --- | --- |
| 1 | Windows MCP | 讀 AD 網域狀態、使用者／群組原則、系統服務 |
| 2 | Linux MCP | 讀 Linux 系統健康、執行中服務、應用日誌 |
| 3 | Cisco MCP | 查 Cisco `show` 命令、SNMP 狀態、syslog（**嚴格唯讀**） |
| 4 | Monitoring MCP | 查 Prometheus metrics、Grafana alerts、日誌彙整 |
| 5 | Documentation MCP | 存取主機事實、IP 規劃、服務目錄、漂移檢查基準 |

---

## 5. 成功準則

- **三族（Windows／Linux／Cisco）全部可達、可存取、被監控。**
- **IaC 模板可以由空環境完整重建整套基建。**
- **Ansible／PowerShell 自動化具幂等性**，可重跑而**零設定漂移**。
- **AI 只做唯讀**診斷、問答、漂移檢查；**所有變更都需要人手批准**。
- **交付完整文件、架構圖、命令 transcript、測試日誌。**

### 最終驗收

- **最低可行（Stage B）**：至少 1 台實體 Cisco 設備被 AI 以唯讀模式管理。
- **目標（Stage C）**：Cisco 4 路由器 ＋ 2 交換器全部納入 AI 管理層。
- **完成要求**：三族可達性、可重現 IaC、幂等自動化、唯讀 AI 診斷、審批式變更執行，以及完整文件／稽核日誌。

---

## 6. 範圍外（Non-Goals）

- ❌ **唔准**把 Packet Tracer 當作「AI 可管理」嘅網絡設備（PT 只係設計工具）。
- ❌ **唔准**自動變更或未經批准嘅寫入操作。
- ❌ **唔准**觸碰生產資料、公網 IP、商業授權。
- ❌ **唔准**微調模型、建 digital twin、實作自主自癒（self-healing）。

---

## 7. 評估與基準套件

改動 AI 相關嘅嘢，以下五類必須全過：

| 類別 | 內容 |
| --- | --- |
| **12 個固定情境** | 每個情境跑 **3 次**，驗證操作穩定性 |
| **5 個注入故障** | 對照已知 ground truth，驗診斷準確度 |
| **9 個權限邊界測試** | 嚴格測試未授權呼叫嘅**拒絕路徑** |
| **幻覺檢查** | 對唔存在嘅主機／服務／網段提問，AI 必須唔會作出嚟 |
| **漂移與稽核完整性** | 漂移誤報檢查；稽核日誌 **100% 覆蓋**驗證 |

---

## 8. 質素保證：驗證 ＋ 每次改動一個 commit

本目錄行兩條硬規矩（完整條文見 [agent.md](agent.md) §0）：

> **R1**：有任何修改都要進行驗證，**全部通過先可以繼續**。
> **R2**：**每一次修改都要進行一次 commit**。

### 8.1 一鍵驗證

```powershell
# 在 FYP 目錄執行
pwsh -NoProfile -ExecutionPolicy Bypass -File tools/verify.ps1 -Note "簡述今次改動"
```

- 退出碼 `0` 且最後一行 `RESULT: PASS` ＝ 可以繼續；否則**停手改到過為止**。
- 必須用 `-ExecutionPolicy Bypass`（本機停用了指令碼執行）。
- 每次驗證都會留底在 `_reports/verify-*.txt`（產生物，不入版控）。

### 8.2 驗證階段

| 階段 | 用於 | 內容 |
| --- | --- | --- |
| **A** | 任何檔案改動 | UTF-8、無 tab／不可見字元、Markdown 連結可解析、`agent.md` 兩條規矩齊全 |
| **B**（預設） | 文件／工具改動 | A ＋ 文件聲明一致性 ＋ `tools/manifest.json` **逐檔 SHA-256 漂移偵測** |
| **C** | IaC／自動化／AI 管理層 | B ＋ 實測：空環境重建、二次執行零漂移、權限拒絕路徑、稽核鏈完整 |
| **D** | 里程碑驗收（G0–G6） | B ＋ 里程碑準則齊全（成功準則／範圍外／評估套件／路線圖／風險） |

### 8.3 標準改動流程

```
① 分類（文件？工具？IaC？MCP？）
② 最小改動
③ 跑驗證：powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/verify.ps1
④ 失敗 → 改到過（唔准 commit 失敗狀態）
⑤ 通過 → 更新 manifest（-WriteManifest）→ 再跑一次確認 PASS
⑥ git add <明確路徑> → git commit（一個改動一個 commit）
⑦ 才開始下一個改動
```

> ⚠️ 本目錄係 monorepo（`D:\File\Program Project`，內含 `TimeMate`、`Umapyoi`）嘅子目錄。
> `git add` **一定要寫明路徑**，**嚴禁** `git add -A`／`git add .`。

### 8.4 編碼規則（踩過先寫落嚟）

| 檔案類型 | 編碼規定 | 原因 |
| --- | --- | --- |
| `.ps1` | **UTF-8 with BOM** | Windows PowerShell 5.1 會用 ANSI 讀冇 BOM 嘅腳本，中文註解令腳本解析失敗 |
| `.md`／`.txt` | **UTF-8 without BOM** | 通用慣例；GitHub 與各種工具都最兼容 |

> 編輯 `tools/verify.ps1` 之後，如果驗證報 `UTF-8 BOM（.ps1 必須有）` FAIL，**要補回 BOM 再跑**，
> 唔准為咗方便而豁免呢項檢查（`edit` 類工具會清走 BOM，這是已知行為）。

---

## 9. 12 週路線圖與關卡

| 週 | 重點工作 | 關卡里程碑 |
| --- | --- | --- |
| W1 | 平台選型、Git 設定、基線模板、手動最小環境 | **G0：Base Setup Passed** |
| W2–W3 | 首台 Cisco 可達、Win AD 部署、初步監控 | **G1：Device Reachability** |
| W4–W6 | 完整 IaC、Infra 擴容、Prometheus／Grafana、本地 LLM spike | **G2-H：Automation & Model Spike** |
| W7–W8 | 開發 5 個 MCP server、Ansible／PowerShell 整合、唯讀 AI 平面 | **G3：AI Read-Only Plane** |
| W9–W10 | AI 診斷、漂移檢查、問答、已批准變更、跑評估套件 | **G4：Evaluation & Guardrails** |
| W11–W12 | 全面驗證、報告定稿、executive summary、最終示範 | **G5／G6：Final Project Acceptance** |

> **W9 技術凍結**：W9 之後唔再加新功能，只做測試與文件。

---

## 10. 團隊角色

| 角色 | 負責範圍 |
| --- | --- |
| **S1** | Cisco 與網絡基建（路由、交換、可達性） |
| **S2** | Windows／AD／身分管理（Active Directory、安全原則、客戶端） |
| **S3** | Linux／服務／監控（Linux 主機、服務備援、Prometheus／Grafana） |
| **S4** | AI／MCP／自動化／文件（本地 LLM、MCP servers、Ansible／PowerShell、文件） |

---

## 11. 風險與緩解

| 主要風險 | 緩解策略 |
| --- | --- |
| Cisco 平台不可達 | W3 前證明 1 台實體設備可用 SSH＋SNMPv3 存取；失敗就轉 hybrid／備案 |
| 模型 tool calling 弱 | 先用 malformed-call rate 前測選模型；必要時縮小用例範圍 |
| 硬件不足 | CPU fallback；確保 LLM **唔會**同被管基建共用同一台機 |
| 範圍蔓延 | W9 嚴格技術凍結；之後專注測試與文件 |
| Packet Tracer 假報告 | 只作設計工具；**禁止**聲稱對 PT 有 AI／自動化管理 |

---

## 12. 交付項（D1–D12）

| 編號 | 交付項 | 編號 | 交付項 |
| --- | --- | --- | --- |
| **D1** | 環境（Environment） | **D7** | 手冊（Manuals） |
| **D2** | 服務（Services） | **D8** | 測試報告（Test Reports） |
| **D3** | AI 管理層（AI Management Plane） | **D9** | 稽核證據（Audit Evidence） |
| **D4** | 評估（Evaluation） | **D10** | 參考架構（Reference Architectures） |
| **D5** | 變更提案（Change Proposals） | **D11** | 簡報（Presentation） |
| **D6** | 設計圖（Design Diagrams） | **D12** | 執行摘要（Executive Summary） |

---

## 13. 目錄結構

```
FYP/
  README.md                                       本檔：專案入口（目標、規模、流程、評估、驗證）
  agent.md                                        AI Agent 工作守則：R1 驗證、R2 每次改動一個 commit、護欄
  tools/
    verify.ps1                                    唯一驗證入口（Stage A／B／D，含 manifest 漂移偵測）
    manifest.json                                 入版控檔案嘅 SHA-256 清單（由 -WriteManifest 產生）
  _reports/                                       驗證記錄（產生物，不入版控）
  Victor2_Enterprise_Network_Infrastructure_4Pages_EN.docx   官方 4 頁計劃書（需求來源，唯讀）
  With in AIMCPLLM.txt                            原始需求草稿（範圍來源，唯讀）
```

未來加入 `iac/`、`ansible/`、`mcp/`、`docs/` 等目錄時，必須同時更新本表與 [agent.md](agent.md) §5 嘅檔案職責表。

---

## 14. 目前狀態

| 項目 | 狀態 |
| --- | --- |
| 專案定義（計劃書／需求草稿） | ✅ 已完成（4 頁計劃書） |
| 治理規則（R1／R2、護欄、驗證階段） | ✅ 已建立（[agent.md](agent.md) ＋ `tools/verify.ps1`） |
| 驗證與漂移偵測機制 | ✅ 可用（`tools/verify.ps1` ＋ `tools/manifest.json`） |
| Stage 1 手動最小環境（G0／G1） | ⏳ 未開始 |
| IaC、Infra、Automations、AI Mgmt | ⏳ 未開始 |

---

## 15. 下一步

1. **W1**：決定 Hypervisor（ESXi／Proxmox VE）、建立 Git 基線、定好 IP 規劃與服務目錄（Documentation MCP 嘅資料來源）。
2. **Stage 1**：手動砌最小環境（1 Win AD、1 Linux、1 Cisco、1 Prometheus），並保存**完整命令 transcript**（G0／G1 證據）。
3. 每次實作都要走 §8.3 流程：**先驗證、後 commit**。
4. 新增任何目錄／工具，都要同步更新本檔、[agent.md](agent.md)、`tools/manifest.json`。
