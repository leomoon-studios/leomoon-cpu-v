SET sign=%CD%\..\..\..\#code-sign\signtool\signtool.exe
SET pfx=%CD%\..\..\..\#code-sign\signtool\cert.pfx
SET /p pass=<%cd%\..\..\..\#code-sign\signtool\cert.txt
SET url=https://leomoon.com

SET AppName=LeoMoon CPU-V
SET app=%CD%\..\build\%AppName%.exe
"%sign%" sign /fd SHA256 /d "%AppName%" /du "%url%" /f "%pfx%" /p %pass% /t "http://timestamp.comodoca.com/authenticode" "%app%"