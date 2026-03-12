page 50103 "EDI Document Types"
{
    Caption = 'EDI Document Types';
    PageType = List;
    SourceTable = "EDI Document Type";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique code for the EDI document type.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of this EDI document type.';
                }
                field("EDI Standard"; Rec."EDI Standard")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the EDI standard (X12 or EDIFACT) for this document type.';
                }
                field("Direction"; Rec."Direction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this document type is inbound or outbound.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the specific EDI document type code.';
                }
                field("BC Document Type"; Rec."BC Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the corresponding Business Central document type.';
                }
                field("Active"; Rec."Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this document type configuration is active.';
                }
                field("Auto Process"; Rec."Auto Process")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to automatically process documents of this type.';
                }
                field("Mapping Template Code"; Rec."Mapping Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the mapping template code to use for this document type.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(FieldMappings)
            {
                Caption = 'Field Mappings';
                ApplicationArea = All;
                Image = MapAccounts;
                RunObject = Page "EDI Field Mappings";
                RunPageLink = "Document Type Code" = field("Code");
                ToolTip = 'View or edit field mappings for this document type.';
            }
        }
    }
}
