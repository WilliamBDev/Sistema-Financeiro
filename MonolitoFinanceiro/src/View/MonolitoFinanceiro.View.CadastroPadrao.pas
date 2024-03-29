unit MonolitoFinanceiro.View.CadastroPadrao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, System.ImageList, Vcl.ImgList,
  Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.WinXPanels;

type
  TfrmCadastroPadrao = class(TForm)
    PnlPrincipal: TCardPanel;
    CardCadastro: TCard;
    CardPesquisa: TCard;
    pnlPesquisa: TPanel;
    pnlPesquisaBotoes: TPanel;
    pnlGrid: TPanel;
    dbgCadastro: TDBGrid;
    edtPesquisar: TEdit;
    Label1: TLabel;
    btnPesquisar: TButton;
    ImageList1: TImageList;
    btnFechar: TButton;
    btnExcluir: TButton;
    btnIncluir: TButton;
    btnAlterar: TButton;
    btnImprimir: TButton;
    Panel1: TPanel;
    btnCancelar: TButton;
    btnSalvar: TButton;
    DataSource1: TDataSource;
    procedure btnIncluirClick(Sender: TObject);
    procedure btnAlterarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPesquisarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
  private
    { Private declarations }
    procedure HabilitarBotoes;
    procedure LimparCampos;
  public
    { Public declarations }
  protected
    procedure Pesquisar; virtual;
  end;

var
  frmCadastroPadrao: TfrmCadastroPadrao;

implementation

uses
  Datasnap.DBClient, Vcl.WinXCtrls;

{$R *.dfm}

procedure TfrmCadastroPadrao.btnAlterarClick(Sender: TObject);
begin
  TClientDataSet(DataSource1.DataSet).Edit;
  PnlPrincipal.ActiveCard := cardCadastro;
end;

procedure TfrmCadastroPadrao.btnCancelarClick(Sender: TObject);
begin
   TClientDataSet(DataSource1.DataSet).Cancel;
  PnlPrincipal.ActiveCard := cardPesquisa;
end;

procedure TfrmCadastroPadrao.btnExcluirClick(Sender: TObject);
begin
  if Application.MessageBox('Deseja mesmo excluir o registro?', 'Pergunta', MB_YESNO + MB_ICONQUESTION) <> mrYes then
    exit;
  try
    TClientDataSet(DataSource1.DataSet).Delete;
    TClientDataSet(DataSource1.DataSet).ApplyUpdates(0);
    Application.MessageBox('Registro excluido com sucesso!', 'Aten��o', MB_OK + MB_ICONINFORMATION);
    Pesquisar;
  except on E : Exception do
     Application.MessageBox(PWideChar(E.Message),'Erro ao excliuir Registro', MB_OK + MB_ICONERROR);
  end;
end;

procedure TfrmCadastroPadrao.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadastroPadrao.btnIncluirClick(Sender: TObject);
begin
  LimparCampos;
  PnlPrincipal.ActiveCard := cardCadastro;
  TClientDataSet(DataSource1.DataSet).Insert;
end;

procedure TfrmCadastroPadrao.btnPesquisarClick(Sender: TObject);
begin
  Pesquisar;
end;

procedure TfrmCadastroPadrao.btnSalvarClick(Sender: TObject);
var
  Mensagem: String;
begin
  Mensagem := 'Registro alterado com sucesso!';
  if DataSource1.State in [dsInsert] then
    Mensagem := 'Registro incluido com sucesso!';

  {casthing = transforma o dataset em clientdataset}
  TClientDataSet(DataSource1.DataSet).Post;
  TClientDataSet(DataSource1.DataSet).ApplyUpdates(0);
  Application.MessageBox(PWideChar(Mensagem), 'Aten��o', MB_OK + MB_ICONINFORMATION);

  Pesquisar;
  pnlPrincipal.ActiveCard := cardPesquisa;
end;

procedure TfrmCadastroPadrao.FormShow(Sender: TObject);
begin
  PnlPrincipal.ActiveCard := cardPesquisa;
  Pesquisar;
end;

procedure TfrmCadastroPadrao.HabilitarBotoes;
begin
  btnExcluir.Enabled := not DataSource1.DataSet.IsEmpty;
  btnAlterar.Enabled := not DataSource1.DataSet.IsEmpty;
end;

procedure TfrmCadastroPadrao.LimparCampos;
var
  Contador : Integer;
begin
  for Contador := 0 to Pred(ComponentCount) do
    begin
      if Components[Contador] is TCustomEdit then {TCustomEdit � uma classe ancestral do edit}
        TCustomEdit(Components[Contador]).Clear
      else if Components[Contador] is TToggleSwitch then
        TToggleSwitch(Components[Contador]).State := tssOn
      else if Components[Contador] is TRadioGroup then
        TRadioGroup(Components[Contador]).ItemIndex := -1;
    end;
end;

procedure TfrmCadastroPadrao.Pesquisar;
begin
  HabilitarBotoes;
end;

end.
