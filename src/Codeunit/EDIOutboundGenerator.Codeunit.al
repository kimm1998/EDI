codeunit 50104 "EDI Outbound Generator"
{
    Caption = 'EDI Outbound Generator';

    var
        EDISetup: Record "EDI Setup";

    procedure GenerateOutboundEDI(var EDIMessageHeader: Record "EDI Message Header")
    begin
        EDISetup.GetSetup();

        case EDIMessageHeader."Document Type Code" of
            'X12-810':
                GenerateX12_810FromHeader(EDIMessageHeader);
            'X12-856':
                GenerateX12_856FromHeader(EDIMessageHeader);
            'EDIFACT-INVOIC':
                GenerateEDIFACT_INVOICFromHeader(EDIMessageHeader);
            'EDIFACT-DESADV':
                GenerateEDIFACT_DESADVFromHeader(EDIMessageHeader);
        end;
    end;

    procedure GenerateX12_810(SalesInvHeader: Record "Sales Invoice Header")
    var
        EDIMessageHeader: Record "EDI Message Header";
        EDITradingPartner: Record "EDI Trading Partner";
        Customer: Record Customer;
    begin
        if not Customer.Get(SalesInvHeader."Sell-to Customer No.") then
            exit;
        if not Customer."EDI Enabled" then
            exit;
        if not EDITradingPartner.Get(Customer."EDI Trading Partner Code") then
            exit;

        EDIMessageHeader.Init();
        EDIMessageHeader.Direction := "EDI Direction"::Outbound;
        EDIMessageHeader."EDI Standard" := "EDI Standard"::X12;
        EDIMessageHeader."Document Type Code" := 'X12-810';
        EDIMessageHeader."Trading Partner Code" := EDITradingPartner.Code;
        EDIMessageHeader."BC Document Type" := EDIMessageHeader."BC Document Type"::"Sales Invoice";
        EDIMessageHeader."BC Document No." := SalesInvHeader."No.";
        EDIMessageHeader.Status := "EDI Message Status"::New;
        EDIMessageHeader.Insert(true);

        BuildX12_810Content(SalesInvHeader, EDIMessageHeader);
    end;

    local procedure GenerateX12_810FromHeader(var EDIMessageHeader: Record "EDI Message Header")
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if SalesInvHeader.Get(EDIMessageHeader."BC Document No.") then
            BuildX12_810Content(SalesInvHeader, EDIMessageHeader);
    end;

    local procedure BuildX12_810Content(SalesInvHeader: Record "Sales Invoice Header"; var EDIMessageHeader: Record "EDI Message Header")
    var
        SalesInvLine: Record "Sales Invoice Line";
        EDITradingPartner: Record "EDI Trading Partner";
        OutStream: OutStream;
        EDIContent: Text;
        ControlNo: Text[9];
        DateStr: Text;
        TimeStr: Text;
        LineCounter: Integer;
        EDIProcessor: Codeunit "EDI Processor";
    begin
        EDISetup.GetSetup();
        ControlNo := PadStr(Format(GetNextControlNo()), 9, '0');
        DateStr := Format(Today(), 0, '<Year4><Month,2><Day,2>');
        TimeStr := Format(Time(), 0, '<Hours24,2><Minutes,2>');

        EDIContent := '';
        EDIContent += StrSubstNo('ISA*00*          *00*          *ZZ*%1          *ZZ*%2          *%3*%4*^*00501*%5*0*P*>~',
            PadStr(EDISetup."ISA Sender ID", 15, ' '),
            PadStr(EDISetup."ISA Receiver ID", 15, ' '),
            Format(Today(), 0, '<Year,2><Month,2><Day,2>'),
            Format(Time(), 0, '<Hours24,2><Minutes,2>'),
            ControlNo);
        EDIContent += StrSubstNo('GS*IN*%1*%2*%3*%4*1*X*005010X231A1~',
            EDISetup."ISA Sender ID",
            EDISetup."ISA Receiver ID",
            DateStr, TimeStr);
        EDIContent += StrSubstNo('ST*810*0001~');
        EDIContent += StrSubstNo('BIG*%1*%2*%3**%4~',
            Format(SalesInvHeader."Posting Date", 0, '<Year4><Month,2><Day,2>'),
            SalesInvHeader."No.",
            Format(SalesInvHeader."Document Date", 0, '<Year4><Month,2><Day,2>'),
            SalesInvHeader."Order No.");

        LineCounter := 1;
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
        if SalesInvLine.FindSet() then
            repeat
                EDIContent += StrSubstNo('IT1*%1*%2*EA*%3**BP*%4~',
                    Format(LineCounter),
                    Format(SalesInvLine.Quantity, 0, '<Precision,2:2><Sign><Integer><Decimals>'),
                    Format(SalesInvLine."Unit Price", 0, '<Precision,2:2><Sign><Integer><Decimals>'),
                    SalesInvLine."No.");
                LineCounter += 1;
            until SalesInvLine.Next() = 0;

        EDIContent += StrSubstNo('TDS*%1~', Format(SalesInvHeader."Amount Including VAT" * 100, 0, '<Integer>'));
        EDIContent += StrSubstNo('SE*%1*0001~', Format(LineCounter + 3));
        EDIContent += 'GE*1*1~';
        EDIContent += StrSubstNo('IEA*1*%1~', ControlNo);

        EDIMessageHeader.CalcFields("Raw Message");
        EDIMessageHeader."Raw Message".CreateOutStream(OutStream);
        OutStream.WriteText(EDIContent);
        EDIMessageHeader."ISA Control No." := ControlNo;
        EDIMessageHeader.Modify();

        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::New);
    end;

    procedure GenerateX12_856(SalesShipHeader: Record "Sales Shipment Header")
    var
        EDIMessageHeader: Record "EDI Message Header";
        EDITradingPartner: Record "EDI Trading Partner";
        Customer: Record Customer;
    begin
        if not Customer.Get(SalesShipHeader."Sell-to Customer No.") then
            exit;
        if not Customer."EDI Enabled" then
            exit;
        if not EDITradingPartner.Get(Customer."EDI Trading Partner Code") then
            exit;

        EDIMessageHeader.Init();
        EDIMessageHeader.Direction := "EDI Direction"::Outbound;
        EDIMessageHeader."EDI Standard" := "EDI Standard"::X12;
        EDIMessageHeader."Document Type Code" := 'X12-856';
        EDIMessageHeader."Trading Partner Code" := EDITradingPartner.Code;
        EDIMessageHeader."BC Document Type" := EDIMessageHeader."BC Document Type"::"Sales Shipment";
        EDIMessageHeader."BC Document No." := SalesShipHeader."No.";
        EDIMessageHeader.Status := "EDI Message Status"::New;
        EDIMessageHeader.Insert(true);

        BuildX12_856Content(SalesShipHeader, EDIMessageHeader);
    end;

    local procedure GenerateX12_856FromHeader(var EDIMessageHeader: Record "EDI Message Header")
    var
        SalesShipHeader: Record "Sales Shipment Header";
    begin
        if SalesShipHeader.Get(EDIMessageHeader."BC Document No.") then
            BuildX12_856Content(SalesShipHeader, EDIMessageHeader);
    end;

    local procedure BuildX12_856Content(SalesShipHeader: Record "Sales Shipment Header"; var EDIMessageHeader: Record "EDI Message Header")
    var
        SalesShipLine: Record "Sales Shipment Line";
        OutStream: OutStream;
        EDIContent: Text;
        ControlNo: Text[9];
        DateStr: Text;
        LineCounter: Integer;
        EDIProcessor: Codeunit "EDI Processor";
    begin
        EDISetup.GetSetup();
        ControlNo := PadStr(Format(GetNextControlNo()), 9, '0');
        DateStr := Format(Today(), 0, '<Year4><Month,2><Day,2>');

        EDIContent := '';
        EDIContent += StrSubstNo('ISA*00*          *00*          *ZZ*%1          *ZZ*%2          *%3*%4*^*00501*%5*0*P*>~',
            PadStr(EDISetup."ISA Sender ID", 15, ' '),
            PadStr(EDISetup."ISA Receiver ID", 15, ' '),
            Format(Today(), 0, '<Year,2><Month,2><Day,2>'),
            Format(Time(), 0, '<Hours24,2><Minutes,2>'),
            ControlNo);
        EDIContent += StrSubstNo('GS*SH*%1*%2*%3*%4*1*X*005010X217~',
            EDISetup."ISA Sender ID",
            EDISetup."ISA Receiver ID",
            DateStr,
            Format(Time(), 0, '<Hours24,2><Minutes,2>'));
        EDIContent += 'ST*856*0001~';
        EDIContent += StrSubstNo('BSN*00*%1*%2*%3*0001~',
            SalesShipHeader."No.",
            DateStr,
            Format(Time(), 0, '<Hours24,2><Minutes,2>'));
        EDIContent += 'HL*1**S*1~';

        LineCounter := 1;
        SalesShipLine.SetRange("Document No.", SalesShipHeader."No.");
        SalesShipLine.SetRange(Type, SalesShipLine.Type::Item);
        if SalesShipLine.FindSet() then
            repeat
                EDIContent += StrSubstNo('HL*%1*1*I*0~', Format(LineCounter + 1));
                EDIContent += StrSubstNo('LIN**BP*%1~', SalesShipLine."No.");
                EDIContent += StrSubstNo('SN1**%1*EA~',
                    Format(SalesShipLine.Quantity, 0, '<Precision,2:2><Sign><Integer><Decimals>'));
                LineCounter += 1;
            until SalesShipLine.Next() = 0;

        EDIContent += StrSubstNo('CTT*%1~', Format(LineCounter - 1));
        EDIContent += StrSubstNo('SE*%1*0001~', Format(LineCounter + 4));
        EDIContent += 'GE*1*1~';
        EDIContent += StrSubstNo('IEA*1*%1~', ControlNo);

        EDIMessageHeader.CalcFields("Raw Message");
        EDIMessageHeader."Raw Message".CreateOutStream(OutStream);
        OutStream.WriteText(EDIContent);
        EDIMessageHeader."ISA Control No." := ControlNo;
        EDIMessageHeader.Modify();

        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::New);
    end;

    procedure GenerateEDIFACT_INVOIC(SalesInvHeader: Record "Sales Invoice Header")
    var
        EDIMessageHeader: Record "EDI Message Header";
        EDITradingPartner: Record "EDI Trading Partner";
        Customer: Record Customer;
    begin
        if not Customer.Get(SalesInvHeader."Sell-to Customer No.") then
            exit;
        if not Customer."EDI Enabled" then
            exit;
        if not EDITradingPartner.Get(Customer."EDI Trading Partner Code") then
            exit;
        if EDITradingPartner."EDI Standard" <> "EDI Standard"::EDIFACT then
            exit;

        EDIMessageHeader.Init();
        EDIMessageHeader.Direction := "EDI Direction"::Outbound;
        EDIMessageHeader."EDI Standard" := "EDI Standard"::EDIFACT;
        EDIMessageHeader."Document Type Code" := 'EDIFACT-INVOIC';
        EDIMessageHeader."Trading Partner Code" := EDITradingPartner.Code;
        EDIMessageHeader."BC Document Type" := EDIMessageHeader."BC Document Type"::"Sales Invoice";
        EDIMessageHeader."BC Document No." := SalesInvHeader."No.";
        EDIMessageHeader.Status := "EDI Message Status"::New;
        EDIMessageHeader.Insert(true);

        BuildEDIFACT_INVOICContent(SalesInvHeader, EDIMessageHeader);
    end;

    local procedure GenerateEDIFACT_INVOICFromHeader(var EDIMessageHeader: Record "EDI Message Header")
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if SalesInvHeader.Get(EDIMessageHeader."BC Document No.") then
            BuildEDIFACT_INVOICContent(SalesInvHeader, EDIMessageHeader);
    end;

    local procedure BuildEDIFACT_INVOICContent(SalesInvHeader: Record "Sales Invoice Header"; var EDIMessageHeader: Record "EDI Message Header")
    var
        SalesInvLine: Record "Sales Invoice Line";
        OutStream: OutStream;
        EDIContent: Text;
        ControlNo: Text;
        DateStr: Text;
        LineCounter: Integer;
        EDISetupLocal: Record "EDI Setup";
        EDIProcessor: Codeunit "EDI Processor";
    begin
        EDISetupLocal.GetSetup();
        ControlNo := Format(GetNextControlNo());
        DateStr := Format(Today(), 0, '<Year4><Month,2><Day,2>');

        EDIContent := '';
        EDIContent += StrSubstNo('UNB+UNOA:1+%1+%2+%3:%4+%5''',
            EDISetupLocal."UNB Sender ID",
            EDISetupLocal."UNB Receiver ID",
            DateStr,
            Format(Time(), 0, '<Hours24,2><Minutes,2>'),
            ControlNo);
        EDIContent += StrSubstNo('UNH+1+INVOIC:D:96A:UN:EAN008''');
        EDIContent += StrSubstNo('BGM+380+%1+9''', SalesInvHeader."No.");
        EDIContent += StrSubstNo('DTM+137:%1:102''', DateStr);

        LineCounter := 1;
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
        if SalesInvLine.FindSet() then
            repeat
                EDIContent += StrSubstNo('LIN+%1++%2:BP''', Format(LineCounter), SalesInvLine."No.");
                EDIContent += StrSubstNo('QTY+47:%1:PCE''',
                    Format(SalesInvLine.Quantity, 0, '<Precision,3:3><Sign><Integer><Decimals>'));
                EDIContent += StrSubstNo('PRI+INV:%1:NTP''',
                    Format(SalesInvLine."Unit Price", 0, '<Precision,2:2><Sign><Integer><Decimals>'));
                LineCounter += 1;
            until SalesInvLine.Next() = 0;

        EDIContent += StrSubstNo('MOA+79:%1''',
            Format(SalesInvHeader."Amount Including VAT", 0, '<Precision,2:2><Sign><Integer><Decimals>'));
        EDIContent += StrSubstNo('UNT+%1+1''', Format(LineCounter * 3 + 4));
        EDIContent += StrSubstNo('UNZ+1+%1''', ControlNo);

        EDIMessageHeader.CalcFields("Raw Message");
        EDIMessageHeader."Raw Message".CreateOutStream(OutStream);
        OutStream.WriteText(EDIContent);
        EDIMessageHeader."UNB Reference No." := CopyStr(ControlNo, 1, 20);
        EDIMessageHeader.Modify();

        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::New);
    end;

    procedure GenerateEDIFACT_DESADV(SalesShipHeader: Record "Sales Shipment Header")
    var
        EDIMessageHeader: Record "EDI Message Header";
        EDITradingPartner: Record "EDI Trading Partner";
        Customer: Record Customer;
    begin
        if not Customer.Get(SalesShipHeader."Sell-to Customer No.") then
            exit;
        if not Customer."EDI Enabled" then
            exit;
        if not EDITradingPartner.Get(Customer."EDI Trading Partner Code") then
            exit;
        if EDITradingPartner."EDI Standard" <> "EDI Standard"::EDIFACT then
            exit;

        EDIMessageHeader.Init();
        EDIMessageHeader.Direction := "EDI Direction"::Outbound;
        EDIMessageHeader."EDI Standard" := "EDI Standard"::EDIFACT;
        EDIMessageHeader."Document Type Code" := 'EDIFACT-DESADV';
        EDIMessageHeader."Trading Partner Code" := EDITradingPartner.Code;
        EDIMessageHeader."BC Document Type" := EDIMessageHeader."BC Document Type"::"Sales Shipment";
        EDIMessageHeader."BC Document No." := SalesShipHeader."No.";
        EDIMessageHeader.Status := "EDI Message Status"::New;
        EDIMessageHeader.Insert(true);

        GenerateEDIFACT_DESADVFromHeader(EDIMessageHeader);
    end;

    local procedure GenerateEDIFACT_DESADVFromHeader(var EDIMessageHeader: Record "EDI Message Header")
    var
        OutStream: OutStream;
        EDIContent: Text;
        ControlNo: Text;
        EDIProcessor: Codeunit "EDI Processor";
    begin
        EDISetup.GetSetup();
        ControlNo := Format(GetNextControlNo());

        EDIContent := '';
        EDIContent += StrSubstNo('UNB+UNOA:1+%1+%2+%3:%4+%5''',
            EDISetup."UNB Sender ID",
            EDISetup."UNB Receiver ID",
            Format(Today(), 0, '<Year4><Month,2><Day,2>'),
            Format(Time(), 0, '<Hours24,2><Minutes,2>'),
            ControlNo);
        EDIContent += 'UNH+1+DESADV:D:96A:UN:EAN008''';
        EDIContent += StrSubstNo('BGM+351+%1+9''', EDIMessageHeader."BC Document No.");
        EDIContent += StrSubstNo('DTM+137:%1:102''', Format(Today(), 0, '<Year4><Month,2><Day,2>'));
        EDIContent += 'UNT+4+1''';
        EDIContent += StrSubstNo('UNZ+1+%1''', ControlNo);

        EDIMessageHeader.CalcFields("Raw Message");
        EDIMessageHeader."Raw Message".CreateOutStream(OutStream);
        OutStream.WriteText(EDIContent);
        EDIMessageHeader."UNB Reference No." := CopyStr(ControlNo, 1, 20);
        EDIMessageHeader.Modify();

        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::New);
    end;

    local procedure GetNextControlNo(): Integer
    var
        EDISetupLocal: Record "EDI Setup";
    begin
        EDISetupLocal.GetSetup();
        exit(EDISetupLocal.GetNextControlNo());
    end;
}
