enum 50102 "EDI Message Status"
{
    Extensible = true;
    Caption = 'EDI Message Status';

    value(0; New)
    {
        Caption = 'New';
    }
    value(1; Received)
    {
        Caption = 'Received';
    }
    value(2; Parsed)
    {
        Caption = 'Parsed';
    }
    value(3; Validated)
    {
        Caption = 'Validated';
    }
    value(4; Processing)
    {
        Caption = 'Processing';
    }
    value(5; Posted)
    {
        Caption = 'Posted';
    }
    value(6; Sent)
    {
        Caption = 'Sent';
    }
    value(7; Acknowledged)
    {
        Caption = 'Acknowledged';
    }
    value(8; Error)
    {
        Caption = 'Error';
    }
    value(9; Rejected)
    {
        Caption = 'Rejected';
    }
}
