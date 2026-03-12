page 50102 "EDI Trading Partner Card"
{
    Caption = 'EDI Trading Partner Card';
    PageType = Card;
    SourceTable = "EDI Trading Partner";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
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
                    ToolTip = 'Specifies the communication method for EDI file transfer.';
                }
                field("Partner EDI Identifier"; Rec."Partner EDI Identifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the EDI identifier assigned by the trading partner.';
                }
                field("Partner Qualifier"; Rec."Partner Qualifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the qualifier code for the partner EDI identifier.';
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
                    ToolTip = 'Specifies whether to operate in test mode for this partner.';
                }
                field("Contact Email"; Rec."Contact Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the contact email address for this trading partner.';
                }
                field("Notes"; Rec."Notes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any notes about this trading partner.';
                    MultiLine = true;
                }
            }
            group(CommunicationSettings)
            {
                Caption = 'Communication';
                group(SFTPOverride)
                {
                    Caption = 'SFTP Override';
                    field("SFTP Host Override"; Rec."SFTP Host Override")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the SFTP host override for this partner (leave blank to use global setup).';
                    }
                    field("SFTP Port Override"; Rec."SFTP Port Override")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the SFTP port override for this partner.';
                    }
                    field("SFTP Username Override"; Rec."SFTP Username Override")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the SFTP username override for this partner.';
                    }
                    field("SFTP Password Override"; Rec."SFTP Password Override")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the SFTP password override for this partner.';
                    }
                }
                group(APIOverride)
                {
                    Caption = 'API Override';
                    field("API URL Override"; Rec."API URL Override")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the API URL override for this partner.';
                    }
                    field("API Key Override"; Rec."API Key Override")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the API key override for this partner.';
                    }
                }
                group(FolderOverride)
                {
                    Caption = 'Folder Override';
                    field("Inbound Folder Override"; Rec."Inbound Folder Override")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the inbound folder path override for this partner.';
                    }
                    field("Outbound Folder Override"; Rec."Outbound Folder Override")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the outbound folder path override for this partner.';
                    }
                }
            }
            group(Timestamps)
            {
                Caption = 'Timestamps';
                field("Created DateTime"; Rec."Created DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this trading partner record was created.';
                }
                field("Modified DateTime"; Rec."Modified DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this trading partner record was last modified.';
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
            action(Messages)
            {
                Caption = 'Messages';
                ApplicationArea = All;
                Image = History;
                RunObject = Page "EDI Message List";
                RunPageLink = "Trading Partner Code" = field("Code");
                ToolTip = 'View EDI messages for this trading partner.';
            }
        }
    }
}
