codeunit 50103 "EDI Document Creator"
{
    Caption = 'EDI Document Creator';

    var
        EDISetup: Record "EDI Setup";
        EDIErrorHandler: Codeunit "EDI Error Handler";
        EDIProcessor: Codeunit "EDI Processor";

    procedure CreateBCDocument(var EDIMessageHeader: Record "EDI Message Header")
    var
        IsHandled: Boolean;
    begin
        EDISetup.GetSetup();

        case EDIMessageHeader."BC Document Type" of
            EDIMessageHeader."BC Document Type"::"Sales Order":
                CreateSalesOrderFromEDI(EDIMessageHeader);
            EDIMessageHeader."BC Document Type"::"Purchase Order":
                CreatePurchaseOrderFromEDI(EDIMessageHeader);
            EDIMessageHeader."BC Document Type"::"Sales Invoice":
                CreateSalesInvoiceFromEDI(EDIMessageHeader);
            else begin
                EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::Validated);
            end;
        end;
    end;

    procedure CreateSalesOrderFromEDI(var EDIMessageHeader: Record "EDI Message Header")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        EDITradingPartner: Record "EDI Trading Partner";
        EDIMessageLine: Record "EDI Message Line";
        Customer: Record Customer;
        Item: Record Item;
        LineNo: Integer;
        NoCustomerLbl: Label 'No customer found for trading partner %1.';
        SalesOrderCreatedLbl: Label 'Sales Order %1 created from EDI message %2.';
    begin
        if not EDITradingPartner.Get(EDIMessageHeader."Trading Partner Code") then begin
            EDIErrorHandler.HandleError(EDIMessageHeader, StrSubstNo('Trading partner %1 not found.', EDIMessageHeader."Trading Partner Code"));
            exit;
        end;

        if EDITradingPartner."Customer No." = '' then begin
            EDIErrorHandler.HandleError(EDIMessageHeader, StrSubstNo(NoCustomerLbl, EDIMessageHeader."Trading Partner Code"));
            exit;
        end;

        if not Customer.Get(EDITradingPartner."Customer No.") then begin
            EDIErrorHandler.HandleError(EDIMessageHeader, StrSubstNo('Customer %1 not found.', EDITradingPartner."Customer No."));
            exit;
        end;

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        if EDIMessageHeader."Transaction Date" <> 0D then
            SalesHeader."Document Date" := EDIMessageHeader."Transaction Date";
        SalesHeader."External Document No." := EDIMessageHeader."Message ID";
        SalesHeader.Modify(true);

        LineNo := 10000;
        EDIMessageLine.SetRange("Message Entry No.", EDIMessageHeader."Entry No.");
        if EDIMessageLine.FindSet() then
            repeat
                if EDIMessageLine."Item No." <> '' then begin
                    if Item.Get(EDIMessageLine."Item No.") then begin
                        SalesLine.Init();
                        SalesLine."Document Type" := SalesHeader."Document Type";
                        SalesLine."Document No." := SalesHeader."No.";
                        SalesLine."Line No." := LineNo;
                        SalesLine.Insert(true);
                        SalesLine.Validate(Type, SalesLine.Type::Item);
                        SalesLine.Validate("No.", EDIMessageLine."Item No.");
                        SalesLine.Validate(Quantity, EDIMessageLine.Quantity);
                        if EDIMessageLine."Unit of Measure Code" <> '' then
                            SalesLine.Validate("Unit of Measure Code", EDIMessageLine."Unit of Measure Code");
                        if EDIMessageLine."Unit Price" <> 0 then
                            SalesLine.Validate("Unit Price", EDIMessageLine."Unit Price");
                        SalesLine.Modify(true);
                        LineNo += 10000;
                        EDIMessageLine.Mapped := true;
                        EDIMessageLine.Modify();
                    end else begin
                        EDIMessageLine."Error Message" := CopyStr(StrSubstNo('Item %1 not found.', EDIMessageLine."Item No."), 1, 500);
                        EDIMessageLine.Modify();
                    end;
                end;
            until EDIMessageLine.Next() = 0;

        EDIMessageHeader."BC Document No." := SalesHeader."No.";
        EDIMessageHeader.Modify();

        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::Posted);

        LogInfo(EDIMessageHeader."Entry No.", EDIMessageHeader."Trading Partner Code",
            StrSubstNo(SalesOrderCreatedLbl, SalesHeader."No.", EDIMessageHeader."Entry No."));
    end;

    procedure CreateSalesInvoiceFromEDI(var EDIMessageHeader: Record "EDI Message Header")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        EDITradingPartner: Record "EDI Trading Partner";
        EDIMessageLine: Record "EDI Message Line";
        Customer: Record Customer;
        Item: Record Item;
        LineNo: Integer;
        InvoiceCreatedLbl: Label 'Sales Invoice %1 created from EDI message %2.';
    begin
        if not EDITradingPartner.Get(EDIMessageHeader."Trading Partner Code") then begin
            EDIErrorHandler.HandleError(EDIMessageHeader, StrSubstNo('Trading partner %1 not found.', EDIMessageHeader."Trading Partner Code"));
            exit;
        end;

        if not Customer.Get(EDITradingPartner."Customer No.") then begin
            EDIErrorHandler.HandleError(EDIMessageHeader, StrSubstNo('Customer %1 not found.', EDITradingPartner."Customer No."));
            exit;
        end;

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader."External Document No." := EDIMessageHeader."Message ID";
        SalesHeader.Modify(true);

        LineNo := 10000;
        EDIMessageLine.SetRange("Message Entry No.", EDIMessageHeader."Entry No.");
        if EDIMessageLine.FindSet() then
            repeat
                if EDIMessageLine."Item No." <> '' then
                    if Item.Get(EDIMessageLine."Item No.") then begin
                        SalesLine.Init();
                        SalesLine."Document Type" := SalesHeader."Document Type";
                        SalesLine."Document No." := SalesHeader."No.";
                        SalesLine."Line No." := LineNo;
                        SalesLine.Insert(true);
                        SalesLine.Validate(Type, SalesLine.Type::Item);
                        SalesLine.Validate("No.", EDIMessageLine."Item No.");
                        SalesLine.Validate(Quantity, EDIMessageLine.Quantity);
                        if EDIMessageLine."Unit Price" <> 0 then
                            SalesLine.Validate("Unit Price", EDIMessageLine."Unit Price");
                        SalesLine.Modify(true);
                        LineNo += 10000;
                        EDIMessageLine.Mapped := true;
                        EDIMessageLine.Modify();
                    end;
            until EDIMessageLine.Next() = 0;

        EDIMessageHeader."BC Document No." := SalesHeader."No.";
        EDIMessageHeader.Modify();

        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::Posted);

        LogInfo(EDIMessageHeader."Entry No.", EDIMessageHeader."Trading Partner Code",
            StrSubstNo(InvoiceCreatedLbl, SalesHeader."No.", EDIMessageHeader."Entry No."));
    end;

    procedure CreatePurchaseOrderFromEDI(var EDIMessageHeader: Record "EDI Message Header")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EDITradingPartner: Record "EDI Trading Partner";
        EDIMessageLine: Record "EDI Message Line";
        Vendor: Record Vendor;
        Item: Record Item;
        LineNo: Integer;
        NoVendorLbl: Label 'No vendor found for trading partner %1.';
        POCreatedLbl: Label 'Purchase Order %1 created from EDI message %2.';
    begin
        if not EDITradingPartner.Get(EDIMessageHeader."Trading Partner Code") then begin
            EDIErrorHandler.HandleError(EDIMessageHeader, StrSubstNo('Trading partner %1 not found.', EDIMessageHeader."Trading Partner Code"));
            exit;
        end;

        if EDITradingPartner."Vendor No." = '' then begin
            EDIErrorHandler.HandleError(EDIMessageHeader, StrSubstNo(NoVendorLbl, EDIMessageHeader."Trading Partner Code"));
            exit;
        end;

        if not Vendor.Get(EDITradingPartner."Vendor No.") then begin
            EDIErrorHandler.HandleError(EDIMessageHeader, StrSubstNo('Vendor %1 not found.', EDITradingPartner."Vendor No."));
            exit;
        end;

        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", Vendor."No.");
        if EDIMessageHeader."Transaction Date" <> 0D then
            PurchaseHeader."Document Date" := EDIMessageHeader."Transaction Date";
        PurchaseHeader."Vendor Order No." := EDIMessageHeader."Message ID";
        PurchaseHeader.Modify(true);

        LineNo := 10000;
        EDIMessageLine.SetRange("Message Entry No.", EDIMessageHeader."Entry No.");
        if EDIMessageLine.FindSet() then
            repeat
                if EDIMessageLine."Item No." <> '' then
                    if Item.Get(EDIMessageLine."Item No.") then begin
                        PurchaseLine.Init();
                        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                        PurchaseLine."Document No." := PurchaseHeader."No.";
                        PurchaseLine."Line No." := LineNo;
                        PurchaseLine.Insert(true);
                        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
                        PurchaseLine.Validate("No.", EDIMessageLine."Item No.");
                        PurchaseLine.Validate(Quantity, EDIMessageLine.Quantity);
                        if EDIMessageLine."Unit of Measure Code" <> '' then
                            PurchaseLine.Validate("Unit of Measure Code", EDIMessageLine."Unit of Measure Code");
                        if EDIMessageLine."Unit Price" <> 0 then
                            PurchaseLine.Validate("Direct Unit Cost", EDIMessageLine."Unit Price");
                        PurchaseLine.Modify(true);
                        LineNo += 10000;
                        EDIMessageLine.Mapped := true;
                        EDIMessageLine.Modify();
                    end;
            until EDIMessageLine.Next() = 0;

        EDIMessageHeader."BC Document No." := PurchaseHeader."No.";
        EDIMessageHeader.Modify();

        EDIProcessor.UpdateMessageStatus(EDIMessageHeader, "EDI Message Status"::Posted);

        LogInfo(EDIMessageHeader."Entry No.", EDIMessageHeader."Trading Partner Code",
            StrSubstNo(POCreatedLbl, PurchaseHeader."No.", EDIMessageHeader."Entry No."));
    end;

    local procedure LogInfo(MessageEntryNo: Integer; TradingPartnerCode: Code[20]; Description: Text)
    var
        EDILogEntry: Record "EDI Log Entry";
    begin
        EDILogEntry.Init();
        EDILogEntry."Message Entry No." := MessageEntryNo;
        EDILogEntry."Trading Partner Code" := TradingPartnerCode;
        EDILogEntry.Description := CopyStr(Description, 1, 2048);
        EDILogEntry."Log Level" := EDILogEntry."Log Level"::Information;
        EDILogEntry."Source Codeunit" := 50103;
        EDILogEntry."Source Procedure" := 'CreateBCDocument';
        EDILogEntry.Insert();
    end;
}
