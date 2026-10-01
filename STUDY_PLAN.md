# Victor2 FYP 五學期學習計劃（零基礎版）

> 題目（最新版官方題目頁）：**Victor2 ─ Enterprise Network Infrastructure and Architect**（`Victor2_Topic_AY2627_Detailed.png`，AY2026/27）
> 對象：**完全冇概念**嘅隊友
> 結構：**Sem 1 全隊一齊學晒所有基礎** → **Sem 2–5 各自做返自己嗰 part（並行）＋ 每學期尾整合檢查點**
> 配套文件：[LEARNING_GUIDE.md](LEARNING_GUIDE.md)（名詞「一句人話＋比喻」）｜[README.md](README.md)（專案入口）｜[agent.md](agent.md)（工作守則）

---

## 0. 我哋嘅處境、策略同題目要求

| 現況 | 策略 |
| --- | --- |
| 全隊基本上對呢堆嘢冇概念 | **Sem 1 用一個學期追齊所有基礎**，令之後分工時大家講同一種語言 |
| Sem 2–5 要各自做自己嗰 part | 每個 part 都有獨立任務同證據，**唔會互相等**；每學期尾做一次整合測試 |
| 知識面太廣（網絡／Windows／Linux／雲／AI） | **三級制**：自己主責領域去 L3，其他 L1–L2 |
| 5 個學期好長，容易鬆散 | 每學期一個**明確關卡**，每單元一個**可交嘅證據** |
| 唔知自己做對唔對 | 每個任務都有驗收標準（有 transcript？有 metrics？verify PASS？） |

### 0.1 三級制（成個計劃嘅核心）

| 級別 | 意思 | 比喻 |
| --- | --- | --- |
| **L1 識名** | 聽得明、知係邊個部門 | 識得叫同事個名 |
| **L2 識用** | 跟住步驟做得到 | 識用影印機 |
| **L3 識設計排錯** | 自己規劃、自己 debug、教人 | 識維修影印機 |

> **Sem 1 完結時**：全部人要喺四大領域（網絡／Windows／Linux／Cisco 意識＋監控自動化）達到 **L1–L2**。
> **Sem 2–5**：每個人喺自己主責領域推到 **L3**；其他領域保持 L1–L2（有問題識問、識睇）。

### 0.2 官方題目要求 ↔ 邊個角色負責（唔可以漏）

**以最新版題目頁（`Victor2_Topic_AY2627_Detailed.png`）為準**；較早嘅 `AY2627_FYP topics_v2_Victor Li.docx` 只作背景參考。

| # | 官方要求（最新題目頁） | 具體技術例子 | 主責 | 我哋點覆蓋 | 證據 |
| --- | --- | --- | --- | --- | --- |
| 1 | Microsoft Server Networking and Network Services | ADDS、FSRM、iSCSI、RRAS、IKEv2 | S2 | AD 網域、檔案／儲存服務、遠端存取、站點 VPN | transcript＋截圖 |
| 2 | Linux Server Administrations | Nginx、Keepalived、nftables、OpenVPN／WireGuard | S3 | Linux 服務機：網頁、防火牆、VPN、高可用 | 服務清單＋測試輸出 |
| 3 | Cisco Networking | BGP、OSPF、EIGRP、RSTP、ASA | S1 | 4 Router＋2 Switch：路由／交換／防火牆 | show 輸出＋transcript |
| 4 | Network Automation | PowerShell scripting、Ansible Playbook、Bash shell scripting | S4 主導；S1／S2／S3 各寫自己嗰套腳本 | IaC＋自動化共用一個 Git repo；幂等驗收 | playbook＋二次執行零漂移 |
| 5 | AI Network Management | Agentic AI、OpenClaw Skills | S4 | 本地 LLM＋5 個 MCP server＋審批式變更護欄 | 跨族問答＋稽核記錄 |

**本組計劃書額外要求**（出自 4 頁計劃書同需求草稿；最新題目頁冇列出，但照做）：

