codeunit 50108 "EDI Event Subscribers"
{
    Caption = 'EDI Event Subscribers';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        EDIOutboundGenerator: Codeunit "EDI Outbound Generator";
        Customer: Record Customer;
    begin
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit;
        if not Customer."EDI Enabled" then
            exit;

        if SalesInvHdrNo <> '' then
            if SalesInvoiceHeader.Get(SalesInvHdrNo) then begin
                case Customer."EDI Standard" of
                    "EDI Standard"::X12:
                        EDIOutboundGenerator.GenerateX12_810(SalesInvoiceHeader);
                    "EDI Standard"::EDIFACT:
                        EDIOutboundGenerator.GenerateEDIFACT_INVOIC(SalesInvoiceHeader);
                end;
            end;

        if SalesShptHdrNo <> '' then
            if SalesShipmentHeader.Get(SalesShptHdrNo) then begin
                case Customer."EDI Standard" of
                    "EDI Standard"::X12:
                        EDIOutboundGenerator.GenerateX12_856(SalesShipmentHeader);
                    "EDI Standard"::EDIFACT:
                        EDIOutboundGenerator.GenerateEDIFACT_DESADV(SalesShipmentHeader);
                end;
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', false, false)]
    local procedure OnAfterReleaseSalesDocument(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var LinesWereModified: Boolean)
    var
        EDIAcknowledgmentMgmt: Codeunit "EDI Acknowledgment Mgmt";
        EDIMessageHeader: Record "EDI Message Header";
        Customer: Record Customer;
    begin
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit;
        if not Customer."EDI Enabled" then
            exit;

        // Look for pending inbound EDI message related to this sales order
        EDIMessageHeader.SetRange("BC Document No.", SalesHeader."No.");
        EDIMessageHeader.SetRange("Direction", "EDI Direction"::Inbound);
        if EDIMessageHeader.FindFirst() then begin
            // Generate acknowledgment if needed
            if EDIMessageHeader."Acknowledgment Status" = EDIMessageHeader."Acknowledgment Status"::Pending then
                case Customer."EDI Standard" of
                    "EDI Standard"::X12:
                        EDIAcknowledgmentMgmt.GenerateX12_997(EDIMessageHeader);
                    "EDI Standard"::EDIFACT:
                        EDIAcknowledgmentMgmt.GenerateEDIFACT_CONTRL(EDIMessageHeader);
                end;
        end;
    end;
}
