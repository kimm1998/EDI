table 50103 "EDI Message Header"
{
    Caption = 'EDI Message Header';
    DataClassification = CustomerContent;
    LookupPageId = "EDI Message List";
    DrillDownPageId = "EDI Message List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Message ID"; Code[50])
        {
            Caption = 'Message ID';
            DataClassification = CustomerContent;
        }
        field(3; "Trading Partner Code"; Code[20])
        {
            Caption = 'Trading Partner Code';
            DataClassification = CustomerContent;
            TableRelation = "EDI Trading Partner";
        }
        field(4; "Document Type Code"; Code[20])
        {
            Caption = 'Document Type Code';
            DataClassification = CustomerContent;
            TableRelation = "EDI Document Type";
        }
        field(5; "Direction"; Enum "EDI Direction")
        {
            Caption = 'Direction';
            DataClassification = CustomerContent;
        }
        field(6; "EDI Standard"; Enum "EDI Standard")
        {
            Caption = 'EDI Standard';
            DataClassification = CustomerContent;
        }
        field(7; "Status"; Enum "EDI Message Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(8; "Raw Message"; Blob)
        {
            Caption = 'Raw Message';
            DataClassification = CustomerContent;
        }
        field(9; "File Name"; Text[250])
        {
            Caption = 'File Name';
            DataClassification = CustomerContent;
        }
        field(10; "BC Document Type"; Option)
        {
            Caption = 'BC Document Type';
            DataClassification = CustomerContent;
            OptionMembers = " ","Sales Order","Sales Invoice","Sales Shipment","Purchase Order","Purchase Invoice","Payment";
            OptionCaption = ' ,Sales Order,Sales Invoice,Sales Shipment,Purchase Order,Purchase Invoice,Payment';
        }
        field(11; "BC Document No."; Code[20])
        {
            Caption = 'BC Document No.';
            DataClassification = CustomerContent;
        }
        field(12; "ISA Control No."; Text[20])
        {
            Caption = 'ISA Control No.';
            DataClassification = CustomerContent;
        }
        field(13; "UNB Reference No."; Text[20])
        {
            Caption = 'UNB Reference No.';
            DataClassification = CustomerContent;
        }
        field(14; "GS Control No."; Text[20])
        {
            Caption = 'GS Control No.';
            DataClassification = CustomerContent;
        }
        field(15; "UNH Reference No."; Text[20])
        {
            Caption = 'UNH Reference No.';
            DataClassification = CustomerContent;
        }
        field(16; "Transaction Date"; Date)
        {
            Caption = 'Transaction Date';
            DataClassification = CustomerContent;
        }
        field(17; "Transaction Time"; Time)
        {
            Caption = 'Transaction Time';
            DataClassification = CustomerContent;
        }
        field(18; "Received DateTime"; DateTime)
        {
            Caption = 'Received DateTime';
            DataClassification = CustomerContent;
        }
        field(19; "Processed DateTime"; DateTime)
        {
            Caption = 'Processed DateTime';
            DataClassification = CustomerContent;
        }
        field(20; "Sent DateTime"; DateTime)
        {
            Caption = 'Sent DateTime';
            DataClassification = CustomerContent;
        }
        field(21; "Acknowledgment Status"; Option)
        {
            Caption = 'Acknowledgment Status';
            DataClassification = CustomerContent;
            OptionMembers = Pending,Accepted,Rejected,"Not Required";
            OptionCaption = 'Pending,Accepted,Rejected,Not Required';
        }
        field(22; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(23; "Error Count"; Integer)
        {
            Caption = 'Error Count';
            DataClassification = CustomerContent;
        }
        field(24; "Retry Count"; Integer)
        {
            Caption = 'Retry Count';
            DataClassification = CustomerContent;
        }
        field(25; "Max Retries"; Integer)
        {
            Caption = 'Max Retries';
            DataClassification = CustomerContent;
            InitValue = 3;
        }
        field(26; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(27; "Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TradingPartner; "Trading Partner Code", "Status") { }
        key(Direction; "Direction", "Status", "Created DateTime") { }
        key(MessageID; "Message ID") { }
    }

    trigger OnInsert()
    begin
        "Created By" := CopyStr(UserId(), 1, 50);
        "Created DateTime" := CurrentDateTime();
        if "Message ID" = '' then
            "Message ID" := CopyStr(Format(CreateGuid()), 1, 50);
    end;
}
