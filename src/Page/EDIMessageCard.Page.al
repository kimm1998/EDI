page 50105 "EDI Message Card"
{
    Caption = 'EDI Message';
    PageType = Card;
    SourceTable = "EDI Message Header";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique entry number for this EDI message.';
                    Editable = false;
                }
                field("Message ID"; Rec."Message ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique message identifier.';
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
                    ToolTip = 'Specifies the EDI standard for this message.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current processing status of this message.';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the original filename for this EDI message.';
                }
            }
            group(BCDocument)
            {
                Caption = 'BC Document';
                field("BC Document Type"; Rec."BC Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of Business Central document created from this message.';
                }
                field("BC Document No."; Rec."BC Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central document number.';
                }
            }
            group(ControlNumbers)
            {
                Caption = 'Control Numbers';
                field("ISA Control No."; Rec."ISA Control No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the X12 ISA interchange control number.';
                }
                field("GS Control No."; Rec."GS Control No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the X12 GS functional group control number.';
                }
                field("UNB Reference No."; Rec."UNB Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the EDIFACT UNB interchange reference number.';
                }
                field("UNH Reference No."; Rec."UNH Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the EDIFACT UNH message reference number.';
                }
            }
            group(Dates)
            {
                Caption = 'Dates';
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transaction date from the EDI message.';
                }
                field("Transaction Time"; Rec."Transaction Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transaction time from the EDI message.';
                }
                field("Received DateTime"; Rec."Received DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this message was received.';
                }
                field("Processed DateTime"; Rec."Processed DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this message was processed.';
                }
                field("Sent DateTime"; Rec."Sent DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this message was sent.';
                }
            }
            group(ErrorInfo)
            {
                Caption = 'Error Information';
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message if processing failed.';
                    MultiLine = true;
                }
                field("Error Count"; Rec."Error Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of errors encountered.';
                }
                field("Retry Count"; Rec."Retry Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of retry attempts made.';
                }
                field("Max Retries"; Rec."Max Retries")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum number of retry attempts allowed.';
                }
                field("Acknowledgment Status"; Rec."Acknowledgment Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the acknowledgment status for this message.';
                }
            }
            part(Lines; "EDI Message Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Message Entry No." = field("Entry No.");
                Caption = 'Lines';
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
                ToolTip = 'Processes this EDI message.';

                trigger OnAction()
                var
                    EDIProcessor: Codeunit "EDI Processor";
                    ProcessedLbl: Label 'Message processed successfully.';
                begin
                    EDIProcessor.ProcessMessage(Rec);
                    Message(ProcessedLbl);
                end;
            }
            action(SendMessage)
            {
                Caption = 'Send';
                ApplicationArea = All;
                Image = SendMail;
                ToolTip = 'Sends this outbound EDI message.';

                trigger OnAction()
                var
                    EDICommunication: Codeunit "EDI Communication";
                    SentLbl: Label 'Message sent successfully.';
                begin
                    EDICommunication.SendFile('', Rec);
                    Message(SentLbl);
                end;
            }
            action(ReprocessMessage)
            {
                Caption = 'Reprocess';
                ApplicationArea = All;
                Image = RefreshLines;
                ToolTip = 'Reprocesses this EDI message.';

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
}
