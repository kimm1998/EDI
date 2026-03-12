table 50101 "EDI Trading Partner"
{
    Caption = 'EDI Trading Partner';
    DataClassification = CustomerContent;
    LookupPageId = "EDI Trading Partners";
    DrillDownPageId = "EDI Trading Partners";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Name"; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "EDI Standard"; Enum "EDI Standard")
        {
            Caption = 'EDI Standard';
            DataClassification = CustomerContent;
        }
        field(4; "Communication Type"; Enum "EDI Communication Type")
        {
            Caption = 'Communication Type';
            DataClassification = CustomerContent;
        }
        field(5; "Partner EDI Identifier"; Text[50])
        {
            Caption = 'Partner EDI Identifier';
            DataClassification = CustomerContent;
        }
        field(6; "Partner Qualifier"; Text[10])
        {
            Caption = 'Partner Qualifier';
            DataClassification = CustomerContent;
        }
        field(7; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(8; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(9; "Active"; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(20; "SFTP Host Override"; Text[250])
        {
            Caption = 'SFTP Host Override';
            DataClassification = CustomerContent;
        }
        field(21; "SFTP Port Override"; Integer)
        {
            Caption = 'SFTP Port Override';
            DataClassification = CustomerContent;
        }
        field(22; "SFTP Username Override"; Text[100])
        {
            Caption = 'SFTP Username Override';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(23; "SFTP Password Override"; Text[250])
        {
            Caption = 'SFTP Password Override';
            DataClassification = EndUserPseudonymousIdentifiers;
            ExtendedDatatype = Masked;
        }
        field(30; "API URL Override"; Text[250])
        {
            Caption = 'API URL Override';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
        field(31; "API Key Override"; Text[250])
        {
            Caption = 'API Key Override';
            DataClassification = EndUserPseudonymousIdentifiers;
            ExtendedDatatype = Masked;
        }
        field(40; "Inbound Folder Override"; Text[250])
        {
            Caption = 'Inbound Folder Override';
            DataClassification = CustomerContent;
        }
        field(41; "Outbound Folder Override"; Text[250])
        {
            Caption = 'Outbound Folder Override';
            DataClassification = CustomerContent;
        }
        field(50; "Contact Email"; Text[250])
        {
            Caption = 'Contact Email';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(51; "Notes"; Text[500])
        {
            Caption = 'Notes';
            DataClassification = CustomerContent;
        }
        field(52; "Test Mode"; Boolean)
        {
            Caption = 'Test Mode';
            DataClassification = CustomerContent;
        }
        field(60; "Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(61; "Modified DateTime"; DateTime)
        {
            Caption = 'Modified DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
        key(CustomerNo; "Customer No.") { }
        key(VendorNo; "Vendor No.") { }
    }

    trigger OnInsert()
    begin
        "Created DateTime" := CurrentDateTime();
        "Modified DateTime" := CurrentDateTime();
    end;

    trigger OnModify()
    begin
        "Modified DateTime" := CurrentDateTime();
    end;
}