| 額外要求 | 主責 | 證據 |
| --- | --- | --- |
| Infrastructure monitoring（Prometheus／Grafana／SNMP／syslog） | S3 | targets UP＋儀表板 |
| Disaster Recovery（IaC 重建、Keepalived 切換、DC 還原、路由備援） | S1／S2／S3 各自＋S4 記錄 | 演練報告（前後對照） |
| Visualization（Grafana 儀表板、拓撲圖） | S3 | 圖＋截圖 |

> 官方要求交付 **findings、manuals、steps、screen captures、verifications、references** —— 對應 D7 手冊、D8 測試報告、D9 稽核證據、D10 參考架構（**screen captures 要當正式證據保存**）。
> **要查清楚嘅新名詞**（Sem 4 前）：**Agentic AI**（會自己規劃多步嘅 AI agent）同 **OpenClaw Skills**（題目指定嘅技能包）—— 搵官方文件確認係咩、點用。
> **標準出處**：WorldSkills Occupational Standards **2026** ─ IT Network Systems Administration（**Skill 39**，老師確認）。

---

## 1. 五學期全景圖（一頁睇完）

     Sem 1：共同基礎營（全隊一齊，冇分工）
        ↓ 關卡 G0
     Sem 2–5：各自做自己嗰 part（S1 Cisco／S2 Windows／S3 Linux 監控／S4 AI 自動化）
        每學期尾做一次「整合檢查點」→ G1 → G2-H → G3 → G4/G5/G6

| 學期 | 模式 | 主題 | 關卡 | 學期末成果 |
| --- | --- | --- | --- | --- |
| **Sem 1** | 全隊一齊 | 共同基礎營：虛擬化、網絡、Windows、Linux、Cisco 意識、監控、自動化、Git、AI 概念 | **G0** | 全隊都講得清基礎名詞；IP 規劃表；每人一部機跑得起 |
| **Sem 2** | 各自 part | 三族設備正式上線＋初步監控 | **G1** | 三族可達、AD 有網域、Prometheus 有 target |
| **Sem 3** | 各自 part | 規格化：IaC、模板、備援、監控完善 | **G2-H** | 空環境重建、二次零漂移、模型前測過關 |
| **Sem 4** | 各自 part | AI 唯讀平面：5 個 MCP server | **G3** | 跨族問答、AI 改唔到嘢（有拒絕記錄） |
| **Sem 5** | 各自 part | 審批式變更、評估、災難復原演練、交付 | **G4／G5／G6** | 五步鏈、評估套件全過、D1–D12、示範 |

**為何 Sem 1 要「學晒所有基礎」？**
比喻：**起樓之前，全隊都要識睇同一張圖紙**。如果 S1 只識 Cisco、S2 只識 AD，到 Sem 3 要一齊做 IaC 同監控時，就會雞同鴨講。Sem 1 唔需要你精，只需要你**聽得明同做得到最基本嘅一次**。

---

## 2. 學習方法：LEARN 四步循環

| 步 | 做咩 | 時間 | 比喻 |
| --- | --- | --- | --- |
| **L — Learn** | 只學**一層**：呢個名詞係咩、做咩、關我咩事 | 20 分鐘 | 睇游水教學片 |
| **E — Exercise** | 即刻落手做一次（哪怕只係開一個服務） | 30–60 分鐘 | **落水試** |
| **A — Articulate** | 用自己嘅話＋一個比喻寫 3 句 | 10 分鐘 | 講返畀自己聽 |
| **R — Record** | 跑驗證、更新 manifest、commit（R1／R2） | 15 分鐘 | 入帳簿，成為證據 |
| **N — Next** | 記低一條「我仲未明」嘅問題 | 5 分鐘 | 留條尾巴下個單元解決 |

### 2.1 零基礎三招

1. **先睇片，後睇文件**：官方文件係寫畀已經識嘅人。先睇影片建立印象，做完一次，再返去讀文件。
2. **只學夠用嘅一層**：唔好一開始就鑽協定細節，夠用就停。
3. **每個名詞寫一句比喻**：寫唔出比喻 = 你未明。

