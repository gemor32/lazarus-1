{ JSON data viewer main form

  Copyright (C) 2010 Michael Van Canneyt michael@freepascal.org

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
  Boston, MA 02110-1335, USA.
}

unit frmmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpJSON, jsonscanner, JSONParser,
  Forms, Controls, Dialogs, ActnList, Menus, ComCtrls, IniPropStorage, PropertyStorage,
  DefaultTranslator;

type

  { TMainForm }

  TMainForm = class(TForm)
    ACopy: TAction;
    AFindNext: TAction;
    AFind: TAction;
    AExpandCurrentContainer: TAction;
    AExpandAll: TAction;
    APasteAsDocument: TAction;
    APaste: TAction;
    ACut: TAction;
    ADeleteValue: TAction;
    ANewBooleanValue: TAction;
    ANewNullValue: TAction;
    ANewNumberValue: TAction;
    ANewStringValue: TAction;
    ANewObject: TAction;
    ANewArray: TAction;
    AQuit: TAction;
    ASaveAs: TAction;
    ASave: TAction;
    AOpen: TAction;
    ANew: TAction;
    ALJSON: TActionList;
    FDJSON: TFindDialog;
    ILJSON: TImageList;
    MEDit: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem9: TMenuItem;
    MIQuoteStrings: TMenuItem;
    MIAllowTrailingComma: TMenuItem;
    MIAllowComments: TMenuItem;
    MICompact: TMenuItem;
    MIFInd: TMenuItem;
    MIExpandCurrent: TMenuItem;
    MIExpandAll: TMenuItem;
    MIPasteAsDocument: TMenuItem;
    MIpaste: TMenuItem;
    MICut: TMenuItem;
    MICopy: TMenuItem;
    MISortMembers: TMenuItem;
    MenuItem8: TMenuItem;
    MIDelete: TMenuItem;
    PMTreeView: TPopupMenu;
    PSMain: TIniPropStorage;
    MenuItem1: TMenuItem;
    MINewNull: TMenuItem;
    MINewNumber: TMenuItem;
    MINewBoolean: TMenuItem;
    MINewString: TMenuItem;
    MINewArray: TMenuItem;
    MINewObject: TMenuItem;
    MIdocument: TMenuItem;
    MIStrict: TMenuItem;
    MOptions: TMenuItem;
    MIInsert: TMenuItem;
    MIQuit: TMenuItem;
    MISaveAs: TMenuItem;
    MISave: TMenuItem;
    MIOpen: TMenuItem;
    MINew: TMenuItem;
    MFile: TMenuItem;
    MMJSON: TMainMenu;
    ODJSON: TOpenDialog;
    SDJSON: TSaveDialog;
    TBJSON: TToolBar;
    TBNew: TToolButton;
    TBNewButton: TToolButton;
    TBOpen: TToolButton;
    TBSave: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    TBNEwNull: TToolButton;
    TBNewBoolean: TToolButton;
    TBNewNumber: TToolButton;
    TBNewString: TToolButton;
    TBNewArray: TToolButton;
    TVJSON: TTreeView;
    procedure ACopyExecute(Sender: TObject);
    procedure ACopyUpdate(Sender: TObject);
    procedure ACutExecute(Sender: TObject);
    procedure ACutUpdate(Sender: TObject);
    procedure ADeleteValueExecute(Sender: TObject);
    procedure ADeleteValueUpdate(Sender: TObject);
    procedure AExpandAllExecute(Sender: TObject);
    procedure AExpandAllUpdate(Sender: TObject);
    procedure AExpandCurrentContainerExecute(Sender: TObject);
    procedure AExpandCurrentContainerUpdate(Sender: TObject);
    procedure AFindExecute(Sender: TObject);
    procedure AFindNextExecute(Sender: TObject);
    procedure AFindNextUpdate(Sender: TObject);
    procedure ANewArrayExecute(Sender: TObject);
    procedure ANewBooleanValueExecute(Sender: TObject);
    procedure ANewNullValueExecute(Sender: TObject);
    procedure ANewNumberValueExecute(Sender: TObject);
    procedure ANewObjectExecute(Sender: TObject);
    procedure ANewStringValueExecute(Sender: TObject);
    procedure APasteAsDocumentExecute(Sender: TObject);
    procedure APasteExecute(Sender: TObject);
    procedure APasteUpdate(Sender: TObject);
    procedure AQuitExecute(Sender: TObject);
    procedure ASaveExecute(Sender: TObject);
    procedure ContainerAvailable(Sender: TObject);
    procedure ANewExecute(Sender: TObject);
    procedure AOpenExecute(Sender: TObject);
    procedure FDJSONFind(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HaveData(Sender: TObject);
    procedure MIAllowTrailingCommaClick(Sender: TObject);
    procedure MIAllowCommentsClick(Sender: TObject);
    procedure MICompactClick(Sender: TObject);
    procedure MIdocumentClick(Sender: TObject);
    procedure MIQuoteStringsClick(Sender: TObject);
    procedure MISortMembersClick(Sender: TObject);
    procedure MIStrictClick(Sender: TObject);
    procedure PSMainStoredValues0Restore(Sender: TStoredValue;
      var Value: TStoredType);
    procedure PSMainStoredValues1Restore(Sender: TStoredValue;
      var Value: TStoredType);
    procedure PSMainStoredValues2Restore(Sender: TStoredValue;
      var Value: TStoredType);
    procedure PSMainStoredValues3Restore(Sender: TStoredValue;
      var Value: TStoredType);
    procedure PSMainStoredValues6Restore(Sender: TStoredValue;
      var Value: TStoredType);
    procedure TVJSONEdited(Sender: TObject; Node: TTreeNode; var S: string);
    procedure TVJSONEditing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
  private
    FRoot : TJSONData;
    FFileName : String;
{$IF FPC_FULLVERSION>=30002}
    FOptions : TJSONOptions;
{$ELSE}
    FStrict,
{$ENDIF}
    FQuoteStrings,
    FSortObjectMembers,
    FNewObject,
    FCompact,
    FModified : Boolean;
    FCurrentFind : TTreeNode;
    procedure AddDataToContainer(const AMemberName: String; D: TJSONData);
    procedure CopyCurrentData;
    procedure DeleteCurrentValue;
    function FindNode(Start: TTreeNode; const AText: String;
      CaseInsensitive: Boolean; WholeWord: Boolean): TTreeNode;
    function GetNextSearchNode(Anode: TTreeNode): TTreeNode;
    procedure Modify;
    procedure AddNewValue(AType: TJSONType);
    function CurrentNode: TTreeNode;
    function CurrentNodeType : TJSONType;
    function CurrentData: TJSONData;
    function CurrentContainerNode: TTreeNode;
    function CurrentContainertype: TJSONtype;
    Function CurrentContainer: TJSONData;
    function FindContainerNode(AStart: TTreeNode): TTreeNode;
    function GetSaveFileName(Force: Boolean): String;
    function IsContainerNode(ANode: TTreeNode): Boolean;
    procedure NewDocument;
    procedure OpenFile(const AFileName: String);
    procedure PasteJSON(DoClear: Boolean);
    procedure SaveToFile(const AFileName: string);
    procedure SetCaption;
    procedure ShowJSONData(AParent: TTreeNode; Data: TJSONData);
    procedure ShowJSONDocument;
    {$IF FPC_FULLVERSION>=30002}
    procedure ToggleOption(O: TJSONOption; Enable: Boolean);
    {$ENDIF}
  public

  end; 

var
  MainForm: TMainForm;

implementation

uses
  typinfo,msgjsonviewer, lcltype, frmNewBoolean, frmNewINteger, frmNewString, clipbrd;

{$R *.lfm}
Const
  ImageTypeMap : Array[TJSONtype] of Integer =
//      jtUnknown, jtNumber, jtString, jtBoolean, jtNull, jtArray, jtObject
     (-1,8,9,7,6,5,4);
  JSONTypeNames : Array[TJSONtype] of string =
     ('Unknown','Number','String','Boolean','Null','Array','Object');

{ TMainForm }
{$IF FPC_FULLVERSION>=30002}
procedure TMainForm.ToggleOption(O : TJSONOption; Enable : Boolean);
Var
  S : String;
begin
  if Enable then
    Include(Foptions,O)
  else
    Exclude(Foptions,O);
  S:=GetEnumName(TypeInfo(TJSONOption),Ord(O));
  Delete(S,1,2);
  PSMain.StoredValue[S]:=IntToStr(Ord(Enable));
end;
{$ENDIF}

procedure TMainForm.MIStrictClick(Sender: TObject);
begin
{$IF FPC_FULLVERSION>=30002}
  ToggleOption(joStrict,(Sender as TMenuItem).Checked);
{$ELSE}
  FStrict:=(Sender as TMenuItem).Checked;
  PSMain.StoredValue['strict']:=IntToStr(Ord(Fstrict));
{$ENDIF}
end;

procedure TMainForm.PSMainStoredValues0Restore(Sender: TStoredValue;
  var Value: TStoredType);

{$IF FPC_FULLVERSION>=30002}
Var
  S : String;
  o : integer;
  JO : TJSONOption;
{$ENDIF}
begin
  {$IF FPC_FULLVERSION>=30002}
  S:=Sender.Name;
  O:=GetEnumValue(TypeInfo(TJSONOption),'jo'+S);
  if O<>-1 then
    begin
    JO:=TJSONOption(O);
    if StrToIntDef(Value,0)=1 then
        Include(Foptions,JO)
      else
        Exclude(Foptions,JO);
    end;
  {$ELSE}
  FStrict:=StrToIntDef(Value,0)=1
  {$ENDIF}
end;

procedure TMainForm.PSMainStoredValues1Restore(Sender: TStoredValue;
  var Value: TStoredType);
begin
  FNewObject:=StrToIntDef(Value,0)=1
end;

procedure TMainForm.PSMainStoredValues2Restore(Sender: TStoredValue;
  var Value: TStoredType);
begin
  FSortObjectMembers:=StrToIntDef(Value,0)=1;
end;

procedure TMainForm.PSMainStoredValues3Restore(Sender: TStoredValue;
  var Value: TStoredType);
begin
  FCompact:=StrToIntDef(Value,0)=1;
end;

procedure TMainForm.PSMainStoredValues6Restore(Sender: TStoredValue;
  var Value: TStoredType);
begin
  FQuoteStrings:=StrToIntDef(Value,0)=1;
end;

procedure TMainForm.TVJSONEdited(Sender: TObject; Node: TTreeNode; var S: string);

Var
  D : TJSONData;
  O : TJSONObject;
  L,I : Integer;

begin
  D:=CurrentData;
  If (Node.Data=Nil) then
    begin
    // Member name change
    O:=CurrentContainer as TJSONObject;
    I:=O.IndexOfName(S);
    If (I=-1) then
      begin
      I:=O.IndexOf(D);
      O.Extract(I);
      O.Add(S,D);
      end
    else
      begin
      if (O.Items[i]<>D) then
        begin
        ShowMessage(Format(SDuplicateMemberName,[S]));
        S:=O.Names[I];
        end
      end;
    end
  else
    begin
    // value change
    try
      L:=Length(S);
      if FQuoteStrings and (L>=2) and (S[1]='"') and (S[L]='"') then
        D.AsString:=Copy(S,2,L-2)
      else
        D.AsString:=S;
    except
      ShowMessage(Format(SErrInvalidValue,[S]));
      S:=D.AsString;
    end
    end;
  Modify;
end;

procedure TMainForm.TVJSONEditing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);

