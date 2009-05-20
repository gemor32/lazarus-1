{
 /***************************************************************************
                               LDockTree.pas
                             -----------------

 ***************************************************************************/

 *****************************************************************************
 *                                                                           *
 *  This file is part of the Lazarus Component Library (LCL)                 *
 *                                                                           *
 *  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
 *  for details about the copyright.                                         *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
 *                                                                           *
 *****************************************************************************

  Author: Mattias Gaertner

  Abstract:
    This unit contains TLazDockTree, the default TDockTree for the LCL.
}
unit LDockTree;

{$mode objfpc}{$H+}

interface

uses
  Math, Types, Classes, SysUtils, LCLProc, LCLType, LCLStrConsts,
  Graphics, Controls, ExtCtrls, Forms, Menus, Themes, LCLIntf,
  LMessages, LResources, typinfo;

type
  TLazDockPages = class;
  TLazDockPage = class;
  TLazDockSplitter = class;


  { TLazDockZone }

  TLazDockZone = class(TDockZone)
  private
    FPage: TLazDockPage;
    FPages: TLazDockPages;
    FSplitter: TLazDockSplitter;
  public
    destructor Destroy; override;
    procedure FreeSubComponents;
    function GetCaption: string;
    function GetParentControl: TWinControl;
    property Splitter: TLazDockSplitter read FSplitter write FSplitter;
    property Pages: TLazDockPages read FPages write FPages;
    property Page: TLazDockPage read FPage write FPage;
  end;

  TDockHeaderMouseState = record
    Rect: TRect;
    IsMouseDown: Boolean;
  end;

  TDockHeaderImageKind =
  (
    dhiRestore,
    dhiClose
  );

  TDockHeaderImages = array[TDockHeaderImageKind] of TCustomBitmap;

  { TLazDockTree }

  TLazDockTree = class(TDockTree)
  private
    FAutoFreeDockSite: boolean;
    FMouseState: TDockHeaderMouseState;
    FDockHeaderImages: TDockHeaderImages;
  protected
    procedure AnchorDockLayout(Zone: TLazDockZone);
    procedure CreateDockLayoutHelperControls(Zone: TLazDockZone);
    procedure ResetSizes(Zone: TLazDockZone);
    procedure BreakAnchors(Zone: TDockZone);
    procedure PaintDockFrame(ACanvas: TCanvas; AControl: TControl;
                             const ARect: TRect); override;
    procedure UndockControlForDocking(AControl: TControl);
    function DefaultDockGrabberSize: Integer;
  public
    constructor Create(TheDockSite: TWinControl); override;
    destructor Destroy; override;
    procedure AdjustDockRect(AControl: TControl; var ARect: TRect); override;
    procedure InsertControl(AControl: TControl; InsertAt: TAlign;
                            DropControl: TControl); override;
    procedure RemoveControl(AControl: TControl); override;
    procedure BuildDockLayout(Zone: TLazDockZone);
    procedure FindBorderControls(Zone: TLazDockZone; Side: TAnchorKind;
                                 var List: TFPList);
    function FindBorderControl(Zone: TLazDockZone; Side: TAnchorKind): TControl;
    function GetAnchorControl(Zone: TLazDockZone; Side: TAnchorKind;
                              OutSide: boolean): TControl;
    procedure PaintSite(DC: HDC); override;
    procedure MessageHandler(Sender: TControl; var Message: TLMessage); override;
    procedure DumpLayout(FileName: String); override;
  public
    property AutoFreeDockSite: boolean read FAutoFreeDockSite write FAutoFreeDockSite;
  end;

  TLazDockHeaderPart =
  (
    ldhpAll,           // total header rect
    ldhpCaption,       // header caption
    ldhpRestoreButton, // header restore button
    ldhpCloseButton    // header close button
  );

  { TLazDockForm
    The default DockSite for a TLazDockTree and for TCustomAnchoredDockManager.

    Note: There are two docking managers:
      TLazDockTree uses TLazDockZone to allow docking in rows and columns.
      TCustomAnchoredDockManager does not use TLazDockZone and allows arbitrary
        layouts.
 }

  TLazDockForm = class(TCustomForm)
  private
    FMainControl: TControl;
    FMouseState: TDockHeaderMouseState;
    FDockHeaderImages: TDockHeaderImages;
    procedure SetMainControl(const AValue: TControl);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure UpdateMainControl;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X,Y: Integer); override;
    procedure MouseLeave; override;
    procedure PaintWindow(DC: HDC); override;
    procedure TrackMouse(X, Y: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CloseQuery: boolean; override;
    procedure UpdateCaption; virtual;
    class procedure UpdateMainControlInParents(StartControl: TControl);
    function FindMainControlCandidate: TControl;
    function FindHeader(x, y: integer; out Part: TLazDockHeaderPart): TControl;
    procedure InsertControl(AControl: TControl; Index: integer); override;
    function IsDockedControl(Control: TControl): boolean;
    function ControlHasTitle(Control: TControl): boolean;
    function GetTitleRect(Control: TControl): TRect;
    function GetTitleOrientation(Control: TControl): TDockOrientation;
    property MainControl: TControl read FMainControl write SetMainControl;// used for the default caption
  end;


  { TLazDockPage
    Pretty the same as a TLazDockForm but as page of a TLazDockPages }

  TLazDockPage = class(TCustomPage)
  private
    FDockZone: TDockZone;
    function GetPageControl: TLazDockPages;
  public
    procedure InsertControl(AControl: TControl; Index: integer); override;
    property DockZone: TDockZone read FDockZone;
    property PageControl: TLazDockPages read GetPageControl;
  end;


  { TLazDockPages }

  TLazDockPages = class(TCustomNotebook)
  private
    function GetActiveNotebookPageComponent: TLazDockPage;
    function GetNoteBookPage(Index: Integer): TLazDockPage;
    procedure SetActiveNotebookPageComponent(const AValue: TLazDockPage);
  protected
    function GetFloatingDockSiteClass: TWinControlClass; override;
    procedure Change; override;
  public
    constructor Create(TheOwner: TComponent); override;
    property Page[Index: Integer]: TLazDockPage read GetNoteBookPage;
    property ActivePageComponent: TLazDockPage read GetActiveNotebookPageComponent
                                           write SetActiveNotebookPageComponent;
    property Pages;
  end;


  { TLazDockSplitter }

  TLazDockSplitter = class(TCustomSplitter)
  public
    constructor Create(AOwner: TComponent); override;
  end;


  TCustomAnchoredDockManager = class;

  { TLazDockOwnerComponent
    A TComponent owning all automatically created controls of a
    TCustomAnchoredDockManager, like TLazDockForm }

  TLazDockOwnerComponent = class(TComponent)
  public
    Manager: TCustomAnchoredDockManager;
  end;

  //----------------------------------------------------------------------------

  { TCustomAnchoredDockManager
    This class implements an LCL TDockManager via anchoring.
    It implements the docking, undocking, enlarging, shrinking.

    The TCustomLazDockingManager component in LDockCtrl uses this
    docking manager and extends it by layouts that can be stored/restored. }

  TCustomAnchoredDockManager = class(TDockManager)
  private
    FSplitterSize: integer;
    FTitleHeight: integer;
    FTitleWidth: integer;
    FUpdateCount: integer;
  protected
    FOwnerComponent: TLazDockOwnerComponent;
    procedure DeleteSideSplitter(Splitter: TLazDockSplitter; Side: TAnchorKind;
                                 NewAnchorControl: TControl);
    procedure CombineSpiralSplitterPair(Splitter1, Splitter2: TLazDockSplitter);
    procedure DeletePage(Page: TLazDockPage);
    procedure DeletePages(Pages: TLazDockPages);
    procedure DeleteDockForm(ADockForm: TLazDockForm);
    function GetAnchorDepth(AControl: TControl; Side: TAnchorKind): Integer;
    function GetPreferredTitlePosition(AWidth, AHeight: integer): TAnchorKind;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginUpdate; override;
    procedure EndUpdate; override;
    procedure GetControlBounds(Control: TControl;
                               out AControlBounds: TRect); override;
    procedure DisableLayout(Control: TControl); virtual;
    procedure EnableLayout(Control: TControl); virtual;
    procedure DockControl(Control: TControl; InsertAt: TAlign;
                          DropCtl: TControl);
    procedure UndockControl(Control: TControl; Float: boolean);
    procedure InsertControl(Control: TControl; InsertAt: TAlign;
                            DropCtl: TControl); override;
    function EnlargeControl(Control: TControl; Side: TAnchorKind;
                            Simulate: boolean = false): boolean;
    procedure RemoveControl(Control: TControl); override;
    procedure ReplaceAnchoredControl(OldControl, NewControl: TControl);
    function GetSplitterWidth(Splitter: TControl): integer;
    function GetSplitterHeight(Splitter: TControl): integer;
    property SplitterSize: integer read FSplitterSize write FSplitterSize default 5;
    property TitleWidth: integer read FTitleWidth write FTitleWidth default 20;
    property TitleHeight: integer read FTitleHeight write FTitleHeight default 20;
    procedure UpdateTitlePosition(Control: TControl);

    procedure PaintSite(DC: HDC); override;
    procedure MessageHandler(Sender: TControl; var Message: TLMessage); override;// not implemented
    procedure PositionDockRect(Client, DropCtl: TControl; DropAlign: TAlign;
                               var DockRect: TRect); override;// not implemented
    procedure ResetBounds(Force: Boolean); override;// not implemented
    procedure SetReplacingControl(Control: TControl); override;// not implemented
    procedure LoadFromStream(Stream: TStream); override;// not implemented
    procedure SaveToStream(Stream: TStream); override;// not implemented
    function AutoFreeByControl: Boolean; override;

    // ToDo: move this to protected, after dockig code from LDockCtrl was moved
    // here.
    function CreateForm: TLazDockForm;
  end;


const
  DockAlignOrientations: array[TAlign] of TDockOrientation =
  (
 { alNone   } doPages,
 { alTop    } doHorizontal,
 { alBottom } doHorizontal,
 { alLeft   } doVertical,
 { alRight  } doVertical,
 { alClient } doPages,
 { alCustom } doPages
  );

type
  TAnchorControlsRect = array[TAnchorKind] of TControl;

function GetLazDockSplitter(Control: TControl; Side: TAnchorKind;
                            out Splitter: TLazDockSplitter): boolean;
function GetLazDockSplitterOrParent(Control: TControl; Side: TAnchorKind;
                                    out AnchorControl: TControl): boolean;
function CountAnchoredControls(Control: TControl; Side: TAnchorKind
                               ): Integer;
function NeighbourCanBeShrinked(EnlargeControl, Neighbour: TControl;
                                Side: TAnchorKind): boolean;
function ControlIsAnchoredIndirectly(StartControl: TControl; Side: TAnchorKind;
                                     DestControl: TControl): boolean;
procedure GetAnchorControlsRect(Control: TControl;
                                out ARect: TAnchorControlsRect);
function GetEnclosingControlRect(ControlList: TFPlist;
                                 out ARect: TAnchorControlsRect): boolean;
function GetEnclosedControls(const ARect: TAnchorControlsRect): TFPList;


implementation

const
  DockHeaderImageNames: array[TDockHeaderImageKind] of String =
  (
{ dhiRestore } 'lcl_dock_restore',
{ dhiClose   } 'lcl_dock_close'
  );

type

  { TDockHeader }

  // maybe once it will be control, so now better to move all related to header things to class
  TDockHeader = class
    class procedure CreateDockHeaderImages(out Images: TDockHeaderImages);
    class procedure DestroyDockHeaderImages(var Images: TDockHeaderImages);

    class function GetRectOfPart(AHeaderRect: TRect; AOrientation: TDockOrientation; APart: TLazDockHeaderPart): TRect;
    class function FindPart(AHeaderRect: TRect; APoint: TPoint; AOrientation: TDockOrientation): TLazDockHeaderPart;
    class procedure Draw(ACanvas: TCanvas; ACaption: String; DockBtnImages: TDockHeaderImages; AOrientation: TDockOrientation; const ARect: TRect; const MousePos: TPoint);
    class procedure PerformMouseUp(AControl: TControl; APart: TLazDockHeaderPart);
    class procedure PerformMouseDown(AControl: TControl; APart: TLazDockHeaderPart);
  end;

class procedure TDockHeader.CreateDockHeaderImages(out Images: TDockHeaderImages);
var
  ImageKind: TDockHeaderImageKind;
begin
  for ImageKind := Low(TDockHeaderImageKind) to High(TDockHeaderImageKind) do
    Images[ImageKind] := CreateBitmapFromLazarusResource(DockHeaderImageNames[ImageKind]);
end;

class procedure TDockHeader.DestroyDockHeaderImages(
  var Images: TDockHeaderImages);
var
  ImageKind: TDockHeaderImageKind;
begin
  for ImageKind := Low(TDockHeaderImageKind) to High(TDockHeaderImageKind) do
    FreeAndNil(Images[ImageKind]);
end;

class function TDockHeader.GetRectOfPart(AHeaderRect: TRect; AOrientation: TDockOrientation;
  APart: TLazDockHeaderPart): TRect;
var
  d: Integer;
begin
  Result := AHeaderRect;
  if APart = ldhpAll then
    Exit;
  InflateRect(Result, -2, -2);
  case AOrientation of
    doHorizontal:
    begin
      d := Result.Bottom - Result.Top;
      if APart = ldhpCloseButton then
      begin
        Result.Left := Max(Result.Left, Result.Right - d);
        Exit;
      end;
      Result.Right := Max(Result.Left, Result.Right - d - 1);
      if APart = ldhpRestoreButton then
      begin
        Result.Left := Max(Result.Left, Result.Right - d);
        Exit;
      end;
      Result.Right := Max(Result.Left, Result.Right - d - 1);
      InflateRect(Result, -4, 0);
    end;
    doVertical:
    begin
      d := Result.Right - Result.Left;
      if APart = ldhpCloseButton then
      begin
        Result.Bottom := Min(Result.Bottom, Result.Top + d);
        Exit;
      end;
      Result.Top := Min(Result.Bottom, Result.Top + d + 1);
      if APart = ldhpRestoreButton then
      begin
        Result.Bottom := Min(Result.Bottom, Result.Top + d);
        Exit;
      end;
      Result.Top := Min(Result.Bottom, Result.Top + d + 1);
      InflateRect(Result, 0, -4);
    end;
  end;
end;

class function TDockHeader.FindPart(AHeaderRect: TRect; APoint: TPoint; AOrientation: TDockOrientation): TLazDockHeaderPart;
var
  SubRect: TRect;
begin
  for Result := Low(TLazDockHeaderPart) to High(TLazDockHeaderPart) do
  begin
    if Result = ldhpAll then
      Continue;
    SubRect := GetRectOfPart(AHeaderRect, AOrientation, Result);
    if PtInRect(SubRect, APoint) then
      Exit;
  end;
  Result := ldhpAll;
end;

class procedure TDockHeader.Draw(ACanvas: TCanvas; ACaption: String; DockBtnImages: TDockHeaderImages; AOrientation: TDockOrientation; const ARect: TRect; const MousePos: TPoint);

  procedure DrawButton(ARect: TRect; IsMouseDown, IsMouseOver: Boolean; ABitmap: TCustomBitmap); inline;
  const
    // ------------- Pressed, Hot -----------------------
    BtnDetail: array[Boolean, Boolean] of TThemedToolBar =
    (
     (ttbButtonNormal, ttbButtonHot),
     (ttbButtonNormal, ttbButtonPressed)
    );
  var
    Details: TThemedElementDetails;
    dx, dy: integer;
  begin
    Details := ThemeServices.GetElementDetails(BtnDetail[IsMouseDown, IsMouseOver]);
    ThemeServices.DrawElement(ACanvas.Handle, Details, ARect);
    ARect := ThemeServices.ContentRect(ACanvas.Handle, Details, ARect);
    dx := (ARect.Right - ARect.Left - ABitmap.Width) div 2;
    dy := (ARect.Bottom - ARect.Top - ABitmap.Height) div 2;
    ACanvas.Draw(ARect.Left + dx, ARect.Top + dy, ABitmap);
  end;

  procedure DrawTitle(ARect: TRect); inline;
  begin
    ACanvas.Pen.Color := clBtnShadow;
    ACanvas.Brush.Color := clBtnFace;
    ACanvas.Rectangle(ARect);
  end;

var
  BtnRect: TRect;
  DrawRect: TRect;
  // LCL dont handle orientation in TFont
  OldFont, RotatedFont: HFONT;
  OldMode: Integer;
  ALogFont: TLogFont;
  IsMouseDown: Boolean;
begin
  DrawRect := ARect;
  InflateRect(DrawRect, -1, -1);
  DrawTitle(DrawRect);
  InflateRect(DrawRect, -1, -1);

  IsMouseDown := (GetKeyState(VK_LBUTTON) and $80) <> 0;

  // draw close button
  BtnRect := GetRectOfPart(ARect, AOrientation, ldhpCloseButton);

  DrawButton(BtnRect, IsMouseDown, PtInRect(BtnRect, MousePos), DockBtnImages[dhiClose]);

  // draw restore button
  BtnRect := GetRectOfPart(ARect, AOrientation, ldhpRestoreButton);
  DrawButton(BtnRect, IsMouseDown, PtInRect(BtnRect, MousePos), DockBtnImages[dhiRestore]);

  // draw caption
  DrawRect := GetRectOfPart(ARect, AOrientation, ldhpCaption);

  OldMode := SetBkMode(ACanvas.Handle, TRANSPARENT);

  case AOrientation of
    doHorizontal:
      begin
        DrawText(ACanvas.Handle, PChar(ACaption), -1, DrawRect, DT_LEFT or DT_SINGLELINE or DT_VCENTER);
      end;
    doVertical:
      begin
        OldFont := 0;
        if GetObject(ACanvas.Font.Reference.Handle, SizeOf(ALogFont), @ALogFont) <> 0 then
        begin
          ALogFont.lfEscapement := 900;
          RotatedFont := CreateFontIndirect(ALogFont);
          if RotatedFont <> 0 then
            OldFont := SelectObject(ACanvas.Handle, RotatedFont);
        end;
        // from msdn: DrawText doesnot support font with orientation and escapement <> 0
        TextOut(ACanvas.Handle, DrawRect.Left, DrawRect.Bottom, PChar(ACaption), Length(ACaption));
        if OldFont <> 0 then
          DeleteObject(SelectObject(ACanvas.Handle, OldFont));
      end;
  end;
  SetBkMode(ACanvas.Handle, OldMode);
end;

class procedure TDockHeader.PerformMouseUp(AControl: TControl;
  APart: TLazDockHeaderPart);
begin
  case APart of
    ldhpRestoreButton:
      AControl.ManualDock(nil, nil, alNone);
    ldhpCloseButton:
      if AControl is TCustomForm then
        TCustomForm(AControl).Close
      else
        // not a form => doesnot have close => just hide
        AControl.Visible := False;
  end;
end;

class procedure TDockHeader.PerformMouseDown(AControl: TControl;
  APart: TLazDockHeaderPart);
begin
  case APart of
    ldhpAll, ldhpCaption:
      // mouse down on not buttons => start drag
      AControl.BeginDrag(False);
  end;
end;


function GetLazDockSplitter(Control: TControl; Side: TAnchorKind; out
  Splitter: TLazDockSplitter): boolean;
begin
  Result:=false;
  Splitter:=nil;
  if not (Side in Control.Anchors) then exit;
  Splitter:=TLazDockSplitter(Control.AnchorSide[Side].Control);
  if not (Splitter is TLazDockSplitter) then begin
    Splitter:=nil;
    exit;
  end;
  if Splitter.Parent<>Control.Parent then exit;
  Result:=true;
end;

function GetLazDockSplitterOrParent(Control: TControl; Side: TAnchorKind; out
  AnchorControl: TControl): boolean;
begin
  Result:=false;
  AnchorControl:=nil;
  if not (Side in Control.Anchors) then exit;
  AnchorControl:=Control.AnchorSide[Side].Control;
  if (AnchorControl is TLazDockSplitter)
  and (AnchorControl.Parent=Control.Parent)
  then
    Result:=true
  else if AnchorControl=Control.Parent then
    Result:=true;
end;

function CountAnchoredControls(Control: TControl; Side: TAnchorKind): Integer;
{ return the number of siblings, that are anchored on Side of Control
  For example: if Side=akLeft it will return the number of controls, which
  right side is anchored to the left of Control }
var
  i: Integer;
  Neighbour: TControl;
begin
  Result:=0;
  for i:=0 to Control.Parent.ControlCount-1 do begin
    Neighbour:=Control.Parent.Controls[i];
    if Neighbour=Control then continue;
    if (OppositeAnchor[Side] in Neighbour.Anchors)
    and (Neighbour.AnchorSide[OppositeAnchor[Side]].Control=Control) then
      inc(Result);
  end;
end;

function NeighbourCanBeShrinked(EnlargeControl, Neighbour: TControl;
  Side: TAnchorKind): boolean;
const
  MinControlSize = 20;
var
  Splitter: TLazDockSplitter;
begin
  Result:=false;
  if not GetLazDockSplitter(EnlargeControl,OppositeAnchor[Side],Splitter) then
    exit;
  case Side of
  akLeft: // check if left side of Neighbour can be moved
    Result:=Neighbour.Left+Neighbour.Width
        >EnlargeControl.Left+EnlargeControl.Width+Splitter.Width+MinControlSize;
  akRight: // check if right side of Neighbour can be moved
    Result:=Neighbour.Left+MinControlSize+Splitter.Width<EnlargeControl.Left;
  akTop: // check if top side of Neighbour can be moved
    Result:=Neighbour.Top+Neighbour.Height
       >EnlargeControl.Top+EnlargeControl.Height+Splitter.Height+MinControlSize;
  akBottom: // check if bottom side of Neighbour can be moved
    Result:=Neighbour.Top+MinControlSize+Splitter.Height<EnlargeControl.Top;
  end;
end;

function ControlIsAnchoredIndirectly(StartControl: TControl; Side: TAnchorKind;
  DestControl: TControl): boolean;
{ true if there is an Anchor way from StartControl to DestControl over Side.
  For example:

    +-+|+-+
    |A|||B|
    +-+|+-+

  A is akLeft to B.
  B is akRight to A.
  The splitter is akLeft to B.
  The splitter is akRight to A.
  All other are false.
}
var
  Checked: array of Boolean;
  Parent: TWinControl;

  function Check(ControlIndex: integer): boolean;
  var
    AControl: TControl;
    SideControl: TControl;
    i: Integer;
  begin
    if Checked[ControlIndex] then
      exit(false);
    Checked[ControlIndex]:=true;
    AControl:=Parent.Controls[ControlIndex];
    if AControl=DestControl then exit(true);

    if (Side in AControl.Anchors) then begin
      SideControl:=AControl.AnchorSide[Side].Control;
      if (SideControl<>nil) and Check(Parent.GetControlIndex(SideControl)) then
        exit(true);
    end;
    for i:=0 to Parent.ControlCount-1 do begin
      if Checked[i] then continue;
      SideControl:=Parent.Controls[i];
      if OppositeAnchor[Side] in SideControl.Anchors then begin
        if (SideControl.AnchorSide[OppositeAnchor[Side]].Control=AControl)
        and Check(i) then
          exit(true);
      end;
    end;
    Result:=false;
  end;

var
  i: Integer;
begin
  if (StartControl=nil) or (DestControl=nil)
  or (StartControl.Parent=nil)
  or (StartControl.Parent<>DestControl.Parent)
  or (StartControl=DestControl) then
    exit(false);
  Parent:=StartControl.Parent;
  SetLength(Checked,Parent.ControlCount);
  for i:=0 to length(Checked)-1 do Checked[i]:=false;
  Result:=Check(Parent.GetControlIndex(StartControl));
end;

procedure GetAnchorControlsRect(Control: TControl;
  out ARect: TAnchorControlsRect);
var
  a: TAnchorKind;
begin
  for a:=Low(TAnchorKind) to High(TAnchorKind) do
    ARect[a]:=Control.AnchorSide[a].Control;
end;

function GetEnclosingControlRect(ControlList: TFPlist; out
  ARect: TAnchorControlsRect): boolean;
{ ARect will be the minimum TAnchorControlsRect around the controls in the list
  returns true, if there is such a TAnchorControlsRect.

  The controls in ARect will either be the Parent or a TLazDockSplitter
}
var
  Parent: TWinControl;

  function ControlIsValidAnchor(Control: TControl; Side: TAnchorKind): boolean;
  var
    i: Integer;
  begin
    Result:=false;
    if (Control=ARect[Side]) then exit(true);// this allows Parent at the beginning

    if not (Control is TLazDockSplitter) then
      exit;// not a splitter
    if (TLazDockSplitter(Control).ResizeAnchor in [akLeft,akRight])
      <>(Side in [akLeft,akRight]) then
        exit;// wrong alignment
    if ControlList.IndexOf(Control)>=0 then
      exit;// is an inner control
    if ControlIsAnchoredIndirectly(Control,Side,ARect[Side]) then
      exit; // this anchor would be worse than the current maximum
    for i:=0 to ControlList.Count-1 do begin
      if not ControlIsAnchoredIndirectly(Control,Side,TControl(ControlList[i]))
      then begin
        // this anchor is not above (below, ...) the inner controls
        exit;
      end;
    end;
    Result:=true;
  end;

var
  TopIndex: Integer;
  TopControl: TControl;
  RightIndex: Integer;
  RightControl: TControl;
  BottomIndex: Integer;
  BottomControl: TControl;
  LeftIndex: Integer;
  LeftControl: TControl;
  Candidates: TFPList;
  i: Integer;
  a: TAnchorKind;
begin
  Result:=false;
  if (ControlList=nil) or (ControlList.Count=0) then exit;

  // get Parent
  Parent:=TControl(ControlList[0]).Parent;
  if Parent=nil then exit;
  for i:=0 to ControlList.Count-1 do
    if TControl(ControlList[i]).Parent<>Parent then exit;

  // set the default rect: the Parent
  Result:=true;
  for a:=Low(TAnchorKind) to High(TAnchorKind) do
    ARect[a]:=Parent;

  // find all possible Candidates
  Candidates:=TFPList.Create;
  Candidates.Add(Parent);
  for i:=0 to Parent.ControlCount-1 do
    if Parent.Controls[i] is TLazDockSplitter then
      Candidates.Add(Parent.Controls[i]);

  // now check every possible rectangle
  // Note: four loops seems to be dog slow, but the checks
  //       avoid most possibilities early
  for TopIndex:=0 to Candidates.Count-1 do begin
    TopControl:=TControl(Candidates[TopIndex]);
    if not ControlIsValidAnchor(TopControl,akTop) then continue;

    for RightIndex:=0 to Candidates.Count-1 do begin
      RightControl:=TControl(Candidates[RightIndex]);
      if (TopControl.AnchorSide[akRight].Control<>RightControl)
      and (RightControl.AnchorSide[akTop].Control<>TopControl) then
        continue; // not touching / not a corner
      if not ControlIsValidAnchor(RightControl,akRight) then continue;

      for BottomIndex:=0 to Candidates.Count-1 do begin
        BottomControl:=TControl(Candidates[BottomIndex]);
        if (RightControl.AnchorSide[akBottom].Control<>BottomControl)
        and (BottomControl.AnchorSide[akRight].Control<>RightControl) then
          continue; // not touching / not a corner
        if not ControlIsValidAnchor(BottomControl,akBottom) then continue;

        for LeftIndex:=0 to Candidates.Count-1 do begin
          LeftControl:=TControl(Candidates[LeftIndex]);
          if (BottomControl.AnchorSide[akLeft].Control<>LeftControl)
          and (LeftControl.AnchorSide[akBottom].Control<>BottomControl) then
            continue; // not touching / not a corner
          if (TopControl.AnchorSide[akLeft].Control<>LeftControl)
          and (LeftControl.AnchorSide[akTop].Control<>LeftControl) then
            continue; // not touching / not a corner
          if not ControlIsValidAnchor(LeftControl,akLeft) then continue;

          // found a better rectangle
          ARect[akLeft]  :=LeftControl;
          ARect[akRight] :=RightControl;
          ARect[akTop]   :=TopControl;
          ARect[akBottom]:=BottomControl;
        end;
      end;
    end;
  end;

  Candidates.Free;
end;

function GetEnclosedControls(const ARect: TAnchorControlsRect): TFPList;
{ return a list of all controls bounded by the anchors in ARect }
var
  Parent: TWinControl;

  procedure Fill(AControl: TControl);
  var
    a: TAnchorKind;
    SideControl: TControl;
    i: Integer;
  begin
    if AControl=nil then exit;
    if AControl=Parent then exit;// do not add Parent
    for a:=Low(TAnchorKind) to High(TAnchorKind) do
      if ARect[a]=AControl then exit;// do not add boundary

    if Result.IndexOf(AControl)>=0 then exit;// already added
    Result.Add(AControl);

    for a:=Low(TAnchorKind) to High(TAnchorKind) do
      Fill(AControl.AnchorSide[a].Control);
    for i:=0 to Parent.ControlCount-1 do begin
      SideControl:=Parent.Controls[i];
      for a:=Low(TAnchorKind) to High(TAnchorKind) do
        if SideControl.AnchorSide[a].Control=AControl then
          Fill(SideControl);
    end;
  end;

var
  i: Integer;
  AControl: TControl;
  LeftTopControl: TControl;
begin
  Result:=TFPList.Create;

  // find the Parent
  if (ARect[akLeft]=ARect[akRight]) and (ARect[akLeft] is TWinControl) then
    Parent:=TWinControl(ARect[akLeft])
  else
    Parent:=ARect[akLeft].Parent;

  // find the left, top most control
  for i:=0 to Parent.ControlCount-1 do begin
    AControl:=Parent.Controls[i];
    if (AControl.AnchorSide[akLeft].Control=ARect[akLeft])
    and (AControl.AnchorSide[akTop].Control=ARect[akTop]) then begin
      LeftTopControl:=AControl;
      break;
    end;
  end;
  if Result.Count=0 then exit;

  // use flood fill to find the rest
  Fill(LeftTopControl);
end;

{ TLazDockPages }

function TLazDockPages.GetActiveNotebookPageComponent: TLazDockPage;
begin
  Result:=TLazDockPage(inherited ActivePageComponent);
end;

function TLazDockPages.GetNoteBookPage(Index: Integer): TLazDockPage;
begin
  Result:=TLazDockPage(inherited Page[Index]);
end;

procedure TLazDockPages.SetActiveNotebookPageComponent(
  const AValue: TLazDockPage);
begin
  ActivePageComponent:=AValue;
end;

function TLazDockPages.GetFloatingDockSiteClass: TWinControlClass;
begin
  Result:=TLazDockForm;
end;

procedure TLazDockPages.Change;
begin
  inherited Change;
  TLazDockForm.UpdateMainControlInParents(Self);
end;

constructor TLazDockPages.Create(TheOwner: TComponent);
begin
  PageClass:=TLazDockPage;
  inherited Create(TheOwner);
end;

{ TLazDockTree }

procedure TLazDockTree.UndockControlForDocking(AControl: TControl);
var
  AWinControl: TWinControl;
  Sibling: TControl;
  a: TAnchorKind;
  i: Integer;
begin
  DebugLn(['TLazDockTree.UndockControlForDocking AControl=',DbgSName(AControl),' AControl.Parent=',DbgSName(AControl.Parent)]);
  // undock AControl
  if AControl is TWinControl then begin
    AWinControl:=TWinControl(AControl);
    if (AWinControl.DockManager<>nil)
    and (AWinControl.DockManager<>Self) then begin
      raise Exception.Create('TLazDockTree.UndockControlForDocking mixing docking managers is not supported');
    end;
  end;
  if AControl.Parent<>nil then begin
    AControl.Parent:=nil;
  end;
  for i:=AControl.AnchoredControlCount-1 downto 0 do begin
    Sibling:=AControl.AnchoredControls[i];
    if (Sibling<>AControl.Parent) and (Sibling.Parent<>AControl) then begin
      for a:=low(TAnchorKind) to high(TAnchorKind) do
        if Sibling.AnchorSide[a].Control=AControl then
          Sibling.AnchorSide[a].Control:=nil;
    end;
  end;
end;

function TLazDockTree.DefaultDockGrabberSize: Integer;
begin
  Result := {Abs(DockSite.Font.Height) + 4} 20;
end;

procedure TLazDockTree.BreakAnchors(Zone: TDockZone);
begin
  if Zone=nil then exit;
  if (Zone.ChildControl<>nil) and (Zone.ChildControl<>DockSite) then
  begin
    Zone.ChildControl.AnchorSide[akLeft].Control:=nil;
    Zone.ChildControl.AnchorSide[akTop].Control:=nil;
    Zone.ChildControl.Anchors:=[akLeft,akTop];
    Zone.ChildControl.BorderSpacing.Left:=0;
    Zone.ChildControl.BorderSpacing.Top:=0;
  end;
  BreakAnchors(Zone.FirstChild);
  BreakAnchors(Zone.NextSibling);
end;

procedure TLazDockTree.PaintDockFrame(ACanvas: TCanvas; AControl: TControl; const ARect: TRect);
var
  Pt: TPoint;
begin
  GetCursorPos(Pt);
  Pt := DockSite.ScreenToClient(Pt);
  TDockHeader.Draw(ACanvas, DockSite.GetDockCaption(AControl), FDockHeaderImages,
    AControl.DockOrientation, ARect, Pt);
end;

procedure TLazDockTree.CreateDockLayoutHelperControls(Zone: TLazDockZone);
var
  ParentPages: TLazDockPages;
  ZoneIndex: LongInt;
begin
  if Zone = nil then
    Exit;

  // create needed TLazDockSplitter
  if (Zone.Parent <> nil) and
     (Zone.Parent.Orientation in [doVertical,doHorizontal]) and
     (Zone.PrevSibling <> nil) then
  begin
    // a zone with a side sibling -> needs a TLazDockSplitter
    if Zone.Splitter = nil then
    begin
      Zone.Splitter := TLazDockSplitter.Create(nil);
      Zone.Splitter.Align := alNone;
    end;
  end
  else
  if Zone.Splitter <> nil then
  begin
    // zone no longer needs the splitter
    Zone.Splitter.Free;
    Zone.Splitter := nil;
  end;

  // create needed TLazDockPages
  if (Zone.Orientation = doPages) then
  begin
    // a zone of pages -> needs a TLazDockPages
    if Zone.FirstChild = nil then
      RaiseGDBException('TLazDockTree.CreateDockLayoutHelperControls Inconsistency: doPages without childs');
    if (Zone.Pages = nil) then
      Zone.Pages:=TLazDockPages.Create(nil);
  end
  else
  if Zone.Pages<>nil then
  begin
    // zone no longer needs the pages
    Zone.Pages.Free;
    Zone.Pages := nil;
  end;

  // create needed TLazDockPage
  if (Zone.Parent<>nil) and
     (Zone.Parent.Orientation = doPages) then
  begin
    // a zone as page -> needs a TLazDockPage
    if (Zone.Page = nil) then
    begin
      ParentPages := TLazDockZone(Zone.Parent).Pages;
      ZoneIndex := Zone.GetIndex;
      ParentPages.Pages.Insert(ZoneIndex,Zone.GetCaption);
      Zone.Page := ParentPages.Page[ZoneIndex];
    end;
  end
  else
  if Zone.Page <> nil then
  begin
    // zone no longer needs the page
    Zone.Page.Free;
    Zone.Page := nil;
  end;

  // create controls for childs and siblings
  CreateDockLayoutHelperControls(Zone.FirstChild as TLazDockZone);
  CreateDockLayoutHelperControls(Zone.NextSibling as TLazDockZone);
end;

procedure TLazDockTree.ResetSizes(Zone: TLazDockZone);
var
  NewSize, NewPos: Integer;
  Child: TLazDockZone;
begin
  if Zone = nil then
    Exit;

  // split available size between children
  if (Zone.Orientation in [doHorizontal, doVertical]) and
     (Zone.VisibleChildCount > 0) then
  begin
    NewSize := Zone.LimitSize div Zone.VisibleChildCount;
    NewPos := Zone.LimitBegin;
    Child := Zone.FirstChild as TLazDockZone;
    while Child <> nil do
    begin
      if Child.Visible then
      begin
        case Zone.Orientation of
          doHorizontal:
            begin
              Child.Top := NewPos;
              Child.Height := NewSize;
            end;
          doVertical:
            begin
              Child.Left := NewPos;
              Child.Width := NewSize;
            end;
        end;
        ResetSizes(Child);
        inc(NewPos, NewSize);
      end;
      Child := Child.NextSibling as TLazDockZone;
    end;
  end;
end;

procedure TLazDockTree.AdjustDockRect(AControl: TControl; var ARect: TRect);
begin
  // offset one of the borders of control rect in order to get space for frame
  case AControl.DockOrientation of
    doHorizontal:
      Inc(ARect.Top, DefaultDockGrabberSize);
    doVertical:
      Inc(ARect.Left, DefaultDockGrabberSize);
  end;
end;

procedure TLazDockTree.AnchorDockLayout(Zone: TLazDockZone);
// setup all anchors between all docked controls and helper controls
const
  SplitterWidth = 5;
  SplitterHeight = 5;
var
  AnchorControls: array[TAnchorKind] of TControl;
  a: TAnchorKind;
  SplitterSide: TAnchorKind;
  CurControl: TControl;
  NewSplitterAnchors: TAnchors;
  NewAnchors: TAnchors;
begin
  if Zone = nil then
    Exit;

  if Zone.Pages <> nil then
    CurControl := Zone.Pages
  else
    CurControl := Zone.ChildControl;
  //DebugLn(['TLazDockTree.AnchorDockLayout CurControl=',DbgSName(CurControl),' DockSite=',DbgSName(DockSite)]);
  if ((CurControl <> nil) and (CurControl <> DockSite)) or (Zone.Splitter <> nil) then
  begin
    // get outside anchor controls
    NewAnchors := [akLeft, akRight, akTop, akBottom];
    for a := Low(TAnchorKind) to High(TAnchorKind) do
      AnchorControls[a] := GetAnchorControl(Zone, a, true);

    // anchor splitter
    if (Zone.Splitter <> nil) then
    begin
      if Zone.Parent.Orientation = doHorizontal then
      begin
        SplitterSide := akTop;
        NewSplitterAnchors := [akLeft, akRight];
        Zone.Splitter.AnchorSide[akLeft].Side := asrTop;
        Zone.Splitter.AnchorSide[akRight].Side := asrBottom;
        Zone.Splitter.Height := SplitterHeight;
        if Zone.PrevSibling <> nil then
          Zone.Splitter.Top := (Zone.PrevSibling.Top + Zone.PrevSibling.Height) - DefaultDockGrabberSize;
        Zone.Splitter.ResizeAnchor := akBottom;
      end
      else
      begin
        SplitterSide := akLeft;
        NewSplitterAnchors := [akTop, akBottom];
        Zone.Splitter.AnchorSide[akTop].Side := asrTop;
        Zone.Splitter.AnchorSide[akBottom].Side := asrBottom;
        Zone.Splitter.Width := SplitterWidth;
        if Zone.PrevSibling <> nil then
          Zone.Splitter.Left := (Zone.PrevSibling.Left + Zone.PrevSibling.Width) - DefaultDockGrabberSize;
        Zone.Splitter.ResizeAnchor := akRight;
      end;
      // IMPORTANT: first set the AnchorSide, then set the Anchors
      for a := Low(TAnchorKind) to High(TAnchorKind) do
      begin
        if a in NewSplitterAnchors then
          Zone.Splitter.AnchorSide[a].Control := AnchorControls[a]
        else
          Zone.Splitter.AnchorSide[a].Control := nil;
      end;
      Zone.Splitter.Anchors := NewSplitterAnchors;
      Zone.Splitter.Parent := Zone.GetParentControl;
      AnchorControls[SplitterSide] := Zone.Splitter;
    end;

    if (CurControl <> nil) then
    begin
      // anchor pages
      // IMPORTANT: first set the AnchorSide, then set the Anchors
      //DebugLn(['TLazDockTree.AnchorDockLayout CurControl.Parent=',DbgSName(CurControl.Parent),' ',CurControl.Visible]);
      for a := Low(TAnchorKind) to High(TAnchorKind) do
      begin
        if AnchorControls[a] <> CurControl then
          CurControl.AnchorSide[a].Control := AnchorControls[a];
        if (AnchorControls[a] <> nil) and (AnchorControls[a].Parent = CurControl.Parent) then
          CurControl.AnchorSide[a].Side := DefaultSideForAnchorKind[a]
        else
          CurControl.AnchorSide[a].Side := DefaultSideForAnchorKind[OppositeAnchor[a]];
      end;
      CurControl.Anchors := NewAnchors;
      // set space for header
      case CurControl.DockOrientation of
        doHorizontal: CurControl.BorderSpacing.Top := DefaultDockGrabberSize;
        doVertical: CurControl.BorderSpacing.Left := DefaultDockGrabberSize;
      end;
    end;
  end;

  // anchor controls for childs and siblings
  AnchorDockLayout(Zone.FirstChild as TLazDockZone);
  AnchorDockLayout(Zone.NextSibling as TLazDockZone);
end;

constructor TLazDockTree.Create(TheDockSite: TWinControl);
begin
  FillChar(FMouseState, SizeOf(FMouseState), 0);
  TDockHeader.CreateDockHeaderImages(FDockHeaderImages);
  SetDockZoneClass(TLazDockZone);
  if TheDockSite = nil then
  begin
    TheDockSite := TLazDockForm.Create(nil);
    TheDockSite.DockManager := Self;
    FAutoFreeDockSite := True;
  end;
  inherited Create(TheDockSite);
end;

destructor TLazDockTree.Destroy;
begin
  if FAutoFreeDockSite then
  begin
    if DockSite.DockManager = Self then
      DockSite.DockManager := nil;
    DockSite.Free;
    DockSite := nil;
  end;
  TDockHeader.DestroyDockHeaderImages(FDockHeaderImages);
  inherited Destroy;
end;

procedure TLazDockTree.InsertControl(AControl: TControl; InsertAt: TAlign;
  DropControl: TControl);
{ undocks AControl and docks it into the tree
  It creates a new TDockZone for AControl and inserts it as a new leaf.
  It automatically changes the tree, so that the parent of the new TDockZone
  will have the Orientation for InsertAt.

  Example 1:

    A newly created TLazDockTree has only a DockSite (TLazDockForm) and a single
    TDockZone - the RootZone, which has as ChildControl the DockSite.

    Visual:
      +-DockSite--+
      |           |
      +-----------+
    Tree of TDockZone:
      RootZone (DockSite,doNoOrient)


  Inserting the first control:  InsertControl(Form1,alLeft,nil);
    Visual:
      +-DockSite---+
      |+--Form1---+|
      ||          ||
      |+----------+|
      +------------+
    Tree of TDockZone:
      RootZone (DockSite,doHorizontal)
       +-Zone2 (Form1,doNoOrient)


  Dock Form2 right of Form1:  InsertControl(Form2,alLeft,Form1);
    Visual:
      +-DockSite----------+
      |+-Form1-+|+-Form2-+|
      ||        ||       ||
      |+-------+|+-------+|
      +-------------------+
    Tree of TDockZone:
      RootZone (DockSite,doHorizontal)
       +-Zone2 (Form1,doNoOrient)
       +-Zone3 (Form2,doNoOrient)
}

  procedure PrepareControlForResize(AControl: TControl); inline;
  var
    a: TAnchorKind;
  begin
    AControl.Align := alNone;
    AControl.Anchors := [akLeft, akTop];
    for a := Low(TAnchorKind) to High(TAnchorKind) do
      AControl.AnchorSide[a].Control := nil;
    AControl.AutoSize := False;
  end;

var
  CtlZone, DropZone, OldParentZone, NewParentZone: TDockZone;
  NewZone: TLazDockZone;
  NewOrientation: TDockOrientation;
  NeedNewParentZone: Boolean;
  NewBounds: TRect;
begin
  CtlZone := RootZone.FindZone(AControl);
  if CtlZone <> nil then
    RemoveControl(AControl);

  if (DropControl = nil) or (DropControl = AControl) then
    DropControl := DockSite;

  DropZone := RootZone.FindZone(DropControl);
  if DropZone = nil then
    raise Exception.Create('TLazDockTree.InsertControl DropControl is not part of this TDockTree');

  NewOrientation := DockAlignOrientations[InsertAt];

  // undock
  UndockControlForDocking(AControl);

  // dock
  // create a new zone for AControl
  NewZone := DockZoneClass.Create(Self,AControl) as TLazDockZone;

  // insert new zone into tree
  if (DropZone = RootZone) and (RootZone.FirstChild = nil) then
  begin
    // this is the first child
    debugln('TLazDockTree.InsertControl First Child');
    //RootZone.Orientation := NewOrientation;
    RootZone.AddAsFirstChild(NewZone);
    AControl.DockOrientation := NewOrientation;
    if not AControl.Visible then
      DockSite.Visible := False;

    NewBounds := DockSite.ClientRect;
    AdjustDockRect(AControl, NewBounds);
    PrepareControlForResize(AControl);

    AControl.BoundsRect := NewBounds;
    AControl.Parent := DockSite;

    if AControl.Visible then
      DockSite.Visible := True;
  end else
  begin
    // there are already other childs

    // optimize DropZone
    if (DropZone.ChildCount>0) and
       (NewOrientation in [doHorizontal,doVertical]) and
       (DropZone.Orientation in [NewOrientation, doNoOrient]) then
    begin
      // docking on a side of an inner node is the same as docking to a side of
      // a child
      if InsertAt in [alLeft,alTop] then
        DropZone := DropZone.FirstChild
      else
        DropZone := DropZone.GetLastChild;
    end;

    // insert a new Parent Zone if needed
    NeedNewParentZone := True;
    if (DropZone.Parent <> nil) then
    begin
      if (DropZone.Parent.Orientation = doNoOrient) then
        NeedNewParentZone := False;
      if (DropZone.Parent.Orientation = NewOrientation) then
        NeedNewParentZone := False;
    end;
    if NeedNewParentZone then
    begin
      // insert a new zone between current DropZone.Parent and DropZone
      // this new zone will become the new DropZone.Parent
      OldParentZone := DropZone.Parent;
      NewParentZone := DockZoneClass.Create(Self, nil);
      if OldParentZone <> nil then
        OldParentZone.ReplaceChild(DropZone, NewParentZone);
      NewParentZone.AddAsFirstChild(DropZone);
      if RootZone = DropZone then
        FRootZone := NewParentZone;
    end;

    if DropZone.Parent = nil then
      RaiseGDBException('TLazDockTree.InsertControl Inconsistency DropZone.Parent=nil');
    // adjust Orientation in tree
    if DropZone.Parent.Orientation = doNoOrient then
    begin
      // child control already had orientation but now we moved it to parent
      // which can take another orientation => change child control orientation
      DropZone.Parent.Orientation := NewOrientation;
      if (DropZone.Parent.ChildCount = 1) and (DropZone.Parent.FirstChild.ChildControl <> nil) then
        DropZone.Parent.FirstChild.ChildControl.DockOrientation := NewOrientation;
    end;
    if DropZone.Parent.Orientation <> NewOrientation then
      RaiseGDBException('TLazDockTree.InsertControl Inconsistency DropZone.Orientation<>NewOrientation');

    // insert new node
    //DoDi: should insert relative to dropzone, not at begin/end of the parent zone
    DropZone.AddSibling(NewZone, InsertAt);

    // add AControl to DockSite
    PrepareControlForResize(AControl);
    AControl.DockOrientation := NewOrientation;
    AControl.Parent := NewZone.GetParentControl;
  end;

  // Build dock layout (anchors, splitters, pages)
  if NewZone.Parent <> nil then
    BuildDockLayout(NewZone.Parent as TLazDockZone)
  else
    BuildDockLayout(RootZone as TLazDockZone);
end;

procedure TLazDockTree.RemoveControl(AControl: TControl);
var
  RemoveZone, ParentZone: TLazDockZone;
begin
  RemoveZone := RootZone.FindZone(AControl) as TLazDockZone;

  // no such control => exit
  if RemoveZone = nil then
    Exit;

  // has children
  if (RemoveZone.ChildCount > 0) then
    raise Exception.Create('TLazDockTree.RemoveControl RemoveZone.ChildCount > 0');

  // destroy child zone and all parents if they does not contain anything else
  while (RemoveZone <> RootZone) and
        (RemoveZone.ChildCount = 0) do
  begin
    ParentZone := RemoveZone.Parent as TLazDockZone;
    RemoveZone.FreeSubComponents;
    if ParentZone <> nil then
      ParentZone.Remove(RemoveZone);
    RemoveZone.Free;
    // try with ParentZone now
    RemoveZone := ParentZone;
  end;

  // reset orientation
  if (RemoveZone.ChildCount = 1) and (RemoveZone.Orientation in [doHorizontal, doVertical]) then
    RemoveZone.Orientation := doNoOrient;

  // Build dock layout (anchors, splitters, pages)
  if (RemoveZone.Parent <> nil) then
    BuildDockLayout(RemoveZone.Parent as TLazDockZone)
  else
    BuildDockLayout(RootZone as TLazDockZone);
end;

procedure TLazDockTree.BuildDockLayout(Zone: TLazDockZone);
begin
  if DockSite <> nil then
    DockSite.DisableAlign;
  try
    BreakAnchors(Zone);
    CreateDockLayoutHelperControls(Zone);
    ResetSizes(Zone);
    AnchorDockLayout(Zone);
  finally
    if DockSite <> nil then
    begin
      DockSite.EnableAlign;
      DockSite.Invalidate;
    end;
  end;
end;

procedure TLazDockTree.FindBorderControls(Zone: TLazDockZone; Side: TAnchorKind;
  var List: TFPList);
begin
  if List=nil then List:=TFPList.Create;
  if Zone=nil then exit;

  if (Zone.Splitter<>nil) and (Zone.Parent<>nil)
  and (Zone.Orientation=doVertical) then begin
    // this splitter is leftmost, topmost, bottommost
    if Side in [akLeft,akTop,akBottom] then
      List.Add(Zone.Splitter);
    if Side=akLeft then begin
      // the splitter fills the whole left side => no more controls
      exit;
    end;
  end;
  if (Zone.Splitter<>nil) and (Zone.Parent<>nil)
  and (Zone.Orientation=doHorizontal) then begin
    // this splitter is topmost, leftmost, rightmost
    if Side in [akTop,akLeft,akRight] then
      List.Add(Zone.Splitter);
    if Side=akTop then begin
      // the splitter fills the whole top side => no more controls
      exit;
    end;
  end;
  if Zone.ChildControl<>nil then begin
    // the ChildControl fills the whole zone (except for the splitter)
    List.Add(Zone.ChildControl);
    exit;
  end;
  if Zone.Pages<>nil then begin
    // the pages fills the whole zone (except for the splitter)
    List.Add(Zone.Pages);
    exit;
  end;

  // go recursively through all child zones
  if (Zone.Parent<>nil) and (Zone.Orientation in [doVertical,doHorizontal])
  and (Zone.FirstChild<>nil) then
  begin
    if Side in [akLeft,akTop] then
      FindBorderControls(Zone.FirstChild as TLazDockZone,Side,List)
    else
      FindBorderControls(Zone.GetLastChild as TLazDockZone,Side,List);
  end;
end;

function TLazDockTree.FindBorderControl(Zone: TLazDockZone; Side: TAnchorKind
  ): TControl;
var
  List: TFPList;
begin
  Result:=nil;
  if Zone=nil then exit;
  List:=nil;
  FindBorderControls(Zone,Side,List);
  if (List=nil) or (List.Count=0) then
    Result:=DockSite
  else
    Result:=TControl(List[0]);
  List.Free;
end;

function TLazDockTree.GetAnchorControl(Zone: TLazDockZone; Side: TAnchorKind;
  OutSide: boolean): TControl;
// find a control to anchor the Zone's Side
begin
  if Zone = nil then
  begin
    Result := DockSite;
    exit;
  end;

  if not OutSide then
  begin
    // also check the Splitter and the Page
    if (Side = akLeft) and (Zone.Parent <> nil) and
       (Zone.Parent.Orientation = doVertical) and (Zone.Splitter<>nil) then
    begin
      Result := Zone.Splitter;
      exit;
    end;
    if (Side = akTop) and (Zone.Parent<>nil) and
       (Zone.Parent.Orientation=doHorizontal) and (Zone.Splitter<>nil) then
    begin
      Result := Zone.Splitter;
      exit;
    end;
    if (Zone.Page <> nil) then
    begin
      Result := Zone.Page;
      exit;
    end;
  end;

  // search the neighbour zones:
  Result := DockSite;
  if (Zone.Parent = nil) then
    Exit;

  case Zone.Parent.Orientation of
    doHorizontal:
      if (Side=akTop) and (Zone.PrevSibling<>nil) then
        Result:=FindBorderControl(Zone.PrevSibling as TLazDockZone,akBottom)
      else if (Side=akBottom) and (Zone.NextSibling<>nil) then
        Result:=FindBorderControl(Zone.NextSibling as TLazDockZone,akTop)
      else
        Result:=GetAnchorControl(Zone.Parent as TLazDockZone,Side,false);
    doVertical:
      if (Side=akLeft) and (Zone.PrevSibling<>nil) then
        Result:=FindBorderControl(Zone.PrevSibling as TLazDockZone,akRight)
      else if (Side=akRight) and (Zone.NextSibling<>nil) then
        Result:=FindBorderControl(Zone.NextSibling as TLazDockZone,akLeft)
      else
        Result:=GetAnchorControl(Zone.Parent as TLazDockZone,Side,false);
    doPages:
      Result:=GetAnchorControl(Zone.Parent as TLazDockZone,Side,false);
  end;
end;

procedure TLazDockTree.PaintSite(DC: HDC);
var
  ACanvas: TCanvas;
  ARect: TRect;
  i: integer;
begin
  // paint bounds for each control and close button
  if DockSite.ControlCount > 0 then
  begin
    ACanvas := TCanvas.Create;
    ACanvas.Handle := DC;
    try
      for i := 0 to DockSite.ControlCount - 1 do
      begin
        if (DockSite.Controls[i].HostDockSite = DockSite) and
           (DockSite.Controls[i].Visible) then
        begin
          ARect := DockSite.Controls[i].BoundsRect;
          case DockSite.Controls[i].DockOrientation of
            doHorizontal:
              begin
                ARect.Bottom := ARect.Top;
                Dec(ARect.Top, DefaultDockGrabberSize);
              end;
            doVertical:
              begin
                ARect.Right := ARect.Left;
                Dec(ARect.Left, DefaultDockGrabberSize);
              end;
          end;
          PaintDockFrame(ACanvas, DockSite.Controls[i], ARect);
        end;
      end;
    finally
      ACanvas.Free;
    end;
  end;
end;

procedure TLazDockTree.MessageHandler(Sender: TControl; var Message: TLMessage);

  procedure CheckNeedRedraw(AControl: TControl; ARect: TRect; APart: TLazDockHeaderPart);
  var
    NewMouseState: TDockHeaderMouseState;
  begin
    if AControl = nil then
      FillChar(ARect, SizeOf(ARect), 0)
    else
      ARect := TDockHeader.GetRectOfPart(ARect, AControl.DockOrientation, APart);
    // we cannot directly redraw this part since we should paint only in paint events
    FillChar(NewMouseState, SizeOf(NewMouseState), 0);
    NewMouseState.Rect := ARect;
    NewMouseState.IsMouseDown := (GetKeyState(VK_LBUTTON) and $80) <> 0;
    if not CompareMem(@FMouseState, @NewMouseState, SizeOf(NewMouseState)) then
    begin
      if not CompareRect(@FMouseState.Rect, @NewMouseState.Rect) then
        InvalidateRect(DockSite.Handle, @FMouseState.Rect, False);
      FMouseState := NewMouseState;
      InvalidateRect(DockSite.Handle, @NewMouseState.Rect, False);
    end;
  end;

  function GetControlHeaderRect(AControl: TControl; out ARect: TRect): Boolean;
  begin
    Result := True;
    ARect := AControl.BoundsRect;
    case AControl.DockOrientation of
      doHorizontal:
        begin
          ARect.Bottom := ARect.Top;
          Dec(ARect.Top, DefaultDockGrabberSize);
        end;
      doVertical:
        begin
          ARect.Right := ARect.Left;
          Dec(ARect.Left, DefaultDockGrabberSize);
        end;
      else
        Result := False;
    end;
  end;

  function FindControlAndPart(MouseMsg: TLMMouse; out ARect: TRect; out APart: TLazDockHeaderPart): TControl;
  var
    i: integer;
    Pt: TPoint;
  begin
    Pt := SmallPointToPoint(MouseMsg.Pos);
    for i := 0 to DockSite.ControlCount - 1 do
    begin
      if DockSite.Controls[i].HostDockSite = DockSite then
      begin
        if not GetControlHeaderRect(DockSite.Controls[i], ARect) then
          Continue;
        if not PtInRect(ARect, Pt) then
          Continue;
        // we have control here
        Result := DockSite.Controls[i];
        APart := TDockHeader.FindPart(ARect, Pt, DockSite.Controls[i].DockOrientation);
        Exit;
      end;
    end;
    Result := nil;
  end;

var
  ARect: TRect;
  Part: TLazDockHeaderPart;
  Control: TControl;
  AZone: TLazDockZone;
begin
  case Message.msg of
    LM_LBUTTONUP:
      begin
        Control := FindControlAndPart(TLMMouse(Message), ARect, Part);
        CheckNeedRedraw(Control, ARect, Part);
        TDockHeader.PerformMouseUp(Control, Part);
      end;
    LM_LBUTTONDOWN:
      begin
        Control := FindControlAndPart(TLMMouse(Message), ARect, Part);
        CheckNeedRedraw(Control, ARect, Part);
        TDockHeader.PerformMouseDown(Control, Part);
      end;
    LM_MOUSEMOVE:
      begin
        Control := FindControlAndPart(TLMMouse(Message), ARect, Part);
        CheckNeedRedraw(Control, ARect, Part);
      end;
    CM_MOUSELEAVE:
      CheckNeedRedraw(nil, Rect(0,0,0,0), ldhpAll);
    CM_TEXTCHANGED:
      begin
        if GetControlHeaderRect(Sender, ARect) then
        begin
          ARect := TDockHeader.GetRectOfPart(ARect, Sender.DockOrientation, ldhpCaption);
          InvalidateRect(DockSite.Handle, @ARect, False);
        end;
      end;
    CM_VISIBLECHANGED:
      begin
        if not (csDestroying in Sender.ComponentState) then
        begin
          AZone := RootZone.FindZone(Sender) as TLazDockZone;
          if AZone <> nil then
            BuildDockLayout(TLazDockZone(AZone.Parent));
        end;
      end;
    LM_SIZE, LM_MOVE:
      begin
        if GetControlHeaderRect(Sender, ARect) then
          InvalidateRect(DockSite.Handle, @ARect, False);
      end;
  end
end;

procedure TLazDockTree.DumpLayout(FileName: String);
var
  Stream: TStream;

  procedure WriteLn(S: String);
  begin
    S := S + #$D#$A;
    Stream.Write(S[1], Length(S));
  end;

  procedure WriteHeader;
  begin
    WriteLn('<HTML>');
    WriteLn('<HEAD>');
    WriteLn('<TITLE>Dock Layout</TITLE>');
    WriteLn('<META content="text/html; charset=utf-8" http-equiv=Content-Type>');
    WriteLn('</HEAD>');
    WriteLn('<BODY>');
  end;

  procedure WriteFooter;
  begin
    WriteLn('</BODY>');
    WriteLn('</HTML>');
  end;

  procedure DumpAnchors(Title: String; AControl: TControl);
  var
    a: TAnchorKind;
    S, Name: String;
  begin
    S := Title;
    if AControl.Anchors <> [] then
    begin
      S := S + '<UL>';
      for a := Low(TAnchorKind) to High(TAnchorKind) do
        if a in AControl.Anchors then
        begin
          Name := DbgsName(AControl.AnchorSide[a].Control);
          if (AControl.AnchorSide[a].Control <> nil) and (AControl.AnchorSide[a].Control.Name = '') then
            Name := dbgs(AControl.AnchorSide[a].Control) + Name;
          S := S + '<LI><b>' + GetEnumName(TypeInfo(TAnchorKind), Ord(a)) + '</b> = ' +
             Name + ' (' +
             GetEnumName(TypeInfo(TAnchorSideReference), Ord(AControl.AnchorSide[a].Side)) +
             ')' + '</LI>';
        end;
      S := S + '</UL>';
    end
    else
      S := S + '[]';
    WriteLn(S);
  end;

  procedure DumpZone(Zone: TDockZone);
  const
    DumpStr = 'Zone: Orientation = <b>%s</b>, ChildCount = <b>%d</b>, ChildControl = <b>%s</b>, %s, Splitter = <b>%s</b>';
    StrOrientation: array[TDockOrientation] of String =
    (
      'doNoOrient',
      'doHorizontal',
      'doVertical',
      'doPages'
    );
  begin
    WriteLn(Format(DumpStr, [StrOrientation[Zone.Orientation], Zone.ChildCount,
      DbgSName(Zone.ChildControl), DbgS(Bounds(Zone.Left, Zone.Top, Zone.Width, Zone.Height)),
      dbgs(TLazDockZone(Zone).Splitter)]));
    if TLazDockZone(Zone).Splitter <> nil then
      DumpAnchors('<br>Splitter anchors: ', TLazDockZone(Zone).Splitter);
    if Zone.ChildControl <> nil then
      DumpAnchors('<br>ChildControl anchors: ', Zone.ChildControl);
  end;

  procedure WriteZone(Zone: TDockZone);
  begin
    if Zone <> nil then
    begin
      WriteLn('<LI>');
      DumpZone(Zone);
      if Zone.ChildCount > 0 then
      begin
        WriteLn('<OL>');
        WriteZone(Zone.FirstChild);
        WriteLn('</OL>');
      end;
      WriteLn('</LI>');
      WriteZone(Zone.NextSibling);
    end;
  end;

  procedure WriteLayout;
  begin
    WriteLn('<OL>');
    WriteZone(RootZone);
    WriteLn('</OL>');
  end;

begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    WriteHeader;
    WriteLayout;
    WriteFooter;
  finally
    Stream.Free;
  end;
end;

{ TLazDockZone }

destructor TLazDockZone.Destroy;
begin
  FreeSubComponents;
  inherited Destroy;
end;

procedure TLazDockZone.FreeSubComponents;
begin
  FreeAndNil(FSplitter);
  FreeAndNil(FPage);
  FreeAndNil(FPages);
end;

function TLazDockZone.GetCaption: string;
begin
  if ChildControl<>nil then
    Result:=ChildControl.Caption
  else
    Result:=IntToStr(GetIndex);
end;

function TLazDockZone.GetParentControl: TWinControl;
var
  Zone: TDockZone;
begin
  Result := nil;
  Zone := Parent;
  while Zone <> nil do
  begin
    if Zone.Orientation = doPages then
      Exit((Zone as TLazDockZone).Pages);

    if (Zone.Parent = nil) then
    begin
      if Zone.ChildControl is TWinControl then
        Result := TWinControl(Zone.ChildControl)
      else
      if Zone = Tree.RootZone then
        Result := Tree.DockSite;
      Exit;
    end;
    Zone := Zone.Parent;
  end;
end;

{ TCustomAnchoredDockManager }

procedure TCustomAnchoredDockManager.DeleteSideSplitter(Splitter: TLazDockSplitter;
  Side: TAnchorKind; NewAnchorControl: TControl);
var
  SplitterParent: TWinControl;
  i: Integer;
  CurControl: TControl;
  NewSideRef: TAnchorSideReference;
begin
  //DebugLn('TCustomAnchoredDockManager.DeleteSideSplitter Splitter=',DbgSName(Splitter),' Side=',dbgs(Side),' NewAnchorControl=',DbgSName(NewAnchorControl));
  SplitterParent:=Splitter.Parent;
  SplitterParent.DisableAlign;
  try
    for i:=0 to SplitterParent.ControlCount-1 do begin
      CurControl:=SplitterParent.Controls[i];
      if CurControl.AnchorSide[Side].Control=Splitter then begin
        CurControl.AnchorSide[Side].Control:=NewAnchorControl;
        if NewAnchorControl=CurControl.Parent then
          NewSideRef:=DefaultSideForAnchorKind[OppositeAnchor[Side]]
        else
          NewSideRef:=DefaultSideForAnchorKind[Side];
        CurControl.AnchorSide[Side].Side:=NewSideRef;
        //DebugLn('TCustomAnchoredDockManager.DeleteSideSplitter Anchor ',DbgSName(CurControl),'(',dbgs(Side),') to ',DbgSName(NewAnchorControl));
      end;
    end;
    Splitter.Free;
  finally
    SplitterParent.EnableAlign;
  end;
end;

procedure TCustomAnchoredDockManager.CombineSpiralSplitterPair(Splitter1,
  Splitter2: TLazDockSplitter);
{  - Anchor all controls anchored to Splitter2 to Splitter1
   - extend Splitter1
   - delete Splitter2

   Example:

   Four spiral splitters:

     Before:
              |
           A  |
     ---------|
       | +--+ |  C
     B | |  | |
       | +--+ |
       | ----------
       |   D

     The left and right splitter will be combined to one.

     After:
              |
           A  |
       -------|
              |  C
            B |
              |
              |------
              |   D
  }

  procedure MoveAnchorSide(AControl: TControl; Side: TAnchorKind);
  begin
    if AControl.AnchorSide[Side].Control=Splitter2 then
      AControl.AnchorSide[Side].Control:=Splitter1;
  end;

  procedure EnlargeSplitter(Side: TAnchorKind);
  begin
    if GetAnchorDepth(Splitter1,Side)>GetAnchorDepth(Splitter2,Side) then
      Splitter1.AnchorSide[Side].Assign(Splitter2.AnchorSide[Side]);
  end;

var
  LeftRightSplitter: boolean;
  ParentControl: TWinControl;
  i: Integer;
  CurControl: TControl;
begin
  DebugLn('TCustomAnchoredDockManager.CombineSpiralSplitterPair Splitter1=',DbgSName(Splitter1),dbgs(Splitter1.BoundsRect),' Splitter2=',DbgSName(Splitter2),dbgs(Splitter2.BoundsRect));
  // check splitters have the same Parent
  ParentControl:=Splitter1.Parent;
  if (ParentControl=nil) then
    RaiseGDBException('TCustomAnchoredDockManager.CombineSpiralSplitterPair Inconsistency: Parent=nil');
  if (ParentControl<>Splitter2.Parent) then
    RaiseGDBException('TCustomAnchoredDockManager.CombineSpiralSplitterPair Inconsistency: Splitters not siblings');
  // check splitters have same orientation
  LeftRightSplitter:=(Splitter1.ResizeAnchor in [akLeft,akRight]);
  if LeftRightSplitter<>(Splitter2.ResizeAnchor in [akLeft,akRight]) then
    RaiseGDBException('TCustomAnchoredDockManager.CombineSpiralSplitterPair Inconsistency: different orientation');

  ParentControl.DisableAlign;
  try
    // move incident anchors from Splitter2 to Splitter1
    for i:=0 to ParentControl.ControlCount-1 do begin
      CurControl:=ParentControl.Controls[i];
      if CurControl=Splitter1 then continue;
      if CurControl=Splitter2 then continue;
      if LeftRightSplitter then begin
        MoveAnchorSide(CurControl,akLeft);
        MoveAnchorSide(CurControl,akRight);
      end else begin
        MoveAnchorSide(CurControl,akTop);
        MoveAnchorSide(CurControl,akBottom);
      end;
    end;

    // enlarge Splitter1
    if LeftRightSplitter then begin
      // enlarge Splitter1 to top and bottom
      EnlargeSplitter(akTop);
      EnlargeSplitter(akBottom);
    end else begin
      // enlarge Splitter1 to left and right
      EnlargeSplitter(akLeft);
      EnlargeSplitter(akRight);
    end;

    // delete Splitter2
    Splitter2.Free;
  finally
    ParentControl.EnableAlign;
  end;
end;

procedure TCustomAnchoredDockManager.DeletePage(Page: TLazDockPage);
var
  Pages: TLazDockPages;
begin
  DebugLn('TCustomAnchoredDockManager.DeletePage Page=',DbgSName(Page));
  Pages:=Page.PageControl;
  Page.Free;
  if Pages.PageCount=0 then
    DeletePages(Pages);
end;

procedure TCustomAnchoredDockManager.DeletePages(Pages: TLazDockPages);
begin
  DebugLn('TCustomAnchoredDockManager.DeletePages Pages=',DbgSName(Pages));
  if Pages.Parent<>nil then
    UndockControl(Pages,false);
  Pages.Free;
end;

procedure TCustomAnchoredDockManager.DeleteDockForm(ADockForm: TLazDockForm);
begin
  DebugLn('TCustomAnchoredDockManager.DeleteDockForm ADockForm=',DbgSName(ADockForm));
  if ADockForm.Parent<>nil then
    UndockControl(ADockForm,false);
  ADockForm.DockManager:=nil;
  ADockForm.UseDockManager:=false;
  Application.ReleaseComponent(ADockForm);
end;

function TCustomAnchoredDockManager.GetAnchorDepth(AControl: TControl;
  Side: TAnchorKind): Integer;
var
  NewControl: TControl;
begin
  Result:=0;
  while (AControl<>nil) do begin
    inc(Result);
    if not (Side in AControl.Anchors) then break; // loose end
    NewControl:=AControl.AnchorSide[Side].Control;
    if NewControl=nil then break; // loose end
    if NewControl.Parent<>AControl.Parent then break; // parent end
    if Result>AControl.Parent.ControlCount then break; // circle
    AControl:=NewControl;
  end;
end;

function TCustomAnchoredDockManager.GetPreferredTitlePosition(AWidth,
  AHeight: integer): TAnchorKind;
begin
  if AWidth>((AHeight*3) div 2) then
    Result:=akLeft
  else
    Result:=akTop;
end;

procedure TCustomAnchoredDockManager.UpdateTitlePosition(Control: TControl);
var
  TitlePos: TAnchorKind;
begin
  if Control.Parent is TLazDockForm then begin
    TitlePos:=GetPreferredTitlePosition(Control.Width,Control.Height);
    if TitlePos=akLeft then begin
      Control.BorderSpacing.Left:=TitleWidth;
      Control.BorderSpacing.Top:=0;
    end else begin
      Control.BorderSpacing.Left:=0;
      Control.BorderSpacing.Top:=TitleHeight;
    end;
  end else begin
    Control.BorderSpacing.Left:=0;
    Control.BorderSpacing.Top:=0;
  end;
end;

constructor TCustomAnchoredDockManager.Create;
begin
  FOwnerComponent:=TLazDockOwnerComponent.Create(nil);
  FSplitterSize:=5;
  FTitleWidth:=20;
  FTitleHeight:=20;
end;

destructor TCustomAnchoredDockManager.Destroy;
begin
  FreeAndNil(FOwnerComponent);
  inherited Destroy;
end;

procedure TCustomAnchoredDockManager.BeginUpdate;
begin
  inc(FUpdateCount);
end;

procedure TCustomAnchoredDockManager.EndUpdate;
begin
  if FUpdateCount<=0 then
    RaiseGDBException('TCustomAnchoredDockManager.EndUpdate');
  dec(FUpdateCount);
  if FUpdateCount=0 then begin

  end;
end;

procedure TCustomAnchoredDockManager.GetControlBounds(Control: TControl;
  out AControlBounds: TRect);
begin
  AControlBounds:=Control.BoundsRect;
end;

procedure TCustomAnchoredDockManager.DisableLayout(Control: TControl);
begin

end;

procedure TCustomAnchoredDockManager.EnableLayout(Control: TControl);
begin

end;

{-------------------------------------------------------------------------------
  procedure TCustomAnchoredDockManager.DockControl(Control: TControl;
    InsertAt: TAlign; DropCtl: TControl);

  Docks Control to or into DropCtl.
  Control.Parent must be nil.

  If InsertAt in [alLeft,alTop,alRight,alBottom] then Control will be docked to
  the side of DropCtl.
  Otherwise it is docked as Page to a TLazDockPages.

  Docking to a side:
    If DockCtl.Parent=nil then a parent will be created via
    DropCtl.ManualFloat.
    Then Control is added as child to DockCtl.Parent.
    Then a Splitter is added.
    Then all three are anchored.

  Docking as page:
    if DropCtl.Parent is not a TLazDockPage then a new TLazDockPages is created
    and replaces DropCtl and DropCtl is added as page.
    Then Control is added as page.
-------------------------------------------------------------------------------}
procedure TCustomAnchoredDockManager.DockControl(Control: TControl;
  InsertAt: TAlign; DropCtl: TControl);
var
  Splitter: TLazDockSplitter;
  NewDropCtlBounds: TRect;
  NewControlBounds: TRect;
  NewDropCtlWidth: Integer;
  SplitterBounds: TRect;
  a: TAnchorKind;
  ControlAnchor: TAnchorKind;
  DropCtlAnchor: TAnchorKind;
  NewDropCtlHeight: Integer;
  SplitterWidth: LongInt;
  SplitterHeight: LongInt;
  DockPages: TLazDockPages;
  DropCtlPage: TLazDockPage;
  NewPageIndex: Integer;
  NewPage: TLazDockPage;
  NewParent: TLazDockForm;
  ParentDisabledAlign: Boolean;
  DropCtlTitlePos: TAnchorKind;
begin
  if Control.Parent<>nil then
    RaiseGDBException('TCustomAnchoredDockManager.InsertControl Control.Parent<>nil');
  if Control=DropCtl then
    RaiseGDBException('TCustomAnchoredDockManager.InsertControl Control=DropCtl');
  DisableLayout(Control);
  DisableLayout(DropCtl);
  try

    // dock Control to DropCtl
    case InsertAt of
    alLeft,alTop,alRight,alBottom:
      begin
        // dock Control to a side of DropCtl
        // e.g. alLeft: insert Control to the left of DropCtl

        DropCtlAnchor:=MainAlignAnchor[InsertAt];
        ControlAnchor:=OppositeAnchor[DropCtlAnchor];

        DropCtlTitlePos:=GetPreferredTitlePosition(DropCtl.ClientWidth,
                                                   DropCtl.ClientHeight);

        ParentDisabledAlign := False;
        try
          NewDropCtlBounds:=DropCtl.BoundsRect;
          if DropCtlTitlePos=akLeft then
            inc(NewDropCtlBounds.Right,TitleWidth)
          else
            inc(NewDropCtlBounds.Bottom,TitleHeight);

          // make sure, there is a parent HostSite
          if DropCtl.Parent=nil then begin
            // remember bounds
            NewDropCtlBounds:=Rect(0,0,DropCtl.ClientWidth,DropCtl.ClientHeight);
            // create a TLazDockForm as new parent with the size of DropCtl
            NewParent := CreateForm;// starts with Visible=false
            NewParent.DisableAlign;
            ParentDisabledAlign := True;
            NewParent.BoundsRect:=DropCtl.BoundsRect;
            // move the WindowState to the new parent
            if DropCtl is TCustomForm then
            begin
              NewParent.WindowState:=TCustomForm(DropCtl).WindowState;
              TCustomForm(DropCtl).WindowState:=wsNormal;
            end;
            // first move DropCtl to the invsible parent, so changes do not cause flicker
            DropCtl.Dock(NewParent, Rect(0, 0, 0, 0));
            // init anchors of DropCtl
            DropCtl.Align:=alNone;
            DropCtl.AnchorClient(0);
            DropCtl.Anchors:=[akLeft,akTop,akRight,akBottom];
            DropCtl.Visible:=true;
            NewParent.Visible:=true;
            //DebugLn('TCustomAnchoredDockManager.DockControl DropCtl=',DbgSName(DropCtl),' NewParent.BoundsRect=',dbgs(NewParent.BoundsRect));
          end else begin
            if (DropCtl.Parent is TLazDockForm) then begin
              // ok
            end else if (DropCtl.Parent is TLazDockPage) then begin
              // ok
            end else begin
              RaiseGDBException('TCustomAnchoredDockManager.InsertControl DropCtl has invalid parent');
            end;
          end;

          if not ParentDisabledAlign then
          begin
            DropCtl.Parent.DisableAlign;
            ParentDisabledAlign := True;
          end;
          // create a splitter
          Splitter := TLazDockSplitter.Create(Control);
          Splitter.Align:=alNone;
          Splitter.Beveled:=true;
          Splitter.ResizeAnchor:=ControlAnchor;
          //debugln('TCustomAnchoredDockManager.InsertControl A Control.Bounds=',DbgSName(Control),dbgs(Control.BoundsRect),' DropCtl.Bounds=',DbgSName(DropCtl),dbgs(DropCtl.BoundsRect),' Splitter.Bounds=',DbgSName(Splitter),dbgs(Splitter.BoundsRect));

          // calculate new bounds
          NewControlBounds := NewDropCtlBounds;
          if InsertAt in [alLeft,alRight] then begin
            SplitterWidth:=Splitter.Constraints.MinMaxWidth(SplitterSize);
            NewDropCtlWidth:=NewDropCtlBounds.Right-NewDropCtlBounds.Left;
            dec(NewDropCtlWidth,Control.Width+SplitterWidth);
            NewDropCtlWidth:=DropCtl.Constraints.MinMaxWidth(NewDropCtlWidth);
            if InsertAt=alLeft then begin
              // alLeft: insert Control to the left of DropCtl
              NewDropCtlBounds.Left:=NewDropCtlBounds.Right-NewDropCtlWidth;
              NewControlBounds.Right:=NewDropCtlBounds.Left-SplitterWidth;
              SplitterBounds:=Rect(NewControlBounds.Right,NewDropCtlBounds.Top,
                                   NewDropCtlBounds.Left,NewDropCtlBounds.Bottom);
            end else begin
              // alRight: insert Control to the right of DropCtl
              NewDropCtlBounds.Right:=NewDropCtlBounds.Left+NewDropCtlWidth;
              NewControlBounds.Left:=NewDropCtlBounds.Right+SplitterWidth;
              SplitterBounds:=Rect(NewDropCtlBounds.Right,NewDropCtlBounds.Top,
                                   NewControlBounds.Left,NewDropCtlBounds.Bottom);
              //debugln('TCustomAnchoredDockManager.InsertControl A NewDropCtlBounds=',dbgs(NewDropCtlBounds),' NewControlBounds=',dbgs(NewControlBounds),' SplitterBounds=',dbgs(SplitterBounds));
            end;
          end else begin
            SplitterHeight:=Splitter.Constraints.MinMaxHeight(SplitterSize);
            NewDropCtlHeight:=NewDropCtlBounds.Bottom-NewDropCtlBounds.Top;
            dec(NewDropCtlHeight,Control.Height+SplitterHeight);
            NewDropCtlHeight:=DropCtl.Constraints.MinMaxHeight(NewDropCtlHeight);
            if InsertAt=alTop then begin
              // alTop: insert Control to the top of DropCtl
              NewDropCtlBounds.Top:=NewDropCtlBounds.Bottom-NewDropCtlHeight;
              NewControlBounds.Bottom:=NewDropCtlBounds.Top-SplitterHeight;
              SplitterBounds:=Rect(NewDropCtlBounds.Left,NewControlBounds.Bottom,
                                   NewDropCtlBounds.Right,NewDropCtlBounds.Top);
            end else begin
              // alBottom: insert Control to the bottom of DropCtl
              NewDropCtlBounds.Bottom:=NewDropCtlBounds.Top+NewDropCtlHeight;
              NewControlBounds.Top:=NewDropCtlBounds.Bottom+SplitterHeight;
              SplitterBounds:=Rect(NewDropCtlBounds.Left,NewDropCtlBounds.Bottom,
                                   NewDropCtlBounds.Right,NewControlBounds.Top);
            end;
            //debugln('TCustomAnchoredDockManager.InsertControl A NewDropCtlBounds=',dbgs(NewDropCtlBounds),' NewControlBounds=',dbgs(NewControlBounds),' SplitterBounds=',dbgs(SplitterBounds));
          end;

          // position splitter
          Splitter.BoundsRect:=SplitterBounds;
          if InsertAt in [alLeft,alRight] then begin
            Splitter.AnchorSide[akTop].Assign(DropCtl.AnchorSide[akTop]);
            Splitter.AnchorSide[akBottom].Assign(DropCtl.AnchorSide[akBottom]);
            Splitter.Anchors:=[akLeft,akTop,akBottom];
          end else begin
            Splitter.AnchorSide[akLeft].Assign(DropCtl.AnchorSide[akLeft]);
            Splitter.AnchorSide[akRight].Assign(DropCtl.AnchorSide[akRight]);
            Splitter.Anchors:=[akLeft,akTop,akRight];
          end;
          Splitter.Parent := DropCtl.Parent;

          // position Control
          Control.Align := alNone;
          for a:=Low(TAnchorKind) to High(TAnchorKind) do begin
            Control.AnchorSide[a].Control:=nil;
            Control.BorderSpacing.Space[a]:=0;
          end;
          Control.AnchorSide[DropCtlAnchor].Assign(DropCtl.AnchorSide[DropCtlAnchor]);
          Control.AnchorToNeighbour(ControlAnchor,0,Splitter);
          if InsertAt in [alLeft,alRight] then begin
            Control.AnchorSide[akTop].Assign(DropCtl.AnchorSide[akTop]);
            Control.AnchorSide[akBottom].Assign(DropCtl.AnchorSide[akBottom]);
          end else begin
            Control.AnchorSide[akLeft].Assign(DropCtl.AnchorSide[akLeft]);
            Control.AnchorSide[akRight].Assign(DropCtl.AnchorSide[akRight]);
          end;
          Control.Anchors := [akLeft,akTop,akRight,akBottom];
          Control.Dock(DropCtl.Parent, Rect(0, 0, 0, 0));
          Control.Visible := true;

          // position DropCtl
          DropCtl.AnchorToNeighbour(DropCtlAnchor,0,Splitter);

          // set titles
          UpdateTitlePosition(DropCtl);
          UpdateTitlePosition(Control);

          //debugln('TCustomAnchoredDockManager.InsertControl BEFORE ALIGNING Control.Bounds=',DbgSName(Control),dbgs(Control.BoundsRect),' DropCtl.Bounds=',DbgSName(DropCtl),dbgs(DropCtl.BoundsRect),' Splitter.Bounds=',DbgSName(Splitter),dbgs(Splitter.BoundsRect));
        finally
          // in case of Exception inside try-finally Parent can be nil
          if ParentDisabledAlign and (DropCtl.Parent <> nil) then
            DropCtl.Parent.EnableAlign;
        end;
        //debugln('TCustomAnchoredDockManager.InsertControl END Control.Bounds=',DbgSName(Control),dbgs(Control.BoundsRect),' DropCtl.Bounds=',DbgSName(DropCtl),dbgs(DropCtl.BoundsRect),' Splitter.Bounds=',DbgSName(Splitter),dbgs(Splitter.BoundsRect));
      end;

    alClient:
      begin
        // docking as page
        DebugLn('TCustomAnchoredDockManager.InsertControl alClient DropCtl=',DbgSName(DropCtl),' Control=',DbgSName(Control));

        if not (DropCtl.Parent is TLazDockPage) then begin
          // create a new TLazDockPages
          //DebugLn('TCustomAnchoredDockManager.InsertControl Create TLazDockPages');
          DockPages:=TLazDockPages.Create(nil);
          if DropCtl.Parent<>nil then begin
            // DockCtl is a child control
            // => replace the anchors to and from DockCtl with the new DockPages
            ReplaceAnchoredControl(DropCtl,DockPages);
          end else begin
            // DockCtl has no parent
            // => float DockPages
            DockPages.ManualFloat(DropCtl.BoundsRect);
            DockPages.AnchorClient(0);
          end;
          // add DockCtl as page to DockPages
          DockPages.Pages.Add(DropCtl.Caption);
          DropCtlPage:=DockPages.Page[0];
          DropCtlPage.DisableAlign;
          try
            DropCtl.Dock(DropCtlPage, Rect(0,0,0,0));
            DropCtl.AnchorClient(0);
          finally
            DropCtlPage.EnableAlign;
          end;
        end;
        // add Control as new page behind the page of DockCtl
        DropCtlPage:=DropCtl.Parent as TLazDockPage;
        DockPages:=DropCtlPage.PageControl as TLazDockPages;
        NewPageIndex:=DropCtlPage.PageIndex+1;
        DockPages.Pages.Insert(NewPageIndex,Control.Caption);
        NewPage:=DockPages.Page[NewPageIndex];
        DebugLn(['TCustomAnchoredDockManager.DockControl NewPage=',NewPage.Caption,' Control=',Control.Caption,',',DbgSName(Control)]);
        NewPage.DisableAlign;
        try
          if DropCtl is TCustomForm then
            TCustomForm(DropCtl).WindowState:=wsNormal;
          Control.Dock(NewPage, Rect(0, 0, 0, 0));
          Control.AnchorClient(0);
        finally
          NewPage.EnableAlign;
        end;
      end;
    else
      RaiseGDBException('TCustomAnchoredDockManager.InsertControl TODO');
    end;
  finally
    EnableLayout(Control);
    EnableLayout(DropCtl);
  end;
end;

{-------------------------------------------------------------------------------
  procedure TCustomAnchoredDockManager.UndockControl(Control: TControl);

  Removes a control from a docking form.
  It breaks all anchors and cleans up.

  The created gap will be tried to fill up.
  It removes TLazDockSplitter, TLazDockPage and TLazDockPages if they are no
  longer needed.
-------------------------------------------------------------------------------}
procedure TCustomAnchoredDockManager.UndockControl(Control: TControl; Float: boolean);
{

  Examples:

  Search Order:

  1. A TLazDockSplitter dividing only two controls:

     Before:
     |-------------
     | +--+ | +---
     | |  | | | B
     | +--+ | +---
     |-------------

     The splitter will be deleted and the right control will be anchored to the
     left.

     After:
     |-------------
     | +---
     | | B
     | +---
     |-------------


  2. Four spiral splitters:

     Before:
              |
           A  |
     ---------|
       | +--+ |  C
     B | |  | |
       | +--+ |
       | ----------
       |   D

     The left and right splitter will be combined to one.

     After:
              |
           A  |
       -------|
              |  C
            B |
              |
              |------
              |   D


  3. No TLazDockSplitter. Control is the only child of a TLazDockPage
     In this case the page will be deleted.
     If the TLazDockPages has no childs left, it is recursively undocked.

  4. No TLazDockSplitter, Control is the only child of a TLazDockForm.
     The TLazDockForm is deleted and the Control is floated.
     This normally means: A form will simply be placed on the desktop, other
     controls will be docked into their DockSite.

  5. Otherwise: this control was not docked.
}
var
  AnchorControl: TControl;
  AnchorSplitter: TLazDockSplitter;
  i: Integer;
  Sibling: TControl;
  OldAnchorControls: array[TAnchorKind] of TControl;
  IsSpiralSplitter: Boolean;
  ParentControl: TWinControl;
  Done: Boolean;

  procedure DoFinallyForParent;
  var
    OldParentControl: TWinControl;
    NewBounds: TRect;
    NewOrigin: TPoint;
    OtherControl: TControl;
    a: TAnchorKind;
  begin
    try
      NewBounds:=Control.BoundsRect;
      NewOrigin:=Control.ControlOrigin;
      OffsetRect(NewBounds,NewOrigin.X,NewOrigin.Y);
      if Float then begin
        Control.ManualFloat(NewBounds);
        if Control.Parent<>nil then
          Control.AnchorClient(0);
      end else if Control.Parent<>nil then begin
        Control.Anchors:=[akLeft,akTop];
        for a:=Low(TAnchorKind) to High(TAnchorKind) do
          Control.AnchorSide[a].Control:=nil;
        Control.BoundsRect:=NewBounds;
        Control.Parent:=nil;
      end;
    finally
      if (ParentControl<>nil) then begin
        OldParentControl:=ParentControl;
        ParentControl:=nil;
        DebugLn(['DoFinallyForParent EnableAlign for ',DbgSName(OldParentControl),' Control=',DbgSName(Control),' OldParentControl.ControlCount=',OldParentControl.ControlCount]);
        OldParentControl.EnableAlign;

        // check if the remaining is a TLazDockForm with only one child
        if (OldParentControl is TLazDockForm)
        and (OldParentControl.ControlCount=1) then
        begin
          OtherControl:=OldParentControl.Controls[0];
          DebugLn(['DoFinallyForParent OtherControl=',DbgSName(OtherControl)]);
          if (OtherControl is TWinControl)
          and (TWinControl(OtherControl).UseDockManager)
          and (TWinControl(OtherControl).DockManager=Self)
          then begin
            UndockControl(OtherControl,true);
          end;
        end;

        //OldParentControl.WriteLayoutDebugReport('X  ');
      end;
    end;
  end;

var
  OldParentPage: TLazDockPage;
  OldParentForm: TLazDockForm;
  a: TAnchorKind;
begin
  if Control.Parent=nil then begin
    // already undocked
    RaiseGDBException('TCustomAnchoredDockManager.UndockControl Control.Parent=nil');
  end;

  ParentControl:=Control.Parent;
  ParentControl.DisableAlign;
  try
    // break anchors
    Control.Align:=alNone;
    for a:=Low(TAnchorKind) to High(TAnchorKind) do begin
      OldAnchorControls[a]:=Control.AnchorSide[a].Control;
      Control.AnchorSide[a].Control:=nil;
    end;
    Control.Anchors:=[akLeft,akTop];

    Done:=false;

    if not Done then begin
      // check if there is a splitter, that has a side with only 'Control'
      // anchored to it.
      for a:=Low(TAnchorKind) to High(TAnchorKind) do begin
        AnchorControl:=OldAnchorControls[a];
        if AnchorControl is TLazDockSplitter then begin
          AnchorSplitter:=TLazDockSplitter(AnchorControl);
          i:=ParentControl.ControlCount-1;
          while i>=0 do begin
            Sibling:=ParentControl.Controls[i];
            if (Sibling.AnchorSide[a].Control=AnchorSplitter) then begin
              // Sibling is anchored with the same side to the splitter
              // => this splitter is needed, can not be deleted.
              //DebugLn('TCustomAnchoredDockManager.UndockControl Splitter still needed: ',DbgSName(AnchorSplitter),'(',dbgs(AnchorSplitter.BoundsRect),') by ',DbgSName(Sibling));
              break;
            end;
            dec(i);
          end;
          if i<0 then begin
            // this splitter is not needed anymore
            //DebugLn('TCustomAnchoredDockManager.UndockControl Splitter not needed: ',DbgSName(AnchorSplitter),'(',dbgs(AnchorSplitter.BoundsRect),')');
            DeleteSideSplitter(AnchorSplitter,OppositeAnchor[a],
                               OldAnchorControls[OppositeAnchor[a]]);
            Done:=true;
          end;
        end;
      end;
    end;

    if not Done then begin
      // check if there are four spiral splitters around Control
      IsSpiralSplitter:=true;
      for a:=Low(TAnchorKind) to High(TAnchorKind) do begin
        AnchorControl:=OldAnchorControls[a];
        if (AnchorControl=nil)
        or (not (AnchorControl is TLazDockSplitter)) then begin
          IsSpiralSplitter:=false;
        end;
      end;
      if IsSpiralSplitter then begin
        CombineSpiralSplitterPair(OldAnchorControls[akLeft] as TLazDockSplitter,
                                OldAnchorControls[akRight] as TLazDockSplitter);
        Done:=true;
      end;
    end;

    if not Done then begin
      // check if Control is the only child of a TLazDockPage
      if (ParentControl.ControlCount=1)
      and (ParentControl is TLazDockPage) then begin
        OldParentPage:=TLazDockPage(ParentControl);
        DoFinallyForParent;
        DeletePage(OldParentPage);
        Done:=true;
      end;
    end;

    if not Done then begin
      // check if Control is the only child of a TLazDockForm
      if (ParentControl.ControlCount=1)
      and (ParentControl is TLazDockForm) then begin
        OldParentForm:=TLazDockForm(ParentControl);
        DoFinallyForParent;
        DeleteDockForm(OldParentForm);
        Done:=true;
      end;
    end;

    if not Done then begin
      // otherwise: keep
    end;

  finally
    DoFinallyForParent;
  end;
end;

procedure TCustomAnchoredDockManager.InsertControl(Control: TControl;
  InsertAt: TAlign; DropCtl: TControl);
begin
  DockControl(Control, InsertAt, DropCtl);
end;

function TCustomAnchoredDockManager.EnlargeControl(Control: TControl;
  Side: TAnchorKind; Simulate: boolean): boolean;
{ If Simulate=true then it will only test if control can be enlarged.

  Case A:
  Shrink one neighbour control, enlarge Control. Two splitters are resized.

      |#|         |#         |#|         |#
      |#| Control |#         |#|         |#
    --+#+---------+#   --> --+#| Control |#
    ===============#       ===#|         |#
    --------------+#       --+#|         |#
        A         |#        A|#|         |#
    --------------+#       --+#+---------+#
    ==================     ===================


  Case B:
  Move one neighbour splitter, enlarge Control, resize one splitter,
  rotate the other splitter.

      |#|         |#|          |#|         |#|
      |#| Control |#|          |#|         |#|
    --+#+---------+#+--  --> --+#| Control |#+--
    ===================      ===#|         |#===
    --------+#+--------      --+#|         |#+--
            |#|   B            |#|         |#|B
            |#+--------        |#|         |#+--
        A   |#=========       A|#|         |#===
            |#+--------        |#|         |#+--
            |#|   C            |#|         |#|C
    --------+#+--------      --+#+---------+#+--
    ===================      ===================
}
const
  MinControlSize = 20;
var
  MainSplitter: TLazDockSplitter;
  Side2: TAnchorKind;
  Side3: TAnchorKind;
  Side2Anchor: TControl;
  Side3Anchor: TControl;
  Parent: TWinControl;
  i: Integer;
  Sibling: TControl;
  CurSplitter: TLazDockSplitter;
  Neighbour: TControl;
  ShrinkSide: TAnchorKind;
  ParentDisabledAlign: Boolean;
  EnlargeSplitter: TLazDockSplitter;
  RotateSplitter: TLazDockSplitter;

  procedure ParentDisableAlign;
  begin
    if ParentDisabledAlign then exit;
    ParentDisabledAlign:=true;
    Parent.DisableAlign;
  end;

begin
  Result:=false;
  if Control=nil then exit;
  DebugLn(['TCustomAnchoredDockManager.EnlargeControl Control=',DbgSName(Control),' Side=',AnchorNames[Side]]);
  if Side in [akLeft,akRight] then
    Side2:=akTop
  else
    Side2:=akLeft;
  Side3:=OppositeAnchor[Side2];
  if not GetLazDockSplitter(Control,Side,MainSplitter) then exit;
  if not GetLazDockSplitterOrParent(Control,Side2,Side2Anchor) then exit;
  if not GetLazDockSplitterOrParent(Control,Side3,Side3Anchor) then exit;
  Parent:=Control.Parent;
  if (Side2Anchor=Parent) and (Side3Anchor=Parent) then exit;

  // search controls anchored to the MainSplitter on the other side
  Neighbour:=nil;
  for i:=0 to Parent.ControlCount-1 do begin
    Sibling:=Parent.Controls[i];
    if (not GetLazDockSplitter(Sibling,OppositeAnchor[Side],CurSplitter))
    or (CurSplitter<>MainSplitter) then continue;
    DebugLn(['TCustomAnchoredDockManager.EnlargeControl neighbour Sibling=',DbgSName(Sibling)]);
    // Sibling is anchored to MainSplitter on the other side
    // check if it is at the same height as Control
    if Side in [akTop,akBottom] then begin
      if (Side2Anchor is TLazDockSplitter) then begin
        if (Sibling.Left+Sibling.Width<Side2Anchor.Left) then continue;
      end else begin
        // Side2Anchor is Parent
        if Sibling.Left+Sibling.Width<Control.Left then continue;
      end;
      if (Side3Anchor is TLazDockSplitter) then begin
        if (Sibling.Left>Side3Anchor.Left+Side3Anchor.Width) then continue;
      end else begin
        // Side3Anchor is Parent
        if Sibling.Left>Control.Left+Control.Width then continue;
      end;
    end else begin
      if (Side2Anchor is TLazDockSplitter) then begin
        if (Sibling.Top+Sibling.Height<Side2Anchor.Top) then continue;
      end else begin
        // Side2Anchor is Parent
        if Sibling.Top+Sibling.Height<Control.Top then continue;
      end;
      if (Side3Anchor is TLazDockSplitter) then begin
        if (Sibling.Top>Side3Anchor.Top+Side3Anchor.Height) then continue;
      end else begin
        // Side3Anchor is Parent
        if Sibling.Top>Control.Top+Control.Height then continue;
      end;
    end;

    if Neighbour=nil then
      Neighbour:=Sibling
    else if Sibling is TLazDockSplitter then begin
      if Neighbour is TLazDockSplitter then begin
        // two splitters means, there is at least one Neighbour which can not
        // be shrinked
        exit;
      end;
      Neighbour:=Sibling;
    end;
  end;

  if Neighbour=nil then exit; // no neighbour found
  DebugLn(['TCustomAnchoredDockManager.EnlargeControl Neighbour=',DbgSName(Neighbour)]);

  ParentDisabledAlign:=false;
  try
    if Neighbour is TLazDockSplitter then begin
      // one splitter as Neighbour
      RotateSplitter:=TLazDockSplitter(Neighbour);
      DebugLn(['TCustomAnchoredDockManager.EnlargeControl rotate splitter RotateSplitter=',DbgSName(RotateSplitter)]);
      // check that all anchored controls of this splitter can be shrinked
      for i:=0 to Parent.ControlCount-1 do begin
        Sibling:=Parent.Controls[i];
        if Sibling=RotateSplitter then continue;
        if GetLazDockSplitter(Sibling,Side2,CurSplitter)
        and (CurSplitter=RotateSplitter)
        and (not NeighbourCanBeShrinked(Control,Sibling,Side2))
        then begin
          // this Sibling is anchored with Side2 at RotateSplitter
          // but can not be shrinked
          exit;
        end;
        if GetLazDockSplitter(Sibling,Side3,CurSplitter)
        and (CurSplitter=RotateSplitter)
        and (not NeighbourCanBeShrinked(Control,Sibling,Side3))
        then begin
          // this Sibling is anchored with Side3 at RotateSplitter
          // but can not be shrinked
          exit;
        end;
      end;

      {   |#|         |#|          |#|         |#|
          |#| Control |#|          |#|         |#|
        --+#+---------+#+--  --> --+#| Control |#+--
        ===================      ===#|         |#===
        --------+#+--------      --+#|         |#+--
                |#|   B            |#|         |#|B
                |#+--------        |#|         |#+--
            A   |#=========       A|#|         |#===
                |#+--------        |#|         |#+--
                |#|   C            |#|         |#|C
        --------+#+--------      --+#+---------+#+--
        ===================      =================== }

      Result:=true;
      if not Simulate then begin
        ParentDisableAlign;
        GetLazDockSplitter(Control,OppositeAnchor[Side2],EnlargeSplitter);
        // enlarge Control and its two side splitters
        Control.AnchorSame(Side,RotateSplitter);
        Side2Anchor.AnchorSame(Side,RotateSplitter);
        Side3Anchor.AnchorSame(Side,RotateSplitter);
        // shrink controls anchored to RotateSplitter
        for i:=0 to Parent.ControlCount-1 do begin
          Sibling:=Parent.Controls[i];
          if Sibling=RotateSplitter then continue;
          if GetLazDockSplitter(Sibling,Side2,CurSplitter)
          and (CurSplitter=RotateSplitter) then begin
            // this Sibling is anchored with Side2 at RotateSplitter
            Sibling.AnchorToNeighbour(Side2,0,Side3Anchor);
          end;
          if GetLazDockSplitter(Sibling,Side3,CurSplitter)
          and (CurSplitter=RotateSplitter) then begin
            // this Sibling is anchored with Side3 at RotateSplitter
            Sibling.AnchorToNeighbour(Side3,0,Side2Anchor);
          end;
        end;
        // rotate RotateSplitter
        RotateSplitter.AnchorSide[Side].Control:=nil;
        RotateSplitter.AnchorSide[OppositeAnchor[Side]].Control:=nil;
        RotateSplitter.ResizeAnchor:=Side;
        RotateSplitter.AnchorToNeighbour(Side2,0,Side3Anchor);
        RotateSplitter.AnchorSame(Side3,MainSplitter);
        if Side in [akLeft,akRight] then
          RotateSplitter.Anchors:=RotateSplitter.Anchors-[akRight]+[akLeft]
        else
          RotateSplitter.Anchors:=RotateSplitter.Anchors-[akBottom]+[akTop];
        // shrink MainSplitter
        MainSplitter.AnchorToNeighbour(Side2,0,Side2Anchor);
        // reanchor controls from MainSplitter to RotateSplitter
        for i:=0 to Parent.ControlCount-1 do begin
          Sibling:=Parent.Controls[i];
          if GetLazDockSplitter(Sibling,Side,CurSplitter)
          and (CurSplitter=MainSplitter) then begin
            if Side in [akLeft,akRight] then begin
              if Sibling.Top>Control.Top then
                Sibling.AnchorSide[Side].Control:=RotateSplitter;
            end else begin
              if Sibling.Left>Control.Left then
                Sibling.AnchorSide[Side].Control:=RotateSplitter;
            end;
          end;
        end;
        UpdateTitlePosition(Control);
      end;

    end else begin
      // shrink a neighbour control
      DebugLn(['TCustomAnchoredDockManager.EnlargeControl Shrink one control: Neighbour=',DbgSName(Neighbour)]);
      // check if Neighbour already shares a side with Control
      if (Neighbour.AnchorSide[Side2].Control<>Side2Anchor)
      and (Neighbour.AnchorSide[Side3].Control<>Side3Anchor) then begin
        { Neighbour is too broad.
            |#|         |#|
            |#| Control |#|
          --+#+---------+#+--
          ===================
          -------------------
               Neighbour
          ------------------- }
        exit;
      end;

      // check if the Neighbour can be shrinked
      if NeighbourCanBeShrinked(Control,Neighbour,Side2) then begin
        ShrinkSide:=Side2;
      end else if NeighbourCanBeShrinked(Control,Neighbour,Side3) then begin
        ShrinkSide:=Side3;
      end else begin
        // Neighbour can not be shrinked
        exit;
      end;


      {              EnlargeSplitter
                           ^
                          |#|         |#         |#|         |#
                          |#| Control |#         |#|         |#
                        --+#+---------+#   --> --+#| Control |#
       MainSplitter <-- ===============#       ===#|         |#
                        --------------+#       --+#|         |#
                             Neighbour|#        N|#|         |#
                        --------------+#       --+#+---------+#
                        ==================     =================== }
      Result:=true;
      if not Simulate then begin
        ParentDisableAlign;
        GetLazDockSplitter(Control,OppositeAnchor[ShrinkSide],EnlargeSplitter);
        Neighbour.AnchorToNeighbour(ShrinkSide,0,EnlargeSplitter);
        MainSplitter.AnchorToNeighbour(ShrinkSide,0,EnlargeSplitter);
        EnlargeSplitter.AnchorSame(Side,Neighbour);
        Control.AnchorSame(Side,Neighbour);
        UpdateTitlePosition(Control);
        UpdateTitlePosition(Neighbour);
      end;
    end;
  finally
    if ParentDisabledAlign then
      Parent.EnableAlign;
  end;
end;

procedure TCustomAnchoredDockManager.LoadFromStream(Stream: TStream);
begin
  RaiseGDBException('TCustomAnchoredDockManager.LoadFromStream TODO');
end;

procedure TCustomAnchoredDockManager.PaintSite(DC: HDC);
begin
  // drawing of titles is done by TLazDockForm
end;

procedure TCustomAnchoredDockManager.PositionDockRect(Client, DropCtl: TControl;
  DropAlign: TAlign; var DockRect: TRect);
begin
  RaiseGDBException('TCustomAnchoredDockManager.PositionDockRect TODO');
end;

procedure TCustomAnchoredDockManager.RemoveControl(Control: TControl);
begin
  UndockControl(Control,false);
end;

procedure TCustomAnchoredDockManager.ResetBounds(Force: Boolean);
begin
  // TODO: 'TCustomAnchoredDockManager.ResetBounds'
end;

procedure TCustomAnchoredDockManager.SaveToStream(Stream: TStream);
begin
  RaiseGDBException('TCustomAnchoredDockManager.SaveToStream TODO');
end;

function TCustomAnchoredDockManager.AutoFreeByControl: Boolean;
begin
  Result:=false;
end;

procedure TCustomAnchoredDockManager.SetReplacingControl(Control: TControl);
begin
  RaiseGDBException('TCustomAnchoredDockManager.SetReplacingControl TODO');
end;

procedure TCustomAnchoredDockManager.MessageHandler(Sender: TControl; var Message: TLMessage);
begin

end;

function TCustomAnchoredDockManager.CreateForm: TLazDockForm;
begin
  Result:=TLazDockForm.Create(FOwnerComponent);
  Result.DockManager:=Self;
  Result.UseDockManager:=true;
end;

procedure TCustomAnchoredDockManager.ReplaceAnchoredControl(OldControl,
  NewControl: TControl);
var
  a: TAnchorKind;
  Side: TAnchorSide;
  i: Integer;
  Sibling: TControl;
  CurParent: TWinControl;
begin
  if OldControl.Parent<>nil then begin
    CurParent:=OldControl.Parent;
    CurParent.DisableAlign;
    try
      // put NewControl on the same Parent with the same bounds
      NewControl.Parent:=nil;
      NewControl.Align:=alNone;
      NewControl.BoundsRect:=OldControl.BoundsRect;
      NewControl.Parent:=CurParent;
      // copy all four AnchorSide
      for a:=Low(TAnchorKind) to High(TAnchorKind) do
        NewControl.AnchorSide[a].Assign(OldControl.AnchorSide[a]);
      // bend all Anchors from OldControl to NewControl
      for i:=0 to CurParent.ControlCount-1 do begin
        Sibling:=CurParent.Controls[i];
        if (Sibling=NewControl) or (Sibling=OldControl) then continue;
        for a:=Low(TAnchorKind) to High(TAnchorKind) do begin
          Side:=Sibling.AnchorSide[a];
          if Side.Control=OldControl then begin
            Side.Control:=NewControl;
          end;
        end;
      end;
      // remove OldControl from its Parent
      OldControl.Parent:=nil;
    finally
      CurParent.EnableAlign;
    end;
  end else begin
    NewControl.Parent:=nil;
    NewControl.Align:=alNone;
    NewControl.BoundsRect:=OldControl.BoundsRect;
  end;
end;

function TCustomAnchoredDockManager.GetSplitterWidth(Splitter: TControl): integer;
begin
  Result:=Splitter.Constraints.MinMaxWidth(SplitterSize);
end;

function TCustomAnchoredDockManager.GetSplitterHeight(Splitter: TControl): integer;
begin
  Result:=Splitter.Constraints.MinMaxHeight(SplitterSize);
end;

{ TLazDockPage }

function TLazDockPage.GetPageControl: TLazDockPages;
begin
  Result:=Parent as TLazDockPages;
end;

procedure TLazDockPage.InsertControl(AControl: TControl; Index: integer);
begin
  inherited InsertControl(AControl, Index);
  TLazDockForm.UpdateMainControlInParents(Self);
end;

{ TLazDockForm }

procedure TLazDockForm.SetMainControl(const AValue: TControl);
var
  NewValue: TControl;
begin
  if (AValue<>nil) and (not IsParentOf(AValue)) then
    raise Exception.Create('invalid main control');
  NewValue:=AValue;
  if NewValue=nil then
    NewValue:=FindMainControlCandidate;
  if FMainControl=NewValue then exit;
  FMainControl:=NewValue;
  if FMainControl<>nil then
    FMainControl.FreeNotification(Self);
  UpdateCaption;
end;

procedure TLazDockForm.PaintWindow(DC: HDC);
var
  i: Integer;
  Control: TControl;
  ACanvas: TCanvas;
  Pt: TPoint;
begin
  inherited PaintWindow(DC);
  ACanvas:=nil;
  try
    for i := 0 to ControlCount-1 do
    begin
      Control := Controls[i];
      if not ControlHasTitle(Control) then
        continue;

      if ACanvas = nil then
      begin
        ACanvas := TCanvas.Create;
        ACanvas.Handle := DC;
      end;
      GetCursorPos(Pt);
      Pt := ScreenToClient(Pt);
      TDockHeader.Draw(ACanvas, Control.Caption, FDockHeaderImages,
        GetTitleOrientation(Control), GetTitleRect(Control), Pt);
    end;
  finally
    ACanvas.Free;
  end;
end;

procedure TLazDockForm.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation=opRemove) then begin
    if AComponent=FMainControl then
      MainControl:=nil;
  end;
  inherited Notification(AComponent, Operation);
