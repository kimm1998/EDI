codeunit 50102 "EDI EDIFACT Parser"
{
    Caption = 'EDI EDIFACT Parser';

    var
        ComponentSeparator: Char;
        DataElementSeparator: Char;
        SegmentTerminator: Char;
        ReleaseChar: Char;
        UNHReference: Text[20];
        MessageType: Text[10];

    procedure ParseEDIFACTMessage(var EDIMessageHeader: Record "EDI Message Header")
    var
        InStream: InStream;
        RawData: Text;
        Segments: List of [Text];
        Segment: Text;
        SegID: Text;
        EDIErrorHandler: Codeunit "EDI Error Handler";
        EDIProcessor: Codeunit "EDI Processor";
    begin
        ComponentSeparator := ':';
        DataElementSeparator := '+';
        SegmentTerminator := '''';
        ReleaseChar := '?';

        EDIMessageHeader.CalcFields("Raw Message");
        if not EDIMessageHeader."Raw Message".HasValue() then begin
            EDIErrorHandler.HandleError(EDIMessageHeader, 'Raw message is empty.');
            exit;
        end;

        EDIMessageHeader."Raw Message".CreateInStream(InStream);
        InStream.ReadText(RawData);

        if CopyStr(RawData, 1, 3) <> 'UNB' then begin
            EDIErrorHandler.HandleError(EDIMessageHeader, 'Message does not start with UNB segment.');
            exit;
        end;

        Segments := SplitEDIFACTSegments(RawData, SegmentTerminator);

        foreach Segment in Segments do begin
            Segment := Segment.TrimStart();
            if StrLen(Segment) > 2 then begin
                SegID := CopyStr(Segment, 1, 3).TrimEnd('+');
                case SegID of
                    'UNB':
                        ParseUNBSegment(Segment, EDIMessageHeader);
                    'UNH':
                        ParseUNHSegment(Segment, EDIMessageHeader);
                    'BGM':
                        ParseBGMSegment(Segment, EDIMessageHeader);
                    'DTM':
                        ParseDTMSegment(Segment, EDIMessageHeader);
                    'LIN':
                        ParseLINSegment(Segment, EDIMessageHeader);
                    'QTY':
                        ParseQTYSegment(Segment, EDIMessageHeader);
                    'PRI':
                        ParsePRISegment(Segment, EDIMessageHeader);
                    'UNT', 'UNZ':
                        begin
                        end;
                end;
            end;
        end;

        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::Parsed);
    end;

    procedure ParseUNBSegment(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        Elements: List of [Text];
        Components: List of [Text];
    begin
        Elements := SplitElements(Segment, DataElementSeparator);
        if Elements.Count() >= 5 then begin
            EDIMessageHeader."UNB Reference No." := CopyStr(Elements.Get(5).Trim(), 1, 20);
            EDIMessageHeader.Modify();
        end;
    end;

    procedure ParseUNHSegment(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        Elements: List of [Text];
        Components: List of [Text];
        MsgRef: Text;
        MsgTypeComp: Text;
    begin
        Elements := SplitElements(Segment, DataElementSeparator);
        if Elements.Count() >= 2 then begin
            UNHReference := CopyStr(Elements.Get(2).Trim(), 1, 20);
            EDIMessageHeader."UNH Reference No." := UNHReference;
        end;
        if Elements.Count() >= 3 then begin
            MsgTypeComp := Elements.Get(3);
            Components := SplitElements(MsgTypeComp, ComponentSeparator);
            if Components.Count() >= 1 then begin
                MessageType := CopyStr(Components.Get(1).Trim(), 1, 10);
                SetDocumentTypeFromMessageType(EDIMessageHeader);
            end;
        end;
        EDIMessageHeader.Modify();
    end;

    local procedure ParseBGMSegment(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    begin
        // BGM segment contains document number and function code
    end;

    local procedure ParseDTMSegment(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        Elements: List of [Text];
        Components: List of [Text];
        DateStr: Text;
        DateQualifier: Text;
    begin
        Elements := SplitElements(Segment, DataElementSeparator);
        if Elements.Count() >= 2 then begin
            Components := SplitElements(Elements.Get(2), ComponentSeparator);
            if Components.Count() >= 3 then begin
                DateQualifier := Components.Get(1).Trim();
                DateStr := Components.Get(2).Trim();
                if DateQualifier = '137' then
                    EDIMessageHeader."Transaction Date" := ParseEDIFACTDate(DateStr);
                EDIMessageHeader.Modify();
            end;
        end;
    end;

    local procedure ParseLINSegment(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        Elements: List of [Text];
        Components: List of [Text];
        EDIMessageLine: Record "EDI Message Line";
        LineNo: Integer;
    begin
        Elements := SplitElements(Segment, DataElementSeparator);

        EDIMessageLine.SetRange("Message Entry No.", EDIMessageHeader."Entry No.");
        if EDIMessageLine.FindLast() then
            LineNo := EDIMessageLine."Line No." + 10000
        else
            LineNo := 10000;

        EDIMessageLine.Init();
        EDIMessageLine."Message Entry No." := EDIMessageHeader."Entry No.";
        EDIMessageLine."Line No." := LineNo;
        EDIMessageLine."Segment ID" := 'LIN';
        EDIMessageLine."Element Data" := CopyStr(Segment, 1, 2048);

        if Elements.Count() >= 3 then begin
            Components := SplitElements(Elements.Get(3), ComponentSeparator);
            if Components.Count() >= 1 then
                EDIMessageLine."Item No." := CopyStr(Components.Get(1).Trim(), 1, 20);
        end;

        EDIMessageLine.Insert(true);
    end;

    local procedure ParseQTYSegment(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        Elements: List of [Text];
        Components: List of [Text];
        EDIMessageLine: Record "EDI Message Line";
        QtyText: Text;
    begin
        Elements := SplitElements(Segment, DataElementSeparator);
        if Elements.Count() >= 2 then begin
            Components := SplitElements(Elements.Get(2), ComponentSeparator);
            if Components.Count() >= 2 then begin
                QtyText := Components.Get(2).Trim();
                EDIMessageLine.SetRange("Message Entry No.", EDIMessageHeader."Entry No.");
                EDIMessageLine.SetRange("Segment ID", 'LIN');
                if EDIMessageLine.FindLast() then begin
                    Evaluate(EDIMessageLine.Quantity, QtyText);
                    EDIMessageLine.Modify();
                end;
            end;
        end;
    end;

    local procedure ParsePRISegment(Segment: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        Elements: List of [Text];
        Components: List of [Text];
        EDIMessageLine: Record "EDI Message Line";
        PriceText: Text;
    begin
        Elements := SplitElements(Segment, DataElementSeparator);
        if Elements.Count() >= 2 then begin
            Components := SplitElements(Elements.Get(2), ComponentSeparator);
            if Components.Count() >= 2 then begin
                PriceText := Components.Get(2).Trim();
                EDIMessageLine.SetRange("Message Entry No.", EDIMessageHeader."Entry No.");
                EDIMessageLine.SetRange("Segment ID", 'LIN');
                if EDIMessageLine.FindLast() then begin
                    Evaluate(EDIMessageLine."Unit Price", PriceText);
                    EDIMessageLine."Line Amount" := EDIMessageLine.Quantity * EDIMessageLine."Unit Price";
                    EDIMessageLine.Modify();
                end;
            end;
        end;
    end;

    local procedure SetDocumentTypeFromMessageType(var EDIMessageHeader: Record "EDI Message Header")
    begin
        case MessageType of
            'ORDERS':
                begin
                    EDIMessageHeader."Document Type Code" := 'EDIFACT-ORDERS';
                    EDIMessageHeader."BC Document Type" := EDIMessageHeader."BC Document Type"::"Purchase Order";
                end;
            'INVOIC':
                begin
                    EDIMessageHeader."Document Type Code" := 'EDIFACT-INVOIC';
                    EDIMessageHeader."BC Document Type" := EDIMessageHeader."BC Document Type"::"Sales Invoice";
                end;
            'DESADV':
                begin
                    EDIMessageHeader."Document Type Code" := 'EDIFACT-DESADV';
                    EDIMessageHeader."BC Document Type" := EDIMessageHeader."BC Document Type"::"Sales Shipment";
                end;
            'CONTRL':
                EDIMessageHeader."Document Type Code" := 'EDIFACT-CONTRL';
            'ORDRSP':
                EDIMessageHeader."Document Type Code" := 'EDIFACT-ORDRSP';
            'REMADV':
                EDIMessageHeader."Document Type Code" := 'EDIFACT-REMADV';
        end;
    end;

    procedure SplitEDIFACTSegments(RawData: Text; Terminator: Char) SegmentList: List of [Text]
    var
        TermStr: Text[1];
        Pos: Integer;
        LastPos: Integer;
        CurrentChar: Char;
        PrevChar: Char;
    begin
        TermStr := Format(Terminator);
        LastPos := 1;
        Pos := 1;
        while Pos <= StrLen(RawData) do begin
            CurrentChar := RawData[Pos];
            if Pos > 1 then
                PrevChar := RawData[Pos - 1]
            else
                PrevChar := 0;

            if (CurrentChar = Terminator) and (PrevChar <> ReleaseChar) then begin
                SegmentList.Add(CopyStr(RawData, LastPos, Pos - LastPos));
                LastPos := Pos + 1;
            end;
            Pos += 1;
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

    local procedure ParseEDIFACTDate(DateStr: Text): Date
    var
        ResultDate: Date;
        Year: Integer;
        Month: Integer;
        Day: Integer;
    begin
        if StrLen(DateStr) = 8 then begin
            Evaluate(Year, CopyStr(DateStr, 1, 4));
            Evaluate(Month, CopyStr(DateStr, 5, 2));
            Evaluate(Day, CopyStr(DateStr, 7, 2));
            ResultDate := DMY2Date(Day, Month, Year);
        end;
        exit(ResultDate);
    end;

    procedure ParseORDERS(var EDIMessageHeader: Record "EDI Message Header")
    begin
        ParseEDIFACTMessage(EDIMessageHeader);
    end;

    procedure ParseINVOIC(var EDIMessageHeader: Record "EDI Message Header")
    begin
        ParseEDIFACTMessage(EDIMessageHeader);
    end;

    procedure ParseDESADV(var EDIMessageHeader: Record "EDI Message Header")
    begin
        ParseEDIFACTMessage(EDIMessageHeader);
    end;

    procedure ParseCONTRL(var EDIMessageHeader: Record "EDI Message Header")
    begin
        ParseEDIFACTMessage(EDIMessageHeader);
    end;
}