begin
  if (Node.Data=Nil) then
    // Label node. Allow member name change for objects
    AllowEdit:=(CurrentContainerType=jtObject)
  else
    // value node. Allow change for simple not null values
    AllowEdit:=Not (CurrentNodeType in [jtNull,jtArray,jtObject]);
end;

procedure TMainForm.Modify;
begin
  FModified:=True;
  SetCaption;
end;

procedure TMainForm.SetCaption;

Var
  FN : String;

begin
  If (FFileName='') then
    FN:=SEmpty
  else
    FN:=FFileName;
  If FModified then
    FN:=FN+' *';
  Caption:=SCaption+' ['+FN+']';
end;

procedure TMainForm.ANewExecute(Sender: TObject);
begin
  NewDocument;
end;

procedure TMainForm.NewDocument;

begin
  FreeAndNil(FRoot);
  If FNewObject then
    FRoot:=TJSONObject.Create;
  ShowJSONDocument;
  FFileName:='';
  SetCaption;
end;

procedure TMainForm.ContainerAvailable(Sender: TObject);

begin
  (Sender as Taction).Enabled:=(TVJSON.Items.Count=0) or (Nil<>CurrentContainer) ;
end;

procedure TMainForm.ASaveExecute(Sender: TObject);

Var
  S : String;