end;

procedure TLazDockForm.InsertControl(AControl: TControl; Index: integer);
begin
  inherited InsertControl(AControl, Index);
  UpdateMainControl;
end;

procedure TLazDockForm.UpdateMainControl;
var
  NewMainControl: TControl;
begin
  if (FMainControl=nil) or (not FMainControl.IsVisible) then begin
    NewMainControl:=FindMainControlCandidate;
    if NewMainControl<>nil then
      MainControl:=NewMainControl;
  end;
end;

function TLazDockForm.CloseQuery: boolean;
// query all top level forms, if form can close

  function QueryForms(ParentControl: TWinControl): boolean;
  var
    i: Integer;
    AControl: TControl;
  begin
    for i:=0 to ParentControl.ControlCount-1 do begin
      AControl:=ParentControl.Controls[i];
      if (AControl is TWinControl) then begin
        if (AControl is TCustomForm) then begin
          // a top level form: query and do not ask childs
          if (not TCustomForm(AControl).CloseQuery) then
            exit(false);
        end
        else if not QueryForms(TWinControl(AControl)) then
          // search childs for forms
          exit(false);
      end;
    end;
    Result:=true;
  end;

begin
  Result:=inherited CloseQuery;
  if Result then
    Result:=QueryForms(Self);
end;

