codeunit 50100 "EDI Processor"
{
    Caption = 'EDI Processor';

    var
        EDISetup: Record "EDI Setup";
        EDIErrorHandler: Codeunit "EDI Error Handler";
        SetupLoaded: Boolean;

    procedure ProcessInboundFiles()
    var
        EDICommunication: Codeunit "EDI Communication";
        EDIMessageHeader: Record "EDI Message Header";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        InStream: InStream;
        OutStream: OutStream;
        NoFilesLbl: Label 'No inbound EDI files found to process.';
    begin
        LoadSetup();
        if not EDICommunication.ReceiveFiles(TempBlob, FileName) then begin
            LogInfo(0, '', "EDI Direction"::Inbound, "EDI Message Status"::New, NoFilesLbl, 50100, 'ProcessInboundFiles');
            exit;
        end;

        EDIMessageHeader.Init();
        EDIMessageHeader."File Name" := CopyStr(FileName, 1, 250);
        EDIMessageHeader."Direction" := "EDI Direction"::Inbound;
        EDIMessageHeader."Status" := "EDI Message Status"::Received;
        EDIMessageHeader."Received DateTime" := CurrentDateTime();
        EDIMessageHeader.Insert(true);

        TempBlob.CreateInStream(InStream);
        EDIMessageHeader."Raw Message".CreateOutStream(OutStream);
        CopyStream(OutStream, InStream);
        EDIMessageHeader.Modify();

        ProcessMessage(EDIMessageHeader);
    end;

    procedure ProcessOutboundMessages()
    var
        EDIMessageHeader: Record "EDI Message Header";
        EDICommunication: Codeunit "EDI Communication";
    begin
        LoadSetup();
        EDIMessageHeader.SetRange("Direction", "EDI Direction"::Outbound);
        EDIMessageHeader.SetRange("Status", "EDI Message Status"::New);
        if EDIMessageHeader.FindSet() then
            repeat
                EDICommunication.SendFile('', EDIMessageHeader);
            until EDIMessageHeader.Next() = 0;
    end;

    procedure ProcessMessage(var EDIMessageHeader: Record "EDI Message Header")
    var
        EDIX12Parser: Codeunit "EDI X12 Parser";
        EDIEDIFACTParser: Codeunit "EDI EDIFACT Parser";
        EDIDocumentCreator: Codeunit "EDI Document Creator";
        IsHandled: Boolean;
    begin
        OnBeforeProcessMessage(EDIMessageHeader, IsHandled);
        if IsHandled then
            exit;

        UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::Processing);

        if not DetermineEDIStandard(EDIMessageHeader) then begin
            EDIErrorHandler.HandleError(EDIMessageHeader, 'Cannot determine EDI standard from message content.');
            exit;
        end;

        case EDIMessageHeader."EDI Standard" of
            "EDI Standard"::X12:
                begin
                    EDIX12Parser.ParseX12Message(EDIMessageHeader);
                    if EDIMessageHeader.Status = "EDI Message Status"::Parsed then
                        EDIDocumentCreator.CreateBCDocument(EDIMessageHeader);
                end;
            "EDI Standard"::EDIFACT:
                begin
                    EDIEDIFACTParser.ParseEDIFACTMessage(EDIMessageHeader);
                    if EDIMessageHeader.Status = "EDI Message Status"::Parsed then
                        EDIDocumentCreator.CreateBCDocument(EDIMessageHeader);
                end;
        end;

        OnAfterProcessMessage(EDIMessageHeader);
    end;

    procedure ReprocessMessage(var EDIMessageHeader: Record "EDI Message Header")
    var
        CannotRetryLbl: Label 'Message has reached maximum retry count (%1). Cannot reprocess.';
    begin
        if not EDIErrorHandler.CanRetry(EDIMessageHeader) then begin
            Error(CannotRetryLbl, EDIMessageHeader."Max Retries");
        end;

        EDIMessageHeader."Error Message" := '';
        EDIMessageHeader."Error Count" := 0;
        EDIMessageHeader.Modify();

        UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::Received);
        ProcessMessage(EDIMessageHeader);
    end;

    procedure UpdateMessageStatus(var EDIMessageHeader: Record "EDI Message Header"; NewStatus: Enum "EDI Message Status")
    var
        OldStatus: Enum "EDI Message Status";
        IsHandled: Boolean;
        StatusChangeLbl: Label 'Status changed from %1 to %2.';
    begin
        OldStatus := EDIMessageHeader.Status;
        OnBeforeStatusChange(EDIMessageHeader, NewStatus, IsHandled);
        if IsHandled then
            exit;

        EDIMessageHeader.Status := NewStatus;

        if NewStatus = "EDI Message Status"::Processing then
            EDIMessageHeader."Processed DateTime" := CurrentDateTime();
        if NewStatus = "EDI Message Status"::Sent then
            EDIMessageHeader."Sent DateTime" := CurrentDateTime();

        EDIMessageHeader.Modify();

        LoadSetup();
        if EDISetup."Enable Logging" then
            LogInfo(EDIMessageHeader."Entry No.", EDIMessageHeader."Trading Partner Code",
                EDIMessageHeader.Direction, NewStatus,
                StrSubstNo(StatusChangeLbl, OldStatus, NewStatus), 50100, 'UpdateMessageStatus');

        OnAfterStatusChange(EDIMessageHeader, OldStatus, NewStatus);
    end;

    local procedure DetermineEDIStandard(var EDIMessageHeader: Record "EDI Message Header"): Boolean
    var
        InStream: InStream;
        RawData: Text;
        MsgPrefix: Text[3];
    begin
        // If the standard is already set, no detection needed
        if (EDIMessageHeader."EDI Standard" = "EDI Standard"::X12) or
           (EDIMessageHeader."EDI Standard" = "EDI Standard"::EDIFACT)
        then
            exit(true);

        // Auto-detect from message content
        EDIMessageHeader.CalcFields("Raw Message");
        if not EDIMessageHeader."Raw Message".HasValue() then
            exit(false);

        EDIMessageHeader."Raw Message".CreateInStream(InStream);
        InStream.ReadText(RawData, 200);
        MsgPrefix := CopyStr(RawData, 1, 3);

        if MsgPrefix = 'ISA' then begin
            EDIMessageHeader."EDI Standard" := "EDI Standard"::X12;
            EDIMessageHeader.Modify();
            exit(true);
        end;
        if MsgPrefix = 'UNB' then begin
            EDIMessageHeader."EDI Standard" := "EDI Standard"::EDIFACT;
            EDIMessageHeader.Modify();
            exit(true);
        end;
        exit(false);
    end;

    local procedure LoadSetup()
    begin
        if not SetupLoaded then begin
            EDISetup.GetSetup();
            SetupLoaded := true;
        end;
    end;

    local procedure LogInfo(MessageEntryNo: Integer; TradingPartnerCode: Code[20]; Direction: Enum "EDI Direction"; Status: Enum "EDI Message Status"; Description: Text; SourceCodeunit: Integer; SourceProcedure: Text)
    var
        EDILogEntry: Record "EDI Log Entry";
    begin
        EDILogEntry.Init();
        EDILogEntry."Message Entry No." := MessageEntryNo;
        EDILogEntry."Trading Partner Code" := TradingPartnerCode;
        EDILogEntry.Direction := Direction;
        EDILogEntry.Status := Status;
        EDILogEntry.Description := CopyStr(Description, 1, 2048);
        EDILogEntry."Log Level" := EDILogEntry."Log Level"::Information;
        EDILogEntry."Source Codeunit" := SourceCodeunit;
        EDILogEntry."Source Procedure" := CopyStr(SourceProcedure, 1, 100);
        EDILogEntry.Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessMessage(var EDIMessageHeader: Record "EDI Message Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessMessage(var EDIMessageHeader: Record "EDI Message Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStatusChange(var EDIMessageHeader: Record "EDI Message Header"; var NewStatus: Enum "EDI Message Status"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterStatusChange(var EDIMessageHeader: Record "EDI Message Header"; OldStatus: Enum "EDI Message Status"; NewStatus: Enum "EDI Message Status")
    begin
    end;
}