begin
  S:=GetSaveFileName(Sender=ASaveAs);
  If (S<>'') then
    SaveToFile(S);
end;

procedure TMainForm.AQuitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.ANewNullValueExecute(Sender: TObject);
begin
  AddNewValue(jtNull);
end;

procedure TMainForm.ANewArrayExecute(Sender: TObject);
begin
  AddNewValue(jtArray);
end;

procedure TMainForm.ADeleteValueUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:=(CurrentNodeType<>jtUnknown)
end;

procedure TMainForm.AExpandAllExecute(Sender: TObject);
begin
  With TVJSON do
    if (Items.Count>0) then
      Items[0].Expand(True);
end;

procedure TMainForm.AExpandAllUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:=Assigned(FRoot);
end;

procedure TMainForm.AExpandCurrentContainerExecute(Sender: TObject);

Var
  N : TTreeNode;

begin
  N:=CurrentContainerNode;
  If Assigned(N) then
    N.Expand(True);
end;

procedure TMainForm.AExpandCurrentContainerUpdate(Sender: TObject);
begin
  (Sender as TACtion).Enabled:=(CurrentContainerType<>jtUnknown)
end;

procedure TMainForm.AFindExecute(Sender: TObject);
begin
  With FDJSON do
    Execute;
end;

procedure TMainForm.AFindNextExecute(Sender: TObject);
begin
  FDJSONFind(Sender);