### 2.2 唔明白嘅求助階梯（防止卡死）

    自己試 → 20 分鐘
    查官方文件／教學 → 20 分鐘
    問隊友或 AI → 20 分鐘
    仍然唔得 → 記落「未明清單」，繼續下一樣（總共唔好卡超過 3 小時）

### 2.3 每個概念嘅筆記模板（照抄）

    名詞：
    一句人話：
    比喻：
    喺本專案邊度用：
    我做過嘅證據（檔案／截圖／commit）：
    我仲未明：

---

## 3. 每週節奏模板（每學期通用）

| 日 | 時數 | 做咩 |
| --- | --- | --- |
| 一 | 1.5h | 學本單元第 1 個概念（影片＋筆記） |
| 二 | 1.5h | 落手做一次（跟教學，但改一個參數試下） |
| 三 | 1.5h | 自己由零再做一次（唔睇教學） |
| 四 | 1.5h | 寫筆記（比喻）＋記低未明問題 |
| 五 | 1.5h | 跑驗證、更新 manifest、commit（R1／R2） |
| 六 | 2h | 小組整合、交叉檢查、補漏 |
| 日 | — | 休息／覆盤 |

**每日 15 分鐘微習慣**：抄低一個新名詞＋一句比喻。5 個學期之後你會多 **150–250 個名詞**。

---

## 4. Sem 0：開學前兩星期（完全零基礎熱身）

| 日 | 做咩 | 完成標準 |
| --- | --- | --- |
| D1–D2 | 裝虛擬機軟件＋開一部 Ubuntu VM | 見到 Ubuntu 登入畫面 |
| D3–D4 | 終端機基本：ls、cd、pwd、cat、sudo、apt install、systemctl status | 唔睇教學打得出一半命令 |
| D5–D6 | SSH：由主機連入 VM | 成功登入並執行 whoami |
| D7–D8 | 裝 Git，做第一次 add／commit／log | 見到自己嘅 commit |
| D9–D10 | 讀 LEARNING_GUIDE 第 1 節，用一句話講 IP／網段／閘道／DNS／DHCP | 畫得出「兩部機點樣通」嘅圖 |
| D11–D12 | 跑一次 tools/verify.ps1，睇 RESULT: PASS 同 _reports | 明白「驗證」係咩 |
| D13–D14 | 讀完 LEARNING_GUIDE，寫低「我仲未明」清單（最少 15 條） | 有一張問題清單 |

---

## 5. Sem 1：共同基礎營（關卡 G0：Base Setup Passed）

**學期目標（一句）**：全隊由「乜都唔識」變成「四大領域都聽得明、做得到最基本嘅一次」，並定好 IP 規劃同服務目錄。

**教學方式**：每週一次全隊 2 小時「共學」（輪流做小老師：每人講一個自己學識嘅概念）＋ 各自落手做。

| 單元 | 學咩（比喻） | 做咩 | 交咩證據 |
| --- | --- | --- | --- |
| **1.1 環境與版控** | VM ＝ 魚缸；快照 ＝ 遊戲存檔；Git ＝ 紀錄簿 | 每人開 2 部 VM（1 Windows、1 Linux）；互相 ping／SSH；跑 tools/verify.ps1；做一次 commit | VM 截圖＋SSH 輸出＋verify PASS |
| **1.2 網絡全餐** | IP ＝ 地址；閘道 ＝ 大閘；DNS ＝ 電話簿；DHCP ＝ 派房卡；VLAN ＝ 地毯分區；Router ＝ 分揀中心 | 畫全網絡拓撲草圖；寫 **IP 規劃表**同**服務目錄**；查自己機嘅 IP／閘道／DNS；用 ping／tracert 睇路徑 | 拓撲圖＋IP 規劃表（放 docs/） |
| **1.3 Windows 與 Linux 入門** | AD ＝ 人事部＋門禁；CLI ＝ 精確落單；systemd ＝ 值班表 | Windows：升一個臨時 DC、開 2 個 user、1 條 GPO。Linux：裝 nginx、開服務、睇日誌、設 SSH key | AD 截圖＋nginx 可用＋日誌輸出 |
| **1.4 Cisco 意識＋監控＋自動化＋AI 概念** | IOS ＝ 權限房間；Prometheus ＝ 抄錶員；幂等 ＝ 確保你著住鞋；MCP ＝ USB-C 插頭 | 用 Packet Tracer／模擬器打一次基本 Cisco 命令；裝 Prometheus 睇一部機嘅 CPU；寫第一個 Ansible playbook（裝套件）；跑一次本地 LLM 問答 | 命令 transcript＋CPU 圖＋playbook＋LLM 問答截圖 |

