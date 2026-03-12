page 50106 "EDI Message Lines"
{
    Caption = 'EDI Message Lines';
    PageType = ListPart;
    SourceTable = "EDI Message Line";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line number within the EDI message.';
                }
                field("Segment ID"; Rec."Segment ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the EDI segment identifier (e.g., PO1, IT1).';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Business Central item number.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item description.';
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ordered/shipped quantity.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit price.';
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total line amount.';
                }
                field("BC Field Value"; Rec."BC Field Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the mapped BC field value.';
                }
                field("Mapped"; Rec."Mapped")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this line has been successfully mapped to a BC field.';
                }
                field("Element Data"; Rec."Element Data")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the raw EDI element data for this line.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any error message for this line.';
                }
            }
        }
    }
}
