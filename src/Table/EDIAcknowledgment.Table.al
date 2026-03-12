table 50107 "EDI Acknowledgment"
{
    Caption = 'EDI Acknowledgment';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Original Message Entry No."; Integer)
        {
            Caption = 'Original Message Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "EDI Message Header"."Entry No.";
        }
        field(3; "Acknowledgment Type"; Option)
        {
            Caption = 'Acknowledgment Type';
            DataClassification = CustomerContent;
            OptionMembers = X12_997,X12_855,EDIFACT_CONTRL,EDIFACT_ORDRSP;
            OptionCaption = 'X12 997,X12 855,EDIFACT CONTRL,EDIFACT ORDRSP';
        }
        field(4; "Trading Partner Code"; Code[20])
        {
            Caption = 'Trading Partner Code';
            DataClassification = CustomerContent;
            TableRelation = "EDI Trading Partner";
        }
        field(5; "Status"; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionMembers = Accepted,"Accepted with Errors",Rejected,Pending;
            OptionCaption = 'Accepted,Accepted with Errors,Rejected,Pending';
        }
        field(6; "Acknowledgment Message"; Blob)
        {
            Caption = 'Acknowledgment Message';
            DataClassification = CustomerContent;
        }
        field(7; "Received DateTime"; DateTime)
        {
            Caption = 'Received DateTime';
            DataClassification = CustomerContent;
        }
        field(8; "ISA Control No."; Text[20])
        {
            Caption = 'ISA Control No.';
            DataClassification = CustomerContent;
        }
        field(9; "UNB Control No."; Text[20])
        {
            Caption = 'UNB Control No.';
            DataClassification = CustomerContent;
        }
        field(10; "Error Codes"; Text[500])
        {
            Caption = 'Error Codes';
            DataClassification = CustomerContent;
        }
        field(11; "Notes"; Text[500])
        {
            Caption = 'Notes';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(OriginalMessage; "Original Message Entry No.") { }
        key(TradingPartner; "Trading Partner Code", "Received DateTime") { }
    }
}