### 5.1 基礎營完成標準（每人要親手做過，唔可以只睇）

- [ ] 可以唔睇筆記，用**一句話＋比喻**解釋：IP／網段／閘道／DNS／DHCP／SSH／Port／VLAN／AD／GPO／Docker 容器／IaC／幂等／MCP（14 個）
- [ ] 可以自己開一部 VM、SSH 入去、裝一個服務、睇日誌、跑一次 commit
- [ ] 可以畫出我哋目標網絡嘅草圖（三族＋監控＋AI 平面）
- [ ] IP 規劃表同服務目錄已經寫入 docs/ 並 commit
- [ ] 有一張「我仲未明」清單（呢張清單會跟住你 5 個學期）

### 5.2 學期末自測 5 題（全隊都要答得出）

| # | 問題 | 答案要點 |
| --- | --- | --- |
| 1 | VM 同容器最大分別？ | VM＝獨立單位（有自己核心）；容器＝外賣盒（共用主機核心） |
| 2 | 為何 AD 一定要配 DNS？ | AD 靠 DNS 做服務定位，冇 DNS 搵唔到 DC |
| 3 | 咩叫幂等？舉相反例子 | 做多次結果一樣；相反＝著多對鞋 |
| 4 | 「驗證通過」嘅準確定義？ | verify.ps1 退出碼 0，最後一行 RESULT: PASS |
| 5 | 為何唔准 git add -A？ | 呢度係 monorepo，會誤 commit 其他專案嘅檔案 |

### 5.3 卡關提示

- **唔好追求精通**：Sem 1 只需要 L1–L2。精通留返 Sem 2–5 各自做自己 part 嗰時。
- **唔好一個人學**：每週共學一次，輪流講；講得出＝真係明。
- 唔夠 RAM：一次只開一部 VM。

---

## 6. Sem 2–5：各自做自己嗰 part（並行）＋ 每學期整合檢查點

> 運作方式：**每人只追自己嗰欄**，每兩星期同步一次；每學期最後兩星期做「整合檢查點」（跨 part 測試），通過才報關卡。
> 角色：**S1** Cisco 與網絡｜**S2** Windows／AD／身分｜**S3** Linux／服務／監控／視覺化｜**S4** AI／MCP／自動化／文件。

### 6.1 Sem 2 ── 關卡 G1：Device Reachability

**學期目標（一句）**：三族設備正式上線、全部可達，AD 有網域，Prometheus 見到第一個 target。

| 角色 | 自己嗰 part（本學期要做嘅事） | 交咩證據 |
| --- | --- | --- |
| **S1** | 設備上線：設管理 IP、開 SSH＋SNMPv3、介面／VLAN 基本設定、整理命令清單 | **完整 transcript**＋show ip interface brief＋重啟後仍可達 |
| **S2** | 裝 Windows Server、升 DC（配 DNS）、建 OU／user／group、寫 1 條 GPO、客戶端加入網域 | AD 結構截圖＋GPO 生效證明 |
| **S3** | 裝 Linux 服務機：nginx、nftables（只開必要 port）、SSH key 登入；裝 Prometheus＋node_exporter，令第一個 target UP | 服務可用截圖＋targets UP＋一張 PromQL 結果 |
| **S4** | 建立文件基準：IP 規劃表、服務目錄、拓撲圖入 docs/；整理 Git／驗證流程；準備本地 LLM 環境 | docs/ 文件＋verify PASS＋LLM 跑得起嘅截圖 |

