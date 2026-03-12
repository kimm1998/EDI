# EDI Module for Microsoft Dynamics 365 Business Central

A fully functioning **EDI (Electronic Data Interchange) AL Extension** for Microsoft Dynamics 365 Business Central, supporting both **X12** (North American) and **EDIFACT** (International) standards.

---

## Features

- **Dual EDI Standard Support**: X12 and EDIFACT with complete message parsing
- **Inbound Processing**: Automated parsing and BC document creation from EDI messages
- **Outbound Generation**: Generate EDI documents from posted BC sales invoices and shipments
- **Trading Partner Management**: Full configuration per partner with communication overrides
- **Field Mapping**: Dynamic EDI-to-BC field mapping with transformation rules
- **Comprehensive Logging**: Audit trail for all EDI processing activities
- **Acknowledgment Management**: Automatic 997/CONTRL acknowledgment generation
- **Error Handling**: Configurable retry logic with error notifications
- **Multiple Communication Methods**: SFTP, REST API, Azure Blob Storage, File System, AS2
- **Event-Driven Automation**: Auto-generate outbound EDI on posting of BC documents

---

## Supported Document Types

| X12 Code | EDIFACT Code | Description | Direction |
|----------|--------------|-------------|-----------|
| 850 | ORDERS | Purchase Order | Inbound |
| 810 | INVOIC | Invoice | Outbound |
| 856 | DESADV | ASN / Dispatch Advice | Outbound |
| 997 | CONTRL | Functional Acknowledgment | Both |
| 855 | ORDRSP | PO Acknowledgment / Order Response | Outbound |
| 820 | REMADV | Payment Order / Remittance Advice | Inbound |

---

## Project Structure

```
/
├── app.json                          # AL app manifest
├── .editorconfig
├── .gitignore
├── src/
│   ├── Enum/
│   │   ├── EDIDirection.Enum.al         # Inbound / Outbound
│   │   ├── EDIStandard.Enum.al          # X12 / EDIFACT
│   │   ├── EDIMessageStatus.Enum.al     # New, Received, Parsed, ... Error
│   │   ├── EDIDocType.Enum.al           # X12_850, EDIFACT_ORDERS, etc.
│   │   └── EDICommunicationType.Enum.al # SFTP, API, AzureBlob, FileSystem, AS2
│   ├── Table/
│   │   ├── EDISetup.Table.al
│   │   ├── EDITradingPartner.Table.al
│   │   ├── EDIDocumentType.Table.al
│   │   ├── EDIMessageHeader.Table.al
│   │   ├── EDIMessageLine.Table.al
│   │   ├── EDIFieldMapping.Table.al
│   │   ├── EDILogEntry.Table.al
│   │   └── EDIAcknowledgment.Table.al
│   ├── TableExt/
│   │   ├── CustomerEDI.TableExt.al      # EDI fields on Customer
│   │   └── VendorEDI.TableExt.al        # EDI fields on Vendor
│   ├── Page/
│   │   ├── EDISetup.Page.al
│   │   ├── EDITradingPartners.Page.al
│   │   ├── EDITradingPartnerCard.Page.al
│   │   ├── EDIDocumentTypes.Page.al
│   │   ├── EDIMessageList.Page.al
│   │   ├── EDIMessageCard.Page.al
│   │   ├── EDIMessageLines.Page.al
│   │   ├── EDIFieldMappings.Page.al
│   │   ├── EDILogEntries.Page.al
│   │   └── EDIAcknowledgments.Page.al
│   ├── Codeunit/
│   │   ├── EDIProcessor.Codeunit.al
│   │   ├── EDIX12Parser.Codeunit.al
│   │   ├── EDIEDIFACTParser.Codeunit.al
│   │   ├── EDIDocumentCreator.Codeunit.al
│   │   ├── EDIOutboundGenerator.Codeunit.al
│   │   ├── EDICommunication.Codeunit.al
│   │   ├── EDIAcknowledgmentMgmt.Codeunit.al
│   │   ├── EDIErrorHandler.Codeunit.al
│   │   └── EDIEventSubscribers.Codeunit.al
│   ├── Report/
│   │   ├── EDIMessageReport.Report.al
│   │   └── EDIMessageReport.rdlc
│   ├── XMLPort/
│   │   └── EDIImportExport.XMLPort.al
│   └── PermissionSet/
│       ├── EDIAdmin.PermissionSet.al
│       └── EDIUser.PermissionSet.al
└── test/
    └── EDIModuleTest.Codeunit.al
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    EDI Module Architecture                   │
├─────────────────────────────────────────────────────────────┤
│  Communication Layer                                         │
│  ┌──────────┐ ┌──────┐ ┌────────────┐ ┌────────────────┐   │
│  │   SFTP   │ │ API  │ │ Azure Blob │ │  File System   │   │
│  └──────────┘ └──────┘ └────────────┘ └────────────────┘   │
│                         ▲ ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              EDI Communication (50105)               │   │
│  └──────────────────────────────────────────────────────┘   │
│                         ▲ ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │               EDI Processor (50100)                  │   │
│  │           (Main Orchestration Engine)                │   │
│  └──────────────────────────────────────────────────────┘   │
│            ▼                          ▼                       │
│  ┌───────────────────┐    ┌───────────────────────────┐     │
│  │  EDI X12 Parser   │    │  EDI EDIFACT Parser       │     │
│  │     (50101)       │    │       (50102)             │     │
│  └───────────────────┘    └───────────────────────────┘     │
│            ▼                          ▼                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           EDI Document Creator (50103)               │   │
│  │  Creates Sales Orders, Purchase Orders, Invoices     │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         EDI Outbound Generator (50104)               │   │
│  │  Generates X12 810/856 and EDIFACT INVOIC/DESADV     │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         EDI Acknowledgment Mgmt (50106)              │   │
│  │         997 / CONTRL generation and processing       │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           EDI Error Handler (50107)                  │   │
│  │        Retry logic, error logging, notifications     │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Installation

### Prerequisites
- Microsoft Dynamics 365 Business Central (version 22.0 or later)
- AL Language extension for VS Code
- Access to a BC environment (cloud or on-premise)

### Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/kimm1998/EDI.git
   cd EDI
   ```