end;

procedure TMainForm.AFindNextUpdate(Sender: TObject);
begin
  (Sender as TAction).ENabled:=(FCurrentFind<>Nil)
end;

procedure TMainForm.ADeleteValueExecute(Sender: TObject);

begin
  DeleteCurrentValue;
end;

procedure TMainForm.DeleteCurrentValue;

Var
  PN : TTreeNode;
  P,D : TJSONData;

begin
  D:=CurrentData;
  If (CurrentContainerNode=CurrentNode) then
    PN:=FindContainerNode(CurrentNode.Parent)
  else
    PN:=CurrentContainerNode;
 If (PN=Nil) then
   begin
   FreeAndNil(FRoot);
   ShowJSONDocument;
   end
 else
   begin
   P:=TJSONData(PN.Data);
   If P.JSONType=jtArray then
     TJSONArray(P).Remove(D)
   else If P.JSONType=jtObject then
     TJSONObject(P).Remove(D);
   PN:=PN.Parent;
   If PN<>Nil then
     begin
     PN.DeleteChildren;
     ShowJSONData(PN,P);
     end
   else
     ShowJSONDocument;
   end;
   Modify;
end;

procedure TMainForm.ACopyUpdate(Sender: TObject);
begin
  (Sender as Taction).Enabled:=Assigned(CurrentData);
end;

procedure TMainForm.ACutExecute(Sender: TObject);
begin
  CopyCurrentData;
  DeleteCurrentValue;
end;

procedure TMainForm.ACopyExecute(Sender: TObject);
begin
  CopyCurrentData;
end;

procedure TMainForm.CopyCurrentData;

Var
  D : TJSONData;

begin
  D:=CurrentData;
  If Not Assigned(D) then
    exit;
  ShowMessage(D.AsJSON);
  Clipboard.Clear;
  ClipBoard.AsText:=D.AsJSON;
end;

procedure TMainForm.ACutUpdate(Sender: TObject);
begin
  (Sender as Taction).Enabled:=Assigned(CurrentData);
end;

procedure TMainForm.ANewBooleanValueExecute(Sender: TObject);
begin
  AddNewValue(jtBoolean);
