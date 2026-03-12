table 50100 "EDI Setup"
{
    Caption = 'EDI Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Default EDI Standard"; Enum "EDI Standard")
        {
            Caption = 'Default EDI Standard';
            DataClassification = CustomerContent;
        }
        field(3; "Default Communication Type"; Enum "EDI Communication Type")
        {
            Caption = 'Default Communication Type';
            DataClassification = CustomerContent;
        }
        field(4; "Inbound Folder Path"; Text[250])
        {
            Caption = 'Inbound Folder Path';
            DataClassification = CustomerContent;
        }
        field(5; "Outbound Folder Path"; Text[250])
        {
            Caption = 'Outbound Folder Path';
            DataClassification = CustomerContent;
        }
        field(6; "Archive Folder Path"; Text[250])
        {
            Caption = 'Archive Folder Path';
            DataClassification = CustomerContent;
        }
        field(7; "Error Folder Path"; Text[250])
        {
            Caption = 'Error Folder Path';
            DataClassification = CustomerContent;
        }
        field(10; "SFTP Host"; Text[250])
        {
            Caption = 'SFTP Host';
            DataClassification = CustomerContent;
        }
        field(11; "SFTP Port"; Integer)
        {
            Caption = 'SFTP Port';
            DataClassification = CustomerContent;
            InitValue = 22;
        }
        field(12; "SFTP Username"; Text[100])
        {
            Caption = 'SFTP Username';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "SFTP Password"; Text[250])
        {
            Caption = 'SFTP Password';
            DataClassification = EndUserPseudonymousIdentifiers;
            ExtendedDatatype = Masked;
        }
        field(20; "API Base URL"; Text[250])
        {
            Caption = 'API Base URL';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
        field(21; "API Key"; Text[250])
        {
            Caption = 'API Key';
            DataClassification = EndUserPseudonymousIdentifiers;
            ExtendedDatatype = Masked;
        }
        field(30; "Azure Storage Account"; Text[100])
        {
            Caption = 'Azure Storage Account';
            DataClassification = CustomerContent;
        }
        field(31; "Azure Container"; Text[100])
        {
            Caption = 'Azure Container';
            DataClassification = CustomerContent;
        }
        field(32; "Azure Access Key"; Text[500])
        {
            Caption = 'Azure Access Key';
            DataClassification = EndUserPseudonymousIdentifiers;
            ExtendedDatatype = Masked;
        }
        field(40; "Auto Process Inbound"; Boolean)
        {
            Caption = 'Auto Process Inbound';
            DataClassification = CustomerContent;
        }
        field(41; "Auto Send Outbound"; Boolean)
        {
            Caption = 'Auto Send Outbound';
            DataClassification = CustomerContent;
        }
        field(42; "Enable Logging"; Boolean)
        {
            Caption = 'Enable Logging';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(50; "ISA Sender ID"; Code[15])
        {
            Caption = 'ISA Sender ID';
            DataClassification = CustomerContent;
        }
        field(51; "ISA Receiver ID"; Code[15])
        {
            Caption = 'ISA Receiver ID';
            DataClassification = CustomerContent;
        }
        field(52; "UNB Sender ID"; Text[35])
        {
            Caption = 'UNB Sender ID';
            DataClassification = CustomerContent;
        }
        field(53; "UNB Receiver ID"; Text[35])
        {
            Caption = 'UNB Receiver ID';
            DataClassification = CustomerContent;
        }
        field(60; "Segment Terminator"; Code[1])
        {
            Caption = 'Segment Terminator';
            DataClassification = CustomerContent;
            InitValue = '~';
        }
        field(61; "Element Separator"; Code[1])
        {
            Caption = 'Element Separator';
            DataClassification = CustomerContent;
            InitValue = '*';
        }
        field(62; "Sub-Element Separator"; Code[1])
        {
            Caption = 'Sub-Element Separator';
            DataClassification = CustomerContent;
            InitValue = ':';
        }
        field(70; "Job Queue Interval (Min)"; Integer)
        {
            Caption = 'Job Queue Interval (Min)';
            DataClassification = CustomerContent;
            InitValue = 15;
            MinValue = 1;
        }
        field(80; "Last Message Entry No."; Integer)
        {
            Caption = 'Last Message Entry No.';
            DataClassification = CustomerContent;
        }
        field(81; "Last Log Entry No."; Integer)
        {
            Caption = 'Last Log Entry No.';
            DataClassification = CustomerContent;
        }
        field(82; "Last Ack Entry No."; Integer)
        {
            Caption = 'Last Ack Entry No.';
            DataClassification = CustomerContent;
        }
        field(83; "Last Control No."; Integer)
        {
            Caption = 'Last Control No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup(): Boolean
    begin
        if not Get('') then begin
            Init();
            "Primary Key" := '';
            Insert();
        end;
        exit(true);
    end;

    procedure GetNextControlNo(): Integer
    var
        LockedSetup: Record "EDI Setup";
    begin
        LockedSetup.LockTable();
        LockedSetup.GetSetup();
        LockedSetup."Last Control No." += 1;
        LockedSetup.Modify();
        exit(LockedSetup."Last Control No.");
    end;
}