2. **Open in VS Code** with the AL Language extension installed.

3. **Configure `launch.json`** in `.vscode/` for your BC environment.

4. **Download symbols** (Ctrl+Shift+P → "AL: Download Symbols").

5. **Publish the extension** (F5 or Ctrl+Shift+P → "AL: Publish").

---

## Configuration Guide

### 1. EDI Setup

Navigate to **Search → EDI Setup** and configure:

| Group | Setting | Description |
|-------|---------|-------------|
| General | Default EDI Standard | X12 or EDIFACT |
| General | Default Communication Type | SFTP, API, Azure Blob, File System |
| General | Enable Logging | Enable audit logging |
| X12 | ISA Sender ID | Your ISA sender identifier |
| X12 | ISA Receiver ID | Your ISA receiver identifier |
| X12 | Segment Terminator | Default: `~` |
| X12 | Element Separator | Default: `*` |
| EDIFACT | UNB Sender ID | Your UNB sender identifier |
| EDIFACT | UNB Receiver ID | Your UNB receiver identifier |
| Automation | Auto Process Inbound | Auto-process inbound files |
| Automation | Auto Send Outbound | Auto-send outbound messages |
| Automation | Job Queue Interval | Processing interval in minutes |

### 2. Trading Partners

Navigate to **Search → EDI Trading Partners** and create partners:

- Set **Code** and **Name** for identification
- Link to **Customer No.** (for inbound sales orders) or **Vendor No.** (for inbound POs)
- Set **EDI Standard** (X12 or EDIFACT)
- Set **Partner EDI Identifier** (their ISA/UNB ID)
- Configure **Communication** overrides if different from global setup
- Enable **Active** flag when ready

### 3. Customer/Vendor EDI Fields

On the **Customer Card** or **Vendor Card**, set:
- **EDI Trading Partner Code**: Link to the trading partner
- **EDI Enabled**: Enable auto-generation of outbound EDI on posting
- **EDI Standard**: X12 or EDIFACT

### 4. Document Types

Navigate to **Search → EDI Document Types** to configure supported document types and their BC mappings.

### 5. Field Mappings

Navigate to **Search → EDI Field Mappings** to define EDI-to-BC field mappings:
- Select **Document Type Code**
- Set optional **Trading Partner Code** for partner-specific overrides
- Define **EDI Segment ID** and **Element Position**
- Map to **BC Table ID** and **BC Field ID**
- Set **Transformation Rules** (UPPERCASE, TRIM, DATEFORMAT:YYYYMMDD)

---

## Usage Guide

### Inbound Processing

**Automatic (Job Queue):**
1. Configure EDI Setup with inbound folder/SFTP/API settings
2. Enable **Auto Process Inbound**
3. Job Queue will pick up files automatically

**Manual:**
1. Navigate to **EDI Messages**
2. Use **Process** action on messages with status "Received"

### Outbound Processing

**Automatic (Event-Driven):**
1. Enable **EDI Enabled** on the Customer record
2. Set **EDI Trading Partner Code** on the Customer
3. Post a Sales Invoice → X12 810 or EDIFACT INVOIC is auto-generated
4. Post a Sales Shipment → X12 856 or EDIFACT DESADV is auto-generated

**Manual:**
1. Navigate to **EDI Messages**
2. Find the outbound message with status "New"
3. Use **Send** action to transmit

### Monitoring

- **EDI Message List**: View all messages with status and error information
- **EDI Log Entries**: Detailed audit trail for all processing events
- **EDI Acknowledgments**: Track 997/CONTRL acknowledgments
- **EDI Message Report**: Summary report by date range, partner, and status

---

## Troubleshooting

| Issue | Solution |
|-------|---------|
| Message stuck in "Received" | Check Log Entries for parsing errors; verify EDI format |
| Document not created | Verify Trading Partner has correct Customer/Vendor No.; check Item No. mapping |
| SFTP connection failed | Verify SFTP Host, Port, Username, Password in EDI Setup |
| API request failed | Check API Base URL and API Key; verify endpoint availability |
| Max retries exceeded | Check error message; fix root cause; use "Reprocess" action |
| Wrong EDI Standard detected | Manually set EDI Standard on the message header |

---

## Permission Sets

| Permission Set | Access Level |
|---------------|-------------|
| **EDI Admin** (50100) | Full RIMD access to all EDI objects |
| **EDI User** (50101) | Read/Insert/Modify on messages; Read-only on setup/mappings |

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes following AL coding conventions
4. Ensure all objects are in the ID range 50100-50199
5. Use PascalCase for all AL identifiers
6. Include tooltips on all page fields
7. Submit a pull request with a clear description

---

## License

This project is licensed under the MIT License.