end;

procedure TMainForm.ANewNumberValueExecute(Sender: TObject);
begin
  AddNewValue(jtNumber);
end;

procedure TMainForm.ANewObjectExecute(Sender: TObject);
begin
  AddNewValue(jtObject);
end;

procedure TMainForm.ANewStringValueExecute(Sender: TObject);
begin
  AddNewValue(jtString);
end;

procedure TMainForm.APasteAsDocumentExecute(Sender: TObject);
begin
  PasteJSON(True);
end;

procedure TMainForm.APasteExecute(Sender: TObject);
begin
  PasteJSON(False);
end;

procedure TMainForm.PasteJSON(DoClear : Boolean);

Var
  P : TJSONParser;
  D : TJSONData;
  N : String;
begin
  D:=Nil;
  try
{$IF FPC_FULLVERSION>=30002}
    P:=TJSONParser.Create(Clipboard.AsText,[]);
    P.Options:=FOptions;
{$ELSE}
    P:=TJSONParser.Create(Clipboard.AsText);
    P.Strict:=FStrict;
{$ENDIF}
    try
      D:=P.Parse;
    finally
      P.Free;
    end;
  except
    On E : Exception do
      ShowMessage(SErrNoValidJSONClipBoard)
  end;
  N:=SNewMember;
  If DoClear then
    begin
    If FModified then
      case QuestionDlg(SDocumentModified,SDocumentModifiedAction,mtWarning,[
          mrNo,SDiscard,
          mrYes,SSaveData,
          mrCancel,SCancelPaste],0) of
        mrYes : SaveToFile(GetSaveFileName(FFileName=''));
        mrNo : ;
        mrCancel : Exit;
      end;
    FreeAndNil(FRoot);
    TVJSON.Items.Clear;
    FFileName:='';
    N:='';
    end
  else If CurrentContainerType=jtObject then
    if not InputQuery(SNewMember,Format(SNewMemberName,[JSONTypeNames[D.JSONType]]),N) then
      begin
      D.Free;
      Exit;
      end;
  AddDataToContainer(N,D);
end;

procedure TMainForm.APasteUpdate(Sender: TObject);
begin
//  (Sender as TAction).Enabled:=ClipBoard.HasFormat(Clipboard.FindFormatID('text/plain'));
  (Sender as TAction).Enabled:=ClipBoard.HasFormat(CF_TEXT);
end;

procedure TMainForm.AddNewValue(AType : TJSONType);

  Function NewMemberName : string;

  begin
    Case CurrentContainerType of
      jtUnknown : Result:= '';
      jtObject  : Result:=SNewMember;
      jtArray   : Result:=Format(SElement,[TJSONArray(CurrentContainer).Count]);
    end;
  end;

Var
  D : TJSONData;
  N : String;

begin
  Case AType of
    jtNull,
    jtObject,
    jtArray :
      begin
      N:=SNewMember;
      If (CurrentContainerType=jtObject) then
        if not InputQuery(SNewMember,Format(SNewMemberName,[JSONTypeNames[AType]]),N) then
           Exit;
      Case AType of
         jtNull : D:=TJSONNull.Create;
         jtObject : D:=TJSONObject.Create;
         jtArray : D:=TJSONArray.Create;
      end;
      end;
    jtBoolean:
      begin
      With TNewBooleanForm.Create(Self) do
        try
          MemberName:=NewMemberName;
          AllowName:=CurrentContainerType=jtObject;
          If (ShowModal<>mrOK) then
            Exit;
          N:=MemberName;
          D:=TJSONBoolean.Create(Value);
        finally
          Free;
        end;
      end;
    jtString:
      begin
        With TNewStringForm.Create(Self) do
          try
            MemberName:=NewMemberName;
            AllowName:=CurrentContainerType=jtObject;
            If (ShowModal<>mrOK) then
              Exit;
            N:=MemberName;
            D:=TJSONString.Create(Value);
          finally
            Free;
          end;
      end;
    jtNumber:
      begin
        With TNewNumberForm.Create(Self) do
          try
            MemberName:=NewMemberName;
            AllowName:=CurrentContainerType=jtObject;
            NumberType:=ntInteger;
            If (ShowModal<>mrOK) then
              Exit;
            N:=MemberName;
            Case NumberType of
              ntInteger : D:=TJSONIntegerNumber.Create(AsInteger);
              ntFloat   : D:=TJSONFloatNumber.Create(AsFloat);
              ntInt64   : D:=TJSONInt64Number.Create(AsInt64);
            end;
          finally
            Free;
          end;
      end;
  end;
  AddDataToContainer(N,D);
