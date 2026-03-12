table 50102 "EDI Document Type"
{
    Caption = 'EDI Document Type';
    DataClassification = CustomerContent;
    LookupPageId = "EDI Document Types";
    DrillDownPageId = "EDI Document Types";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "EDI Standard"; Enum "EDI Standard")
        {
            Caption = 'EDI Standard';
            DataClassification = CustomerContent;
        }
        field(4; "Direction"; Enum "EDI Direction")
        {
            Caption = 'Direction';
            DataClassification = CustomerContent;
        }
        field(5; "Document Type"; Enum "EDI Doc Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(6; "BC Document Type"; Option)
        {
            Caption = 'BC Document Type';
            DataClassification = CustomerContent;
            OptionMembers = " ","Sales Order","Sales Invoice","Sales Shipment","Purchase Order","Purchase Invoice","Payment";
            OptionCaption = ' ,Sales Order,Sales Invoice,Sales Shipment,Purchase Order,Purchase Invoice,Payment';
        }
        field(7; "Active"; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(8; "Auto Process"; Boolean)
        {
            Caption = 'Auto Process';
            DataClassification = CustomerContent;
        }
        field(9; "Mapping Template Code"; Code[20])
        {
            Caption = 'Mapping Template Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
        key(Standard; "EDI Standard", "Direction") { }
    }
}
