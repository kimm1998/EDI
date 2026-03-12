enum 50100 "EDI Direction"
{
    Extensible = true;
    Caption = 'EDI Direction';

    value(0; Inbound)
    {
        Caption = 'Inbound';
    }
    value(1; Outbound)
    {
        Caption = 'Outbound';
    }
}
