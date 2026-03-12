page 50108 "EDI Log Entries"
{
    Caption = 'EDI Log Entries';
    PageType = List;
    SourceTable = "EDI Log Entry";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique entry number for this log entry.';
                }
                field("DateTime"; Rec."DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time of this log entry.';
                }
                field("Log Level"; Rec."Log Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the severity level of this log entry.';
                    StyleExpr = LogLevelStyle;
                }
                field("Message Entry No."; Rec."Message Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the related EDI message entry number.';
                }
                field("Trading Partner Code"; Rec."Trading Partner Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the trading partner for this log entry.';
                }
                field("Direction"; Rec."Direction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this is an inbound or outbound message log.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the message status at the time of this log entry.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of this log event.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who triggered this log entry.';
                }
                field("Source Codeunit"; Rec."Source Codeunit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the codeunit number that generated this log entry.';
                }
                field("Source Procedure"; Rec."Source Procedure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the procedure name that generated this log entry.';
                }
            }
        }
    }

    var
        LogLevelStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec."Log Level" of
            Rec."Log Level"::Error, Rec."Log Level"::Critical:
                LogLevelStyle := 'Unfavorable';
            Rec."Log Level"::Warning:
                LogLevelStyle := 'Ambiguous';
            else
                LogLevelStyle := 'Standard';
        end;
    end;
}
