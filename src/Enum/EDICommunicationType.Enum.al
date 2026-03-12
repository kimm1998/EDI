enum 50104 "EDI Communication Type"
{
    Extensible = true;
    Caption = 'EDI Communication Type';

    value(0; SFTP)
    {
        Caption = 'SFTP';
    }
    value(1; API)
    {
        Caption = 'API';
    }
    value(2; AzureBlob)
    {
        Caption = 'Azure Blob';
    }
    value(3; FileSystem)
    {
        Caption = 'File System';
    }
    value(4; AS2)
    {
        Caption = 'AS2';
    }
}
