codeunit 50107 "EDI Error Handler"
{
    Caption = 'EDI Error Handler';

    var
        EDISetup: Record "EDI Setup";

    procedure HandleError(var EDIMessageHeader: Record "EDI Message Header"; ErrorText: Text)
    var
        EDIProcessor: Codeunit "EDI Processor";
    begin
        EDIMessageHeader."Error Message" := CopyStr(ErrorText, 1, 2048);
        EDIMessageHeader."Error Count" += 1;
        EDIMessageHeader.Modify();

        LogError(EDIMessageHeader."Entry No.", EDIMessageHeader."Trading Partner Code",
            EDIMessageHeader.Direction, ErrorText, 50107, 'HandleError');

        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::Error);

        if CanRetry(EDIMessageHeader) then
            RetryMessage(EDIMessageHeader)
        else
            MoveToErrorFolder(EDIMessageHeader);
    end;

    procedure LogError(MessageEntryNo: Integer; TradingPartnerCode: Code[20]; Direction: Enum "EDI Direction"; ErrorText: Text; SourceCodeunit: Integer; SourceProcedure: Text)
    var
        EDILogEntry: Record "EDI Log Entry";
    begin
        EDISetup.GetSetup();
        if not EDISetup."Enable Logging" then
            exit;

        EDILogEntry.Init();
        EDILogEntry."Message Entry No." := MessageEntryNo;
        EDILogEntry."Trading Partner Code" := TradingPartnerCode;
        EDILogEntry.Direction := Direction;
        EDILogEntry.Description := CopyStr(ErrorText, 1, 2048);
        EDILogEntry."Log Level" := EDILogEntry."Log Level"::Error;
        EDILogEntry."Source Codeunit" := SourceCodeunit;
        EDILogEntry."Source Procedure" := CopyStr(SourceProcedure, 1, 100);
        EDILogEntry.Insert();
    end;

    procedure GetRetryableErrors() RetryableErrors: List of [Text]
    begin
        RetryableErrors.Add('Connection timeout');
        RetryableErrors.Add('Network error');
        RetryableErrors.Add('SFTP connection failed');
        RetryableErrors.Add('API request failed');
        RetryableErrors.Add('File not found');
        RetryableErrors.Add('Temporary server error');
    end;

    procedure CanRetry(var EDIMessageHeader: Record "EDI Message Header"): Boolean
    begin
        exit(EDIMessageHeader."Retry Count" < EDIMessageHeader."Max Retries");
    end;

    procedure RetryMessage(var EDIMessageHeader: Record "EDI Message Header")
    var
        EDIProcessor: Codeunit "EDI Processor";
        RetryLbl: Label 'Retrying message. Attempt %1 of %2.';
    begin
        if not CanRetry(EDIMessageHeader) then
            exit;

        EDIMessageHeader."Retry Count" += 1;
        EDIMessageHeader.Modify();

        LogInfo(EDIMessageHeader."Entry No.", EDIMessageHeader."Trading Partner Code",
            EDIMessageHeader.Direction,
            StrSubstNo(RetryLbl, EDIMessageHeader."Retry Count", EDIMessageHeader."Max Retries"),
            50107, 'RetryMessage');

        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::Received);
    end;

    procedure MoveToErrorFolder(var EDIMessageHeader: Record "EDI Message Header")
    var
        ErrorFolderLbl: Label 'Message moved to error folder. Max retries (%1) exceeded.';
    begin
        LogError(EDIMessageHeader."Entry No.", EDIMessageHeader."Trading Partner Code",
            EDIMessageHeader.Direction,
            StrSubstNo(ErrorFolderLbl, EDIMessageHeader."Max Retries"),
            50107, 'MoveToErrorFolder');

        SendErrorNotification(EDIMessageHeader);
    end;

    procedure SendErrorNotification(var EDIMessageHeader: Record "EDI Message Header")
    var
        EDITradingPartner: Record "EDI Trading Partner";
        NotificationSentLbl: Label 'Error notification sent for message %1.';
        NotificationLbl: Label 'Error notification configured for message entry %1. Trading Partner: %2. Error: %3';
    begin
        if not EDITradingPartner.Get(EDIMessageHeader."Trading Partner Code") then
            exit;

        if EDITradingPartner."Contact Email" = '' then
            exit;

        LogInfo(EDIMessageHeader."Entry No.", EDIMessageHeader."Trading Partner Code",
            EDIMessageHeader.Direction,
            StrSubstNo(NotificationLbl,
                EDIMessageHeader."Entry No.",
                EDIMessageHeader."Trading Partner Code",
                EDIMessageHeader."Error Message"),
            50107, 'SendErrorNotification');
    end;

    local procedure LogInfo(MessageEntryNo: Integer; TradingPartnerCode: Code[20]; Direction: Enum "EDI Direction"; Description: Text; SourceCodeunit: Integer; SourceProcedure: Text)
    var
        EDILogEntry: Record "EDI Log Entry";
    begin
        EDISetup.GetSetup();
        if not EDISetup."Enable Logging" then
            exit;

        EDILogEntry.Init();
        EDILogEntry."Message Entry No." := MessageEntryNo;
        EDILogEntry."Trading Partner Code" := TradingPartnerCode;
        EDILogEntry.Direction := Direction;
        EDILogEntry.Description := CopyStr(Description, 1, 2048);
        EDILogEntry."Log Level" := EDILogEntry."Log Level"::Information;
        EDILogEntry."Source Codeunit" := SourceCodeunit;
        EDILogEntry."Source Procedure" := CopyStr(SourceProcedure, 1, 100);
        EDILogEntry.Insert();
    end;
}