procedure TLazDockForm.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  Part: TLazDockHeaderPart;
  Control: TControl;
begin
  inherited MouseUp(Button, Shift, X, Y);
  TrackMouse(X, Y);
  if Button = mbLeft then
  begin
    Control := FindHeader(X, Y, Part);
    if (Control <> nil) then
      TDockHeader.PerformMouseUp(Control, Part);
  end;
end;

procedure TLazDockForm.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  Part: TLazDockHeaderPart;
  Control: TControl;
begin
  inherited MouseDown(Button, Shift, X, Y);
  TrackMouse(X, Y);
  if Button = mbLeft then
  begin
    Control := FindHeader(X, Y, Part);
    if (Control <> nil) then
      TDockHeader.PerformMouseDown(Control, Part);
  end;
end;

procedure TLazDockForm.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  TrackMouse(X, Y);
end;

procedure TLazDockForm.MouseLeave;
begin
  inherited MouseLeave;
  TrackMouse(-1, -1);
end;

procedure TLazDockForm.TrackMouse(X, Y: Integer);
var
  Control: TControl;
  Part: TLazDockHeaderPart;
  ARect: TRect;
  NewMouseState: TDockHeaderMouseState;
begin
  Control := FindHeader(X, Y, Part);
  FillChar(NewMouseState,SizeOf(NewMouseState),0);
  if (Control <> nil) then
  begin
    ARect := GetTitleRect(Control);
    ARect := TDockHeader.GetRectOfPart(ARect, GetTitleOrientation(Control), Part);
    NewMouseState.Rect := ARect;
    NewMouseState.IsMouseDown := (GetKeyState(VK_LBUTTON) and $80) <> 0;
  end;
  if not CompareMem(@FMouseState, @NewMouseState, SizeOf(NewMouseState)) then
  begin
    if not CompareRect(@FMouseState.Rect, @NewMouseState.Rect) then
      InvalidateRect(Handle, @FMouseState.Rect, False);
    FMouseState := NewMouseState;
    InvalidateRect(Handle, @NewMouseState.Rect, False);
  end;