**整合檢查點（Sem 2 最後兩星期）**

1. 三族互相 ping（Windows ↔ Linux ↔ Cisco）
2. Prometheus 抄到 Linux ＋ 用 SNMP 抄到 Cisco
3. AD 客戶端可以經 DNS 解析到 Linux 服務嘅名
4. 全部證據入 docs/ 並通過 verify

**自測 3 題**

| # | 問題 | 答案要點 |
| --- | --- | --- |
| 1 | 改完 Cisco 設定唔存會點？ | 重啟即失去（白板冇抄落簿） |
| 2 | Metrics 同 Logs 分別？ | 數字（話你咩唔正常）／事件文字（話你點解） |
| 3 | 點證明「可達性」？ | ping 通＋SSH 登入成功＋有 transcript |

**卡關提示**：冇實體 Cisco 就用 Packet Tracer／GNS3 **練命令**（只作設計工具），同時書面提出備案；**唔可以**聲稱 AI 管理模擬設備。

---

### 6.2 Sem 3 ── 關卡 G2-H：Automation & Model Spike

**學期目標（一句）**：由「手動砌好」變成「用檔案描述、可以重建、重跑唔變」，並完成本地 LLM 前測。

| 角色 | 自己嗰 part（本學期要做嘅事） | 交咩證據 |
| --- | --- | --- |
| **S1** | 路由骨幹：OSPF（必要時 EIGRP／再分發）、VLAN／Trunk、HSRP；把 Cisco 設定**模板化**（同一套可重複套用多部機） | show ip route／ospf neighbor 輸出＋模板＋二部機套用記錄 |
| **S2** | Windows 自動化：用 PowerShell 做 AD／GPO／服務設定；把 Windows VM 模板化（可複製） | PowerShell 腳本＋模板複製流程＋重跑結果 |
| **S3** | Linux 自動化：用 Ansible roles 管服務；設定 **Keepalived 備援**；Prometheus alert rules＋第一塊 Grafana 儀表板（Visualization） | roles＋備援切換實測＋alert 觸發記錄＋儀表板截圖 |
| **S4** | 建立 Ansible 框架同 Git 目錄結構（IaC 同自動化共用同一個 repo）；做**本地 LLM spike**：20 次工具呼叫測試、計 malformed-call rate | playbook 框架＋兩次執行零漂移＋模型前測表 |

**整合檢查點（Sem 3 最後兩星期）**

1. **空環境重建**：由零跑一次全部 IaC → 三族服務都起返
2. **第二次執行零漂移**（changed＝0 或設定 hash 一致）
3. **Disaster Recovery 初步**：刪一部 VM／清一個服務，用 IaC 重建返（呢個就係最基本嘅災難復原）
4. Stage C 等級驗證 PASS

**自測 3 題**

| # | 問題 | 答案要點 |
| --- | --- | --- |
| 1 | 漂移同幂等嘅關係？ | 幂等工具重跑會拉返一致；漂移就係不一致本身 |
| 2 | malformed-call rate 高代表咩？ | 模型唔可靠，唔可以畀佢掂真系統 |
| 3 | 為何唔准寫明文密碼？ | 版控會令密碼永久留存；用 Vault 或環境變數 |

---

### 6.3 Sem 4 ── 關卡 G3：AI Read-Only Plane

**學期目標（一句）**：5 個 MCP server 齊備，AI 可以跨族問答同診斷，但**完全改唔到任何嘢**。

| 角色 | 自己嗰 part（本學期要做嘅事） | 交咩證據 |
| --- | --- | --- |
| **S1** | **Cisco MCP**：只提供 show 類唯讀工具（命令白名單）；整理 syslog 收集 | 工具清單＋呼叫輸出＋「寫入被拒」記錄 |
| **S2** | **Windows MCP**：讀 AD 網域狀態、使用者／群組原則、系統服務（唯讀） | 同上 |
| **S3** | **Linux MCP** ＋ **Monitoring MCP**：讀服務狀態／日誌／資源；查 metrics、alerts、日誌彙整 | 同上 |
| **S4** | **Documentation MCP**（主機事實、IP 規劃、服務目錄、漂移基準）＋ MCP host／agent 整合＋唯讀驗證 | 5 個 server 工具總表＋跨族問答完整記錄 |

