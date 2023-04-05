unit LazCWUtil;

//Legacy: modified "LazCUtil" from  "...\components\compilers\c"
//added "C" vocabulary ...

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLProc, SrcEditorIntf, LCLType;

type

  { TCWSrcEditCompletion }

  TCWSrcEditCompletion = class(TSourceEditorCompletionPlugin)
  private
    FEditor: TSourceEditorInterface;
    FFilteredList: TStrings;
    FLastPrefix: string;
    FList: TStrings;
    procedure SetLastPrefix(const AValue: string);
    procedure RebuildFilteredList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Cancel; override;
    function Collect(List: TStrings): boolean; override;
    procedure Complete(var Value: string; SourceValue: string; var SourceStart,
      SourceEnd: TPoint; KeyChar: TUTF8Char; Shift: TShiftState); override;
    procedure CompletePrefix(var Prefix: string); override;
    procedure IndexChanged(Position: integer); override;
    procedure Init(SrcEdit: TSourceEditorInterface; JumpToError: boolean;
      var Handled, Abort: boolean; var Prefix: string; var BoxX, BoxY: integer
      ); override;
    procedure PrefixChanged(const NewPrefix: string; var NewIndex: integer;
      var s: TStrings); override;
    property Editor: TSourceEditorInterface read FEditor;
    property List: TStrings read FList;
    property FilteredList: TStrings read FFilteredList;
    property LastPrefix: string read FLastPrefix write SetLastPrefix;
  end;

var
  CWSrcEditCompletion: TCWSrcEditCompletion = nil;

procedure Register;

implementation

procedure Register;
begin
  CWSrcEditCompletion:=TCWSrcEditCompletion.Create(nil);
  SourceEditorManagerIntf.RegisterCompletionPlugin(CWSrcEditCompletion);
end;

{ TCWSrcEditCompletion }

procedure TCWSrcEditCompletion.SetLastPrefix(const AValue: string);
begin
  if FLastPrefix=AValue then exit;
  FLastPrefix:=AValue;
  RebuildFilteredList;
end;

procedure TCWSrcEditCompletion.RebuildFilteredList;
var
  i: Integer;
  s: string;
  len: Integer;
  p: PChar;
begin
  FFilteredList.Clear;
  len:=length(LastPrefix);
  p:=PChar(LastPrefix);
  for i:=0 to FList.Count-1 do begin
    s:=FList[i];
    if length(s)<len then continue;
    if (len=0) or CompareMem(PChar(s),p,len) then
      FFilteredList.Add(s);
  end;
end;

constructor TCWSrcEditCompletion.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FList:=TStringList.Create;
  FFilteredList:=TStringList.Create;
end;

destructor TCWSrcEditCompletion.Destroy;
begin
  if Self=CWSrcEditCompletion then CWSrcEditCompletion:=nil;
  FreeAndNil(FFilteredList);
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TCWSrcEditCompletion.Cancel;
begin
  FEditor:=nil;
  FList.Clear;
  FFilteredList.Clear;
end;

function TCWSrcEditCompletion.Collect(List: TStrings): boolean;
begin
  List.Assign(FFilteredList);
  Result:=true;
end;

procedure TCWSrcEditCompletion.Complete(var Value: string; SourceValue: string;
  var SourceStart, SourceEnd: TPoint; KeyChar: TUTF8Char; Shift: TShiftState);
begin
  //
end;

procedure TCWSrcEditCompletion.CompletePrefix(var Prefix: string);
begin
  LastPrefix:=Prefix;
end;

procedure TCWSrcEditCompletion.IndexChanged(Position: integer);
begin
  //
end;

procedure TCWSrcEditCompletion.Init(SrcEdit: TSourceEditorInterface;
  JumpToError: boolean; var Handled, Abort: boolean; var Prefix: string;
  var BoxX, BoxY: integer);
var
  Ext: String;
