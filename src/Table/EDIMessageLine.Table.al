table 50104 "EDI Message Line"
{
    Caption = 'EDI Message Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Message Entry No."; Integer)
        {
            Caption = 'Message Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "EDI Message Header"."Entry No.";
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Segment ID"; Code[10])
        {
            Caption = 'Segment ID';
            DataClassification = CustomerContent;
        }
        field(5; "Element Data"; Text[2048])
        {
            Caption = 'Element Data';
            DataClassification = CustomerContent;
        }
        field(6; "BC Table No."; Integer)
        {
            Caption = 'BC Table No.';
            DataClassification = CustomerContent;
        }
        field(7; "BC Field No."; Integer)
        {
            Caption = 'BC Field No.';
            DataClassification = CustomerContent;
        }
        field(8; "BC Field Value"; Text[250])
        {
            Caption = 'BC Field Value';
            DataClassification = CustomerContent;
        }
        field(9; "Mapped"; Boolean)
        {
            Caption = 'Mapped';
            DataClassification = CustomerContent;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(11; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(12; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(13; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(14; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(15; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
        }
        field(16; "Error Message"; Text[500])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Message Entry No.", "Line No.")
        {
            Clustered = true;
        }
        key(EntryNo; "Entry No.") { }
    }
}
