report 50100 "EDI Message Report"
{
    Caption = 'EDI Message Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = RDLCLayout;

    dataset
    {
        dataitem(EDIMessageHeader; "EDI Message Header")
        {
            RequestFilterFields = "Trading Partner Code", "Direction", "Status", "Created DateTime", "EDI Standard";

            column(EntryNo; "Entry No.")
            {
                Caption = 'Entry No.';
            }
            column(MessageID; "Message ID")
            {
                Caption = 'Message ID';
            }
            column(TradingPartnerCode; "Trading Partner Code")
            {
                Caption = 'Trading Partner';
            }
            column(DocumentTypeCode; "Document Type Code")
            {
                Caption = 'Document Type';
            }
            column(Direction; Direction)
            {
                Caption = 'Direction';
            }
            column(EDIStandard; "EDI Standard")
            {
                Caption = 'EDI Standard';
            }
            column(Status; Status)
            {
                Caption = 'Status';
            }
            column(FileName; "File Name")
            {
                Caption = 'File Name';
            }
            column(BCDocumentNo; "BC Document No.")
            {
                Caption = 'BC Document No.';
            }
            column(TransactionDate; "Transaction Date")
            {
                Caption = 'Transaction Date';
            }
            column(ErrorMessage; "Error Message")
            {
                Caption = 'Error Message';
            }
            column(CreatedDateTime; "Created DateTime")
            {
                Caption = 'Created DateTime';
            }
            column(CreatedBy; "Created By")
            {
                Caption = 'Created By';
            }
            column(CompanyName; CompanyName())
            {
            }
            column(ReportTitle; ReportTitleLbl)
            {
            }
            column(PrintedDateTime; CurrentDateTime())
            {
            }

            trigger OnPreDataItem()
            begin
                if DateFrom <> 0DT then
                    SetFilter("Created DateTime", '>=%1', DateFrom);
                if DateTo <> 0DT then
                    SetFilter("Created DateTime", '<=%1', DateTo);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DateFromField; DateFrom)
                    {
                        ApplicationArea = All;
                        Caption = 'Date From';
                        ToolTip = 'Specifies the start date for filtering messages.';
                    }
                    field(DateToField; DateTo)
                    {
                        ApplicationArea = All;
                        Caption = 'Date To';
                        ToolTip = 'Specifies the end date for filtering messages.';
                    }
                }
            }
        }
    }

    rendering
    {
        layout(RDLCLayout)
        {
            Type = RDLC;
            LayoutFile = 'src/Report/EDIMessageReport.rdlc';
            Caption = 'EDI Message Report (RDLC)';
        }
    }

    var
        DateFrom: DateTime;
        DateTo: DateTime;
        ReportTitleLbl: Label 'EDI Message Report';
}
