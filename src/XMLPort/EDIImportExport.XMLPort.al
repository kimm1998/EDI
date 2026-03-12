xmlport 50100 "EDI Import/Export"
{
    Caption = 'EDI Import/Export';
    Direction = Both;
    Format = VariableText;
    FieldSeparator = ',';
    RecordSeparator = NewLine;

    schema
    {
        textelement(Root)
        {
            tableelement(EDIMessageHeader; "EDI Message Header")
            {
                XmlName = 'EDIMessage';
                fieldelement(EntryNo; EDIMessageHeader."Entry No.")
                {
                    XmlName = 'EntryNo';
                }
                fieldelement(MessageID; EDIMessageHeader."Message ID")
                {
                    XmlName = 'MessageID';
                }
                fieldelement(TradingPartnerCode; EDIMessageHeader."Trading Partner Code")
                {
                    XmlName = 'TradingPartnerCode';
                }
                fieldelement(DocumentTypeCode; EDIMessageHeader."Document Type Code")
                {
                    XmlName = 'DocumentTypeCode';
                }
                fieldelement(Direction; EDIMessageHeader."Direction")
                {
                    XmlName = 'Direction';
                }
                fieldelement(EDIStandard; EDIMessageHeader."EDI Standard")
                {
                    XmlName = 'EDIStandard';
                }
                fieldelement(Status; EDIMessageHeader."Status")
                {
                    XmlName = 'Status';
                }
                fieldelement(FileName; EDIMessageHeader."File Name")
                {
                    XmlName = 'FileName';
                }
                fieldelement(BCDocumentNo; EDIMessageHeader."BC Document No.")
                {
                    XmlName = 'BCDocumentNo';
                }
                fieldelement(TransactionDate; EDIMessageHeader."Transaction Date")
                {
                    XmlName = 'TransactionDate';
                }
                fieldelement(CreatedDateTime; EDIMessageHeader."Created DateTime")
                {
                    XmlName = 'CreatedDateTime';
                }
                fieldelement(ErrorMessage; EDIMessageHeader."Error Message")
                {
                    XmlName = 'ErrorMessage';
                }
            }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                }
            }
        }
    }
}
