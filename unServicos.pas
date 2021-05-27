unit unServicos;

interface

uses Classes, System.JSON, SysUtils, XMLDoc, XMLIntf, unConsumirServicos;

type
  TCliente = class(TObject)
  private
    fNome: string;
    fIdentidade: string;
    fCPF: string;
    fTelefone: string;
    fEmail: string;
    fCep: string;
    fLogradouro: string;
    fNumero: string;
    fComplemento: string;
    fBairro: string;
    fCidade: string;
    fEstado: string;
    fPais: string;
  public
    property Nome: string read fNome write fNome;
    property Identidade: string read fIdentidade write fIdentidade;
    property CPF: string read fCPF write fCPF;
    property Telefone: string read fTelefone write fTelefone;
    property Email: string read fEmail write fEmail;
    property Cep: string read fCep write fCep;
    property Logradouro: string read fLogradouro write fLogradouro;
    property Numero: string read fNumero write fNumero;
    property Complemento: string read fComplemento write fComplemento;
    property Bairro: string read fBairro write fBairro;
    property Cidade: string read fCidade write fCidade;
    property Estado: string read fEstado write fEstado;
    property Pais: string read fPais write fPais;

end;

type
  TArquivoHTML = class(TObject)
  private
    XMLDocument: TXMLDocument;
    NodeTabela, NodeRegistro, NodeEndereco: IXMLNode;
    fRegistros: integer;
  public
    property TotalRegistros: integer read fRegistros;
    constructor CreateNew(AOwner: TComponent);
    destructor Destroy; override;
    procedure AdicionarCliente(cliente: TCliente);
    function GerarArquivo(): string;

end;

type
  TServicos = class(TObject)
  private
  public
    class function ConsultaCEP(cep: string): TJSONObject;
    class function ValidarEMail(emails: string): Boolean; static;
end;

implementation

{ TServicos }

class function TServicos.ConsultaCEP(cep: string): TJSONObject;
var
  url: string;
begin
  url := 'http://viacep.com.br/ws/' + StringReplace(cep,'-','',[rfReplaceAll]) + '/json/';
  Result := TConsumirServico.Consumir(url);
end;

class function TServicos.ValidarEMail(emails: string): Boolean;
var
  email: string;
begin
  Result := True;
  emails := Trim(UpperCase(emails));
  if emails = '' then
    Abort();

  if (pos(';',emails) = 0) or (copy(emails,length(emails),1) <> ';') then
    emails := emails + ';';

  email := trim(copy(emails,1,pos(';',emails) - 1));
  emails := copy(emails,pos(';',emails) + 1, length(emails));

  repeat

    if Pos('@', email) > 1 then
    begin
      Delete(email, 1, pos('@', email));
      Result := (Length(email) > 0) and (Pos('.', email) > 2);
    end else
      Result := False;

    if emails = '' then
      email := ''
    else
    begin
      email := trim(copy(emails,1,pos(';',emails) - 1));
      emails := copy(emails,pos(';',emails) + 1, length(emails));
    end;
  until ((email = '') or (Result = False));
end;

{ TCliente }

procedure TArquivoHTML.AdicionarCliente(cliente: TCliente);
begin

  NodeRegistro := NodeTabela.AddChild('Cliente');
  NodeRegistro.ChildValues['Nome'] := cliente.Nome;
  NodeRegistro.ChildValues['Identidade'] := cliente.Identidade;
  NodeRegistro.ChildValues['CPF'] := cliente.CPF;
  NodeRegistro.ChildValues['Telefone'] := cliente.Telefone;
  NodeRegistro.ChildValues['Email'] := cliente.Email;
  NodeEndereco := NodeRegistro.AddChild('Endereco');
  NodeEndereco.ChildValues['Cep'] := cliente.Cep;
  NodeEndereco.ChildValues['Logradouro'] := cliente.Logradouro;
  NodeEndereco.ChildValues['Numero'] := cliente.Numero;
  NodeEndereco.ChildValues['Complemento'] := cliente.Complemento;
  NodeEndereco.ChildValues['Bairro'] := cliente.Bairro;
  NodeEndereco.ChildValues['Cidade'] := cliente.Cidade;
  NodeEndereco.ChildValues['Estado'] := cliente.Estado;
  NodeEndereco.ChildValues['Pais'] := cliente.Pais;
  inc(fRegistros);
end;

constructor TArquivoHTML.CreateNew(AOwner: TComponent);
begin
  inherited;
  XMLDocument := TXMLDocument.Create(nil);
  XMLDocument.Active := True;
  NodeTabela := XMLDocument.AddChild('Clientes');
  fRegistros := 0;
end;

destructor TArquivoHTML.Destroy;
begin
  XMLDocument.Free;
  inherited;
end;

function TArquivoHTML.GerarArquivo: string;
begin
  Result := 'c:\windows\temp\ClientesCadastrados.html';
  XMLDocument.SaveToFile(Result);
end;

end.
