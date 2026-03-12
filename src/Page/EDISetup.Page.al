page 50100 "EDI Setup"
{
    Caption = 'EDI Setup';
    PageType = Card;
    SourceTable = "EDI Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Default EDI Standard"; Rec."Default EDI Standard")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default EDI standard to use (X12 or EDIFACT).';
                }
                field("Default Communication Type"; Rec."Default Communication Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default communication method for file transfer.';
                }
                field("Enable Logging"; Rec."Enable Logging")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to enable detailed logging for EDI processing.';
                }
            }
            group(Communication)
            {
                Caption = 'Communication';
                group(FileSystem)
                {
                    Caption = 'File System';
                    field("Inbound Folder Path"; Rec."Inbound Folder Path")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the folder path for incoming EDI files.';
                    }
                    field("Outbound Folder Path"; Rec."Outbound Folder Path")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the folder path for outgoing EDI files.';
                    }
                    field("Archive Folder Path"; Rec."Archive Folder Path")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the folder path for archiving processed EDI files.';
                    }
                    field("Error Folder Path"; Rec."Error Folder Path")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the folder path for EDI files that failed processing.';
                    }
                }
                group(SFTP)
                {
                    Caption = 'SFTP';
                    field("SFTP Host"; Rec."SFTP Host")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the SFTP server hostname or IP address.';
                    }
                    field("SFTP Port"; Rec."SFTP Port")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the SFTP server port (default: 22).';
                    }
                    field("SFTP Username"; Rec."SFTP Username")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the username for SFTP authentication.';
                    }
                    field("SFTP Password"; Rec."SFTP Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the password for SFTP authentication.';
                    }
                }
                group(API)
                {
                    Caption = 'API';
                    field("API Base URL"; Rec."API Base URL")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the base URL for the EDI API endpoint.';
                    }
                    field("API Key"; Rec."API Key")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the API key for authentication.';
                    }
                }
                group(AzureBlob)
                {
                    Caption = 'Azure Blob Storage';
                    field("Azure Storage Account"; Rec."Azure Storage Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Azure Storage account name.';
                    }
                    field("Azure Container"; Rec."Azure Container")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Azure Blob container name.';
                    }
                    field("Azure Access Key"; Rec."Azure Access Key")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Azure Storage access key.';
                    }
                }
            }
            group(X12Settings)
            {
                Caption = 'X12';
                field("ISA Sender ID"; Rec."ISA Sender ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ISA Sender ID used in X12 interchange headers.';
                }
                field("ISA Receiver ID"; Rec."ISA Receiver ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ISA Receiver ID used in X12 interchange headers.';
                }
                field("Segment Terminator"; Rec."Segment Terminator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the character used to terminate X12 segments (default: ~).';
                }
                field("Element Separator"; Rec."Element Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the character used to separate X12 elements (default: *).';
                }
                field("Sub-Element Separator"; Rec."Sub-Element Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the character used to separate X12 sub-elements (default: :).';
                }
            }
            group(EDIFACTSettings)
            {
                Caption = 'EDIFACT';
                field("UNB Sender ID"; Rec."UNB Sender ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the UNB Sender ID used in EDIFACT interchange headers.';
                }
                field("UNB Receiver ID"; Rec."UNB Receiver ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the UNB Receiver ID used in EDIFACT interchange headers.';
                }
            }
            group(Automation)
            {
                Caption = 'Automation';
                field("Auto Process Inbound"; Rec."Auto Process Inbound")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to automatically process inbound EDI messages.';
                }
                field("Auto Send Outbound"; Rec."Auto Send Outbound")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to automatically send outbound EDI messages.';
                }
                field("Job Queue Interval (Min)"; Rec."Job Queue Interval (Min)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the job queue processing interval in minutes.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                Caption = 'Test Connection';
                ApplicationArea = All;
                Image = TestFile;
                ToolTip = 'Tests the current communication connection settings.';

                trigger OnAction()
                var
                    EDICommunication: Codeunit "EDI Communication";
                    ConnectedLbl: Label 'Connection test successful.';
                    FailedLbl: Label 'Connection test failed. Please check your settings.';
                begin
                    if EDICommunication.TestConnection() then
                        Message(ConnectedLbl)
                    else
                        Message(FailedLbl);
                end;
            }
            action(InitializeSetup)
            {
                Caption = 'Initialize Setup';
                ApplicationArea = All;
                Image = Setup;
                ToolTip = 'Initializes the EDI setup with default values.';

                trigger OnAction()
                var
                    InitLbl: Label 'EDI Setup has been initialized with default values.';
                begin
                    Rec.GetSetup();
                    Message(InitLbl);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}