**整合檢查點（Sem 4 最後兩星期）**

1. **跨族問答**：例如「Linux 上嘅網頁服務健唔健康？相關 Cisco 介面有冇異常？」→ AI 要跨 2 族以上找答案
2. **拒絕測試**：要求 AI 執行變更 → 必須被拒絕（有記錄）
3. 全部 5 個 server 都有工具清單同唯讀證明

**自測 3 題**

| # | 問題 | 答案要點 |
| --- | --- | --- |
| 1 | MCP 解決咩問題？ | 唔需要為每個系統寫專用接口；統一標準（USB-C） |
| 2 | 白名單比黑名單安全喺邊？ | 只准某幾樣，比禁止某幾樣更難繞過 |
| 3 | AI 提出要改嘢時正確流程？ | 6 欄位提案 → 人手批准 → 一次性 token → 執行 → 稽核 |

---

### 6.4 Sem 5 ── 關卡 G4／G5／G6：Evaluation, DR & Delivery

**學期目標（一句）**：實作五步鏈、跑完評估套件、完成災難復原演練，交出 D1–D12 並完成示範。

| 角色 | 自己嗰 part（本學期要做嘅事） | 交咩證據 |
| --- | --- | --- |
| **S1** | 4 Router＋2 Switch 全部接入 AI 管理層；做**路由／設備故障演練**（斷一條 link／停一部機，睇 HSRP／OSPF 收斂） | show 前後對照＋演練報告 |
| **S2** | 安全原則同稽核政策；做 **DC 備援／還原演練**（備份 → 破壞 → 還原） | 還原前後對照＋時間記錄 |
| **S3** | **服務備援切換演練**（停正機，Keepalived 接手）；完成 Visualization：總儀表板＋拓撲圖＋服務目錄圖 | 切換前後（服務不中斷）＋圖 |
| **S4** | 變更五步鏈實作（6 欄位提案／批准／一次性 token／執行／稽核）；跑評估套件；寫報告同簡報 | 提案樣本＋9 邊界測試＋稽核 100%＋D1–D12 |

**整合檢查點（Sem 5 最後三星期）**

1. 評估套件：**12 情境 ×3 次**、**5 個注入故障**（對 ground truth）、**9 個權限邊界測試**、**幻覺檢查**、**漂移＋稽核 100%**
2. 三次**災難復原演練**全部有前後對照記錄
3. Stage D 驗證 PASS；D1–D12 齊；示範演練 3 次

**自測 3 題**

| # | 問題 | 答案要點 |
| --- | --- | --- |
| 1 | 五步鏈缺一步會點？ | 唔算已批准變更，屬違規 |
| 2 | 何謂「拒絕路徑」測試？ | 故意做未授權嘅事，確認系統真係拒絕 |
| 3 | 為何報告要寫失敗過程？ | 證明真係排錯過，亦係 D8 測試報告嘅要求 |

---

## 7. 五個學期嘅能力遞進（每學期尾自我檢查）

| 領域 | Sem 1（全隊） | Sem 2 | Sem 3 | Sem 4 | Sem 5 |
| --- | --- | --- | --- | --- | --- |
| 網絡基礎 | L2 | L2 | L2 | L2 | L2 |
| 虛擬化 | L2 | L2 | L3 | L3 | L3 |
| Windows／AD | L1 | L2（S2） | L3（S2） | L3（S2） | L3（S2） |
| Linux 服務 | L1 | L2（S3） | L3（S3） | L3（S3） | L3（S3） |
| Cisco | L1 | L2（S1） | L2（S1） | L2（S1） | L3（S1） |
| 監控／視覺化 | L1 | L2（S3） | L3（S3） | L3（S3） | L3（S3） |
| 自動化／IaC | L1 | L1 | L3（S4） | L3（S4） | L3（S4） |
| 災難復原 | L0 | L0 | L1 | L1 | L3（各自） |
| Git／驗證流程 | L2 | L2 | L2 | L3 | L3 |
| AI／MCP／護欄 | L1 | L1 | L2 | L3（S4） | L3（S4） |