end;

procedure TMainForm.AddDataToContainer(Const AMemberName : String; D : TJSONData);

Var
  P : TTreeNode;
  I : Integer;

begin
  Case CurrentContainerType of
    jtUnknown  :
       begin
       FRoot:=D;
       P:=Nil;
       end;
    jtObject :
       begin
       TJSONObject(CurrentContainer).Add(AmemberName,D);
       P:=TVJSON.Items.AddChild(CurrentContainerNode,AmemberName)
       end;
    jtArray:
       begin
       I:=TJSONArray(CurrentContainer).Add(D);
       P:=TVJSON.Items.AddChild(CurrentContainerNode,IntToStr(I))
       end;
  end;
  Modify;
  If Assigned(P) then
    begin
    P.ImageIndex:=ImageTypeMap[D.JSONType];
    P.SelectedIndex:=ImageTypeMap[D.JSONType];
    P.MakeVisible;
    end;
  ShowJSONData(P,D);
end;

function TMainForm.CurrentNode: TTreeNode;
begin
  Result:=TVJSON.Selected;
end;

function TMainForm.CurrentNodeType: TJSONType;

Var
  D : TJSONData;

begin
  D:=CurrentData;
  If (D=Nil) then
    Result:=jtUnknown
  else
    Result:=D.JSONType;
end;

Procedure TMainForm.SaveToFile(Const AFileName : string);

Var
  S : String;
  F : TFileStream;

begin
  if (AFileName<>'') then
  begin
    F:=TFileStream.Create(AFileName,fmCreate);
    try
      If Assigned(FRoot) then
        S:=FRoot.AsJSON;
      If length(S)>0 then
        F.WriteBuffer(S[1],Length(S));
      FModified:=False;
    finally
      F.Free;
    end;
    FFileName:=AFileName;
    SetCaption;
  end;
end;

Function TMainForm.GetSaveFileName(Force : Boolean) : String;

begin
  Result:=FFileName;
  If Force or (Result='') then
    with SDJSON do
      begin
      FileName:=Result;
      If Execute then
        Result:=FileName
      else
        Result:=''
      end;
end;


Function TMainForm.CurrentData : TJSONData;

Var
  N : TTreeNode;

begin
  N:=CurrentNode;
  If (N=Nil) then
    Result:=Nil
  else
    begin
    Result:=TJSONData(N.Data);
    If (Result=Nil) and (N.Count=1) then
      Result:=TJSONData(N.Items[0].Data);
    end;
end;

Function TMainForm.CurrentContainerType : TJSONtype;

Var
  D : TJSONData;

begin
  D:=CurrentContainer;
  If (D=Nil) then
    Result:=jtUnknown
  else
    Result:=D.JSONType;
end;

Function TMainForm.IsContainerNode(ANode : TTreeNode) : Boolean;

begin
  Result:=Assigned(ANode)
          and Assigned(ANode.Data)
          and (TJSONData(ANode.Data).JSONType in [jtArray,jtObject]);
end;

Function TMainForm.FindContainerNode(AStart : TTreeNode) : TTreeNode;

begin
  Result:=Astart;
  While (Result<>Nil) and Not IsContainerNode(Result) do
    Result:=Result.Parent;
end;

Function TMainForm.CurrentContainerNode : TTreeNode;

begin
  Result:=FindContainerNode(CurrentNode);
end;

Function TMainForm.CurrentContainer : TJSONData;

Var
  N : TTreeNode;

begin
  N:=CurrentContainerNode;
  If (N<>Nil) then
    Result:=TJSONData(N.Data)
  else
    Result:=Nil
end;

procedure TMainForm.AOpenExecute(Sender: TObject);

