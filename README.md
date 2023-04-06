[![N|Solid](https://i.imgur.com/QV57NV9.png)](https://www.lazarus-ide.org/)
# LazC Wizard

- Create, Edit, Complie/Build "C" projects using the "Lazarus IDE" and "Tiny C Compiler"!

[![Version](https://img.shields.io/badge/version-0.2-yellow)](https://github.com/jmpessoa/LazCWizard/archive/refs/heads/main.zip)![Date](https://img.shields.io/badge/date-05%2F04%2F2023-green)
## Getting Started
### 1. Install Tiny C Compiler [TCC]
- 1.1 TCC Windows Install	
- - [TCC Win32](http://download.savannah.gnu.org/releases/tinycc/tcc-0.9.27-win32-bin.zip)
- - [TCC Win64](http://download.savannah.gnu.org/releases/tinycc/tcc-0.9.27-win64-bin.zip)
- - download and unzip the "tcc-0.9.27-win?-bin.zip" 
- 
- 1.2 TCC Linux Install 
- - [Linux](http://download.savannah.gnu.org/releases/tinycc/tcc-0.9.27.tar.bz2)
- - download and unpack "tcc-0.9.27.tar.bz2"
- - - $cd "to unpacked tcc directory" 
- - - $chmod +x configure 
- - - $./configure
- - - $make clean all 
- - - $sudo make install
### 2. Install LazC Wizard
- 2.1.	[Download zip or Clone](https://github.com/jmpessoa/lazcwizard)
- 2.2 Intall [unzip it!]:
- - 2.2.1 Lazarus IDE menu "Package" --> "Open Package File (.lpk)"	
- - -  Open	"LazCWizard.lpk"	(folder "LazCWizard")
- - - Compile
- - -  Use --> Install

- - 2.2.2 Lazarus IDE menu "Package" --> "Open Package File (.lpk)"	
- - - Open "lazcwcompletion.lpk"	[folder "LazCWizardUtils"]
- - - Compile
- - - Use --> "Install"
### 3. Using LazC Wizard
-  3.1 Creating a executable New Project
- - 3.1.1 Lazarus IDE: "Project" --> "New Project"--> ["LazCW Project"](]https://od.lk/d/Ml8xNjU3MjM4MjFf/lazCwizard_windows.png)  
- - - "Path to TinyCC executable"
- - - - ex."C:\tcc-0.9.27\tcc"	[win]
- - - - ex."/usr/local/bin"	[linux]
- - - "Path to Projects Folder [workspace]"
- - - - ex. "C:\tcc-0.9.27\Projects"
- - - "New Project Name"
- - - - ex. "LazCProject1"     -->  produce "lazcproject1.c"     
- - - "[.] Launch Terminal"  			
- - - "(.) Executable"
			
- - 3.1.2 Lazarus IDE: "Run" --> "[LazCW] Compile/Build "C"
- - - Success! From terminal execute your "lazcproject1" !!

- 3.2 Creating a Shared Library (.dll/.so)
- - 3.2.1 Lazarus IDE: "Project" --> "New Project" --> "LazCW Project" 
- - - "New Project Name"
- - - - ex."LazCShared1" --> produce "lazcshared1.c"     

- - - "[.] Launch Terminal"  
- - - "(.) Shared Lib"
						
- - 3.2.2 Lazarus IDE "Run" --> "[LazCW] Compile/Build/ "C"
- - - Go to your project folder "LazCShared1"
- - - Windows:
- - - - lazcshared1.dll
- - - - lazcshared1.pp	(auto generated pascal unit interface header file!) 
- - - - - warning: may require some modification/fixes 
- - - linux: 
- - - - liblazcshared1.so
- - - - lazcshared1.pp	 (auto generated pascal unit interface header file!)  
- - - - - warning: may require some modification/fixes

- 3.3 Using the "lazcshared1" Library in a Pascal program
- - 3.3.1 Lazarus IDE: "Project" --> "New Project" --> "Program"
- - - ex. "Project1" and "save all" to the same .dll/.so folder 
- - - Open/Edit "Project1.lpr" add these [code] lines:
- - - - uses
- - - - - ..., lazcshared1;  // <--- library  header unit...
- - - - begin
- - - - - writeln('sum = ', addTwo(5,8) );  //addTwo from "lazcshared1.pp"
- - - - end.

- - 3.3.2 Lazarus IDE: "Run" --> "build" 
- - - Go to your project folder "LazCShared1" and execute:
- - - - Windows
- - - - - Project1.exe
- - - - Linux
- - - - - $export LD_LIBRARY_PATH=./	[linux]
- - - - - $.\project1	
- - - - - - [or]
- - - - - $.\run.sh project1	

- 3.4 [HOW TO] Building the csum.dll/libcsum.so a library from a [tested] "C" code and using it into a Pascal program
- - 3.4.1 Editing and testing the "csum.c" code
- - - - Lazarus IDE "Project" --> "New Project" --> "LazCW Project"
- - - - "New Project Name"
- - - - - ex.	"LazCProject2"	-->  "lazcproject2.c"
- - - - [.] Launch Terminal  

- - 3.4.2 Lazarus IDE "File" --> "New" --> "[LazCW] Create a new .h file" 
- - - - [Save as] ex. "csum.h" and add this "interface" code line:
- - - - - - int addTwoInt(int a, int b);
- - 3.4.3 Lazarus IDE "File" --> "New" --> "[LazCW] Create a new .c file" 
- - - - [Save as] ex. "csum.c" and add this "implementation" code lines:
- - - - - int addTwoInt(int a, int b) {
- - - - - - return (a+b);
- - - - - }
		
- - 3.4.4 Open "lazcproject2.c"  and add these [code] lines:
- - - - - #include "csum.h"
- - - - - main() {
- - - - - - printf("\n Hello C World! \n"); 
- - - - - - printf("\n sum = %d \n", addTwoInt(5,8) ); /*hint: tested tcc comments... */
- - - - - }
- - 3.4.5 [Test it !] Lazarus IDE "Run" --> "[LazCW] Compile/Build C" 
- - - - Success! From terminal execute your "lazcproject2" !!
- - - - - lazcproject2.exe  [win]
- - - - - $.\lazcproject2   [linux]

- - 3.4.6 Building the "csum" Library using the tested csum.c/csum.h code
- - - - Lazarus IDE Editor [right click] "lazcproject2.c" and "Close Page"
- - - - Lazarus IDE "File" --> "Project" --> "Project Inspector..."
- - - - Select "lazcproject2.c" and remove/delete it!
- - - - Lazarus IDE "File" --> "Project" --> "Project Options..."
- - - - - Select "[LazCW] C Projec Options"
- - - - - - Launch Terminal = yes
- - - - - - Main Unit = csum.c
- - - - - - Build Mode = dll    [win] or
- - - - - - Build Mode = so     [linux]
- - - - Open/Edit "csum.h" this code line:
- - - - - extern int addTwoInt(int a, int b);
- - - - Lazarus IDE "Run" --> "[LazCW] Compile/Build C"  

- - - - Go to your project folder "LazCProject2"
- - - - - Windows
- - - - - - csum.dll
- - - - - - csum.pp     (auto generated pascal unit interface header file!) 
- - - - - - - warning: may require some modification/fixes 
- - - - - Linux
- - - - - - libcsum.so
- - - - - - csum.pp     (auto generated pascal unit] interface header file!)  
- - - - - - - warning: may require some modification/fixes 

- 3.5 Using the "csum" Library in a Pascal program	
- - 3.5.1 Lazarus IDE "Project" --> "New Project" --> "Program"
- - - ex. "Project2" and "Save All" to the same [dll/so] folder. 
- - - Open "Project2.lpr" and add these code lines:
- - - - uses
- - - - - ..., csum;  // <--- library  header unit...
- - - - begin
- - - - - writeln('sum = ', addTwoInt(5,8) );  //  addTwoInt from "csum.pp"
- - - - end.

- - 3.5.2 Lazarus IDE "Run" --> "build" 
- - - Go to your project folder "LazCProject2" and execute it!
- - - - Windows
- - - - - project2.exe		
- - - - Linux
- - - - - $export LD_LIBRARY_PATH=./
- - - - - $.\project2
- - - - - or:
- - - - - $.\run.sh project2	

Enjoy yourself!
Thanks to All!