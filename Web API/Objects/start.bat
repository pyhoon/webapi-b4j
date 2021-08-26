REM ================================================================
REM Run this batch file in Windows Command Prompt as Administrator
REM ================================================================

@ECHO OFF
TITLE Web API server is starting...

REM CD C:\Java\jdk-11.0.1\bin
REM java --module-path C:\Java\jdk-11.0.1\javafx\lib --add-modules ALL-MODULE-PATH -jar "C:\Development\B4J\WebAPI\Objects\webapi.jar"

C:
CD C:\Program Files\Java\jdk1.8.0_181\bin
java -jar "C:\Development\B4J\WebAPI\Objects\webapi.jar"
::PAUSE