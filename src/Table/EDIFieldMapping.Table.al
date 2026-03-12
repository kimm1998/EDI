table 50105 "EDI Field Mapping"
{
    Caption = 'EDI Field Mapping';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Document Type Code"; Code[20])
        {
            Caption = 'Document Type Code';
            DataClassification = CustomerContent;
            TableRelation = "EDI Document Type";
        }
        field(3; "Trading Partner Code"; Code[20])
        {
            Caption = 'Trading Partner Code';
            DataClassification = CustomerContent;
            TableRelation = "EDI Trading Partner";
        }
        field(4; "EDI Segment ID"; Code[10])
        {
            Caption = 'EDI Segment ID';
            DataClassification = CustomerContent;
        }
        field(5; "EDI Element Position"; Integer)
        {
            Caption = 'EDI Element Position';
            DataClassification = CustomerContent;
            MinValue = 1;
        }
        field(6; "EDI Sub-Element Position"; Integer)
        {
            Caption = 'EDI Sub-Element Position';
            DataClassification = CustomerContent;
        }
        field(7; "BC Table ID"; Integer)
        {
            Caption = 'BC Table ID';
            DataClassification = CustomerContent;
        }
        field(8; "BC Field ID"; Integer)
        {
            Caption = 'BC Field ID';
            DataClassification = CustomerContent;
        }
        field(9; "BC Field Name"; Text[100])
        {
            Caption = 'BC Field Name';
            DataClassification = CustomerContent;
        }
        field(10; "Default Value"; Text[250])
        {
            Caption = 'Default Value';
            DataClassification = CustomerContent;
        }
        field(11; "Transformation Rule"; Text[250])
        {
            Caption = 'Transformation Rule';
            DataClassification = CustomerContent;
        }
        field(12; "Required"; Boolean)
        {
            Caption = 'Required';
            DataClassification = CustomerContent;
        }
        field(13; "Active"; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(14; "Sort Order"; Integer)
        {
            Caption = 'Sort Order';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(DocTypeSortOrder; "Document Type Code", "Trading Partner Code", "Sort Order") { }
        key(SegmentElement; "Document Type Code", "EDI Segment ID", "EDI Element Position") { }
    }
}