begin
  With ODJSON do
    begin
    FileName:=FFileName;
    If Execute then
      OpenFile(FileName)
    end;
end;

procedure TMainForm.FDJSONFind(Sender: TObject);

Var
  N : TTreeNode;

begin
  If (FCurrentFind=Nil) then
    begin
    If (frEntireScope in FDJSON.Options) and (TVJSON.Items.Count>0) then
      FCurrentFind:=TVJSON.Items[0]
    else
      FCurrentFind:=TVJSON.Selected;
    end
  else
    FCurrentFind:=GetNextSearchNode(FCurrentFind);
  If (FCurrentFind=Nil) then
    Exit;
  With FDJSON do
    N:=FindNode(FCurrentFind,FindText,Not (frMatchCase in Options), frWholeWord in Options);
  If Assigned(N) then
    begin
    N.MakeVisible;
    TVJSON.Selected:=N;
    end
  else
    ShowMessage(SNoMoreMatches);
  FCurrentFind:=N;
end;

Function TMainForm.GetNextSearchNode(Anode : TTreeNode) : TTreeNode;

begin
  Result:=Nil;
  If (ANode=Nil) then Exit;
  If (ANode.Count>0) then
    Result:=ANode.GetFirstChild
  else
    Result:=ANode.GetNextSibling;
  While (Result=Nil) and (ANode<>Nil) do
    begin
    ANode:=ANode.Parent;
    if assigned(ANode) then
      Result:=ANode.GetNextSibling;
    end;
end;

Function TMainForm.FindNode(Start : TTreeNode; Const AText: String; CaseInsensitive : Boolean; WholeWord : Boolean) : TTreeNode;

  Function Match(Const ST : String; ANode : TTreeNode) : boolean;

  Var
    NT : String;

  begin
    If CaseInsensitive then
      NT:=Uppercase(ANode.Text)
    else
      NT:=ANode.Text;
    If WholeWord then
      Result:=(NT=ST)
    else
      Result:=(Pos(ST,NT)>0);
  end;

Var
  ST : String;

begin
  If CaseInsensitive then
    ST:=UpperCase(AText)
  else
    ST:=AText;
  Result:=Start;
  While (Result<>Nil) and not Match(ST,Result)  do
    Result:=GetNextSearchNode(Result);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose:=Not FModified;
  If Not CanClose then
    case QuestionDlg(SDocumentModified,SDocumentModifiedAction,mtWarning,[
      mrNo,SDiscard,
      mrYes,SSaveData,
      mrCancel,SCancelClose],0) of
    mrNo : CanClose:=True;
    mrYes :
       begin
       SaveToFile(GetSaveFileName(FFileName=''));
       CanClose:=True;
       end;
    end;
end;

procedure TMainForm.FormCreate(Sender: TObject);

Var
  S : String;

begin
  S:=GetAppConfigFile(false,true);
  PSMain.IniFileName:=S;
  S:=ExtractFilePath(S);
  If not ForceDirectories(S) then
    ShowMessage(Format(SErrCreatingConfigDir,[S]));
  PSMain.Active:=True;
{$IF FPC_FULLVERSION<30002}
  MIAllowTrailingComma.Visible:=False;
  MIAllowComments.Visible:=False;
{$ENDIF}
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if (ParamCount>0)  and FileExists(ParamStr(1)) then
    OpenFile(ParamStr(1))
  else
    NewDocument;
end;

procedure TMainForm.HaveData(Sender: TObject);
begin
  (Sender as TAction).Enabled:=(FRoot<>Nil);
end;

procedure TMainForm.MIAllowTrailingCommaClick(Sender: TObject);
begin
  {$IF FPC_FULLVERSION>=30002}
    ToggleOption(joIgnoreTrailingComma,(Sender as TMenuItem).Checked);
  {$ENDIF}
end;

procedure TMainForm.MIAllowCommentsClick(Sender: TObject);
begin
  {$IF FPC_FULLVERSION>=30002}
    ToggleOption(joComments,(Sender as TMenuItem).Checked);
  {$ENDIF}
end;

