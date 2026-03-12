page 50104 "EDI Message List"
{
    Caption = 'EDI Messages';
    PageType = List;
    SourceTable = "EDI Message Header";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "EDI Message Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique entry number for this EDI message.';
                }
                field("Message ID"; Rec."Message ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for this EDI message.';
                }
                field("Trading Partner Code"; Rec."Trading Partner Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the trading partner for this message.';
                }
                field("Document Type Code"; Rec."Document Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document type for this message.';
                }
                field("Direction"; Rec."Direction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the message is inbound or outbound.';
                }
                field("EDI Standard"; Rec."EDI Standard")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the EDI standard (X12 or EDIFACT) for this message.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current processing status of this message.';
                    StyleExpr = StatusStyle;
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the original filename for this EDI message.';
                }
                field("BC Document No."; Rec."BC Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central document number created from this message.';
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transaction date from the EDI message.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any error message for this EDI message.';
                }
                field("Created DateTime"; Rec."Created DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this message was created.';
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Links; Links) { ApplicationArea = RecordLinks; }
            systempart(Notes; Notes) { ApplicationArea = Notes; }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ProcessMessage)
            {
                Caption = 'Process';
                ApplicationArea = All;
                Image = Process;
                ToolTip = 'Processes the selected EDI message.';

                trigger OnAction()
                var
                    EDIProcessor: Codeunit "EDI Processor";
                    ProcessedLbl: Label 'Message processed successfully.';
                begin
                    EDIProcessor.ProcessMessage(Rec);
                    Message(ProcessedLbl);
                end;
            }
            action(ReprocessMessage)
            {
                Caption = 'Reprocess';
                ApplicationArea = All;
                Image = RefreshLines;
                ToolTip = 'Reprocesses the selected EDI message.';

                trigger OnAction()
                var
                    EDIProcessor: Codeunit "EDI Processor";
                    ReprocessedLbl: Label 'Message queued for reprocessing.';
                begin
                    EDIProcessor.ReprocessMessage(Rec);
                    Message(ReprocessedLbl);
                end;
            }
            action(ViewLog)
            {
                Caption = 'View Log';
                ApplicationArea = All;
                Image = Log;
                RunObject = Page "EDI Log Entries";
                RunPageLink = "Message Entry No." = field("Entry No.");
                ToolTip = 'View the log entries for this EDI message.';
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Error, Rec.Status::Rejected:
                StatusStyle := 'Unfavorable';
            Rec.Status::Posted, Rec.Status::Sent, Rec.Status::Acknowledged:
                StatusStyle := 'Favorable';
            Rec.Status::Processing, Rec.Status::Validated:
                StatusStyle := 'Ambiguous';
            else
                StatusStyle := 'Standard';
        end;
    end;
}
