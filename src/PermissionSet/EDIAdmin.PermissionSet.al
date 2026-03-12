permissionset 50100 "EDI Admin"
{
    Caption = 'EDI Administrator';
    Assignable = true;
    Permissions =
        tabledata "EDI Setup" = RIMD,
        tabledata "EDI Trading Partner" = RIMD,
        tabledata "EDI Document Type" = RIMD,
        tabledata "EDI Message Header" = RIMD,
        tabledata "EDI Message Line" = RIMD,
        tabledata "EDI Field Mapping" = RIMD,
        tabledata "EDI Log Entry" = RIMD,
        tabledata "EDI Acknowledgment" = RIMD,
        codeunit "EDI Processor" = X,
        codeunit "EDI X12 Parser" = X,
        codeunit "EDI EDIFACT Parser" = X,
        codeunit "EDI Document Creator" = X,
        codeunit "EDI Outbound Generator" = X,
        codeunit "EDI Communication" = X,
        codeunit "EDI Acknowledgment Mgmt" = X,
        codeunit "EDI Error Handler" = X,
        codeunit "EDI Event Subscribers" = X,
        page "EDI Setup" = X,
        page "EDI Trading Partners" = X,
        page "EDI Trading Partner Card" = X,
        page "EDI Document Types" = X,
        page "EDI Message List" = X,
        page "EDI Message Card" = X,
        page "EDI Message Lines" = X,
        page "EDI Field Mappings" = X,
        page "EDI Log Entries" = X,
        page "EDI Acknowledgments" = X,
        report "EDI Message Report" = X,
        xmlport "EDI Import/Export" = X;
}
