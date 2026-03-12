page 50101 "EDI Trading Partners"
{
    Caption = 'EDI Trading Partners';
    PageType = List;
    SourceTable = "EDI Trading Partner";
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "EDI Trading Partner Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the trading partner.';
                }
                field("Name"; Rec."Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the trading partner.';
                }
                field("EDI Standard"; Rec."EDI Standard")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the EDI standard used by this trading partner.';
                }
                field("Communication Type"; Rec."Communication Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the communication method used for EDI file transfer.';
                }
                field("Partner EDI Identifier"; Rec."Partner EDI Identifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the EDI identifier for this trading partner.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the BC customer number linked to this trading partner.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the BC vendor number linked to this trading partner.';
                }
                field("Active"; Rec."Active")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this trading partner is active.';
                }
                field("Test Mode"; Rec."Test Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this trading partner is in test mode.';
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
            action(ToggleActive)
            {
                Caption = 'Toggle Active';
                ApplicationArea = All;
                Image = ToggleBreakpoint;
                ToolTip = 'Activates or deactivates the selected trading partner.';

                trigger OnAction()
                begin
                    Rec.Active := not Rec.Active;
                    Rec.Modify();
                end;
            }
        }
        area(Navigation)
        {
            action(FieldMappings)
            {
                Caption = 'Field Mappings';
                ApplicationArea = All;
                Image = MapAccounts;
                RunObject = Page "EDI Field Mappings";
                RunPageLink = "Trading Partner Code" = field("Code");
                ToolTip = 'View or edit field mappings for this trading partner.';
            }
        }
    }
}
