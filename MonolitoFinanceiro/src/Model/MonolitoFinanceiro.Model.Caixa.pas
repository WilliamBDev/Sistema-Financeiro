unit MonolitoFinanceiro.Model.Caixa;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Datasnap.Provider,
  Data.DB, Datasnap.DBClient, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  MonolitoFinanceiro.Model.Entidades.Caixa.Resumo;

type
  TdmCaixa = class(TDataModule)
    fdqCaixa: TFDQuery;
    cdsCaixa: TClientDataSet;
    dspCaixa: TDataSetProvider;
    cdsCaixaNUMERO_DOC: TStringField;
    cdsCaixaDESCRICAO: TStringField;
    cdsCaixaVALOR: TFMTBCDField;
    cdsCaixaTIPO: TStringField;
    cdsCaixaID: TStringField;
    cdsCaixaDATA_CADASTRO: TDateField;
  private
    { Private declarations }
    Function GetSaldoAnterior(Data: TDate) : Currency;
    Function GetTotalEntradasCaixa(DataInicial, DataFinal: TDate) : Currency;
    Function GetTotalSaidasCaixa(DataInicial, DataFinal: TDate) : Currency;
  public
    { Public declarations }
    function ResumoCaixa(DataInicial, DataFinal: TDate) : TModelResumoCaixa;
  end;

var
  dmCaixa: TdmCaixa;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses MonolitoFinanceiro.Model.Conexao;

{$R *.dfm}

{ TdmCaixa }

function TdmCaixa.GetSaldoAnterior(Data: TDate): Currency;
var
  SQLConsulta : TFDQuery;
  TotalEntradas : Currency;
  TotalSaidas : Currency;
begin
Result := 0;
  SQLConsulta := TFDQuery.Create(nil);
  try
    SQLConsulta.Connection := dmConexao.FDConexao;
    SQLConsulta.SQL.Clear;
    SQLConsulta.SQL.Add('SELECT COALESCE(SUM(VALOR), 0) AS VALOR FROM CAIXA WHERE TIPO = ''R''');
    SQLConsulta.SQL.Add('AND DATA_CADASTRO < :DATA');
    SQLConsulta.ParamByName('DATA').AsDate := Data;
    SQLConsulta.Open;
    TotalEntradas :=  SQLConsulta.FieldByName('VALOR').AsCurrency;

    SQLConsulta.SQL.Clear;
    SQLConsulta.SQL.Add('SELECT COALESCE(SUM(VALOR), 0) AS VALOR FROM CAIXA WHERE TIPO = ''D''');
    SQLConsulta.SQL.Add('AND DATA_CADASTRO < :DATA');
    SQLConsulta.ParamByName('DATA').AsDate := Data;
    SQLConsulta.Open;
    TotalSaidas :=  SQLConsulta.FieldByName('VALOR').AsCurrency;
  finally
    SQLConsulta.Free;
  end;
  Result:= Totalentradas - TotalSaidas;
end;

function TdmCaixa.GetTotalEntradasCaixa(DataInicial,
  DataFinal: TDate): Currency;
var
  SQLConsulta : TFDQuery;
begin
  Result := 0;
  SQLConsulta := TFDQuery.Create(nil);
  try
    SQLConsulta.Connection := dmConexao.FDConexao;
    SQLConsulta.SQL.Clear;
    SQLConsulta.SQL.Add('SELECT COALESCE(SUM(VALOR), 0) AS VALOR FROM CAIXA WHERE TIPO = ''R''');
    SQLConsulta.SQL.Add('AND DATA_CADASTRO BETWEEN :DATAINICIAL AND :DATAFINAL');
    SQLConsulta.ParamByName('DATAINICIAL').AsDate := DataInicial;
    SQLConsulta.ParamByName('DATAFINAL').AsDate := DataFinal;
    SQLConsulta.Open;
    Result := SQLConsulta.FieldByName('VALOR').AsCurrency;
  finally
    SQLConsulta.Free;
  end;
end;

function TdmCaixa.GetTotalSaidasCaixa(DataInicial, DataFinal: TDate): Currency;
var
  SQLConsulta : TFDQuery;
begin
  Result := 0;
  SQLConsulta := TFDQuery.Create(nil);
  try
    SQLConsulta.Connection := dmConexao.FDConexao;
    SQLConsulta.SQL.Clear;
    SQLConsulta.SQL.Add('SELECT COALESCE(SUM(VALOR), 0) AS VALOR FROM CAIXA WHERE TIPO = ''D''');
    SQLConsulta.SQL.Add('AND DATA_CADASTRO BETWEEN :DATAINICIAL AND :DATAFINAL');
    SQLConsulta.ParamByName('DATAINICIAL').AsDate := DataInicial;
    SQLConsulta.ParamByName('DATAFINAL').AsDate := DataFinal;
    SQLConsulta.Open;
    Result := SQLConsulta.FieldByName('VALOR').AsCurrency;
  finally
    SQLConsulta.Free;
  end;
end;

function TdmCaixa.ResumoCaixa(DataInicial, DataFinal: TDate): TModelResumoCaixa;
begin
  if DataInicial > DataFinal then
    raise Exception.Create('Per�odo Inv�lido');

  Result := TModelResumoCaixa.Create;
  try
    Result.SaldoInicial := GetSaldoAnterior(DataInicial);
    Result.TotalEntradas := GetTotalEntradasCaixa(DataInicial, DataFinal);
    Result.TotalSaidas := GetTotalSaidasCaixa(DataInicial, DataFinal);
  Except
    Result.Free;
    raise
  end;
end;

end.