begin
  Ext:=ExtractFileExt(SrcEdit.FileName);
  if not ((Ext='.c') or (Ext='.C') or (Ext='.cc') or (Ext='.CC')
    or (Ext='.cpp') or (Ext='.CPP'))
  then begin
    // not responsible
    exit;
  end;
  //provide completion for c source files
  Handled:=true;
  FList.Clear;
  FList.Add('int');
  FList.Add('int8');
  FList.Add('int16');
  FList.Add('int32');
  FList.Add('char');
  FList.Add('long');
  FList.Add('bool');
  FList.Add('void');
  FList.Add('float');
  FList.Add('double');
  FList.Add('signed');
  FList.Add('struct');
  FList.Add('typedef');
  FList.Add('unsigned');
  FList.Add('public');
  FList.Add('private');
  FList.Add('define'); //#define LENGTH 10

  //extended C vocabulary  ::  by jmpessoa:
  FList.Add('short');
  FList.Add('sizeof()');
  FList.Add('return');

  FList.Add('switch(option) {'+LineEnding+'    case 1: printf("1"\n); break;'+LineEnding+'  }');

  FList.Add('if() {'+LineEnding+'  }');
  FList.Add('else {'+LineEnding+'  }');

  FList.Add('do {'+LineEnding+'  }while(expression);');

  FList.Add('while() {'+LineEnding+'  }');
  FList.Add('for(int i=0; i < 5; i++) {'+LineEnding+'    printf("i = %d \n", i)'+LineEnding+'  }');

  FList.Add('printf("\n");');
  FList.Add('scanf(&data);');


  FList.Add('typedef struct Point{'+LineEnding+'  int x; '+LineEnding+'  int y;'+LineEnding+'}Point;');

  FList.Add('void task(){'+LineEnding+'}');
  FList.Add('float addFloat(float a, float b){'+LineEnding+'  return a+b;'+LineEnding+'}');
  FList.Add('int addInt(int a, int b){'+LineEnding+'  return a+b;'+LineEnding+'}');

  FList.Add('int vector1[4];');
  FList.Add('int vector2[] = {10, 11, 12, 13, 14};');
  FList.Add('int matrix1[2][3] = {{1, 3, 0}, {-1, 5, 9}}');
  FList.Add('int getMaxVector(int vector[], int count){ }');
  FList.Add('int getMaxMatrix(int matrix[], int lin, int col){ }');


  FList.Add('char str1[] = "abcd";');
  FList.Add('char str2[] = {''a'', ''b'', ''c'', ''d'', ''\0''}');
  FList.Add('char str3[80];');
  //warning: gets reads to a newline. scanf only reads up to whitespace!
  FList.Add('gets(str3);');     //warning: use fgets(str, len-1, stdin)!!!!
  FList.Add('puts(str);');
  FList.Add('putchar(ch);');  //or: putc(ch, stdout)
  FList.Add('getchar();');   // or: int c = getc(stdin)

  FList.Add('strcpy(fromStr1, toStr2);');
  FList.Add('strlen(str);');
  FList.Add('strcmp(str1, str2);'); //0=egual
  FList.Add('strcat(str1, str2);');  // concat

  FList.Add('FILE *archive;');
  //archive = fopen("C:\\data.txt","w"); //or "r" read  or "a" append (If the file does not exist, it will be created)
  FList.Add('fopen("C:\\data.txt","w");');
  FList.Add('fclose(archive);');

  FList.Add('fprintf(archive,"%d", num);');
  FList.Add('fscanf(archive,"%d", &num);');

  FList.Add('fgets(strBuffer, len-1, archive);');
  FList.Add('fgets(str, len-1, stdin);'); //replace gets!
  FList.Add('fputs(str, archive');

  FList.Add(
          'FILE *archive1 = fopen("data.txt","w");'+LineEnding+
          '  if(archive1 == NULL){printf("Can''t Open File..."); exit(-1);}'+LineEnding+
          '  char str1[] = "Hello C World!";'+LineEnding+
          '  int count = strlen(str1);'+LineEnding+
          '  for(int i=0; i < count; i++) {'+LineEnding+
          '     putc(str1[i], archive1);'+LineEnding+
          '  }'+LineEnding+
          '  fclose(archive1);');

  FList.Add(
          'FILE *archive2 = fopen("data.txt","r");'+LineEnding+
          '  if(archive2 == NULL){printf("Can''t Open File..."); exit(-1);}'+LineEnding+
          '  int ch;'+LineEnding+
          '  while (!feof(archive2)) {'+LineEnding+
          '    ch = getc(archive2);'+LineEnding+
          '    printf("%c", ch);'+LineEnding+
          '  }'+LineEnding+
          '  fclose(archive2);');


  FList.Add(
          'FILE *archive3 = fopen("data.txt","a+");'+LineEnding+
          '  if(archive3 == NULL){printf("Can''t Open File..."); exit(-1);}'+LineEnding+
          '  char str3[] = "new text appended...";'+LineEnding+
          '  fprintf(archive3, "%s", str3);'+LineEnding+
          '  if(ferror(archive3)) {'+LineEnding+
          '    perror("Error wrinting..");'+LineEnding+  //print error
          '    fclose(archive3);'+LineEnding+
          '    exit(-1);'+LineEnding+
          '  }'+LineEnding+
          '  fclose(archive3);');

  FList.Add(
          'FILE *archive4 = fopen("data.txt","w+");'+LineEnding+
          '  if(archive4 == NULL){printf("Can''t Open File..."); exit(-1);}'+LineEnding+
          '  char str4[] = "add this text to archive...";'+LineEnding+
          '  fprintf(archive4, "%s", str4);'+LineEnding+
          '  fclose(archive4);');

  //warning: fgets reads to a newline. fscanf [and scanf!] only reads up to whitespace!
  FList.Add(
          'FILE *archive5 = fopen("data.txt","r");'+LineEnding+
          '  if(archive5 == NULL){printf("Can''t Open File..."); exit(-1);}'+LineEnding+
          '  char str5[80];'+LineEnding+
          '  while( fgets(str5, 79, archive5) != NULL ) {'+LineEnding+   // 79 + '\0' = 80!
          '    printf("%s", str5);'+LineEnding+
          '  }'+LineEnding+
          '  fclose(archive5);');

  FList.Add('FILE *archive6 = fopen("data.txt","r");'+LineEnding+
            '  int ch1; '+LineEnding+
            '  do {'+LineEnding+
            '    ch1 = getc(archive6);'+LineEnding+
            '    putchar(ch1);'+LineEnding+
            '  }while(ch1 != EOF);');

  FLastPrefix:=Prefix;
  RebuildFilteredList;
end;

procedure TCWSrcEditCompletion.PrefixChanged(const NewPrefix: string;
  var NewIndex: integer; var s: TStrings);
begin
  NewIndex:=0;
  LastPrefix:=NewPrefix;
  s.Assign(FFilteredList);
end;

finalization
  FreeAndNil(CWSrcEditCompletion);

end.
