table 50106 "EDI Log Entry"
{
    Caption = 'EDI Log Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "DateTime"; DateTime)
        {
            Caption = 'DateTime';
            DataClassification = CustomerContent;
        }
        field(3; "Message Entry No."; Integer)
        {
            Caption = 'Message Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "EDI Message Header"."Entry No.";
        }
        field(4; "Trading Partner Code"; Code[20])
        {
            Caption = 'Trading Partner Code';
            DataClassification = CustomerContent;
            TableRelation = "EDI Trading Partner";
        }
        field(5; "Direction"; Enum "EDI Direction")
        {
            Caption = 'Direction';
            DataClassification = CustomerContent;
        }
        field(6; "Status"; Enum "EDI Message Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(7; "Description"; Text[2048])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(8; "Details"; Blob)
        {
            Caption = 'Details';
            DataClassification = CustomerContent;
        }
        field(9; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "Log Level"; Option)
        {
            Caption = 'Log Level';
            DataClassification = CustomerContent;
            OptionMembers = Information,Warning,Error,Critical;
            OptionCaption = 'Information,Warning,Error,Critical';
        }
        field(11; "Source Codeunit"; Integer)
        {
            Caption = 'Source Codeunit';
            DataClassification = CustomerContent;
        }
        field(12; "Source Procedure"; Text[100])
        {
            Caption = 'Source Procedure';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(MessageEntryNo; "Message Entry No.", "DateTime") { }
        key(TradingPartner; "Trading Partner Code", "DateTime") { }
        key(LogLevel; "Log Level", "DateTime") { }
    }

    trigger OnInsert()
    begin
        "DateTime" := CurrentDateTime();
        "User ID" := CopyStr(UserId(), 1, 50);
    end;
}
