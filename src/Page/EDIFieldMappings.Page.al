page 50107 "EDI Field Mappings"
{
    Caption = 'EDI Field Mappings';
    PageType = List;
    SourceTable = "EDI Field Mapping";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Document Type Code"; Rec."Document Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the EDI document type code for this mapping.';
                }
                field("Trading Partner Code"; Rec."Trading Partner Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the trading partner code for this mapping (blank = default).';
                }
                field("EDI Segment ID"; Rec."EDI Segment ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the EDI segment identifier (e.g., BEG, PO1).';
                }
                field("EDI Element Position"; Rec."EDI Element Position")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the position of the element within the segment.';
                }
                field("EDI Sub-Element Position"; Rec."EDI Sub-Element Position")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the position of the sub-element within the element.';
                }
                field("BC Table ID"; Rec."BC Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the BC table number for the target field.';
                }
                field("BC Field ID"; Rec."BC Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the BC field number for the target field.';
                }
                field("BC Field Name"; Rec."BC Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the BC field.';
                }
                field("Default Value"; Rec."Default Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default value to use if the EDI element is blank.';
                }
                field("Transformation Rule"; Rec."Transformation Rule")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies transformation rules (e.g., UPPERCASE, TRIM, DATEFORMAT).';
                }
                field("Required"; Rec."Required")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this mapping is required for processing.';
                }
                field("Active"; Rec."Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this mapping is active.';
                }
                field("Sort Order"; Rec."Sort Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sort order for applying mappings.';
                }
            }
        }
    }
}
