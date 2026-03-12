codeunit 50101 "EDI X12 Parser"
{
    Caption = 'EDI X12 Parser';

    var
        EDISetup: Record "EDI Setup";
        SegmentTerminator: Char;
        ElementSeparator: Char;
        SubElementSeparator: Char;
        ISAControlNo: Text[20];
        GSControlNo: Text[20];
        STControlNo: Text[20];
        TransactionSetID: Text[10];

    procedure ParseX12Message(var EDIMessageHeader: Record "EDI Message Header")
    var
        InStream: InStream;
        RawData: Text;
        Segments: List of [Text];
        Segment: Text;
        SegID: Text;
        EDIErrorHandler: Codeunit "EDI Error Handler";
        EDIProcessor: Codeunit "EDI Processor";
        ParseErrorLbl: Label 'Error parsing X12 message: %1';
    begin
        EDISetup.GetSetup();
        SegmentTerminator := '~';
        ElementSeparator := '*';
        SubElementSeparator := ':';

        EDIMessageHeader.CalcFields("Raw Message");
        if not EDIMessageHeader."Raw Message".HasValue() then begin
            EDIErrorHandler.HandleError(EDIMessageHeader, 'Raw message is empty.');
            exit;
        end;

        EDIMessageHeader."Raw Message".CreateInStream(InStream);
        InStream.ReadText(RawData);

        if StrLen(RawData) < 106 then begin
            EDIErrorHandler.HandleError(EDIMessageHeader, 'Message too short to be a valid X12 ISA segment.');
            exit;
        end;

        SegmentTerminator := RawData[106];
        ElementSeparator := RawData[4];
        SubElementSeparator := RawData[105];

        Segments := SplitSegments(RawData, SegmentTerminator);

        foreach Segment in Segments do begin
            Segment := Segment.TrimStart();
            if StrLen(Segment) > 2 then begin
                SegID := CopyStr(Segment, 1, 3).TrimEnd();
                case SegID of
                    'ISA':
                        ParseISASegment(Segment, EDIMessageHeader);
                    'GS':
                        ParseGSSegment(Segment, EDIMessageHeader);
                    'ST':
                        ParseSTSegment(Segment, EDIMessageHeader);
                    'BEG', 'BPR':
                        begin
                            if TransactionSetID = '850' then
                                Parse850Header(Segment, EDIMessageHeader);
                        end;
                    'PO1':
                        begin
                            if TransactionSetID = '850' then
                                ParsePO1Line(Segment, EDIMessageHeader);
                        end;
                    'BIG':
                        begin
                            if TransactionSetID = '810' then
                                Parse810Header(Segment, EDIMessageHeader);
                        end;
                    'IT1':
                        begin
                            if TransactionSetID = '810' then
                                ParseIT1Line(Segment, EDIMessageHeader);
                        end;
                    'BSN':
                        begin
                            if TransactionSetID = '856' then
                                Parse856Header(Segment, EDIMessageHeader);
                        end;
                    'AK1', 'AK9', 'IEA':
                        begin
                            if TransactionSetID = '997' then
                                Parse997Segment(Segment, EDIMessageHeader);
                        end;
                end;
            end;
        end;

        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::Parsed);
    end;

    procedure ParseISASegment(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        Elements: List of [Text];
    begin
        Elements := SplitElements(Segment, ElementSeparator);
        if Elements.Count() >= 13 then begin
            ISAControlNo := CopyStr(Elements.Get(13).Trim(), 1, 20);
            EDIMessageHeader."ISA Control No." := ISAControlNo;
            EDIMessageHeader.Modify();
        end;
    end;

    procedure ParseGSSegment(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        Elements: List of [Text];
        DateStr: Text;
        TimeStr: Text;
    begin
        Elements := SplitElements(Segment, ElementSeparator);
        if Elements.Count() >= 6 then begin
            GSControlNo := CopyStr(Elements.Get(6).Trim(), 1, 20);
            EDIMessageHeader."GS Control No." := GSControlNo;
            if Elements.Count() >= 4 then begin
                DateStr := Elements.Get(4).Trim();
                TimeStr := Elements.Get(5).Trim();
                EDIMessageHeader."Transaction Date" := ParseX12Date(DateStr);
                EDIMessageHeader."Transaction Time" := ParseX12Time(TimeStr);
            end;
            EDIMessageHeader.Modify();
        end;
    end;

    procedure ParseSTSegment(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        Elements: List of [Text];
    begin
        Elements := SplitElements(Segment, ElementSeparator);
        if Elements.Count() >= 2 then
            TransactionSetID := Elements.Get(2).Trim();
        if Elements.Count() >= 3 then
            STControlNo := CopyStr(Elements.Get(3).Trim(), 1, 20);
        SetDocumentTypeFromTransactionSet(EDIMessageHeader);
    end;

    local procedure Parse850Header(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    begin
        EDIMessageHeader."BC Document Type" := EDIMessageHeader."BC Document Type"::"Purchase Order";
        EDIMessageHeader.Modify();
    end;

    local procedure ParsePO1Line(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        Elements: List of [Text];
        EDIMessageLine: Record "EDI Message Line";
        LineNo: Integer;
    begin
        Elements := SplitElements(Segment, ElementSeparator);
        EDIMessageLine.SetRange("Message Entry No.", EDIMessageHeader."Entry No.");
        if EDIMessageLine.FindLast() then
            LineNo := EDIMessageLine."Line No." + 10000
        else
            LineNo := 10000;

        EDIMessageLine.Init();
        EDIMessageLine."Message Entry No." := EDIMessageHeader."Entry No.";
        EDIMessageLine."Line No." := LineNo;
        EDIMessageLine."Segment ID" := 'PO1';
        EDIMessageLine."Element Data" := CopyStr(Segment, 1, 2048);

        if Elements.Count() >= 2 then
            Evaluate(EDIMessageLine.Quantity, Elements.Get(2).Trim());
        if Elements.Count() >= 4 then
            Evaluate(EDIMessageLine."Unit Price", Elements.Get(4).Trim());
        if Elements.Count() >= 6 then
            EDIMessageLine."Unit of Measure Code" := CopyStr(Elements.Get(6).Trim(), 1, 10);
        if Elements.Count() >= 8 then
            EDIMessageLine."Item No." := CopyStr(Elements.Get(8).Trim(), 1, 20);

        EDIMessageLine."Line Amount" := EDIMessageLine.Quantity * EDIMessageLine."Unit Price";
        EDIMessageLine.Insert(true);
    end;

    local procedure Parse810Header(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    begin
        EDIMessageHeader."BC Document Type" := EDIMessageHeader."BC Document Type"::"Sales Invoice";
        EDIMessageHeader.Modify();
    end;

    local procedure ParseIT1Line(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        Elements: List of [Text];
        EDIMessageLine: Record "EDI Message Line";
        LineNo: Integer;
    begin
        Elements := SplitElements(Segment, ElementSeparator);
        EDIMessageLine.SetRange("Message Entry No.", EDIMessageHeader."Entry No.");
        if EDIMessageLine.FindLast() then
            LineNo := EDIMessageLine."Line No." + 10000
        else
            LineNo := 10000;

        EDIMessageLine.Init();
        EDIMessageLine."Message Entry No." := EDIMessageHeader."Entry No.";
        EDIMessageLine."Line No." := LineNo;
        EDIMessageLine."Segment ID" := 'IT1';
        EDIMessageLine."Element Data" := CopyStr(Segment, 1, 2048);

        if Elements.Count() >= 2 then
            Evaluate(EDIMessageLine.Quantity, Elements.Get(2).Trim());
        if Elements.Count() >= 4 then
            Evaluate(EDIMessageLine."Unit Price", Elements.Get(4).Trim());
        if Elements.Count() >= 5 then
            EDIMessageLine."Unit of Measure Code" := CopyStr(Elements.Get(5).Trim(), 1, 10);

        EDIMessageLine."Line Amount" := EDIMessageLine.Quantity * EDIMessageLine."Unit Price";
        EDIMessageLine.Insert(true);
    end;

    local procedure Parse856Header(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    begin
        EDIMessageHeader."BC Document Type" := EDIMessageHeader."BC Document Type"::"Sales Shipment";
        EDIMessageHeader.Modify();
    end;

    local procedure Parse997Segment(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        EDIAckMgmt: Codeunit "EDI Acknowledgment Mgmt";
    begin
        EDIAckMgmt.ProcessInboundAcknowledgment(EDIMessageHeader);
    end;

    local procedure SetDocumentTypeFromTransactionSet(var EDIMessageHeader: Record "EDI Message Header")
    begin
        case TransactionSetID of
            '850':
                EDIMessageHeader."Document Type Code" := 'X12-850';
            '810':
                EDIMessageHeader."Document Type Code" := 'X12-810';
            '856':
                EDIMessageHeader."Document Type Code" := 'X12-856';
            '997':
                EDIMessageHeader."Document Type Code" := 'X12-997';
            '855':
                EDIMessageHeader."Document Type Code" := 'X12-855';
            '820':
                EDIMessageHeader."Document Type Code" := 'X12-820';
        end;
        EDIMessageHeader.Modify();
    end;

    procedure SplitSegments(RawData: Text; Terminator: Char) SegmentList: List of [Text]
    var
        TermStr: Text[1];
        Pos: Integer;
        LastPos: Integer;
    begin
        TermStr := Format(Terminator);
        LastPos := 1;
        Pos := StrPos(RawData, TermStr);
        while Pos > 0 do begin
            SegmentList.Add(CopyStr(RawData, LastPos, Pos - LastPos));
            LastPos := Pos + 1;
            Pos := StrPos(CopyStr(RawData, LastPos), TermStr);
            if Pos > 0 then
                Pos := Pos + LastPos - 1;
        end;
        if LastPos <= StrLen(RawData) then
            SegmentList.Add(CopyStr(RawData, LastPos));
    end;

    procedure SplitElements(Segment: Text; Separator: Char) ElementList: List of [Text]
    var
        SepStr: Text[1];
        Pos: Integer;
        LastPos: Integer;
    begin
        SepStr := Format(Separator);
        LastPos := 1;
        Pos := StrPos(Segment, SepStr);
        while Pos > 0 do begin
            ElementList.Add(CopyStr(Segment, LastPos, Pos - LastPos));
            LastPos := Pos + 1;
            Pos := StrPos(CopyStr(Segment, LastPos), SepStr);
            if Pos > 0 then
                Pos := Pos + LastPos - 1;
        end;
        if LastPos <= StrLen(Segment) then
            ElementList.Add(CopyStr(Segment, LastPos));
    end;

    local procedure ParseX12Date(DateStr: Text): Date
    var
        ResultDate: Date;
        Year: Integer;
        Month: Integer;
        Day: Integer;
        YearPrefix: Text[2];
        TwoDigitYear: Integer;
    begin
        if StrLen(DateStr) = 8 then begin
            Evaluate(Year, CopyStr(DateStr, 1, 4));
            Evaluate(Month, CopyStr(DateStr, 5, 2));
            Evaluate(Day, CopyStr(DateStr, 7, 2));
            ResultDate := DMY2Date(Day, Month, Year);
        end else
            if StrLen(DateStr) = 6 then begin
                Evaluate(TwoDigitYear, CopyStr(DateStr, 1, 2));
                if TwoDigitYear <= 29 then
                    YearPrefix := '20'
                else
                    YearPrefix := '19';
                Evaluate(Year, YearPrefix + CopyStr(DateStr, 1, 2));
                Evaluate(Month, CopyStr(DateStr, 3, 2));
                Evaluate(Day, CopyStr(DateStr, 5, 2));
                ResultDate := DMY2Date(Day, Month, Year);
            end;
        exit(ResultDate);
    end;

    local procedure ParseX12Time(TimeStr: Text): Time
    var
        ResultTime: Time;
        Hour: Integer;
        Minute: Integer;
    begin
        if StrLen(TimeStr) >= 4 then begin
            Evaluate(Hour, CopyStr(TimeStr, 1, 2));
            Evaluate(Minute, CopyStr(TimeStr, 3, 2));
            ResultTime := CreateTime(Hour, Minute, 0);
        end;
        exit(ResultTime);
    end;

    procedure Parse850(var EDIMessageHeader: Record "EDI Message Header")
    begin
        ParseX12Message(EDIMessageHeader);
    end;

    procedure Parse810(var EDIMessageHeader: Record "EDI Message Header")
    begin
        ParseX12Message(EDIMessageHeader);
    end;

    procedure Parse856(var EDIMessageHeader: Record "EDI Message Header")
    begin
        ParseX12Message(EDIMessageHeader);
    end;

    procedure Parse997(var EDIMessageHeader: Record "EDI Message Header")
    begin
        ParseX12Message(EDIMessageHeader);
    end;
}
