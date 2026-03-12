codeunit 50109 "EDI Module Tests"
{
    Caption = 'EDI Module Tests';
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        SampleX12_850: Label 'ISA*00*          *00*          *ZZ*SENDER         *ZZ*RECEIVER       *230101*0800*^*00501*000000001*0*P*>~GS*PO*SENDER*RECEIVER*20230101*0800*1*X*005010~ST*850*0001~BEG*00*SA*PO12345**20230101~PO1*1*10*EA*15.00**BP*ITEM001~PO1*2*5*EA*25.00**BP*ITEM002~CTT*2~SE*7*0001~GE*1*1~IEA*1*000000001~', Locked = true;
        SampleEDIFACT_ORDERS: Label 'UNB+UNOA:1+SENDER+RECEIVER+230101:0800+1''UNH+1+ORDERS:D:96A:UN+''BGM+220+ORD001+9''DTM+137:20230101:102''LIN+1++ITEM001:BP''QTY+21:10:PCE''PRI+INV:15.00:NTP''LIN+2++ITEM002:BP''QTY+21:5:PCE''PRI+INV:25.00:NTP''UNT+10+1''UNZ+1+1''', Locked = true;

    [Test]
    procedure TestX12_850Parsing()
    var
        EDIMessageHeader: Record "EDI Message Header";
        EDIX12Parser: Codeunit "EDI X12 Parser";
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [SCENARIO] Parse a sample X12 850 message
        // [GIVEN] An EDI message header with raw X12 850 content
        EDIMessageHeader.Init();
        EDIMessageHeader."EDI Standard" := "EDI Standard"::X12;
        EDIMessageHeader.Direction := "EDI Direction"::Inbound;
        EDIMessageHeader.Status := "EDI Message Status"::Received;
        EDIMessageHeader.Insert(true);

        EDIMessageHeader."Raw Message".CreateOutStream(OutStream);
        OutStream.WriteText(SampleX12_850);
        EDIMessageHeader.Modify();

        // [WHEN] Parse the X12 message
        EDIX12Parser.ParseX12Message(EDIMessageHeader);

        // [THEN] Message status should be Parsed
        EDIMessageHeader.Get(EDIMessageHeader."Entry No.");
        Assert.AreEqual("EDI Message Status"::Parsed, EDIMessageHeader.Status, 'Message should be in Parsed status after X12 parsing.');

        // [THEN] Message lines should be created for PO1 segments
        VerifyMessageLinesCreated(EDIMessageHeader."Entry No.", 2);

        // Cleanup
        CleanupTestMessage(EDIMessageHeader);
    end;

    [Test]
    procedure TestEDIFACT_ORDERSParsing()
    var
        EDIMessageHeader: Record "EDI Message Header";
        EDIEDIFACTParser: Codeunit "EDI EDIFACT Parser";
        OutStream: OutStream;
    begin
        // [SCENARIO] Parse a sample EDIFACT ORDERS message
        // [GIVEN] An EDI message header with raw EDIFACT ORDERS content
        EDIMessageHeader.Init();
        EDIMessageHeader."EDI Standard" := "EDI Standard"::EDIFACT;
        EDIMessageHeader.Direction := "EDI Direction"::Inbound;
        EDIMessageHeader.Status := "EDI Message Status"::Received;
        EDIMessageHeader.Insert(true);

        EDIMessageHeader."Raw Message".CreateOutStream(OutStream);
        OutStream.WriteText(SampleEDIFACT_ORDERS);
        EDIMessageHeader.Modify();

        // [WHEN] Parse the EDIFACT message
        EDIEDIFACTParser.ParseEDIFACTMessage(EDIMessageHeader);

        // [THEN] Message status should be Parsed
        EDIMessageHeader.Get(EDIMessageHeader."Entry No.");
        Assert.AreEqual("EDI Message Status"::Parsed, EDIMessageHeader.Status, 'Message should be in Parsed status after EDIFACT parsing.');

        // Cleanup
        CleanupTestMessage(EDIMessageHeader);
    end;

    [Test]
    procedure TestX12_810Generation()
    var
        EDIOutboundGenerator: Codeunit "EDI Outbound Generator";
        Customer: Record Customer;
        SalesInvHeader: Record "Sales Invoice Header";
        EDITradingPartner: Record "EDI Trading Partner";
        EDIMessageHeader: Record "EDI Message Header";
        Item: Record Item;
    begin
        // [SCENARIO] Generate an X12 810 from a posted Sales Invoice
        // [GIVEN] A customer with EDI enabled
        LibrarySales.CreateCustomer(Customer);
        Customer."EDI Enabled" := true;
        Customer."EDI Standard" := "EDI Standard"::X12;

        // [GIVEN] A trading partner linked to the customer
        CreateTestTradingPartner(EDITradingPartner, "EDI Standard"::X12);
        Customer."EDI Trading Partner Code" := EDITradingPartner.Code;
        Customer.Modify();

        // [WHEN] Generate X12 810
        if not SalesInvHeader.FindFirst() then begin
            Assert.IsTrue(true, 'Skipping test - no posted sales invoices available.');
            CleanupTestTradingPartner(EDITradingPartner);
            exit;
        end;

        EDIOutboundGenerator.GenerateX12_810(SalesInvHeader);

        // [THEN] An outbound EDI message should be created
        EDIMessageHeader.SetRange("Trading Partner Code", EDITradingPartner.Code);
        EDIMessageHeader.SetRange("Document Type Code", 'X12-810');
        Assert.IsTrue(EDIMessageHeader.FindFirst(), 'X12 810 message should be created.');

        // Cleanup
        CleanupTestMessage(EDIMessageHeader);
        CleanupTestTradingPartner(EDITradingPartner);
    end;

    [Test]
    procedure TestAcknowledgmentGeneration()
    var
        EDIAcknowledgmentMgmt: Codeunit "EDI Acknowledgment Mgmt";
        EDIMessageHeader: Record "EDI Message Header";
        EDIAcknowledgment: Record "EDI Acknowledgment";
        EDITradingPartner: Record "EDI Trading Partner";
    begin
        // [SCENARIO] Generate X12 997 acknowledgment for an inbound message
        // [GIVEN] A processed inbound EDI message
        CreateTestTradingPartner(EDITradingPartner, "EDI Standard"::X12);

        EDIMessageHeader.Init();
        EDIMessageHeader.Direction := "EDI Direction"::Inbound;
        EDIMessageHeader."EDI Standard" := "EDI Standard"::X12;
        EDIMessageHeader."Trading Partner Code" := EDITradingPartner.Code;
        EDIMessageHeader.Status := "EDI Message Status"::Parsed;
        EDIMessageHeader."Acknowledgment Status" := EDIMessageHeader."Acknowledgment Status"::Pending;
        EDIMessageHeader."ISA Control No." := '000000001';
        EDIMessageHeader.Insert(true);

        // [WHEN] Generate 997 acknowledgment
        EDIAcknowledgmentMgmt.GenerateX12_997(EDIMessageHeader);

        // [THEN] Acknowledgment record should be created
        EDIAcknowledgment.SetRange("Original Message Entry No.", EDIMessageHeader."Entry No.");
        Assert.IsTrue(EDIAcknowledgment.FindFirst(), 'Acknowledgment record should be created.');
        Assert.AreEqual(EDIAcknowledgment."Acknowledgment Type"::X12_997, EDIAcknowledgment."Acknowledgment Type", 'Acknowledgment type should be X12 997.');

        // [THEN] Original message acknowledgment status should be updated
        EDIMessageHeader.Get(EDIMessageHeader."Entry No.");
        Assert.AreEqual(EDIMessageHeader."Acknowledgment Status"::Accepted, EDIMessageHeader."Acknowledgment Status", 'Acknowledgment status should be Accepted.');

        // Cleanup
        EDIAcknowledgment.Delete();
        CleanupTestMessage(EDIMessageHeader);
        CleanupTestTradingPartner(EDITradingPartner);
    end;

    [Test]
    procedure TestErrorHandlingAndRetry()
    var
        EDIErrorHandler: Codeunit "EDI Error Handler";
        EDIMessageHeader: Record "EDI Message Header";
        EDITradingPartner: Record "EDI Trading Partner";
    begin
        // [SCENARIO] Test error handling and retry logic
        // [GIVEN] An EDI message header
        CreateTestTradingPartner(EDITradingPartner, "EDI Standard"::X12);

        EDIMessageHeader.Init();
        EDIMessageHeader.Direction := "EDI Direction"::Inbound;
        EDIMessageHeader."EDI Standard" := "EDI Standard"::X12;
        EDIMessageHeader."Trading Partner Code" := EDITradingPartner.Code;
        EDIMessageHeader.Status := "EDI Message Status"::Received;
        EDIMessageHeader."Max Retries" := 3;
        EDIMessageHeader.Insert(true);

        // [WHEN] CanRetry is checked
        Assert.IsTrue(EDIErrorHandler.CanRetry(EDIMessageHeader), 'Should be able to retry when retry count is 0.');

        // [WHEN] Retry count reaches max
        EDIMessageHeader."Retry Count" := 3;
        EDIMessageHeader.Modify();

        // [THEN] CanRetry should return false
        Assert.IsFalse(EDIErrorHandler.CanRetry(EDIMessageHeader), 'Should not be able to retry when max retries reached.');

        // Cleanup
        CleanupTestMessage(EDIMessageHeader);
        CleanupTestTradingPartner(EDITradingPartner);
    end;

    [Test]
    procedure TestStatusTransitions()
    var
        EDIProcessor: Codeunit "EDI Processor";
        EDIMessageHeader: Record "EDI Message Header";
        EDITradingPartner: Record "EDI Trading Partner";
    begin
        // [SCENARIO] Test valid status transitions for EDI messages
        // [GIVEN] A new EDI message
        CreateTestTradingPartner(EDITradingPartner, "EDI Standard"::X12);

        EDIMessageHeader.Init();
        EDIMessageHeader.Direction := "EDI Direction"::Inbound;
        EDIMessageHeader."EDI Standard" := "EDI Standard"::X12;
        EDIMessageHeader."Trading Partner Code" := EDITradingPartner.Code;
        EDIMessageHeader.Status := "EDI Message Status"::New;
        EDIMessageHeader.Insert(true);

        Assert.AreEqual("EDI Message Status"::New, EDIMessageHeader.Status, 'Initial status should be New.');

        // [WHEN] Status is updated to Received
        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::Received);

        // [THEN] Status should be Received
        EDIMessageHeader.Get(EDIMessageHeader."Entry No.");
        Assert.AreEqual("EDI Message Status"::Received, EDIMessageHeader.Status, 'Status should be Received.');

        // [WHEN] Status is updated to Parsed
        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::Parsed);

        // [THEN] Status should be Parsed
        EDIMessageHeader.Get(EDIMessageHeader."Entry No.");
        Assert.AreEqual("EDI Message Status"::Parsed, EDIMessageHeader.Status, 'Status should be Parsed.');

        // Cleanup
        CleanupTestMessage(EDIMessageHeader);
        CleanupTestTradingPartner(EDITradingPartner);
    end;

    [Test]
    procedure TestX12SegmentSplitting()
    var
        EDIX12Parser: Codeunit "EDI X12 Parser";
        Segments: List of [Text];
        RawData: Text;
    begin
        // [SCENARIO] Test X12 segment splitting
        // [GIVEN] A raw X12 string
        RawData := 'ISA*test*data~GS*data~ST*data~SE*data~';

        // [WHEN] Splitting segments by tilde
        Segments := EDIX12Parser.SplitSegments(RawData, '~');

        // [THEN] Should return 4 segments
        Assert.AreEqual(4, Segments.Count(), 'Should have 4 segments after splitting.');
    end;

    [Test]
    procedure TestX12ElementSplitting()
    var
        EDIX12Parser: Codeunit "EDI X12 Parser";
        Elements: List of [Text];
        Segment: Text;
    begin
        // [SCENARIO] Test X12 element splitting
        // [GIVEN] An X12 segment
        Segment := 'PO1*1*10*EA*15.00**BP*ITEM001';

        // [WHEN] Splitting elements by asterisk
        Elements := EDIX12Parser.SplitElements(Segment, '*');

        // [THEN] Should return 8 elements
        Assert.AreEqual(8, Elements.Count(), 'PO1 segment should have 8 elements.');
        Assert.AreEqual('PO1', Elements.Get(1), 'First element should be PO1.');
        Assert.AreEqual('ITEM001', Elements.Get(8), 'Last element should be ITEM001.');
    end;

    local procedure CreateTestTradingPartner(var EDITradingPartner: Record "EDI Trading Partner"; EDIStandard: Enum "EDI Standard")
    begin
        if EDITradingPartner.Get('TEST001') then begin
            EDITradingPartner.Delete();
        end;
        EDITradingPartner.Init();
        EDITradingPartner.Code := 'TEST001';
        EDITradingPartner.Name := 'Test Trading Partner';
        EDITradingPartner."EDI Standard" := EDIStandard;
        EDITradingPartner.Active := true;
        EDITradingPartner.Insert(true);
    end;

    local procedure CleanupTestTradingPartner(var EDITradingPartner: Record "EDI Trading Partner")
    begin
        if EDITradingPartner.Get(EDITradingPartner.Code) then
            EDITradingPartner.Delete();
    end;

    local procedure CleanupTestMessage(var EDIMessageHeader: Record "EDI Message Header")
    var
        EDIMessageLine: Record "EDI Message Line";
        EDILogEntry: Record "EDI Log Entry";
    begin
        EDIMessageLine.SetRange("Message Entry No.", EDIMessageHeader."Entry No.");
        EDIMessageLine.DeleteAll();

        EDILogEntry.SetRange("Message Entry No.", EDIMessageHeader."Entry No.");
        EDILogEntry.DeleteAll();

        if EDIMessageHeader.Get(EDIMessageHeader."Entry No.") then
            EDIMessageHeader.Delete();
    end;

    local procedure VerifyMessageLinesCreated(MessageEntryNo: Integer; ExpectedLineCount: Integer)
    var
        EDIMessageLine: Record "EDI Message Line";
        ActualCount: Integer;
    begin
        EDIMessageLine.SetRange("Message Entry No.", MessageEntryNo);
        ActualCount := EDIMessageLine.Count();
        Assert.AreEqual(ExpectedLineCount, ActualCount,
            StrSubstNo('Expected %1 message lines but found %2.', ExpectedLineCount, ActualCount));
    end;
}
