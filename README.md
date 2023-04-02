# LazCWizard
"Create, Edit, Build and Run "C" projects using the Lazarus IDE!"
	LazC Wizard	[by jmpessoa]
		
		"Create, Edit, Build and Run "C" projects using the Lazarus IDE!"

		"A helper/assistant to "LazC" package  [\lazarus\components\compilers\c]

		ref.	https://github.com/jmpessoa/lazcwizard


Version 0.1 [TinyCC Edition]  - 10 January - 2019


1. Install Tiny C Compiler [tcc]

	1.1.1	win32:	http://download.savannah.gnu.org/releases/tinycc/tcc-0.9.27-win32-bin.zip
		win64:	http://download.savannah.gnu.org/releases/tinycc/tcc-0.9.27-win64-bin.zip

		-download and unzip the "tcc-0.9.27-win?-bin.zip" file 

		
	1.1.2	Linux: http://download.savannah.gnu.org/releases/tinycc/tcc-0.9.27.tar.bz2
		
		-download and unpack "tcc-0.9.27.tar.bz2" file

		$cd "to unpacked tcc directory" 
		$chmod +x configure 
		$./configure
		$make clean all 
		$sudo make install
				
2. Install LazC Wizard

	2.1.	download/clone:	https://github.com/jmpessoa/lazcwizard
	2.2.	[unzip]
	2.3.	Intall
			Lazarus IDE menu "Package" --> "Open Package File (.lpk)"	
			select/open	"LazCWizard.lpk"
		
			"Compile"
			"Use" --> "Install"


3. Using LazC Wizard
	
3.1 Create and Build/Run New [template/executable] Project

	.Lazarus IDE "Project" --> "New Project" --> "LazCW Project" 

			ref. https://od.lk/d/Ml8xNjU3MjM4MjFf/lazCwizard_windows.png

		"Path to TinyCC executable"
			ex.	"C:\tcc-0.9.27\tcc"  		[win]
			ex.	"/usr/local/bin"		[linux]

		"Path to Projects Folder [workspace]"
			ex.	"C:\tcc-0.9.27\Projects"

		"New Project Name"
			ex.	"LazCProject1"     -->  "lazcproject1.c"     

		[ ] Launch Terminal  
			[x] if you need interactive data input...

		(.) Executable
			
	.Lazarus IDE "Run" --> "[LazCW] Build/Run C"

3.2 Create and Build/Run New [template/shared lib] Project

	.Lazarus IDE "Project" --> "New Project" --> "LazCW Project" 

		"New Project Name"
			ex.	"LazCShared1" --> "lazcshared1.c"     

		[x] Launch Terminal  

		(.) Shared Lib
						
	.Lazarus IDE "Run" --> "[LazCW] Build/Run C"

		.Go to your project folder "LazCShared1"
			Hint: "paste" path-to-project from clipboard to cmd/terminal...


		>dir		[win]

			lazcshared1.dll
			lazcshared1.pp	 <--- [auto generated] pascal [unit] interface header file! 
                                               WARNING: may require some modification/fixes 

		$ls		[linux]

			liblazcshared1.so
			lazcshared1.pp	 <--- [auto generated] pascal [unit] interface header file!  
                                               WARNING: may require some modification/fixes  



3.2.1 Using the "lazcshared1" Library in a Pascal program	

	.Lazarus IDE "Project" --> "New Project" --> "Program"
		.[Shift Ctrl + s][Save All] ex. "Project1" to the same [dll/so] folder. Ex. "LazCShared1" 
	
	.Open/Edit "Project1.lpr" add these [code] lines:

		uses
			..., lazcshared1;  // <--- library  header unit...
	
		begin
		   writeln('sum = ', addTwo(5,8) );  //addTwo from "lazcshared1.pp"
		end;


	.Lazarus IDE "Run" --> "build" 

		.Go to your project folder "LazCShared1"

		>Project1.exe			[win]


		$export LD_LIBRARY_PATH=./	[linux]
		$.\project1	
		
		[or]
		
		$.\run.sh project1	


3.3 [How to] Building a library called "csum.dll/libcsum.so" from a [tested] "C" code and use it in a Pascal program

3.3.1 Edit and test the "csum" code

	Make a test program:

	.Lazarus IDE "Project" --> "New Project" --> "LazCW Project"

		"New Project Name"
			ex.	"LazCProject2"	-->  "lazcproject2.c"

		[x] Launch Terminal  

	.Lazarus IDE "File" --> "New" --> "[LazCW] Create a new .h file" 
		.[Ctrl + s][Save as] ex. "csum.h"

		.Add [header] code line:

			int addTwoInt(int a, int b);

	.Lazarus IDE "File" --> "New" --> "[LazCW] Create a new .c file" 
		.[Ctrl + s][Save as] ex. "csum.c"

		.Add [body] code lines:

			int addTwoInt(int a, int b) {
 				return (a+b);
			}
		
	.Open/Edit "lazcproject2.c"  add these [code] lines:
 
			#include "csum.h"
			
			main() {
				printf("\n Hello C world! \n"); 
				printf("\n sum = %d \n", addTwoInt(5,8) ); /* test */
			}

			
			warning! tinyCC comments: 
					/* test */   


	.[Test it !] Lazarus IDE "Run" --> "[LazCW] Build/Run C"  

		Hint: "paste" path-to-project from clipboard to cmd/terminal...

		>lazcproject2.exe		[win]

		$.\lazcproject2			[linux]


3.3.2 Building the "csum" Library

	.Lazarus IDE "File" --> "Project" --> "Project Inspector..."

		[select] "lazcproject2.c" --> "Remove"

	.Lazarus IDE Editor [right click] "lazcproject2.c" --> "Close Page"

	.Lazarus IDE "File" --> "Project" --> "Project Options..."

		.[LazCW] C Projec Options

			->Launch Terminal = yes

			->Main Unit = csum.c

			->Build Mode = dll	[win]
			->Build Mode = so      	[linux]

	.Open/Edit "csum.h" code line:

		extern int addTwoInt(int a, int b);

	.Lazarus IDE "Run" --> "[LazCW] Build/Run C"  

		.Go to your project folder "LazCProject2"
			Hint: "paste" path-to-project from clipboard to cmd/terminal...

		>dir		[win]

			csum.dll
			csum.pp		<--- [auto generated] pascal [unit] interface header file! 
                                              WARNING: may require some modification/fixes 

		$ls		[linux]

			libcsum.so
			csum.pp		<--- [auto generated] pascal [unit] interface header file!  
                                             WARNING: may require some modification/fixes  


3.3.3 Using the "csum" Library in a Pascal program	

	.Lazarus IDE "Project" --> "New Project" --> "Program"
		.[Shift Ctrl + s][Save All] ex. "Project2" to the same [dll/so] folder. Ex. "LazCProject2" 
	
	.Open/Edit "Project2.lpr" add these [code] lines:

		uses
			..., csum;  // <--- library  header unit...
	
		begin
			writeln('sum = ', addTwoInt(5,8) );  //  addTwoInt from "csum.pp"
		end;


	.Lazarus IDE "Run" --> "build" 

		.Go to your project folder "LazCProject2"

		>project2.exe			[win]


		$export LD_LIBRARY_PATH=./	[linux]
		$.\project2	
		
			[or]

		$.\run.sh project2		[linux]	
