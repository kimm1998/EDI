codeunit 50106 "EDI Acknowledgment Mgmt"
{
    Caption = 'EDI Acknowledgment Mgmt';

    procedure GenerateX12_997(var OriginalMessage: Record "EDI Message Header")
    var
        EDIAcknowledgment: Record "EDI Acknowledgment";
        EDIMessageHeader: Record "EDI Message Header";
        EDISetupLocal: Record "EDI Setup";
        OutStream: OutStream;
        EDIContent: Text;
        ControlNo: Text[9];
    begin
        EDISetupLocal.GetSetup();
        ControlNo := PadStr(Format(EDISetupLocal.GetNextControlNo()), 9, '0');

        EDIContent := '';
        EDIContent += StrSubstNo('ISA*00*          *00*          *ZZ*%1          *ZZ*%2          *%3*%4*^*00501*%5*0*P*>~',
            PadStr(EDISetupLocal."ISA Sender ID", 15, ' '),
            PadStr(EDISetupLocal."ISA Receiver ID", 15, ' '),
            Format(Today(), 0, '<Year,2><Month,2><Day,2>'),
            Format(Time(), 0, '<Hours24,2><Minutes,2>'),
            ControlNo);
        EDIContent += StrSubstNo('GS*FA*%1*%2*%3*%4*1*X*005010~',
            EDISetupLocal."ISA Sender ID",
            EDISetupLocal."ISA Receiver ID",
            Format(Today(), 0, '<Year4><Month,2><Day,2>'),
            Format(Time(), 0, '<Hours24,2><Minutes,2>'));
        EDIContent += 'ST*997*0001~';
        EDIContent += StrSubstNo('AK1*%1*1~', 'IN');
        EDIContent += 'AK9*A*1*1*1~';
        EDIContent += 'SE*4*0001~';
        EDIContent += 'GE*1*1~';
        EDIContent += StrSubstNo('IEA*1*%1~', ControlNo);

        EDIAcknowledgment.Init();
        EDIAcknowledgment."Original Message Entry No." := OriginalMessage."Entry No.";
        EDIAcknowledgment."Acknowledgment Type" := EDIAcknowledgment."Acknowledgment Type"::X12_997;
        EDIAcknowledgment."Trading Partner Code" := OriginalMessage."Trading Partner Code";
        EDIAcknowledgment.Status := EDIAcknowledgment.Status::Accepted;
        EDIAcknowledgment."Received DateTime" := CurrentDateTime();
        EDIAcknowledgment."ISA Control No." := ControlNo;
        EDIAcknowledgment.Insert(true);

        EDIAcknowledgment.CalcFields("Acknowledgment Message");
        EDIAcknowledgment."Acknowledgment Message".CreateOutStream(OutStream);
        OutStream.WriteText(EDIContent);
        EDIAcknowledgment.Modify();

        EDIMessageHeader.Init();
        EDIMessageHeader.Direction := "EDI Direction"::Outbound;
        EDIMessageHeader."EDI Standard" := "EDI Standard"::X12;
        EDIMessageHeader."Document Type Code" := 'X12-997';
        EDIMessageHeader."Trading Partner Code" := OriginalMessage."Trading Partner Code";
        EDIMessageHeader.Status := "EDI Message Status"::New;
        EDIMessageHeader.Insert(true);

        OriginalMessage."Acknowledgment Status" := OriginalMessage."Acknowledgment Status"::Accepted;
        OriginalMessage.Modify();
    end;

    procedure GenerateEDIFACT_CONTRL(var OriginalMessage: Record "EDI Message Header")
    var
        EDIAcknowledgment: Record "EDI Acknowledgment";
        EDIMessageHeader: Record "EDI Message Header";
        EDISetupLocal: Record "EDI Setup";
        OutStream: OutStream;
        EDIContent: Text;
        ControlNo: Text;
    begin
        EDISetupLocal.GetSetup();
        ControlNo := Format(EDISetupLocal.GetNextControlNo());

        EDIContent := '';
        EDIContent += StrSubstNo('UNB+UNOA:1+%1+%2+%3:%4+%5''',
            EDISetupLocal."UNB Sender ID",
            EDISetupLocal."UNB Receiver ID",
            Format(Today(), 0, '<Year4><Month,2><Day,2>'),
            Format(Time(), 0, '<Hours24,2><Minutes,2>'),
            ControlNo);
        EDIContent += 'UNH+1+CONTRL:D:96A:UN''';
        EDIContent += StrSubstNo('UCI+%1+%2+%3+7''',
            OriginalMessage."UNB Reference No.",
            EDISetupLocal."UNB Receiver ID",
            EDISetupLocal."UNB Sender ID");
        EDIContent += 'UNT+3+1''';
        EDIContent += StrSubstNo('UNZ+1+%1''', ControlNo);

        EDIAcknowledgment.Init();
        EDIAcknowledgment."Original Message Entry No." := OriginalMessage."Entry No.";
        EDIAcknowledgment."Acknowledgment Type" := EDIAcknowledgment."Acknowledgment Type"::EDIFACT_CONTRL;
        EDIAcknowledgment."Trading Partner Code" := OriginalMessage."Trading Partner Code";
        EDIAcknowledgment.Status := EDIAcknowledgment.Status::Accepted;
        EDIAcknowledgment."Received DateTime" := CurrentDateTime();
        EDIAcknowledgment."UNB Control No." := CopyStr(ControlNo, 1, 20);
        EDIAcknowledgment.Insert(true);

        EDIAcknowledgment.CalcFields("Acknowledgment Message");
        EDIAcknowledgment."Acknowledgment Message".CreateOutStream(OutStream);
        OutStream.WriteText(EDIContent);
        EDIAcknowledgment.Modify();

        EDIMessageHeader.Init();
        EDIMessageHeader.Direction := "EDI Direction"::Outbound;
        EDIMessageHeader."EDI Standard" := "EDI Standard"::EDIFACT;
        EDIMessageHeader."Document Type Code" := 'EDIFACT-CONTRL';
        EDIMessageHeader."Trading Partner Code" := OriginalMessage."Trading Partner Code";
        EDIMessageHeader.Status := "EDI Message Status"::New;
        EDIMessageHeader.Insert(true);

        OriginalMessage."Acknowledgment Status" := OriginalMessage."Acknowledgment Status"::Accepted;
        OriginalMessage.Modify();
    end;

    procedure ProcessInboundAcknowledgment(var EDIMessageHeader: Record "EDI Message Header")
    var
        EDIAcknowledgment: Record "EDI Acknowledgment";
        AckType: Option X12_997,X12_855,EDIFACT_CONTRL,EDIFACT_ORDRSP;
    begin
        EDIAcknowledgment.Init();
        EDIAcknowledgment."Original Message Entry No." := 0;
        EDIAcknowledgment."Trading Partner Code" := EDIMessageHeader."Trading Partner Code";
        EDIAcknowledgment."Received DateTime" := CurrentDateTime();
        EDIAcknowledgment.Status := EDIAcknowledgment.Status::Accepted;

        if EDIMessageHeader."EDI Standard" = "EDI Standard"::X12 then
            EDIAcknowledgment."Acknowledgment Type" := EDIAcknowledgment."Acknowledgment Type"::X12_997
        else
            EDIAcknowledgment."Acknowledgment Type" := EDIAcknowledgment."Acknowledgment Type"::EDIFACT_CONTRL;

        EDIAcknowledgment.Insert(true);
        UpdateOriginalMessageAckStatus(EDIAcknowledgment);
    end;

    procedure UpdateOriginalMessageAckStatus(var AckEntry: Record "EDI Acknowledgment")
    var
        OriginalMessage: Record "EDI Message Header";
    begin
        if AckEntry."Original Message Entry No." = 0 then
            exit;

        if not OriginalMessage.Get(AckEntry."Original Message Entry No.") then
            exit;

        case AckEntry.Status of
            AckEntry.Status::Accepted:
                begin
                    OriginalMessage."Acknowledgment Status" := OriginalMessage."Acknowledgment Status"::Accepted;
                    OriginalMessage.Status := "EDI Message Status"::Acknowledged;
                end;
            AckEntry.Status::"Accepted with Errors":
                OriginalMessage."Acknowledgment Status" := OriginalMessage."Acknowledgment Status"::Accepted;
            AckEntry.Status::Rejected:
                begin
                    OriginalMessage."Acknowledgment Status" := OriginalMessage."Acknowledgment Status"::Rejected;
                    OriginalMessage.Status := "EDI Message Status"::Rejected;
                end;
        end;
        OriginalMessage.Modify();
    end;
}
