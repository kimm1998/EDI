enum 50101 "EDI Standard"
{
    Extensible = true;
    Caption = 'EDI Standard';

    value(0; X12)
    {
        Caption = 'X12';
    }
    value(1; EDIFACT)
    {
        Caption = 'EDIFACT';
    }
}
