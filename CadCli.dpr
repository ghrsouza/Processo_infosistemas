program CadCli;

uses
  Vcl.Forms,
  unCadastro in 'unCadastro.pas' {frmCadCli},
  unServicos in 'unServicos.pas',
  unEnviaEmail in 'unEnviaEmail.pas' {frmEnviaEmail},
  unConsumirServicos in 'unConsumirServicos.pas',
  unEmail in 'unEmail.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmCadCli, frmCadCli);
  Application.Run;
end.