end;

constructor TLazDockForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FillChar(FMouseState, SizeOf(FMouseState), 0);
  TDockHeader.CreateDockHeaderImages(FDockHeaderImages);
end;

destructor TLazDockForm.Destroy;
begin
  TDockHeader.DestroyDockHeaderImages(FDockHeaderImages);
  inherited Destroy;
end;

procedure TLazDockForm.UpdateCaption;
begin
  if FMainControl<>nil then
    Caption:=FMainControl.Caption
  else
    Caption:='';
end;

class procedure TLazDockForm.UpdateMainControlInParents(StartControl: TControl
  );
var
  Form: TLazDockForm;
begin
  while StartControl<>nil do begin
    if (StartControl is TLazDockForm) then
    begin
      Form:=TLazDockForm(StartControl);
      if (Form.MainControl=nil)
      or (not Form.MainControl.IsVisible) then
        Form.UpdateMainControl;
    end;
    StartControl:=StartControl.Parent;
  end;
end;

function TLazDockForm.FindMainControlCandidate: TControl;
var
  BestLevel: integer;

  procedure FindCandidate(ParentControl: TWinControl; Level: integer);
  var
    i: Integer;
    AControl: TControl;
    ResultIsForm, ControlIsForm: boolean;
  begin
    for i:=0 to ParentControl.ControlCount-1 do begin
      AControl:=ParentControl.Controls[i];
      //DebugLn(['FindCandidate ParentControl=',DbgSName(ParentControl),' AControl=',DbgSName(AControl)]);
      if (not AControl.IsControlVisible) then continue;
      if ((AControl.Name<>'') or (AControl.Caption<>''))
      and (not (AControl is TLazDockForm))
      and (not (AControl is TLazDockSplitter))
      and (not (AControl is TLazDockPages))
      and (not (AControl is TLazDockPage))
      then begin
        // this is a candidate
        // prefer forms and top level controls
        if (Application<>nil) and (Application.MainForm=AControl) then begin
          // the MainForm is the best control
          Result:=Application.MainForm;
          BestLevel:=-1;
          exit;
        end;
        ResultIsForm:=Result is TCustomForm;
        ControlIsForm:=AControl is TCustomForm;
        if (Result=nil)
        or ((not ResultIsForm) and ControlIsForm)
        or ((ResultIsForm=ControlIsForm) and (Level<BestLevel))
        then begin
          BestLevel:=Level;
          Result:=AControl;
        end;
      end;
      if AControl is TWinControl then
        FindCandidate(TWinControl(AControl),Level+1);
    end;
  end;

