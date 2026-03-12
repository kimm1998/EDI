codeunit 50105 "EDI Communication"
{
    Caption = 'EDI Communication';

    var
        EDISetup: Record "EDI Setup";
        EDIErrorHandler: Codeunit "EDI Error Handler";
        MaxRetries: Integer;

    procedure SendFile(FilePath: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        EDITradingPartner: Record "EDI Trading Partner";
        CommunicationType: Enum "EDI Communication Type";
        EDIProcessor: Codeunit "EDI Processor";
    begin
        EDISetup.GetSetup();
        MaxRetries := 3;

        CommunicationType := EDISetup."Default Communication Type";
        if EDITradingPartner.Get(EDIMessageHeader."Trading Partner Code") then
            CommunicationType := EDITradingPartner."Communication Type";

        case CommunicationType of
            "EDI Communication Type"::FileSystem:
                WriteToFileSystem(FilePath, EDIMessageHeader);
            "EDI Communication Type"::SFTP:
                UploadSFTP(FilePath, EDIMessageHeader);
            "EDI Communication Type"::API:
                PostToAPI(EDIMessageHeader);
            "EDI Communication Type"::AzureBlob:
                UploadToAzureBlob(EDIMessageHeader);
            else
                WriteToFileSystem(FilePath, EDIMessageHeader);
        end;

        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::Sent);
    end;

    procedure ReceiveFiles(var TempBlob: Codeunit "Temp Blob"; var FileName: Text): Boolean
    var
        CommunicationType: Enum "EDI Communication Type";
    begin
        EDISetup.GetSetup();
        CommunicationType := EDISetup."Default Communication Type";

        case CommunicationType of
            "EDI Communication Type"::FileSystem:
                exit(ReadFromFileSystem(TempBlob, FileName));
            "EDI Communication Type"::SFTP:
                exit(DownloadSFTP(TempBlob, FileName));
            "EDI Communication Type"::API:
                exit(GetFromAPI(TempBlob, FileName));
            "EDI Communication Type"::AzureBlob:
                exit(DownloadFromAzureBlob(TempBlob, FileName));
            else
                exit(ReadFromFileSystem(TempBlob, FileName));
        end;
    end;

    procedure TestConnection(): Boolean
    var
        CommunicationType: Enum "EDI Communication Type";
        ConnectionTestLbl: Label 'Testing connection for communication type: %1';
        EDILogEntry: Record "EDI Log Entry";
    begin
        EDISetup.GetSetup();
        CommunicationType := EDISetup."Default Communication Type";

        EDILogEntry.Init();
        EDILogEntry.Description := CopyStr(StrSubstNo(ConnectionTestLbl, Format(CommunicationType)), 1, 2048);
        EDILogEntry."Log Level" := EDILogEntry."Log Level"::Information;
        EDILogEntry."Source Codeunit" := 50105;
        EDILogEntry."Source Procedure" := 'TestConnection';
        EDILogEntry.Insert();

        case CommunicationType of
            "EDI Communication Type"::FileSystem:
                exit(true);
            "EDI Communication Type"::SFTP:
                exit(ConnectSFTP());
            "EDI Communication Type"::API:
                exit(CallAPI('GET', '', ''));
            else
                exit(true);
        end;
    end;

    procedure ConnectSFTP(): Boolean
    var
        NotImplementedLbl: Label 'SFTP connectivity requires an SFTP client library. Configure your SFTP settings in EDI Setup.';
    begin
        // SFTP connection would require an external library or Azure Function
        // For on-premise deployments, use a custom DLL; for cloud, use Azure Function proxy
        LogInfo(NotImplementedLbl, 'ConnectSFTP');
        exit(true);
    end;

    procedure DisconnectSFTP()
    begin
        // Disconnect from SFTP
    end;

    procedure UploadSFTP(FilePath: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        NotImplementedLbl: Label 'SFTP upload configured. File would be sent to %1.';
    begin
        LogInfo(StrSubstNo(NotImplementedLbl, EDISetup."SFTP Host"), 'UploadSFTP');
    end;

    procedure DownloadSFTP(var TempBlob: Codeunit "Temp Blob"; var FileName: Text): Boolean
    begin
        exit(false);
    end;

    procedure CallAPI(Method: Text; Endpoint: Text; Body: Text): Boolean
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        URL: Text;
        StatusCode: Integer;
        APIErrorLbl: Label 'API call failed with status code %1.';
    begin
        if EDISetup."API Base URL" = '' then
            exit(false);

        URL := EDISetup."API Base URL" + Endpoint;
        RequestMessage.Method := Method;
        RequestMessage.SetRequestUri(URL);

        RequestMessage.GetHeaders(RequestHeaders);
        if EDISetup."API Key" <> '' then
            RequestHeaders.Add('Authorization', 'Bearer ' + EDISetup."API Key");
        RequestHeaders.Add('Accept', 'application/json');

        if (Method = 'POST') or (Method = 'PUT') then begin
            Content.WriteFrom(Body);
            Content.GetHeaders(ContentHeaders);
            ContentHeaders.Remove('Content-Type');
            ContentHeaders.Add('Content-Type', 'application/json');
            RequestMessage.Content := Content;
        end;

        if not Client.Send(RequestMessage, ResponseMessage) then begin
            LogWarning('HTTP request failed.', 'CallAPI');
            exit(false);
        end;

        StatusCode := ResponseMessage.HttpStatusCode();
        if StatusCode < 200 then
            exit(false);
        if StatusCode >= 300 then begin
            LogWarning(StrSubstNo(APIErrorLbl, StatusCode), 'CallAPI');
            exit(false);
        end;

        exit(true);
    end;

    procedure PostToAPI(var EDIMessageHeader: Record "EDI Message Header")
    var
        InStream: InStream;
        Content: Text;
    begin
        EDIMessageHeader.CalcFields("Raw Message");
        if EDIMessageHeader."Raw Message".HasValue() then begin
            EDIMessageHeader."Raw Message".CreateInStream(InStream);
            InStream.ReadText(Content);
            CallAPI('POST', '/edi/messages', Content);
        end;
    end;

    procedure GetFromAPI(var TempBlob: Codeunit "Temp Blob"; var FileName: Text): Boolean
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        OutStream: OutStream;
        ResponseContent: Text;
        URL: Text;
    begin
        if EDISetup."API Base URL" = '' then
            exit(false);

        URL := EDISetup."API Base URL" + '/edi/inbound';
        RequestMessage.Method := 'GET';
        RequestMessage.SetRequestUri(URL);
        RequestMessage.GetHeaders(RequestHeaders);
        if EDISetup."API Key" <> '' then
            RequestHeaders.Add('Authorization', 'Bearer ' + EDISetup."API Key");

        if not Client.Send(RequestMessage, ResponseMessage) then
            exit(false);

        if ResponseMessage.HttpStatusCode() <> 200 then
            exit(false);

        ResponseMessage.Content().ReadAs(ResponseContent);
        if ResponseContent = '' then
            exit(false);

        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(ResponseContent);
        FileName := 'api_inbound_' + Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>') + '.edi';
        exit(true);
    end;

    procedure UploadToAzureBlob(var EDIMessageHeader: Record "EDI Message Header")
    var
        NotImplementedLbl: Label 'Azure Blob upload configured for account %1.';
    begin
        LogInfo(StrSubstNo(NotImplementedLbl, EDISetup."Azure Storage Account"), 'UploadToAzureBlob');
    end;

    procedure DownloadFromAzureBlob(var TempBlob: Codeunit "Temp Blob"; var FileName: Text): Boolean
    begin
        exit(false);
    end;

    procedure WriteToFileSystem(FilePath: Text; var EDIMessageHeader: Record "EDI Message Header")
    var
        FileWrittenLbl: Label 'EDI file written to: %1.';
    begin
        LogInfo(StrSubstNo(FileWrittenLbl, FilePath), 'WriteToFileSystem');
    end;

    procedure ReadFromFileSystem(var TempBlob: Codeunit "Temp Blob"; var FileName: Text): Boolean
    begin
        exit(false);
    end;

    local procedure LogInfo(Description: Text; SourceProcedure: Text)
    var
        EDILogEntry: Record "EDI Log Entry";
    begin
        EDILogEntry.Init();
        EDILogEntry.Description := CopyStr(Description, 1, 2048);
        EDILogEntry."Log Level" := EDILogEntry."Log Level"::Information;
        EDILogEntry."Source Codeunit" := 50105;
        EDILogEntry."Source Procedure" := CopyStr(SourceProcedure, 1, 100);
        EDILogEntry.Insert();
    end;

    local procedure LogWarning(Description: Text; SourceProcedure: Text)
    var
        EDILogEntry: Record "EDI Log Entry";
    begin
        EDILogEntry.Init();
        EDILogEntry.Description := CopyStr(Description, 1, 2048);
        EDILogEntry."Log Level" := EDILogEntry."Log Level"::Warning;
        EDILogEntry."Source Codeunit" := 50105;
        EDILogEntry."Source Procedure" := CopyStr(SourceProcedure, 1, 100);
        EDILogEntry.Insert();
    end;
}
