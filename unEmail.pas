unit unEmail;

interface

uses SysUtils, IdMessage, IdText, IdAttachmentFile, IdSSLOpenSSL, IdSMTP,
  Classes, IdExplicitTLSClientServerBase;

type
  TEmail = class(TObject)
  private
    fDe: string;
    fPara: string;
    fAssunto: String;
    fSenha: string;
    fCorpo: string;
    fArquivo: string;
    IdSSLIOHandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
    IdSMTP: TIdSMTP;
    IdMessage: TIdMessage;
    IdText: TIdText;
    procedure Configuracoes();
  public
    property De: string read fDe write fDe;
    property Para: string read fPara write fPara;
    property Assunto: string read fPara write fPara;
    property Corpo: string read fCorpo write fCorpo;
    property Senha: string read fSenha write fSenha;
    property CaminhoArquivo: string read fArquivo write fArquivo;

    constructor CreateNew(AOwner: TComponent);
    destructor Destroy; override;

    function EnviarEmail(): string;
end;

implementation

{ TEmail }

procedure TEmail.Configuracoes;
begin
    IdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv23;
    IdSSLIOHandlerSocket.SSLOptions.Mode := sslmClient;

    // Configuração do servidor SMTP (TIdSMTP)
    IdSMTP.IOHandler := IdSSLIOHandlerSocket;
    IdSMTP.UseTLS := utUseImplicitTLS;
    IdSMTP.AuthType := satDefault;
    IdSMTP.Port := 465;
    IdSMTP.Host := 'smtp.gmail.com';
    IdSMTP.Username := fDe;
    IdSMTP.Password := fSenha;

end;

constructor TEmail.CreateNew(AOwner: TComponent);
begin
  inherited;
  IdSSLIOHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  IdSMTP := TIdSMTP.Create(nil);
  IdMessage := TIdMessage.Create(nil);
end;

destructor TEmail.Destroy;
begin
  FreeAndNil(IdSSLIOHandlerSocket);
  FreeAndNil(IdSMTP);
  FreeAndNil(IdMessage);
  inherited;
end;

function TEmail.EnviarEmail: string;
var
  erro: string;
  destinatario: string;
begin
  Result := '';
  erro := '';
  if trim(fDe) = '' then
    erro := '- Não foi informado um e-mail de envio' + #13#10;
  if trim(fPara) = '' then
    erro := '- Não foi informado o destinatário do e-mail ' + #13#10;
  if not FileExists(CaminhoArquivo) then
    erro := '- Arquivo não foi localizado';
  if erro = '' then
  begin
    Configuracoes();
    // Configuração da mensagem (TIdMessage)
    IdMessage.From.Address := fDe;
    IdMessage.ReplyTo.EMailAddresses := IdMessage.From.Address;
    destinatario := trim(fPara);
    while pos(';',destinatario) > 0 do
    begin
      IdMessage.Recipients.Add.Text := copy(destinatario,1,pos(';',destinatario) - 1);
      destinatario := trim(copy(destinatario,pos(';',destinatario) + 1, length(destinatario)));
    end;
    if destinatario <> '' then
      IdMessage.Recipients.Add.Text := destinatario;
    IdMessage.Subject := fAssunto;
    IdMessage.Encoding := meMIME;

    // Configuração do corpo do email (TIdText)
    IdText := TIdText.Create(IdMessage.MessageParts);
    IdText.Body.Add(fCorpo);
    IdText.ContentType := 'text/plain; charset=iso-8859-1';

    // Anexo da mensagem (TIdAttachmentFile)
    TIdAttachmentFile.Create(IdMessage.MessageParts, fArquivo);

    try
     // Conexão e autenticação
      try
        IdSMTP.Connect;
        IdSMTP.Authenticate;
      except
        on E:Exception do
        begin
          Result := '- Erro na conexão ou autenticação: ' + E.Message;
          Exit;
        end;
      end;

      // Envio da mensagem
      try
        IdSMTP.Send(IdMessage);
      except
        On E:Exception do
        begin
          Result := '- Erro ao enviar a mensagem: ' + E.Message;
        end;
      end;
    finally
     // desconecta do servidor
     IdSMTP.Disconnect;
     // liberação da DLL
     UnLoadOpenSSLLibrary;
    end;
  end else
    Result := erro;
end;

end.