begin
  Result:=nil;
  BestLevel:=High(Integer);
  FindCandidate(Self,0);
end;

function TLazDockForm.FindHeader(x, y: integer; out Part: TLazDockHeaderPart): TControl;
var
  i: Integer;
  Control: TControl;
  TitleRect: TRect;
  p: TPoint;
  Orientation: TDockOrientation;
begin
  for i := 0 to ControlCount-1 do
  begin
    Control := Controls[i];
    if not ControlHasTitle(Control) then
      Continue;
    TitleRect := GetTitleRect(Control);
    p := Point(X,Y);
    if not PtInRect(TitleRect, p) then
      Continue;
    // on header
    // => check sub parts
    Result := Control;
    Orientation := GetTitleOrientation(Control);
    Part := TDockHeader.FindPart(TitleRect, p, Orientation);
    Exit;
  end;
  Result := nil;
end;

function TLazDockForm.IsDockedControl(Control: TControl): boolean;
// checks if control is a child, not a TLazDockSplitter and properly anchor docked
var
  a: TAnchorKind;
  AnchorControl: TControl;
begin
  Result:=false;
  if (Control.Anchors<>[akLeft,akRight,akBottom,akTop])
  or (Control.Parent<>Self) then
    exit;
  for a:=low(TAnchorKind) to high(TAnchorKind) do begin
    AnchorControl:=Control.AnchorSide[a].Control;
    if (AnchorControl=nil) then exit;
    if (AnchorControl<>Self) and (not (AnchorControl is TLazDockSplitter)) then
      exit;
  end;
  Result:=true;
end;

function TLazDockForm.ControlHasTitle(Control: TControl): boolean;
begin
  Result:=Control.Visible
           and IsDockedControl(Control)
           and ((Control.BorderSpacing.Left>0) or (Control.BorderSpacing.Top>0));
end;

function TLazDockForm.GetTitleRect(Control: TControl): TRect;
begin
  Result := Control.BoundsRect;
  if Control.BorderSpacing.Top > 0 then
  begin
    Result.Top := Control.Top - Control.BorderSpacing.Top;
    Result.Bottom := Control.Top;
  end else
  begin
    Result.Left := Control.Left - Control.BorderSpacing.Left;
    Result.Right := Control.Left;
  end;
end;

function TLazDockForm.GetTitleOrientation(Control: TControl): TDockOrientation;
begin
  if Control.BorderSpacing.Top > 0 then
    Result := doHorizontal
  else
  if Control.BorderSpacing.Left > 0 then
    Result := doVertical
  else
    Result := doNoOrient;
end;

{ TLazDockSplitter }

constructor TLazDockSplitter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  MinSize := 1;
end;

initialization
  DefaultDockTreeClass := TLazDockTree;
{$I lcl_dock_images.lrs}

end.
