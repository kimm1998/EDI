page 50109 "EDI Acknowledgments"
{
    Caption = 'EDI Acknowledgments';
    PageType = List;
    SourceTable = "EDI Acknowledgment";
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
                    ToolTip = 'Specifies the unique entry number for this acknowledgment.';
                }
                field("Original Message Entry No."; Rec."Original Message Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number of the original EDI message.';
                }
                field("Acknowledgment Type"; Rec."Acknowledgment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of acknowledgment (997, 855, CONTRL, ORDRSP).';
                }
                field("Trading Partner Code"; Rec."Trading Partner Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the trading partner for this acknowledgment.';
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the acknowledgment status.';
                    StyleExpr = AckStatusStyle;
                }
                field("Received DateTime"; Rec."Received DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this acknowledgment was received.';
                }
                field("ISA Control No."; Rec."ISA Control No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ISA control number from the acknowledgment.';
                }
                field("UNB Control No."; Rec."UNB Control No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the UNB control number from the acknowledgment.';
                }
                field("Error Codes"; Rec."Error Codes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies error codes returned in the acknowledgment.';
                }
                field("Notes"; Rec."Notes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any additional notes about this acknowledgment.';
                }
            }
        }
    }

    var
        AckStatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Rejected:
                AckStatusStyle := 'Unfavorable';
            Rec.Status::Accepted:
                AckStatusStyle := 'Favorable';
            Rec.Status::"Accepted with Errors":
                AckStatusStyle := 'Ambiguous';
            else
                AckStatusStyle := 'Standard';
        end;
    end;
}