> 括號＝主責角色。**L0 ＝ 完全唔需要識，唔好花時間。**

---

## 8. 資源清單（按階段排序，零基礎優先）

### Sem 1（共同基礎）

- Linux 入門：Linux Journey、OverTheWire Bandit（遊戲式，最有效）
- 網絡基礎：Cisco Networking Academy（Skills for All）免費課程；Professor Messer 免費影片
- Git：官方 Git 教學、Learn Git Branching（互動版最好玩）
- 比喻字典：本專案 [LEARNING_GUIDE.md](LEARNING_GUIDE.md)

### Sem 2（各自 part 起跑）

- S1：Cisco Skills for All 嘅 CCNA 課程；Packet Tracer 官方教學；IOS 命令速查
- S2：Microsoft Learn（Active Directory Domain Services、Group Policy、Windows Server）
- S3：Ubuntu Server Guide、nginx Beginner Guide、nftables wiki、Prometheus Getting Started、Grafana Dashboards
- S4：文件寫作（Technical Writing 基礎）、Markdown、Proxmox VE 文件

### Sem 3（規格化）

- Ansible：Getting Started、Inventory、Playbook、Roles、Vault
- PowerShell：Microsoft Learn PowerShell 入門
- 備援：Keepalived 官方文件；Proxmox 備份同還原（Disaster Recovery）
- 監控：PromQL 基礎、Alerting rules、Grafana Alerting

### Sem 4（AI 平面）

- Model Context Protocol 官方網站（規格、範例、SDK）
- Ollama 或 LM Studio（自己電腦跑本地模型）
- 關鍵字：function calling、tool schema、prompt injection、hallucination

### Sem 5（評估與交付）

- OWASP 關於 prompt injection 嘅基礎文章
- WorldSkills Occupational Standards 2024 ─ IT Network Systems Administration（Skill 39）
- 論文／報告寫作同簡報技巧（學校圖書館資源）
- 可選認證：CCNA 200-301、LPIC-1 或 RHCSA、Ansible 基礎

> 全部以**官方網站**為準；影片只用作建立第一印象。

---

## 9. 進度追蹤表（可以 copy 去 Google Sheet）

| 學期 | 我嗰 part | 本學期做咗嘅 3 件事 | 證據路徑 | 自測分數 | 仲未明 |
| --- | --- | --- | --- | --- | --- |
| Sem 1 | 全隊基礎營 | | | /5 | |
| Sem 2 | S? | | | /3 | |
| Sem 3 | S? | | | /3 | |
| Sem 4 | S? | | | /3 | |
| Sem 5 | S? | | | /3 | |

> 每個學期尾填一次。**證據路徑**一定要有（檔案、截圖、commit hash、_reports 記錄）。冇證據＝未完成。
> 每學期完結前，全隊要一齊做「整合檢查點」；檢查點唔過，唔可以報關卡。

---

## 10. 常見卡關與解法（完全零基礎版）

