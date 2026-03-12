tableextension 50100 "Customer EDI" extends Customer
{
    fields
    {
        field(50100; "EDI Trading Partner Code"; Code[20])
        {
            Caption = 'EDI Trading Partner Code';
            DataClassification = CustomerContent;
            TableRelation = "EDI Trading Partner";
        }
        field(50101; "EDI Enabled"; Boolean)
        {
            Caption = 'EDI Enabled';
            DataClassification = CustomerContent;
        }
        field(50102; "EDI Standard"; Enum "EDI Standard")
        {
            Caption = 'EDI Standard';
            DataClassification = CustomerContent;
        }
    }
}
