permissionset 50101 "EDI User"
{
    Caption = 'EDI User';
    Assignable = true;
    Permissions =
        tabledata "EDI Setup" = R,
        tabledata "EDI Trading Partner" = R,
        tabledata "EDI Document Type" = R,
        tabledata "EDI Message Header" = RIM,
        tabledata "EDI Message Line" = RIM,
        tabledata "EDI Field Mapping" = R,
        tabledata "EDI Log Entry" = RI,
        tabledata "EDI Acknowledgment" = RI,
        codeunit "EDI Processor" = X,
        codeunit "EDI X12 Parser" = X,
        codeunit "EDI EDIFACT Parser" = X,
        codeunit "EDI Document Creator" = X,
        codeunit "EDI Outbound Generator" = X,
        codeunit "EDI Communication" = X,
        codeunit "EDI Acknowledgment Mgmt" = X,
        codeunit "EDI Error Handler" = X,
        page "EDI Message List" = X,
        page "EDI Message Card" = X,
        page "EDI Message Lines" = X,
        page "EDI Log Entries" = X,
        page "EDI Acknowledgments" = X,
        report "EDI Message Report" = X;
}