| # | 症狀 | 真正原因 | 解法 |
| --- | --- | --- | --- |
| 1 | 「Sem 1 一次過學咁多，追唔上」 | 想精通 | Sem 1 只要 L1–L2；精通留返自己 part |
| 2 | 「名詞太多，睇兩頁就想放棄」 | 冇記憶鈎 | 每個名詞寫一句比喻；寫唔出就問 |
| 3 | 「官方文件睇唔明」 | 文件係寫畀識嘅人 | 先睇片做一次，再返去讀文件 |
| 4 | 「唔知自己做對唔對」 | 冇驗收標準 | 問：有 transcript 嗎？有 metrics 嗎？verify PASS 嗎？ |
| 5 | 「卡住幾個鐘」 | 唔識停 | 3 小時規則：記落未明清單，繼續下一樣 |
| 6 | 「Sem 2 之後各自做，唔知隊友做緊咩」 | 冇同步機制 | 每兩星期 30 分鐘同步；所有決定寫入 docs/ |
| 7 | 「改咗嘢但驗證 FAIL」 | 未更新 manifest／有 tab／BOM | 睇 _reports/verify-latest.txt 逐項修（LEARNING_GUIDE 第 16 節） |
| 8 | 「唔夠硬件」 | 資源規劃不足 | 用 Core 版 OS、一次只開必要 VM、模型用 CPU fallback |
| 9 | 「災難復原唔知點做」 | 冇演練 | 記住：**能夠由 IaC 重建 = 最基本嘅 DR**；再做一次人為破壞＋還原 |
| 10 | 「驚做錯嘢」 | 冇安全網 | 用 snapshot（遊戲存檔）；先喺隔離環境試 |

---

## 11. 用 AI 幫你學（正確用法）

| 可以叫 AI 做 | 唔可以叫 AI 做 |
| --- | --- |
| 用比喻解釋一個名詞（本專案最有效） | 未經批准就改你嘅設備（明文禁止） |
| 出練習題、改你嘅筆記、模擬問答 | 當 AI 講嘅就係事實（要自己驗證版本、命令、數字） |
| 幫你寫 playbook／腳本草稿（你再逐行睇明） | 貼機密／密碼／憑證畀 AI |
| 幫你檢查文件一致性 | 叫 AI「作」實驗結果（學術誠信） |

**比喻**：AI 係實習生，你係經理。**最後簽名嘅一定係你**。

---

## 12. 學期 ↔ 關卡 ↔ 交付對照

| 學期 | 模式 | 關卡 | 主要交付 |
| --- | --- | --- | --- |
| Sem 1 | 全隊基礎營 | G0 Base Setup Passed | D1 環境（基礎）、D6 設計圖（初稿） |
| Sem 2 | 各自 part | G1 Device Reachability | D1、D2 服務、D6 |
| Sem 3 | 各自 part | G2-H Automation & Model Spike | D2、D10 參考架構 |
| Sem 4 | 各自 part | G3 AI Read-Only Plane | D3 AI 管理層、D5 變更提案（設計） |
| Sem 5 | 各自 part | G4／G5／G6 | D4 評估、D7 手冊、D8 測試報告、D9 稽核證據、D11 簡報、D12 執行摘要 |

---

## 13. 一頁速讀（打印出嚟貼住）

    Sem 1：全隊一齊學晒所有基礎（G0）
    Sem 2–5：各自做自己嗰 part（S1 Cisco｜S2 Windows｜S3 Linux 監控｜S4 AI 自動化）
    每學期尾：整合檢查點，過咗才報關卡
    五階段：Manual → IaC → Infra → Automations → AI Mgmt
    三鐵則：可達先於 IaC｜IaC 穩先於擴規模｜監控先於餵 AI
    官方 8 項：Windows｜Linux｜Cisco｜Monitoring｜Automations｜Disaster Recovery｜Visualization｜AI Agents + MCP
    五步鏈：6 欄位提案 → 人手批准 → 一次性 token → 執行 → 稽核
    五類評估：12 情境 ×3｜5 注入故障｜9 邊界｜幻覺檢查｜漂移＋稽核 100%
    兩個規矩：R1 每次改動都要驗證 PASS｜R2 每次改動一個 commit
    一個核心：AI 只做唯讀診斷，所有變更都要人手批准，而且每一步都有證據

---

> 版本：2026（五學期版：Sem 1 基礎營 ＋ Sem 2–5 分工）｜配合 [LEARNING_GUIDE.md](LEARNING_GUIDE.md)｜驗證入口：tools/verify.ps1｜任何改動都要跑驗證並 commit（見 [agent.md](agent.md)）
