enum 50103 "EDI Doc Type"
{
    Extensible = true;
    Caption = 'EDI Document Type';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; X12_850)
    {
        Caption = 'X12 850 - Purchase Order';
    }
    value(2; X12_810)
    {
        Caption = 'X12 810 - Invoice';
    }
    value(3; X12_856)
    {
        Caption = 'X12 856 - ASN/Ship Notice';
    }
    value(4; X12_997)
    {
        Caption = 'X12 997 - Functional Acknowledgment';
    }
    value(5; X12_855)
    {
        Caption = 'X12 855 - PO Acknowledgment';
    }
    value(6; X12_820)
    {
        Caption = 'X12 820 - Payment Order';
    }
    value(10; EDIFACT_ORDERS)
    {
        Caption = 'EDIFACT ORDERS - Purchase Order';
    }
    value(11; EDIFACT_INVOIC)
    {
        Caption = 'EDIFACT INVOIC - Invoice';
    }
    value(12; EDIFACT_DESADV)
    {
        Caption = 'EDIFACT DESADV - Dispatch Advice';
    }
    value(13; EDIFACT_CONTRL)
    {
        Caption = 'EDIFACT CONTRL - Control Message';
    }
    value(14; EDIFACT_ORDRSP)
    {
        Caption = 'EDIFACT ORDRSP - Order Response';
    }
    value(15; EDIFACT_REMADV)
    {
        Caption = 'EDIFACT REMADV - Remittance Advice';
    }
}