procedure TMainForm.MICompactClick(Sender: TObject);
begin
  FCompact:=MICompact.Checked;
  PSMain.StoredValue['compact']:=IntToStr(Ord(FCompact));
  ShowJSONDocument;
end;

procedure TMainForm.MIdocumentClick(Sender: TObject);
begin
  FNewObject:=(Sender as TMenuItem).Checked;
  PSMain.StoredValue['object']:=IntToStr(Ord(FNewObject));
end;

procedure TMainForm.MIQuoteStringsClick(Sender: TObject);
begin
  FQuoteStrings:=MICompact.Checked;
  PSMain.StoredValue['QuoteStrings']:=IntToStr(Ord(FQuoteStrings));
  ShowJSONDocument;
end;

procedure TMainForm.MISortMembersClick(Sender: TObject);
begin
  FSortObjectMembers:=(Sender as TMenuItem).Checked;
  ShowJSONDocument;
end;

procedure TMainForm.OpenFile(Const AFileName : String);

Var
  S : TFileStream;
  P : TJSONParser;
  D : TJSONData;
begin
  S:=TFileStream.Create(AFileName,fmOpenRead or fmShareDenyWrite);
  try
{$IF FPC_FULLVERSION>=30002}
    P:=TJSONParser.Create(S,[]);
{$ELSE}
    P:=TJSONParser.Create(S);
{$ENDIF}
    try
{$IF FPC_FULLVERSION>=30002}
      P.Options:=P.Options+[joStrict];
{$ELSE}
      P:=TJSONParser.Create(S);
{$ENDIF}
      D:=P.Parse;
    finally
      P.Free;
    end;
  finally
    S.Free;
  end;
  FFileName:=AFileName;
  SetCaption;
  FreeAndNil(FRoot);
  FRoot:=D;
  ShowJSONDocument;
end;

procedure TMainForm.ShowJSONDocument;

begin
  With TVJSON.Items do
    begin
    BeginUpdate;
    try
      TVJSON.Items.Clear;
      ShowJSONData(Nil,FRoot);
      With TVJSON do
        If (Items.Count>0) and Assigned(Items[0]) then
          begin
          Items[0].Expand(False);
          Selected:=Items[0];
          end;
    finally
      EndUpdate;
    end;
    end;
end;

procedure TMainForm.ShowJSONData(AParent : TTreeNode; Data : TJSONData);

Var
  N,N2 : TTreeNode;
  I : Integer;
  D : TJSONData;
  C : String;
  S : TStringList;

begin
  if Not Assigned(Data) then
    exit;
  if FCompact and (AParent<>Nil) then
    N:=AParent
  else
    N:=TVJSON.Items.AddChild(AParent,'');
  Case Data.JSONType of
    jtArray,
    jtObject:
      begin
      If (Data.JSONType=jtArray) then
        C:=SArray
      else
        C:=SObject;
      C:=Format(C,[Data.Count]);
      S:=TstringList.Create;
      try
        For I:=0 to Data.Count-1 do
          If Data.JSONtype=jtArray then
            S.AddObject(IntToStr(I),Data.items[i])
          else
            S.AddObject(TJSONObject(Data).Names[i],Data.items[i]);
        If FSortObjectMembers and (Data.JSONType=jtObject) then
          S.Sort;
        For I:=0 to S.Count-1 do
          begin
          N2:=TVJSON.Items.AddChild(N,S[i]);
          D:=TJSONData(S.Objects[i]);
          N2.ImageIndex:=ImageTypeMap[D.JSONType];
          N2.SelectedIndex:=ImageTypeMap[D.JSONType];
          ShowJSONData(N2,D);
          end
      finally
        S.Free;
      end;
      end;
    jtNull:
      C:=SNull;
  else
    C:=Data.AsString;
    if FQuoteStrings and  (Data.JSONType=jtString) then
      C:='"'+C+'"';
  end;
  If Assigned(N) then
    begin
    If N.Text='' then
      N.Text:=C
    else
      N.Text:=N.Text+': '+C;
    N.ImageIndex:=ImageTypeMap[Data.JSONType];
    N.SelectedIndex:=ImageTypeMap[Data.JSONType];
    N.Data:=Data;
    end;
end;

end.

